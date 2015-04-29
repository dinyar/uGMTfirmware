library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use work.mp7_data_types.all;
use work.ipbus.all;
use work.ipbus_reg_types.all;
use work.ipbus_decode_ugmt_serdes.all;

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

  constant GMT_ALGO_LATENCY : natural := 8;
  -- Valid buffer is in sync with intermediate muons. (We need this to have the
  -- valid bit correct already for the first frame.)
  signal   sValid_buffer    : std_logic_vector(GMT_ALGO_LATENCY-2 downto 0);
  signal   sValid_muons     : std_logic;
  signal   sValid_energies  : std_logic;

  -- Register to disable/enable inputs
  signal sInputDisable : ipb_reg_v(0 downto 0);

  signal sEmptyB : std_logic_vector(35 downto 0);
  signal sEmptyO_plus : std_logic_vector(17 downto 0);
  signal sEmptyO_minus : std_logic_vector(17 downto 0);
  signal sEmptyF_plus : std_logic_vector(17 downto 0);
  signal sEmptyF_minus : std_logic_vector(17 downto 0);

  signal sEnergies     : TCaloRegionEtaSlice_vector(27 downto 0);  -- All energies from Calo trigger.
  signal sEnergies_tmp : TCaloRegionEtaSlice_vector(31 downto 0);
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

  signal sIntermediateMuonsB         : TGMTMu_vector(7 downto 0);
  signal sIntermediateMuonsO         : TGMTMu_vector(7 downto 0);
  signal sIntermediateMuonsF         : TGMTMu_vector(7 downto 0);
  signal sIntermediateSortRanksB     : TSortRank10_vector(7 downto 0);
  signal sIntermediateSortRanksO     : TSortRank10_vector(7 downto 0);
  signal sIntermediateSortRanksF     : TSortRank10_vector(7 downto 0);
  signal sFinalEnergies              : TCaloArea_vector(7 downto 0);
  signal sExtrapolatedCoordsB        : TSpatialCoordinate_vector(35 downto 0);
  signal sExtrapolatedCoordsO        : TSpatialCoordinate_vector(35 downto 0);
  signal sExtrapolatedCoordsF        : TSpatialCoordinate_vector(35 downto 0);
  signal sIntermediateMuonsB_reg     : TGMTMu_vector(7 downto 0);
  signal sIntermediateMuonsO_reg     : TGMTMu_vector(7 downto 0);
  signal sIntermediateMuonsF_reg     : TGMTMu_vector(7 downto 0);
  signal sIntermediateSortRanksB_reg : TSortRank10_vector(7 downto 0);
  signal sIntermediateSortRanksO_reg : TSortRank10_vector(7 downto 0);
  signal sIntermediateSortRanksF_reg : TSortRank10_vector(7 downto 0);
  signal sFinalEnergies_reg          : TCaloArea_vector(7 downto 0);
  signal sExtrapolatedCoordsB_reg    : TSpatialCoordinate_vector(35 downto 0);
  signal sExtrapolatedCoordsO_reg    : TSpatialCoordinate_vector(35 downto 0);
  signal sExtrapolatedCoordsF_reg    : TSpatialCoordinate_vector(35 downto 0);

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
      sel             => ipbus_sel_ugmt_serdes(ipb_in.ipb_addr),
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
      oMuons     => sMuons,
      oTracks    => sTracks,
      oEmpty     => sEmpty,
      oSortRanks => sSortRanks,
      oValid     => sValid_muons
      );

  deserialize_energies : entity work.deserializer_stage_energies
    generic map (
      NCHAN     => NCHAN,
      VALID_BIT => VALID_BIT
      )
    port map (
      clk240    => clk240,
      clk40     => clk40,
      d         => d(NCHAN-1 downto 0),
      oEnergies => sEnergies,
      oValid    => sValid_energies
      );

  -----------------------------------------------------------------------------
  -- End 240 MHz domain.
  -----------------------------------------------------------------------------

  sValid_buffer(0) <= sValid_muons or sValid_energies;

  -----------------------------------------------------------------------------
  -- Begin 40 MHz domain.
  -----------------------------------------------------------------------------

  delay_valid_bit : process(clk40)
  begin  -- process delay_valid_bit
    if clk40'event and clk40 = '1' then  -- rising clock edge
      sValid_buffer(sValid_buffer'high downto 1) <= sValid_buffer(sValid_buffer'high-1 downto 0);
    end if;
  end process delay_valid_bit;


  gmt_index_comp : process (clk40)
  begin  -- process gmt_index_comp
    if clk40'event and clk40 = '1' then  -- rising clock edge
      sMuons_reg                                   <= sMuons;
      sTracks_reg                                  <= sTracks;
      sEmpty_reg                                   <= sEmpty;
      sSortRanks_reg                               <= sSortRanks;
      sEnergies_tmp(sEnergies_tmp'high-4 downto 0) <= sEnergies;
      sEnergies_tmp(sEnergies_tmp'high-3)          <= (others => "00000");
      sEnergies_tmp(sEnergies_tmp'high-2)          <= (others => "00000");
      sEnergies_tmp(sEnergies_tmp'high-1)          <= (others => "00000");
      sEnergies_tmp(sEnergies_tmp'high)            <= (others => "00000");

      for index in sMuons'range loop
        sIndexBits(index) <= to_unsigned(index, sIndexBits(index)'length);
      end loop;  -- index

    end if;
  end process gmt_index_comp;

  disable_inputs_reg : entity work.ipbus_reg_v
    generic map(
        N_REG => 1
    )
    port map(
        clk => clk_ipb,
        reset => rst,
        ipbus_in => ipbw(N_SLV_INPUT_DISABLE_REG),
        ipbus_out => ipbr(N_SLV_INPUT_DISABLE_REG),
        q => sInputDisable
    );

  disable_inputs : process (sEmpty_reg, sEnergies_tmp, sInputDisable)
  begin
      if sInputDisable(0)(0) = '1' then -- disable energies
          for i in sEnergies_reg'range loop
              sEnergies_reg(i) <= (others => "00000");
          end loop;
      else
          sEnergies_reg <= sEnergies_tmp;
      end if;

      ---- Disabling barrel ----
      if sInputDisable(0)(1) = '1' then -- disable barrel
          sEmptyB <= (others => '1');
      else
          sEmptyB <= sEmpty_reg((BARREL_HIGH+1)*3-1 downto BARREL_LOW*NUM_MUONS_IN);
      end if;

      ---- Disable overlap ----
      if sInputDisable(0)(2) = '1' then -- disable ovl pos
          sEmptyO_plus <= (others => '1');
      else
          sEmptyO_plus <= sEmpty_reg((OVL_POS_HIGH+1)*3-1 downto OVL_POS_LOW*NUM_MUONS_IN);
      end if;

      if sInputDisable(0)(3) = '1' then -- disable ovl neg
          sEmptyO_minus <= (others => '1');
      else
          sEmptyO_minus <= sEmpty_reg((OVL_NEG_HIGH+1)*3-1 downto OVL_NEG_LOW*NUM_MUONS_IN);
      end if;

      ---- Disable forward ----
      if sInputDisable(0)(4) = '1' then -- disable fwd pos
          sEmptyF_plus <= (others => '1');
      else
          sEmptyF_plus <= sEmpty_reg((FWD_POS_HIGH+1)*3-1 downto FWD_POS_LOW*NUM_MUONS_IN);
      end if;

      if sInputDisable(0)(5) = '1' then -- disable fwd neg
          sEmptyF_minus <= (others => '1');
      else
          sEmptyF_minus <= sEmpty_reg((FWD_NEG_HIGH+1)*3-1 downto FWD_NEG_LOW*NUM_MUONS_IN);
      end if;
  end process disable_inputs;

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
      iEmptyB           => sEmptyB,
      iEmptyO_plus      => sEmptyO_plus,
      iEmptyO_minus     => sEmptyO_minus,
      iEmptyF_plus      => sEmptyF_plus,
      iEmptyF_minus     => sEmptyF_minus,

      iEnergies => sEnergies_reg,

      oIntermediateMuonsB     => sIntermediateMuonsB,
      oIntermediateMuonsO     => sIntermediateMuonsO,
      oIntermediateMuonsF     => sIntermediateMuonsF,
      oIntermediateSortRanksB => sIntermediateSortRanksB,
      oIntermediateSortRanksO => sIntermediateSortRanksO,
      oIntermediateSortRanksF => sIntermediateSortRanksF,
      oFinalEnergies          => sFinalEnergies,
      oExtrapolatedCoordsB    => sExtrapolatedCoordsB,
      oExtrapolatedCoordsO    => sExtrapolatedCoordsO,
      oExtrapolatedCoordsF    => sExtrapolatedCoordsF,

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

      sIntermediateMuonsO_reg     <= sIntermediateMuonsO;
      sIntermediateMuonsB_reg     <= sIntermediateMuonsB;
      sIntermediateMuonsF_reg     <= sIntermediateMuonsF;
      sIntermediateSortRanksB_reg <= sIntermediateSortRanksB;
      sIntermediateSortRanksO_reg <= sIntermediateSortRanksO;
      sIntermediateSortRanksF_reg <= sIntermediateSortRanksF;
      sFinalEnergies_reg          <= sFinalEnergies;
      sExtrapolatedCoordsB_reg    <= sExtrapolatedCoordsB;
      sExtrapolatedCoordsO_reg    <= sExtrapolatedCoordsO;
      sExtrapolatedCoordsF_reg    <= sExtrapolatedCoordsF;
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
      iValid               => sValid_buffer(sValid_buffer'high),
      sMuons               => oMuons_reg,
      sIso                 => sIso_reg,
      iIntermediateMuonsB  => sIntermediateMuonsB_reg,
      iIntermediateMuonsO  => sIntermediateMuonsO_reg,
      iIntermediateMuonsF  => sIntermediateMuonsF_reg,
      iSortRanksB          => sIntermediateSortRanksB_reg,
      iSortRanksO          => sIntermediateSortRanksO_reg,
      iSortRanksF          => sIntermediateSortRanksF_reg,
      iFinalEnergies       => sFinalEnergies_reg,
      iExtrapolatedCoordsB => sExtrapolatedCoordsB_reg,
      iExtrapolatedCoordsO => sExtrapolatedCoordsO_reg,
      iExtrapolatedCoordsF => sExtrapolatedCoordsF_reg,
      q                    => q((NUM_OUT_CHANS+NUM_INTERM_MU_OUT_CHANS+NUM_INTERM_SRT_OUT_CHANS+NUM_INTERM_ENERGY_OUT_CHANS+NUM_EXTRAP_COORDS_OUT_CHANS)-1 downto 0));

  strobe_high : for i in q'high downto (NUM_OUT_CHANS+NUM_INTERM_MU_OUT_CHANS+NUM_INTERM_SRT_OUT_CHANS+NUM_INTERM_ENERGY_OUT_CHANS+NUM_EXTRAP_COORDS_OUT_CHANS) generate
        q(i).strobe <= '1';
  end generate;

end rtl;
