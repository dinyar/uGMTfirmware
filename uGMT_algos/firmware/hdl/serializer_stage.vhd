library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.mp7_data_types.all;

use work.GMTTypes.all;
use work.ugmt_constants.all;

entity serializer_stage is
  port (clk240               : in  std_logic;
        clk40                : in  std_logic;
        sMuons               : in  TGMTMu_vector (NUM_OUT_CHANS*NUM_MUONS_OUT-1 downto 0);
        sIso                 : in  TIsoBits_vector(NUM_OUT_CHANS*NUM_MUONS_OUT-1 downto 0);
        iIntermediateMuonsB  : in  TGMTMu_vector(7 downto 0);
        iIntermediateMuonsO  : in  TGMTMu_vector(7 downto 0);
        iIntermediateMuonsF  : in  TGMTMu_vector(7 downto 0);
        iSortRanksB          : in  TSortRank10_vector(7 downto 0);
        iSortRanksO          : in  TSortRank10_vector(7 downto 0);
        iSortRanksF          : in  TSortRank10_vector(7 downto 0);
        iFinalEnergies       : in  TCaloArea_vector(7 downto 0);
        iExtrapolatedCoordsB : in  TSpatialCoordinate_vector(35 downto 0);
        iExtrapolatedCoordsO : in  TSpatialCoordinate_vector(35 downto 0);
        iExtrapolatedCoordsF : in  TSpatialCoordinate_vector(35 downto 0);
        q                    : out ldata ((NUM_OUT_CHANS+NUM_INTERM_MU_OUT_CHANS+NUM_INTERM_SRT_OUT_CHANS+NUM_INTERM_ENERGY_OUT_CHANS+NUM_EXTRAP_COORDS_OUT_CHANS)-1 downto 0));
end serializer_stage;

architecture Behavioral of serializer_stage is
  type   TTransceiverBufferOut is array (2*2*NUM_MUONS_LINK-1 downto 0) of ldata((NUM_OUT_CHANS+NUM_INTERM_MU_OUT_CHANS+NUM_INTERM_SRT_OUT_CHANS+NUM_INTERM_ENERGY_OUT_CHANS+NUM_EXTRAP_COORDS_OUT_CHANS)-1 downto 0);
  signal sOutBuf : TTransceiverBufferOut;

  -- Offsetting the beginning of sending to align with 40 MHz clock and make
  -- sending a bit faster.
  signal sSel    : integer range 0 to 5 := 0;
  signal sSelRst : std_logic;

  signal clk40_pseudo  : std_logic;
  signal clk40_pseudo1 : std_logic;
  signal clk40_pseudo2 : std_logic;
  signal clk40_delayed : std_logic;

  signal sIntermediateMuons : TGMTMu_vector(23 downto 0);
  signal sSortRanks         : TSortRank10_vector(23 downto 0);
  signal sFakeIso           : TIsoBits := "00";

  signal sExtrapolatedCoords : TSpatialCoordinate_vector(107 downto 0);
begin

  sIntermediateMuons <= iIntermediateMuonsF(7 downto 4) & iIntermediateMuonsO(7 downto 4) & iIntermediateMuonsB & iIntermediateMuonsO(3 downto 0) & iIntermediateMuonsF(3 downto 0);
  sSortRanks         <= iSortRanksF(7 downto 4) & iSortRanksO(7 downto 4) & iSortRanksB & iSortRanksO(3 downto 0) & iSortRanksF(3 downto 0);

  sExtrapolatedCoords <= iExtrapolatedCoordsF(35 downto 18) & iExtrapolatedCoordsO(35 downto 18) & iExtrapolatedCoordsB & iExtrapolatedCoordsO(17 downto 0) & iExtrapolatedCoordsF(17 downto 0);

  serialize_muons : for i in NUM_MUONS_LINK-1 downto 0 generate
    split_muons : for j in NUM_OUT_CHANS-1 downto 0 generate
      muon_check : if i < NUM_MUONS_OUT generate
        -- First two clocks are always filled with '0'.
        sOutBuf(2*MU_ASSIGNMENT(i))(j).data    <= pack_mu_to_flat(sMuons(i+2*j), sIso(i+2*j))(31 downto 0);
        sOutBuf(2*MU_ASSIGNMENT(i))(j).valid   <= sMuons(i+2*j).valid;
        sOutBuf(2*MU_ASSIGNMENT(i)+1)(j).data  <= pack_mu_to_flat(sMuons(i+2*j), sIso(i+2*j))(63 downto 32);
        sOutBuf(2*MU_ASSIGNMENT(i)+1)(j).valid <= sMuons(i+2*j).valid;
      end generate muon_check;
      empty_check : if i = NUM_MUONS_OUT generate
        sOutBuf(2*MU_ASSIGNMENT(i))(j).data    <= (31 downto 0 => '0');
        sOutBuf(2*MU_ASSIGNMENT(i))(j).valid   <= sMuons(0).valid;
        sOutBuf(2*MU_ASSIGNMENT(i)+1)(j).data  <= (31 downto 0 => '0');
        sOutBuf(2*MU_ASSIGNMENT(i)+1)(j).valid <= sMuons(0).valid;
      end generate empty_check;
    end generate split_muons;
  end generate serialize_muons;

  serialize_intermediate_muons : for i in NUM_MUONS_LINK-1 downto 0 generate
    split_muons : for j in NUM_INTERM_MU_OUT_CHANS-1 downto 0 generate
      -- Intermediate muons don't have isolation applied, so forcing Iso to "00".
      sOutBuf(2*i)(j+NUM_OUT_CHANS).data    <= pack_mu_to_flat(sIntermediateMuons(i+3*j), sFakeIso)(31 downto 0);
      sOutBuf(2*i)(j+NUM_OUT_CHANS).valid   <= sIntermediateMuons(i+3*j).valid;
      sOutBuf(2*i+1)(j+NUM_OUT_CHANS).data  <= pack_mu_to_flat(sIntermediateMuons(i+3*j), sFakeIso)(63 downto 32);
      sOutBuf(2*i+1)(j+NUM_OUT_CHANS).valid <= sIntermediateMuons(i+3*j).valid;
    end generate split_muons;
  end generate serialize_intermediate_muons;

  serialize_intermediate_sort_ranks : for i in NUM_FRAMES_LINK-1 downto 0 generate
    split_srt_ranks : for j in NUM_INTERM_SRT_OUT_CHANS-1 downto 0 generate
      sOutBuf(i)(j+NUM_OUT_CHANS+NUM_INTERM_MU_OUT_CHANS).data  <= sSortRanks(2*i+12*j) & sSortRanks(2*i+12*j+1) & (11 downto 0 => '0');
      sOutBuf(i)(j+NUM_OUT_CHANS+NUM_INTERM_MU_OUT_CHANS).valid <= sIntermediateMuons(2*i+12*j).valid or sIntermediateMuons(2*i+12*j+1).valid;
    end generate split_srt_ranks;
  end generate serialize_intermediate_sort_ranks;

  sOutBuf(0)(NUM_OUT_CHANS+NUM_INTERM_MU_OUT_CHANS+NUM_INTERM_SRT_OUT_CHANS).data  <= std_logic_vector(iFinalEnergies(0)) & std_logic_vector(iFinalEnergies(1)) & std_logic_vector(iFinalEnergies(2)) & std_logic_vector(iFinalEnergies(3)) & (11 downto 0 => '0');
  sOutBuf(0)(NUM_OUT_CHANS+NUM_INTERM_MU_OUT_CHANS+NUM_INTERM_SRT_OUT_CHANS).valid <= sMuons(0).valid;
  sOutBuf(1)(NUM_OUT_CHANS+NUM_INTERM_MU_OUT_CHANS+NUM_INTERM_SRT_OUT_CHANS).data  <= std_logic_vector(iFinalEnergies(4)) & std_logic_vector(iFinalEnergies(5)) & std_logic_vector(iFinalEnergies(6)) & std_logic_vector(iFinalEnergies(7)) & (11 downto 0 => '0');
  sOutBuf(1)(NUM_OUT_CHANS+NUM_INTERM_MU_OUT_CHANS+NUM_INTERM_SRT_OUT_CHANS).valid <= sMuons(0).valid;

  serialize_extrapolated_coordinates : for i in NUM_MUONS_LINK-1 downto 0 generate
    split_coords : for j in NUM_EXTRAP_COORDS_OUT_CHANS-1 downto 0 generate
      sOutBuf(2*i)(j+NUM_OUT_CHANS+NUM_INTERM_MU_OUT_CHANS+NUM_INTERM_SRT_OUT_CHANS+NUM_INTERM_ENERGY_OUT_CHANS).data    <= std_logic_vector(sExtrapolatedCoords(3*i+9*j).phi) & std_logic_vector(sExtrapolatedCoords(3*i+9*j).eta) & std_logic_vector(sExtrapolatedCoords(3*i+9*j+1).phi) & (2 downto 0     => '0');
      sOutBuf(2*i)(j+NUM_OUT_CHANS+NUM_INTERM_MU_OUT_CHANS+NUM_INTERM_SRT_OUT_CHANS+NUM_INTERM_ENERGY_OUT_CHANS).valid   <= sMuons(0).valid;
      sOutBuf(2*i+1)(j+NUM_OUT_CHANS+NUM_INTERM_MU_OUT_CHANS+NUM_INTERM_SRT_OUT_CHANS+NUM_INTERM_ENERGY_OUT_CHANS).data  <= std_logic_vector(sExtrapolatedCoords(3*i+9*j+1).eta) & std_logic_vector(sExtrapolatedCoords(3*i+9*j+2).phi) & std_logic_vector(sExtrapolatedCoords(3*i+9*j+2).eta) & (3 downto 0 => '0');
      sOutBuf(2*i+1)(j+NUM_OUT_CHANS+NUM_INTERM_MU_OUT_CHANS+NUM_INTERM_SRT_OUT_CHANS+NUM_INTERM_ENERGY_OUT_CHANS).valid <= sMuons(0).valid;
    end generate split_coords;
  end generate serialize_extrapolated_coordinates;

  shift_intermediates : process (clk40)
  begin  -- process shift_intermediates
    if clk40'event and clk40 = '1' then  -- rising clock edge
      --sOutBuf(sOutBuf'high downto BUFFER_INTERMEDIATES_POS_LOW) <= sOutBuf(BUFFER_INTERMEDIATES_POS_LOW-1 downto 0);

      clk40_pseudo1 <= '1';
    elsif clk40'event and clk40 = '0' then
      clk40_pseudo2 <= '0';
    end if;
  end process shift_intermediates;

  clk40_pseudo <= clk40_pseudo1 xnor clk40_pseudo2;
  sSelRst      <= clk40_pseudo and (not clk40_delayed);

  serialization : process (clk240)
    --variable vOutBuf : TTransceiverBufferOut;
  begin  -- process serialization
    if clk240'event and clk240 = '1' then  -- rising clock edge

      clk40_delayed <= clk40_pseudo;

      for i in 0 to NUM_OUT_CHANS-1 loop
        q(i) <= sOutBuf(sSel)(i);
      end loop;  -- i
      --for i in NUM_OUT_CHANS to q'high loop
      --  q(i) <= sOutBuf(BUFFER_INTERMEDIATES_POS_LOW+sSel)(i);
      --end loop;  -- i
      if sSelRst = '1' then
        sSel <= 1;
      elsif sSel < 5 then
        sSel <= sSel+1;
      else
        sSel <= 0;
      end if;
    end if;
  end process serialization;

end Behavioral;

