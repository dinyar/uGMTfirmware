library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.mp7_data_types.all;

use work.GMTTypes.all;
use work.ugmt_constants.all;

entity serialize_outputs_quad is
  generic (
    DUMMY    : boolean := false;
    N_MU_OUT : natural := 12
    );
  port (
    clk240           : in  std_logic;
    clk40            : in  std_logic;
    rst              : in  std_logic;
    iValidMuons      : in  std_logic;
    iValidEnergies   : in  std_logic;
    iMuons           : in  TGMTMu_vector(N_MU_OUT-1 downto 0);
    iExtrapolatedPhi : in  TPhi_vector(N_MU_OUT-1 downto 0);
    iIso             : in  TIsoBits_vector(N_MU_OUT-1 downto 0);
    iMuIdxBits       : in  TIndexBits_vector(N_MU_OUT-1 downto 0);
    q                : out ldata (3 downto 0)
    );
end serialize_outputs_quad;

architecture Behavioral of serialize_outputs_quad is
  type TTransceiverBufferOut is array (2*2*NUM_MUONS_LINK-1 downto 0) of ldata((NUM_OUT_CHANS+NUM_INTERM_MU_OUT_CHANS)-1 downto 0);
  signal sOutBuf : TTransceiverBufferOut;

  signal sSel    : integer range 0 to 5;
begin

  selector_gen : process (clk240)
  begin  -- process selector_gen
    if clk240'event and clk240 = '1' then  -- rising clock edge
      if rst = '1' then
        sSel <= 0;
      elsif sSel < 5 then
        sSel <= sSel+1;
      else
        sSel <= 0;
      end if;
    end if;
  end process selector_gen;


  gen_dummy : if DUMMY = true generate
    serialization : process (clk240)
    begin  -- process serialization
      if clk240'event and clk240 = '1' then  -- rising clock edge
        for i in 0 to 3 loop -- Number of channels
          q(i).strobe <= '1';
          q(i).valid  <= iValidMuons or iValidEnergies;
          q(i).data   <= (others => '0');
        end loop;  -- i
      end if;
    end process serialization;
  end generate gen_dummy;

  gen_finals : if (DUMMY = false) and (N_MU_OUT = 8) generate
    serialize_muons : for i in NUM_MUONS_LINK-1 downto 0 generate
      split_muons : for j in 3 downto 0 generate -- Number of channels
        muon_check : if i < NUM_MUONS_OUT generate
          -- First two clocks are always filled with '0'.
          sOutBuf(2*MU_ASSIGNMENT(i))(j).data    <= pack_mu_to_flat(iMuons(i+2*j), iExtrapolatedPhi(i+2*j), iMuIdxBits(i+2*j), iIso(i+2*j))(31 downto 0);
          sOutBuf(2*MU_ASSIGNMENT(i)+1)(j).data  <= pack_mu_to_flat(iMuons(i+2*j), iExtrapolatedPhi(i+2*j), iMuIdxBits(i+2*j), iIso(i+2*j))(63 downto 32);
        end generate muon_check;
        empty_check : if i = NUM_MUONS_OUT generate
          sOutBuf(2*MU_ASSIGNMENT(i))(j).data    <= (31 downto 0 => '0');
          sOutBuf(2*MU_ASSIGNMENT(i)+1)(j).data  <= (31 downto 0 => '0');
        end generate empty_check;
      end generate split_muons;
    end generate serialize_muons;

    serialization : process (clk240)
    begin  -- process serialization
      if clk240'event and clk240 = '1' then  -- rising clock edge
        for i in 0 to 3 loop -- Number of channels
          q(i).strobe <= '1';
          q(i).valid  <= iValidMuons or iValidEnergies;
          q(i).data   <= sOutBuf(sSel)(i).data;
        end loop;  -- i
      end if;
    end process serialization;
  end generate gen_finals;

  gen_intermediates : if (DUMMY = false) and (N_MU_OUT = 12) generate
    serialize_intermediate_muons : for i in NUM_MUONS_LINK-1 downto 0 generate
      split_muons : for j in 3 downto 0 generate -- Number of channels
        sOutBuf(2*i)(j+NUM_OUT_CHANS).data    <= pack_mu_to_flat(iMuons(i+3*j), iExtrapolatedPhi(i+3*j), iMuIdxBits(i+3*j), iIso(i+3*j))(31 downto 0);
        sOutBuf(2*i+1)(j+NUM_OUT_CHANS).data  <= pack_mu_to_flat(iMuons(i+3*j), iExtrapolatedPhi(i+3*j), iMuIdxBits(i+3*j), iIso(i+3*j))(63 downto 32);
      end generate split_muons;
    end generate serialize_intermediate_muons;

    serialization : process (clk240)
    begin  -- process serialization
      if clk240'event and clk240 = '1' then  -- rising clock edge
        for i in 0 to 3 loop -- Number of channels
          q(i).strobe <= '1';
          q(i).valid  <= iValidMuons or iValidEnergies;
          if sSel = 0 then
            q(i).data <= sOutBuf(sSel)(i+NUM_OUT_CHANS).data;
          else
            q(i).data <= sOutBuf(sSel)(i+NUM_OUT_CHANS).data;
          end if;
        end loop;  -- i
      end if;
    end process serialization;
  end generate gen_intermediates;

  shift_intermediates_rising : process (clk40)
  begin  -- process shift_intermediates_rising
    if clk40'event and clk40 = '1' then  -- rising clock edge
      sOutBuf(sOutBuf'high downto BUFFER_INTERMEDIATES_POS_LOW) <= sOutBuf(BUFFER_INTERMEDIATES_POS_LOW-1 downto 0);
    end if;
  end process shift_intermediates_rising;

end Behavioral;
