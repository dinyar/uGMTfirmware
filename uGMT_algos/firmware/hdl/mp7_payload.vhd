library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use work.mp7_data_types.all;
use work.ipbus.all;
use work.ipbus_reg_types.all;
use work.ipbus_decode_mp7_payload.all;

use work.mp7_ttc_decl.all;
use work.mp7_brd_decl.all;

use work.ugmt_constants.all;
use work.GMTTypes.all;

entity mp7_payload is
  generic (
    NCHAN : natural := 72
    );
  port(
    ctrs        : in  ttc_stuff_array(N_REGION - 1 downto 0);
    clk         : in  std_logic;  -- IPbus clock
    rst         : in  std_logic;  -- IPbus reset
    ipb_in      : in  ipb_wbus;
    ipb_out     : out ipb_rbus;
    clk_payload : in  std_logic;  -- LHC clock (40 MHz)
    rst_payload : in  std_logic;
    clk_p       : in  std_logic;  -- board clock (240 MHz)
    rst_loc     : in  std_logic_vector(N_REGION - 1 downto 0); -- per-region reset signals
    clken_loc   : in  std_logic_vector(N_REGION - 1 downto 0); -- per-region clken signals
    d           : in  ldata(NCHAN - 1 downto 0);
    bc0         : out std_logic;
    q           : out ldata(NCHAN - 1 downto 0);
    gpio        : out std_logic_vector(29 downto 0);
    gpio_en     : out std_logic_vector(29 downto 0)
    );

end mp7_payload;

architecture rtl of mp7_payload is

  signal ipbw : ipb_wbus_array(N_SLAVES - 1 downto 0);
  signal ipbr : ipb_rbus_array(N_SLAVES - 1 downto 0);

  constant GMT_ALGO_LATENCY     : natural := 6;
  -- Valid bits delayed less than algo latency due to one register before and
  -- requirement to be 1 bx early in serializer.
  signal   sValid_buffer        : std_logic_vector(GMT_ALGO_LATENCY-3 downto 0);
  signal   sValid_muons         : std_logic;
  signal   sValid_muons_reg     : std_logic;
  signal   sValid_energies      : std_logic;
  signal   sValid_energies_reg  : std_logic;

  -- Muon counter reset signal
  signal sMuCtrReset : std_logic_vector(N_REGION - 1 downto 0);

  -- Register to disable/enable inputs
  signal sInputDisable : ipb_reg_v(0 downto 0);

  signal sEmptyO_plus : std_logic_vector(17 downto 0);
  signal sEmptyO_minus : std_logic_vector(17 downto 0);
  signal sEmptyF_plus : std_logic_vector(17 downto 0);
  signal sEmptyF_minus : std_logic_vector(17 downto 0);

  signal sEnergies     : TCaloRegionEtaSlice_vector(27 downto 0);  -- All energies from Calo trigger.
  signal sEnergies_tmp : TCaloRegionEtaSlice_vector(31 downto 0);
  signal sEnergies_fin : TCaloRegionEtaSlice_vector(31 downto 0);

  signal sCaloIndexBits : TCaloIndexBit_vector(NUM_MU_CHANS*NUM_MUONS_IN-1 downto 0);
  signal sCaloIndexBitsB : TCaloIndexBit_vector(35 downto 0);
  signal sCaloIndexBitsO : TCaloIndexBit_vector(35 downto 0);
  signal sCaloIndexBitsF : TCaloIndexBit_vector(35 downto 0);

  signal sMuons      : TGMTMu_vector(NUM_MU_CHANS*NUM_MUONS_IN-1 downto 0);
  signal sMuonsB     : TGMTMu_vector(35 downto 0);
  signal sMuonsO     : TGMTMu_vector(35 downto 0);
  signal sMuonsF     : TGMTMu_vector(35 downto 0);
  signal sTracks     : TGMTMuTracks_vector(NUM_MU_CHANS-1 downto 0);
  signal sTracksB    : TGMTMuTracks_vector(11 downto 0);
  signal sTracksO    : TGMTMuTracks_vector(11 downto 0);
  signal sTracksF    : TGMTMuTracks_vector(11 downto 0);
  signal sEmpty      : std_logic_vector(NUM_MU_CHANS*NUM_MUONS_IN-1 downto 0);
  signal sEmptyB     : std_logic_vector(35 downto 0);
  signal sEmptyO     : std_logic_vector(35 downto 0);
  signal sEmptyF     : std_logic_vector(35 downto 0);
  signal sSortRanks  : TSortRank10_vector(NUM_MU_CHANS*NUM_MUONS_IN-1 downto 0);
  signal sSortRanksB : TSortRank10_vector(35 downto 0);
  signal sSortRanksO : TSortRank10_vector(35 downto 0);
  signal sSortRanksF : TSortRank10_vector(35 downto 0);
  signal sIndexBits  : TIndexBits_vector(NUM_MU_CHANS*NUM_MUONS_IN-1 downto 0);
  signal sIndexBitsB : TIndexBits_vector(35 downto 0);
  signal sIndexBitsO : TIndexBits_vector(35 downto 0);
  signal sIndexBitsF : TIndexBits_vector(35 downto 0);

  signal sIso       : TIsoBits_vector(7 downto 0);
  signal oMuons     : TGMTMu_vector(7 downto 0);
  signal oMuons_reg : TGMTMu_vector(7 downto 0);
  signal sIso_reg   : TIsoBits_vector(7 downto 0);

  signal sIntermediateMuonsB         : TGMTMu_vector(7 downto 0);
  signal sIntermediateMuonsO         : TGMTMu_vector(7 downto 0);
  signal sIntermediateMuonsF         : TGMTMu_vector(7 downto 0);
  signal sIntermediateMuonsB_reg     : TGMTMu_vector(7 downto 0);
  signal sIntermediateMuonsO_reg     : TGMTMu_vector(7 downto 0);
  signal sIntermediateMuonsF_reg     : TGMTMu_vector(7 downto 0);
  signal sIntermediateSortRanksB     : TSortRank10_vector(7 downto 0);
  signal sIntermediateSortRanksO     : TSortRank10_vector(7 downto 0);
  signal sIntermediateSortRanksF     : TSortRank10_vector(7 downto 0);
  signal sIntermediateSortRanksB_reg : TSortRank10_vector(7 downto 0);
  signal sIntermediateSortRanksO_reg : TSortRank10_vector(7 downto 0);
  signal sIntermediateSortRanksF_reg : TSortRank10_vector(7 downto 0);
  signal sFinalEnergies              : TCaloArea_vector(7 downto 0);
  signal sFinalEnergies_reg          : TCaloArea_vector(7 downto 0);

begin

  gpio    <= (others => '0');
  gpio_en <= (others => '0');

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

  muon_counter_reset_gen : entity work.muon_counter_reset
    port map (
      clk_ipb      => clk,
      rst          => rst_payload,
      ipb_in       => ipbw(N_SLV_MUON_COUNTER_RESET),
      ipb_out      => ipbr(N_SLV_MUON_COUNTER_RESET),
      ttc_command  => ctrs(4).ttc_cmd,  -- Using ctrs from one of the two central clock regions
      clk40        => clk_payload,
      mu_ctr_rst   => sMuCtrReset
    );

  -----------------------------------------------------------------------------
  -- Begin 240 MHz domain.
  -----------------------------------------------------------------------------

  muon_input_stage : entity work.muon_input
    generic map (
      NCHAN     => NCHAN
      )
    port map (
      clk_ipb      => clk,
      rst          => rst_loc,
      ipb_in       => ipbw(N_SLV_MUON_INPUT),
      ipb_out      => ipbr(N_SLV_MUON_INPUT),
      ctrs         => ctrs,
      clk240       => clk_p,
      clk40        => clk_payload,
      d            => d(NCHAN-1 downto 0),
      oMuons       => sMuons,
      oTracks      => sTracks,
      oEmpty       => sEmpty,
      oSortRanks   => sSortRanks,
      oValid       => sValid_muons,
      oCaloIdxBits => sCaloIndexBits
      );

  energy_input_stage : entity work.energy_input
    generic map (
      NCHAN     => NCHAN
      )
    port map (
      clk_ipb   => clk,
      rst       => rst_loc,
      ipb_in    => ipbw(N_SLV_ENERGY_INPUT),
      ipb_out   => ipbr(N_SLV_ENERGY_INPUT),
      ctrs      => ctrs,
      clk240    => clk_p,
      clk40     => clk_payload,
      d         => d(NCHAN-1 downto 0),
      oEnergies => sEnergies,
      oValid    => sValid_energies
      );

  -----------------------------------------------------------------------------
  -- End 240 MHz domain.
  -----------------------------------------------------------------------------

  sValid_buffer(0) <= sValid_muons_reg or sValid_energies_reg;

  -----------------------------------------------------------------------------
  -- Begin 40 MHz domain.
  -----------------------------------------------------------------------------

  delay_valid_bit : process(clk_payload)
  begin  -- process delay_valid_bit
    if clk_payload'event and clk_payload = '1' then  -- rising clock edge
      sValid_muons_reg                           <= sValid_muons;
      sValid_energies_reg                        <= sValid_energies;
      sValid_buffer(sValid_buffer'high downto 1) <= sValid_buffer(sValid_buffer'high-1 downto 0);
    end if;
  end process delay_valid_bit;


  gmt_index_comp : process (clk_payload)
  begin  -- process gmt_index_comp
    if clk_payload'event and clk_payload = '1' then  -- rising clock edge
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
        clk => clk,
        reset => rst,
        ipbus_in => ipbw(N_SLV_INPUT_DISABLE_REG),
        ipbus_out => ipbr(N_SLV_INPUT_DISABLE_REG),
        q => sInputDisable
    );

  disable_inputs : process (sEmpty, sEnergies_tmp, sInputDisable)
  begin
      if sInputDisable(0)(0) = '1' then -- disable energies
          for i in sEnergies_fin'range loop
              sEnergies_fin(i) <= (others => "00000");
          end loop;
      else
          sEnergies_fin <= sEnergies_tmp;
      end if;

      ---- Disabling barrel ----
      if sInputDisable(0)(1) = '1' then -- disable barrel
          sEmptyB <= (others => '1');
      else
          sEmptyB <= sEmpty((BARREL_HIGH+1)*3-1 downto BARREL_LOW*NUM_MUONS_IN);
      end if;

      ---- Disable overlap ----
      if sInputDisable(0)(2) = '1' then -- disable ovl pos
          sEmptyO_plus <= (others => '1');
      else
          sEmptyO_plus <= sEmpty((OVL_POS_HIGH+1)*3-1 downto OVL_POS_LOW*NUM_MUONS_IN);
      end if;

      if sInputDisable(0)(3) = '1' then -- disable ovl neg
          sEmptyO_minus <= (others => '1');
      else
          sEmptyO_minus <= sEmpty((OVL_NEG_HIGH+1)*3-1 downto OVL_NEG_LOW*NUM_MUONS_IN);
      end if;

      ---- Disable forward ----
      if sInputDisable(0)(4) = '1' then -- disable fwd pos
          sEmptyF_plus <= (others => '1');
      else
          sEmptyF_plus <= sEmpty((FWD_POS_HIGH+1)*3-1 downto FWD_POS_LOW*NUM_MUONS_IN);
      end if;

      if sInputDisable(0)(5) = '1' then -- disable fwd neg
          sEmptyF_minus <= (others => '1');
      else
          sEmptyF_minus <= sEmpty((FWD_NEG_HIGH+1)*3-1 downto FWD_NEG_LOW*NUM_MUONS_IN);
      end if;
  end process disable_inputs;

  sMuonsB <= sMuons((BARREL_HIGH+1)*3-1 downto BARREL_LOW*NUM_MUONS_IN);
  sMuonsO <= sMuons((OVL_NEG_HIGH+1)*3-1 downto OVL_NEG_LOW*NUM_MUONS_IN) & sMuons((OVL_POS_HIGH+1)*3-1 downto OVL_POS_LOW*NUM_MUONS_IN);
  sMuonsF <= sMuons((FWD_NEG_HIGH+1)*3-1 downto FWD_NEG_LOW*NUM_MUONS_IN) & sMuons((FWD_POS_HIGH+1)*3-1 downto FWD_POS_LOW*NUM_MUONS_IN);

  sTracksB <= sTracks(BARREL_HIGH downto BARREL_LOW);
  sTracksO <= sTracks(OVL_NEG_HIGH downto OVL_NEG_LOW) & sTracks(OVL_POS_HIGH downto OVL_POS_LOW);
  sTracksF <= sTracks(FWD_NEG_HIGH downto FWD_NEG_LOW) & sTracks(FWD_POS_HIGH downto FWD_POS_LOW);

  sIndexBitsB <= sIndexBits((BARREL_HIGH+1)*3-1 downto BARREL_LOW*NUM_MUONS_IN);
  sIndexBitsO <= sIndexBits((OVL_NEG_HIGH+1)*3-1 downto OVL_NEG_LOW*NUM_MUONS_IN) & sIndexBits((OVL_POS_HIGH+1)*3-1 downto OVL_POS_LOW*NUM_MUONS_IN);
  sIndexBitsF <= sIndexBits((FWD_NEG_HIGH+1)*3-1 downto FWD_NEG_LOW*NUM_MUONS_IN) & sIndexBits((FWD_POS_HIGH+1)*3-1 downto FWD_POS_LOW*NUM_MUONS_IN);

  sCaloIndexBitsB <= sCaloIndexBits((BARREL_HIGH+1)*3-1 downto BARREL_LOW*NUM_MUONS_IN);
  sCaloIndexBitsO <= sCaloIndexBits((OVL_NEG_HIGH+1)*3-1 downto OVL_NEG_LOW*NUM_MUONS_IN) & sCaloIndexBits((OVL_POS_HIGH+1)*3-1 downto OVL_POS_LOW*NUM_MUONS_IN);
  sCaloIndexBitsF <= sCaloIndexBits((FWD_NEG_HIGH+1)*3-1 downto FWD_NEG_LOW*NUM_MUONS_IN) & sCaloIndexBits((FWD_POS_HIGH+1)*3-1 downto FWD_POS_LOW*NUM_MUONS_IN);

  sEmptyO <= sEmptyO_minus & sEmptyO_plus;
  sEmptyF <= sEmptyF_minus & sEmptyF_plus;

  sSortRanksB <= sSortRanks((BARREL_HIGH+1)*3-1 downto BARREL_LOW*NUM_MUONS_IN);
  sSortRanksO <= sSortRanks((OVL_NEG_HIGH+1)*3-1 downto OVL_NEG_LOW*NUM_MUONS_IN) & sSortRanks((OVL_POS_HIGH+1)*3-1 downto OVL_POS_LOW*NUM_MUONS_IN);
  sSortRanksF <= sSortRanks((FWD_NEG_HIGH+1)*3-1 downto FWD_NEG_LOW*NUM_MUONS_IN) & sSortRanks((FWD_POS_HIGH+1)*3-1 downto FWD_POS_LOW*NUM_MUONS_IN);

  sEnergies_tmp(sEnergies_tmp'high-4 downto 0) <= sEnergies;
  sEnergies_tmp(sEnergies_tmp'high-3)          <= (others => "00000");
  sEnergies_tmp(sEnergies_tmp'high-2)          <= (others => "00000");
  sEnergies_tmp(sEnergies_tmp'high-1)          <= (others => "00000");
  sEnergies_tmp(sEnergies_tmp'high)            <= (others => "00000");

  uGMT : entity work.GMT
    port map (
      iMuonsB           => sMuonsB,
      iMuonsO           => sMuonsO,
      iMuonsF           => sMuonsF,
      iTracksB          => sTracksB,
      iTracksO          => sTracksO,
      iTracksF          => sTracksF,
      iSortRanksB       => sSortRanksB,
      iSortRanksO       => sSortRanksO,
      iSortRanksF       => sSortRanksF,
      iIdxBitsB         => sIndexBitsB,
      iIdxBitsO         => sIndexBitsO,
      iIdxBitsF         => sIndexBitsF,
      iCaloIdxBitsB     => sCaloIndexBitsB,
      iCaloIdxBitsO     => sCaloIndexBitsO,
      iCaloIdxBitsF     => sCaloIndexBitsF,
      iEmptyB           => sEmptyB,
      iEmptyO           => sEmptyO,
      iEmptyF           => sEmptyF,

      iEnergies => sEnergies_fin,

      oIntermediateMuonsB     => sIntermediateMuonsB,
      oIntermediateMuonsO     => sIntermediateMuonsO,
      oIntermediateMuonsF     => sIntermediateMuonsF,
      oIntermediateSortRanksB => sIntermediateSortRanksB,
      oIntermediateSortRanksO => sIntermediateSortRanksO,
      oIntermediateSortRanksF => sIntermediateSortRanksF,
      oFinalEnergies          => sFinalEnergies,

      oMuons => oMuons,
      oIso   => sIso,

      clk     => clk_payload,
      clk_ipb => clk,
      sinit   => rst_payload,
      rst_loc => rst_loc,
      ipb_in  => ipbw(N_SLV_UGMT),
      ipb_out => ipbr(N_SLV_UGMT)
      );

  gmt_out_reg : process (clk_payload)
  begin  -- process gmt_out_reg
    if clk_payload'event and clk_payload = '1' then  -- rising clock edge
      sIso_reg   <= sIso;
      oMuons_reg <= oMuons;

      sIntermediateMuonsO_reg     <= sIntermediateMuonsO;
      sIntermediateMuonsB_reg     <= sIntermediateMuonsB;
      sIntermediateMuonsF_reg     <= sIntermediateMuonsF;
      sIntermediateSortRanksB_reg <= sIntermediateSortRanksB;
      sIntermediateSortRanksO_reg <= sIntermediateSortRanksO;
      sIntermediateSortRanksF_reg <= sIntermediateSortRanksF;
      sFinalEnergies_reg          <= sFinalEnergies;
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
      clk240               => clk_p,
      clk40                => clk_payload,
      rst                  => rst_payload,
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
      q                    => q((NUM_OUT_CHANS+NUM_INTERM_MU_OUT_CHANS+NUM_INTERM_SRT_OUT_CHANS+NUM_INTERM_ENERGY_OUT_CHANS+NUM_EXTRAP_COORDS_OUT_CHANS)-1 downto 0));

  strobe_high : for i in q'high downto (NUM_OUT_CHANS+NUM_INTERM_MU_OUT_CHANS+NUM_INTERM_SRT_OUT_CHANS+NUM_INTERM_ENERGY_OUT_CHANS+NUM_EXTRAP_COORDS_OUT_CHANS) generate
        q(i).strobe <= '1';
  end generate;

end rtl;
