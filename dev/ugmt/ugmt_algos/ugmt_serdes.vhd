library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use work.mp7_data_types.all;

use work.ugmt_constants.all;
library Types;
use Types.GMTTypes.all;

entity ugmt_serdes is
  generic(
    NCHAN : positive
    );
  port(
    clk240 : in  std_logic;
    clk120 : in  std_logic;
    clk40  : in  std_logic;
    d      : in  ldata(NCHAN - 1 downto 0);
    q      : out ldata(NCHAN - 1 downto 0)
    );

end ugmt_serdes;

architecture rtl of ugmt_serdes is

  component GMT
    port (
      iMuonsB           : in TGMTMu_vector(35 downto 0);
      iMuonsO_plus      : in TGMTMu_vector(17 downto 0);
      iMuonsO_minus     : in TGMTMu_vector(17 downto 0);
      iMuonsF_plus      : in TGMTMu_vector(17 downto 0);
      iMuonsF_minus     : in TGMTMu_vector(17 downto 0);
      iTracksB          : in TGMTMuTracks_vector(11 downto 0);
      iTracksO          : in TGMTMuTracks_vector(11 downto 0);
      iTracksF          : in TGMTMuTracks_vector(11 downto 0);
      iSortRanksB       : in TSortRank10_vector(35 downto 0);
      iSortRanksO_plus  : in TSortRank10_vector(17 downto 0);
      iSortRanksO_minus : in TSortRank10_vector(17 downto 0);
      iSortRanksF_plus  : in TSortRank10_vector(17 downto 0);
      iSortRanksF_minus : in TSortRank10_vector(17 downto 0);
      iIdxBitsB         : in TIndexBits_vector(35 downto 0);
      iIdxBitsO_plus    : in TIndexBits_vector(17 downto 0);
      iIdxBitsO_minus   : in TIndexBits_vector(17 downto 0);
      iIdxBitsF_plus    : in TIndexBits_vector(17 downto 0);
      iIdxBitsF_minus   : in TIndexBits_vector(17 downto 0);
      iEmptyB           : in std_logic_vector(35 downto 0);
      iEmptyO_plus      : in std_logic_vector(17 downto 0);
      iEmptyO_minus     : in std_logic_vector(17 downto 0);
      iEmptyF_plus      : in std_logic_vector(17 downto 0);
      iEmptyF_minus     : in std_logic_vector(17 downto 0);
      iEnergies         : in TCaloRegionEtaSlice_vector(31 downto 0);

      oMuons : out TGMTMu_vector(7 downto 0);
      oIso   : out TIsoBits_vector(7 downto 0);

      clk   : in std_logic;
      sinit : in std_logic);
  end component;

  component sort_rank_lut
    port (
      clka  : in  std_logic;
      wea   : in  std_logic_vector(0 downto 0);
      addra : in  std_logic_vector(12 downto 0);
      dina  : in  std_logic_vector(9 downto 0);
      douta : out std_logic_vector(9 downto 0);
      clkb  : in  std_logic;
      enb   : in  std_logic;
      web   : in  std_logic_vector(0 downto 0);
      addrb : in  std_logic_vector(13 downto 0);
      dinb  : in  std_logic_vector(4 downto 0);
      doutb : out std_logic_vector(4 downto 0)
      );
  end component;


  signal muon_counter_in    : integer range 0 to NUM_MUONS_LINK -1  := 0;
  -- Determines whether we're in rising or falling flank of 120 MHz clock.
  signal clk240_counter_in  : std_logic                             := '0';
  signal clk240_counter_out : integer range 0 to 2*NUM_MUONS_LINK-1 := 0;
  signal muon_counter_out   : integer range 0 to NUM_MUONS_LINK -1  := 0;

  type TCombinationVector is array (NUM_MU_CHANS-1 downto 0) of std_logic_vector(12 downto 0);
  signal combined_pt_qual : TCombinationVector;

  signal sMuons_flat     : TFlatMuons(NUM_MU_CHANS -1 downto 0);  -- All input muons.
  signal sEmpty          : TEmpty_link(NUM_MU_CHANS -1 downto 0);  -- Empty bits for all input muons.
  signal sIndexBits      : TIndexBits_link(NUM_MU_CHANS -1 downto 0);  -- Index bits for all input muons.
  signal sSortRank       : TSortRank_link(NUM_MU_CHANS -1 downto 0);  -- Sort ranks for all input muons.
  signal sMuons_flat_reg : TFlatMuons(NUM_MU_CHANS -1 downto 0);
  signal sEmpty_reg      : TEmpty_link(NUM_MU_CHANS -1 downto 0);
  signal sIndexBits_reg  : TIndexBits_link(NUM_MU_CHANS -1 downto 0);
  signal sSortRank_reg   : TSortRank_link(NUM_MU_CHANS -1 downto 0);

  signal sEnergies     : TCaloRegionEtaSlice_vector(31 downto 0);  -- All energies from Calo trigger.
  signal sEnergies_reg : TCaloRegionEtaSlice_vector(31 downto 0);

  signal sMuonsInB       : TGMTMuIn_vector(35 downto 0);
  signal sMuonsInO       : TGMTMuIn_vector(35 downto 0);
  signal sMuonsInO_plus  : TGMTMuIn_vector(17 downto 0);
  signal sMuonsInO_minus : TGMTMuIn_vector(17 downto 0);
  signal sMuonsInF       : TGMTMuIn_vector(35 downto 0);
  signal sMuonsInF_plus  : TGMTMuIn_vector(17 downto 0);
  signal sMuonsInF_minus : TGMTMuIn_vector(17 downto 0);
  signal sMuonsB         : TGMTMu_vector(35 downto 0);
  signal sMuonsO_plus    : TGMTMu_vector(17 downto 0);
  signal sMuonsO_minus   : TGMTMu_vector(17 downto 0);
  signal sMuonsF_plus    : TGMTMu_vector(17 downto 0);
  signal sMuonsF_minus   : TGMTMu_vector(17 downto 0);

  signal sMuons     : TGMTMu_vector(7 downto 0);
  signal sIso       : TIsoBits_vector(7 downto 0);
  signal sMuons_reg : TGMTMu_vector(7 downto 0);
  signal sIso_reg   : TIsoBits_vector(7 downto 0);

  type   TTransceiverBuffer is array (integer range <>) of ldata(2*NUM_MUONS_LINK-1);
  signal in_buf : TTransceiverBuffer(NUM_IN_CHANS-1 downto 0);
  signal buf    : TTransceiverBuffer(NUM_OUT_CHANS-1 downto 0);

begin
  -- First receive 6 32 bit words over each channel (this means 6 240 MHz clocks).
  -- Put two successive 32 bit words into one data structure for
  -- the muon.

  -----------------------------------------------------------------------------
  -- Begin 240 MHz domain.
  -----------------------------------------------------------------------------

  start_buffering : for i in in_buf'range generate
    in_buf(i)(0) <= d(i);
  end generate start_buffering;

  fill_buffer : process (clk240)
  begin  -- process fill_buffer
    if clk240'event and clk240 = '1' then  -- rising clock edge
      for i in in_buf'range loop
        in_buf(i)(2*NUM_MUONS_LINK-1 downto 1) <= in_buf(i)(2*NUM_MUONS_LINK-2 downto 0);
      end loop;  -- i
    end if;
  end process fill_buffer;


  --deserialization : process(clk240)
  --begin
  --  if(rising_edge(clk240)) then
  --    -- this is 'rising edge' of 120 MHz clock.
  --    if clk240_counter_in = '0' then
  --      for i in NUM_MU_CHANS-1 downto 0 loop
  --        -- Put first word into data structure for flat muons.
  --        if d(i).valid = '1' then
  --          sMuons_flat(i)(muon_counter_in)(63 downto 32) <= d(i).data;
  --        else
  --          sMuons_flat(i)(muon_counter_in)(63 downto 32) <= (others => '0');
  --        end if;

  --        -- Determine empty bit.
  --        if sMuons_flat(i)(muon_counter_in)(PT_IN_HIGH downto PT_IN_LOW) = (PT_IN_HIGH downto PT_IN_LOW => '0') then
  --          sEmpty(i)(muon_counter_in) <= '1';
  --        else
  --          sEmpty(i)(muon_counter_in) <= '0';
  --        end if;

  --        -- Assign index bits.
  --        -- Will count through all muons, but group by subsystems.
  --        -- Barrel goes from 0 to 35
  --        -- Overlap goes from 36 to 71
  --        -- Forward goes from 72 to 107
  --        sIndexBits(i)(muon_counter_in) <= to_unsigned(3*i+muon_counter_in, sIndexBits(i)(muon_counter_in)'length);
  --      end loop;  -- i


  --      -- Loop over calo links
  --      for i in sEnergies(0)'range loop
  --        sEnergies(0)(i)                <= (others => '0');
  --        sEnergies(1)(i)                <= (others => '0');
  --        sEnergies(sEnergies'high-1)(i) <= (others => '0');
  --        sEnergies(sEnergies'high)(i)   <= (others => '0');
  --      end loop;  -- i
  --      for i in NUM_CALO_CHANS-1 downto 0 loop
  --        -- We receive 32 bit at every clock. we can only use 30 bit of those.
  --        -- This means we receive 6 energy sums per clock.
  --        sEnergies(i+2)(12*muon_counter_in+11 downto 12*muon_counter_in+6) <= calo_etaslice_from_flat(d(NUM_MU_CHANS+i).data);
  --      end loop;  -- i

  --      -- TODO: Get proper 120 MHz clk from framework.
  --      clk240_counter_in <= '1';
  --    elsif clk240_counter_in = '1' then

  --      -- Put every second word into latter part of double_word.
  --      for i in NUM_MU_CHANS-1 downto 0 loop
  --        if d(i).valid = '1' then
  --          sMuons_flat(i)(muon_counter_in)(31 downto 0) <= d(i).data;
  --        else
  --          sMuons_flat(i)(muon_counter_in)(31 downto 0) <= (others => '0');
  --        end if;

  --      end loop;  -- i

  --      -- Loop over calo links
  --      -- TODO: valid flag here and above!
  --      for i in NUM_CALO_CHANS-1 downto 0 loop
  --        sEnergies(i+2)(12*muon_counter_in+5 downto 12*muon_counter_in) <= calo_etaslice_from_flat(d(NUM_MU_CHANS+i).data);
  --      end loop;  -- i

  --      -- Finally increment j by one as we have reached the end of the second
  --      -- 120 MHz clk
  --      muon_counter_in <= muon_counter_in +1;


  --      -- TODO: Get proper 120 MHz clk from framework.
  --      clk240_counter_in <= '0';
  --    end if;
  --  end if;
  --end process;

  -----------------------------------------------------------------------------
  -- End 240 MHz domain.
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- Begin 120 MHz domain.
  -----------------------------------------------------------------------------

  count_muons : process (clk120)
  begin  -- process count_muons
    if clk120'event and clk120 = '1' then  -- rising clock edge
      muon_counter_in  <= muon_counter_in+1;
      muon_counter_out <= muon_counter_out+1;
    end if;
  end process count_muons;

  -- Every first 32 bit word will contain the quality and pT of a muon, use
  -- this as input for the sort rank LUT.
  combine_pt_qual : for i in combined_pt_qual'range generate
    combined_pt_qual(i) <= in_buf(i)(0).data(PT_IN_HIGH-WORD_SIZE downto PT_IN_LOW-WORD_SIZE) & in_buf(i)(0).data(QUAL_IN_HIGH-WORD_SIZE downto QUAL_IN_LOW-WORD_SIZE);
  end generate combine_pt_qual;

  assign_ranks : for i in sSortRank'range generate
    sort_rank_assignment : sort_rank_lut
      port map (
        clka  => clk120,
        wea   => "0",
        addra => combined_pt_qual(i),
        dina  => (others => '0'),
        douta => sSortRank(i)(muon_counter_in),
        clkb  => clk240,  -- Data clock doesn't have to be same speed.
        enb   => '0',
        web   => "0",
        addrb => (others => '0'),
        dinb  => (others => '0'),
        doutb => open);
  end generate assign_ranks;

  -----------------------------------------------------------------------------
  -- End 120 MHz domain.
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- Begin 40 MHz domain.
  -----------------------------------------------------------------------------

  gmt_in_reg : process (clk40)
  begin  -- process gmt_in_reg
    if clk40'event and clk40 = '1' then  -- rising clock edge
      for i in NUM_MU_CHANS-1 downto 0 loop
        for j in in_buf(i)'range loop
          if (j mod 2) = 0 then
            if in_buf(i)(j).valid = '1' then
              sMuons_flat(i)(j/2)(63 downto 32) <= in_buf(i)(j).data;
            else
              sMuons_flat(i)(j/2)(63 downto 32) <= (others => '0');
            end if;

            -- Determine empty bit.
            if in_buf(i)(j).data(PT_IN_HIGH-32 downto PT_IN_LOW-32) = (PT_IN_HIGH downto PT_IN_LOW => '0') then
              sEmpty(i)(j/2) <= '1';
            else
              sEmpty(i)(j/2) <= '0';
            end if;

            -- Assign index bits.
            sIndexBits(i)(j/2) <= to_unsigned(3*i+j/2, sIndexBits(i)(j/2)'length);
          else
            if in_buf(i)(j).valid = '1' then
              sMuons_flat(i)((j-1)/2)(31 downto 0) <= in_buf(i)(j).data;
            else
              sMuons_flat(i)((j-1)/2)(31 downto 0) <= (others => '0');
            end if;
          end if;
        end loop;  -- j
      end loop;  -- i

      for i in NUM_MU_CHANS+NUM_CALO_CHANS-1 downto NUM_MU_CHANS loop
        for j in in_buf(i)'range loop
          if in_buf(i)(j).valid = '1' then
            sEnergies(i-NUM_MU_CHANS)(5*j+4 downto 5*j) <= calo_etaslice_from_flat(in_buf(i)(j).data);
          else
            sEnergies(i-NUM_MU_CHANS)(5*j+4 downto 5*j) <= (others => "00000");
          end if;
        end loop;  -- j
      end loop;  -- i

      --sMuons_flat_reg <= sMuons_flat;
      --sSortRank_reg   <= sSortRank;
      --sIndexBits_reg  <= sIndexBits;
      --sEmpty_reg      <= sEmpty;
      --sEnergies_reg   <= sEnergies;
    end if;
  end process gmt_in_reg;

  sMuonsInB <= muon_flat_to_vec(sMuons_flat(BARREL_HIGH downto BARREL_LOW));
  sMuonsB   <= gmt_mus_from_in_mus(sMuonsInB);

  sMuonsInO_plus  <= muon_flat_to_vec(sMuons_flat(OVL_POS_HIGH downto OVL_POS_LOW));
  sMuonsO_plus    <= gmt_mus_from_in_mus(sMuonsInO_plus);
  sMuonsInO_minus <= muon_flat_to_vec(sMuons_flat(OVL_NEG_HIGH downto OVL_NEG_LOW));
  sMuonsO_minus   <= gmt_mus_from_in_mus(sMuonsInO_minus);
  sMuonsInO       <= sMuonsInO_plus & sMuonsInO_minus;

  sMuonsInF_plus  <= muon_flat_to_vec(sMuons_flat(FWD_POS_HIGH downto FWD_POS_LOW));
  sMuonsF_plus    <= gmt_mus_from_in_mus(sMuonsInF_plus);
  sMuonsInF_minus <= muon_flat_to_vec(sMuons_flat(FWD_NEG_HIGH downto FWD_NEG_LOW));
  sMuonsF_minus   <= gmt_mus_from_in_mus(sMuonsInF_minus);
  sMuonsInF       <= sMuonsInF_plus & sMuonsInF_minus;

  uGMT : GMT
    port map (
      iMuonsB           => sMuonsB,
      iMuonsO_plus      => sMuonsO_plus,
      iMuonsO_minus     => sMuonsO_minus,
      iMuonsF_plus      => sMuonsF_plus,
      iMuonsF_minus     => sMuonsF_minus,
      iTracksB          => track_addresses_from_in_mus(sMuonsInB),
      iTracksO          => track_addresses_from_in_mus(sMuonsInO),
      iTracksF          => track_addresses_from_in_mus(sMuonsInF),
      iSortRanksB       => unpack_sort_rank(sSortRank(BARREL_HIGH downto BARREL_LOW)),
      iSortRanksO_plus  => unpack_sort_rank(sSortRank(OVL_POS_HIGH downto OVL_POS_LOW)),
      iSortRanksO_minus => unpack_sort_rank(sSortRank(OVL_NEG_HIGH downto OVL_NEG_LOW)),
      iSortRanksF_plus  => unpack_sort_rank(sSortRank(FWD_POS_HIGH downto FWD_POS_LOW)),
      iSortRanksF_minus => unpack_sort_rank(sSortRank(FWD_NEG_HIGH downto FWD_NEG_LOW)),
      iIdxBitsB         => unpack_idx_bits(sIndexBits(BARREL_HIGH downto BARREL_LOW)),
      iIdxBitsO_plus    => unpack_idx_bits(sIndexBits(OVL_POS_HIGH downto OVL_POS_LOW)),
      iIdxBitsO_minus   => unpack_idx_bits(sIndexBits(OVL_NEG_HIGH downto OVL_NEG_LOW)),
      iIdxBitsF_plus    => unpack_idx_bits(sIndexBits(FWD_POS_HIGH downto FWD_POS_LOW)),
      iIdxBitsF_minus   => unpack_idx_bits(sIndexBits(FWD_NEG_HIGH downto FWD_NEG_LOW)),
      iEmptyB           => unpack_empty_bits(sEmpty(BARREL_HIGH downto BARREL_LOW)),
      iEmptyO_plus      => unpack_empty_bits(sEmpty(OVL_POS_HIGH downto OVL_POS_LOW)),
      iEmptyO_minus     => unpack_empty_bits(sEmpty(OVL_NEG_HIGH downto OVL_NEG_LOW)),
      iEmptyF_plus      => unpack_empty_bits(sEmpty(FWD_POS_HIGH downto FWD_POS_LOW)),
      iEmptyF_minus     => unpack_empty_bits(sEmpty(FWD_NEG_HIGH downto FWD_NEG_LOW)),

      iEnergies => sEnergies,

      oMuons => sMuons,
      oIso   => sIso,

      clk   => clk40,
      sinit => '0');                    -- What will sinit do? Where does it
  -- come from?

  gmt_out_reg : process (clk40)
  begin  -- process gmt_out_reg
    if clk40'event and clk40 = '1' then  -- rising clock edge
      sIso_reg   <= sIso;
      sMuons_reg <= sMuons;
    end if;
  end process gmt_out_reg;

  -----------------------------------------------------------------------------
  -- End 40 MHz domain.
  -----------------------------------------------------------------------------

  -- Now pass result from uGMT back in serialized fashion.
  -----------------------------------------------------------------------------
  -- Begin 240 MHz domain.
  -----------------------------------------------------------------------------

  serialize_muons : for i in NUM_OUT_CHANS-1 downto 0 generate
    split_muons : for j in NUM_MUONS_OUT downto 0 generate
      muon_check : if j < NUM_MUONS_OUT generate
        buf(i)(2*j).data    <= pack_mu_to_flat(sMuons_reg(i*NUM_MUONS_OUT + muon_counter_out), sIso_reg(i*NUM_MUONS_OUT + muon_counter_out))(63 downto 32);
        buf(i)(2*j).valid   <= '1';
        buf(i)(2*j+1).data  <= pack_mu_to_flat(sMuons_reg(i*NUM_MUONS_OUT + muon_counter_out), sIso_reg(i*NUM_MUONS_OUT + muon_counter_out))(31 downto 0);
        buf(i)(2*j+1).valid <= '1';
      end generate muon_check;
      empty_check : if j = NUM_MUONS_OUT generate
        buf(i)(2*j)   <= LWORD_NULL;
        buf(i)(2*j+1) <= LWORD_NULL;
      end generate empty_check;
    end generate split_muons;
  end generate serialize_muons;

  serialization : process (clk240)
  begin  -- process serialization
    if (rising_edge(clk240)) then       -- rising clock edge
      for i in NUM_OUT_CHANS-1 downto 0 loop
        q(i) <= buf(i)(clk240_counter_out);
      end loop;  -- i
      clk240_counter_out <= clk240_counter_out+1;
    end if;
  end process serialization;

end rtl;
