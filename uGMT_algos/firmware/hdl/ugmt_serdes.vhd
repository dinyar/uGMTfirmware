library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use work.mp7_data_types.all;
use work.ipbus.all;
use work.ipbus_decode_mp7_payload.all;

use work.ugmt_constants.all;
use work.GMTTypes.all;

entity ugmt_serdes is
  generic(
    NCHAN     : positive  := 72;
    VALID_BIT : std_logic := '0'
    );
  port(
    clk_ipb : in  std_logic;
    rst     : in  std_logic;
    ipb_in  : in  ipb_wbus;
    ipb_out : out ipb_rbus;
    clk240  : in  std_logic;
    clk40   : in  std_logic;
    d       : in  ldata(NCHAN - 1 downto 0);
    q       : out ldata(NCHAN - 1 downto 0)
    );

end ugmt_serdes;

architecture rtl of ugmt_serdes is

  signal ipbw : ipb_wbus_array(N_SLAVES - 1 downto 0);
  signal ipbr : ipb_rbus_array(N_SLAVES - 1 downto 0);

  signal sEnergies     : TCaloRegionEtaSlice_vector(27 downto 0);  -- All energies from Calo trigger.
  signal sEnergies_reg : TCaloRegionEtaSlice_vector(31 downto 0);

  signal sMuons         : TGMTMu_vector(NUM_MU_CHANS*NUM_MUONS_IN-1 downto 0);
  signal sMuons_reg     : TGMTMu_vector(NUM_MU_CHANS*NUM_MUONS_IN-1 downto 0);
  signal sTracks        : TGMTMuTracks_vector(NUM_MU_CHANS-1 downto 0);
  signal sTracks_reg    : TGMTMuTracks_vector(NUM_MU_CHANS-1 downto 0);
  signal sEmpty         : std_logic_vector(NUM_MU_CHANS*NUM_MUONS_IN-1 downto 0);
  signal sEmpty_reg     : std_logic_vector(NUM_MU_CHANS*NUM_MUONS_IN-1 downto 0);
  signal sSortRanks     : TSortRank10_vector(NUM_MU_CHANS*NUM_MUONS_IN-1 downto 0);
  signal sSortRanks_reg : TSortRank10_vector(NUM_MU_CHANS*NUM_MUONS_IN-1 downto 0);
  signal sIndexBits     : TIndexBits_vector(NUM_MU_CHANS*NUM_MUONS_IN-1 downto 0);

  signal sIso       : TIsoBits_vector(7 downto 0);
  signal oMuons     : TGMTMu_vector(7 downto 0);
  signal oMuons_reg : TGMTMu_vector(7 downto 0);
  signal sIso_reg   : TIsoBits_vector(7 downto 0);

  signal sIntermediateMuonsB  : TGMTMu_vector(7 downto 0);
  signal sIntermediateMuonsO  : TGMTMu_vector(7 downto 0);
  signal sIntermediateMuonsF  : TGMTMu_vector(7 downto 0);
  signal sSortRanksB          : TSortRank10_vector(7 downto 0);
  signal sSortRanksO          : TSortRank10_vector(7 downto 0);
  signal sSortRanksF          : TSortRank10_vector(7 downto 0);
  signal sFinalEnergies       : TCaloArea_vector(7 downto 0);
  signal sExtrapolatedCoordsB : TSpatialCoordinate_vector(35 downto 0);
  signal sExtrapolatedCoordsO : TSpatialCoordinate_vector(35 downto 0);
  signal sExtrapolatedCoordsF : TSpatialCoordinate_vector(35 downto 0);
  
begin

  -- ipbus address decode
  fabric : entity work.ipbus_fabric_sel
    generic map(
      NSLV      => N_SLAVES,
      SEL_WIDTH => IPBUS_SEL_WIDTH
      )
    port map(
      ipb_in          => ipb_in,
      ipb_out         => ipb_out,
      sel             => ipbus_sel_mp7_payload(ipb_in.ipb_addr),
      ipb_to_slaves   => ipbw,
      ipb_from_slaves => ipbr
      );

  -----------------------------------------------------------------------------
  -- Begin 240 MHz domain.
  -----------------------------------------------------------------------------

  deserialize_muons : entity work.deserializer_stage_muons
    generic map (
      NCHAN     => NCHAN,
      VALID_BIT => VALID_BIT
      )
    port map (
      clk_ipb    => clk_ipb,
      rst        => rst,
      ipb_in     => ipbw(N_SLV_DESERIALIZATION),
      ipb_out    => ipbr(N_SLV_DESERIALIZATION),
      clk240     => clk240,
      clk40      => clk40,
      d          => d(NCHAN-1 downto 0),
      sMuons     => sMuons,
      sTracks    => sTracks,
      sEmpty     => sEmpty,
      sSortRanks => sSortRanks
      );

  deserialize_energies : entity work.deserializer_stage_energies
    generic map (
      NCHAN     => NCHAN,
      VALID_BIT => VALID_BIT
      )
    port map (
      --clk_ipb    => clk_ipb,
      --rst        => rst,
      --ipb_in     => ipbw(1),
      --ipb_out    => ipbr(1),
      clk240    => clk240,
      clk40     => clk40,
      d         => d(NCHAN-1 downto 0),
      sEnergies => sEnergies
      );

  -----------------------------------------------------------------------------
  -- End 240 MHz domain.
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- Begin 40 MHz domain.
  -----------------------------------------------------------------------------

  gmt_in_reg : process (clk40)
  begin  -- process gmt_in_reg
    if clk40'event and clk40 = '1' then  -- rising clock edge
      sMuons_reg                                   <= sMuons;
      sTracks_reg                                  <= sTracks;
      sEmpty_reg                                   <= sEmpty;
      sSortRanks_reg                               <= sSortRanks;
      sEnergies_reg(0)                             <= (others => "00000");
      sEnergies_reg(1)                             <= (others => "00000");
      sEnergies_reg(sEnergies_reg'high)            <= (others => "00000");
      sEnergies_reg(sEnergies_reg'high-1)          <= (others => "00000");
      sEnergies_reg(sEnergies_reg'high-2 downto 2) <= sEnergies;

      --gen_idx_bits : for index in sMuons'range generate
      --  sIndexBits(index) <= to_unsigned(index, sIndexBits(index)'length);
      --end generate gen_idx_bits;

      for index in sMuons'range loop
        sIndexBits(index) <= to_unsigned(index, sIndexBits(index)'length);
      end loop;  -- index

    end if;
  end process gmt_in_reg;



  uGMT : entity work.GMT
    port map (
      iMuonsB           => sMuons_reg((BARREL_HIGH+1)*3-1 downto BARREL_LOW*NUM_MUONS_IN),
      iMuonsO_plus      => sMuons_reg((OVL_POS_HIGH+1)*3-1 downto OVL_POS_LOW*NUM_MUONS_IN),
      iMuonsO_minus     => sMuons_reg((OVL_NEG_HIGH+1)*3-1 downto OVL_NEG_LOW*NUM_MUONS_IN),
      iMuonsF_plus      => sMuons_reg((FWD_POS_HIGH+1)*3-1 downto FWD_POS_LOW*NUM_MUONS_IN),
      iMuonsF_minus     => sMuons_reg((FWD_NEG_HIGH+1)*3-1 downto FWD_NEG_LOW*NUM_MUONS_IN),
      iTracksB          => sTracks_reg(23 downto 12),
      iTracksO          => sTracks_reg(11 downto 0),
      iTracksF          => sTracks_reg(35 downto 24),
      iSortRanksB       => sSortRanks_reg((BARREL_HIGH+1)*3-1 downto BARREL_LOW*NUM_MUONS_IN),
      iSortRanksO_plus  => sSortRanks_reg((OVL_POS_HIGH+1)*3-1 downto OVL_POS_LOW*NUM_MUONS_IN),
      iSortRanksO_minus => sSortRanks_reg((OVL_NEG_HIGH+1)*3-1 downto OVL_NEG_LOW*NUM_MUONS_IN),
      iSortRanksF_plus  => sSortRanks_reg((FWD_POS_HIGH+1)*3-1 downto FWD_POS_LOW*NUM_MUONS_IN),
      iSortRanksF_minus => sSortRanks_reg((FWD_NEG_HIGH+1)*3-1 downto FWD_NEG_LOW*NUM_MUONS_IN),
      iIdxBitsB         => sIndexBits((BARREL_HIGH+1)*3-1 downto BARREL_LOW*NUM_MUONS_IN),
      iIdxBitsO_plus    => sIndexBits((OVL_POS_HIGH+1)*3-1 downto OVL_POS_LOW*NUM_MUONS_IN),
      iIdxBitsO_minus   => sIndexBits((OVL_NEG_HIGH+1)*3-1 downto OVL_NEG_LOW*NUM_MUONS_IN),
      iIdxBitsF_plus    => sIndexBits((FWD_POS_HIGH+1)*3-1 downto FWD_POS_LOW*NUM_MUONS_IN),
      iIdxBitsF_minus   => sIndexBits((FWD_NEG_HIGH+1)*3-1 downto FWD_NEG_LOW*NUM_MUONS_IN),
      iEmptyB           => sEmpty_reg((BARREL_HIGH+1)*3-1 downto BARREL_LOW*NUM_MUONS_IN),
      iEmptyO_plus      => sEmpty_reg((OVL_POS_HIGH+1)*3-1 downto OVL_POS_LOW*NUM_MUONS_IN),
      iEmptyO_minus     => sEmpty_reg((OVL_NEG_HIGH+1)*3-1 downto OVL_NEG_LOW*NUM_MUONS_IN),
      iEmptyF_plus      => sEmpty_reg((FWD_POS_HIGH+1)*3-1 downto FWD_POS_LOW*NUM_MUONS_IN),
      iEmptyF_minus     => sEmpty_reg((FWD_NEG_HIGH+1)*3-1 downto FWD_NEG_LOW*NUM_MUONS_IN),

      iEnergies => sEnergies_reg,

      oIntermediateMuonsB  => sIntermediateMuonsB,
      oIntermediateMuonsO  => sIntermediateMuonsO,
      oIntermediateMuonsF  => sIntermediateMuonsF,
      oSortRanksB          => sSortRanksB,
      oSortRanksO          => sSortRanksO,
      oSortRanksF          => sSortRanksF,
      oFinalEnergies       => sFinalEnergies,
      oExtrapolatedCoordsB => sExtrapolatedCoordsB,
      oExtrapolatedCoordsO => sExtrapolatedCoordsO,
      oExtrapolatedCoordsF => sExtrapolatedCoordsF,

      oMuons => oMuons,
      oIso   => sIso,

      clk     => clk40,
      clk_ipb => clk_ipb,
      sinit   => rst,
      ipb_in  => ipbw(N_SLV_UGMT),
      ipb_out => ipbr(N_SLV_UGMT)
      );

  gmt_out_reg : process (clk40)
  begin  -- process gmt_out_reg
    if clk40'event and clk40 = '1' then  -- rising clock edge
      sIso_reg   <= sIso;
      oMuons_reg <= oMuons;
    end if;
  end process gmt_out_reg;

  -----------------------------------------------------------------------------
  -- End 40 MHz domain.
  -----------------------------------------------------------------------------

  -- Now pass result from uGMT back in serialized fashion.
  -----------------------------------------------------------------------------
  -- Begin 240 MHz domain.
  -----------------------------------------------------------------------------
  serialize : entity work.serializer_stage
    port map (
      clk240               => clk240,
      clk40                => clk40,
      sMuons               => oMuons_reg,
      sIso                 => sIso_reg,
      iIntermediateMuonsB  => sIntermediateMuonsB,
      iIntermediateMuonsO  => sIntermediateMuonsO,
      iIntermediateMuonsF  => sIntermediateMuonsF,
      iSortRanksB          => sSortRanksB,
      iSortRanksO          => sSortRanksO,
      iSortRanksF          => sSortRanksF,
      iFinalEnergies       => sFinalEnergies,
      iExtrapolatedCoordsB => sExtrapolatedCoordsB,
      iExtrapolatedCoordsO => sExtrapolatedCoordsO,
      iExtrapolatedCoordsF => sExtrapolatedCoordsF,
      q                    => q((NUM_OUT_CHANS+NUM_INTERM_MU_OUT_CHANS+NUM_INTERM_SRT_OUT_CHANS)-1 downto 0));

end rtl;
