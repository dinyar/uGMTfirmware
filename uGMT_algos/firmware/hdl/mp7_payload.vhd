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

  function MAX (LEFT, RIGHT: INTEGER) return INTEGER is
  begin
    if LEFT > RIGHT then return LEFT;
    else return RIGHT;
    end if;
  end MAX;

  signal ipbw : ipb_wbus_array(N_SLAVES - 1 downto 0);
  signal ipbr : ipb_rbus_array(N_SLAVES - 1 downto 0);

  type TBGoBuffer is array(natural range <>) of ttc_stuff_array(N_REGION - 1 downto 0);
  -- Currently our master latency is ~39 BX. Making sure we can absorb a significant latency increase.
  signal sBGoDelay_reg_v : ipb_reg_v(0 downto 0);
  signal sBGoDelay       : unsigned(5 downto 0); -- Pointer to position in BGo buffer.
  signal sBCres          : std_logic;

  signal sTrigger     : std_logic := '0';
  signal sTrigger_reg : std_logic := '0';

  constant GMT_ALGO_LATENCY     : natural := 4;
  -- Valid bits delayed less than algo latency due to one register before and
  -- requirement to be 1 bx early in serializer.
  signal   sValid_buffer        : std_logic_vector(GMT_ALGO_LATENCY-3 downto 0);
  signal   sValid_muons         : std_logic;
  signal   sValid_energies      : std_logic;

  -- Muon counter reset signal
  signal sMuCtrReset : std_logic_vector(N_REGION - 1 downto 0);

  -- Register to disable/enable inputs
  signal sBmtfDisable : ipb_reg_v(0 downto 0);
  signal sOmtfDisable : ipb_reg_v(0 downto 0);
  signal sEmtfDisable : ipb_reg_v(0 downto 0);
  signal sCaloDisable : ipb_reg_v(0 downto 0);

  signal sMuonDisable : std_logic_vector(NUM_MU_CHANS-1 downto 0);

  signal sEnergies     : TCaloRegionEtaSlice_vector(27 downto 0);  -- All energies from Calo trigger.
  signal sEnergies_tmp : TCaloRegionEtaSlice_vector(31 downto 0);
  signal sEnergies_fin : TCaloRegionEtaSlice_vector(31 downto 0);

  signal sCaloIndexBits : TCaloIndexBit_vector(NUM_MU_CHANS*NUM_MUONS_IN-1 downto 0);
  signal sCaloIndexBitsB : TCaloIndexBit_vector(35 downto 0);
  signal sCaloIndexBitsO : TCaloIndexBit_vector(35 downto 0);
  signal sCaloIndexBitsE : TCaloIndexBit_vector(35 downto 0);

  signal sMuons      : TGMTMu_vector(NUM_MU_CHANS*NUM_MUONS_IN-1 downto 0);
  signal sMuonsB     : TGMTMu_vector(35 downto 0);
  signal sMuonsO     : TGMTMu_vector(35 downto 0);
  signal sMuonsE     : TGMTMu_vector(35 downto 0);
  signal sTracks     : TGMTMuTracks_vector(NUM_MU_CHANS-1 downto 0);
  signal sTracksB    : TGMTMuTracks_vector(11 downto 0);
  signal sTracksO    : TGMTMuTracks_vector(11 downto 0);
  signal sTracksE    : TGMTMuTracks_vector(11 downto 0);
  signal sSortRanks  : TSortRank10_vector(NUM_MU_CHANS*NUM_MUONS_IN-1 downto 0);
  signal sSortRanksB : TSortRank10_vector(35 downto 0);
  signal sSortRanksO : TSortRank10_vector(35 downto 0);
  signal sSortRanksE : TSortRank10_vector(35 downto 0);
  signal sIndexBits  : TIndexBits_vector(NUM_MU_CHANS*NUM_MUONS_IN-1 downto 0);
  signal sIndexBitsB : TIndexBits_vector(35 downto 0);
  signal sIndexBitsO : TIndexBits_vector(35 downto 0);
  signal sIndexBitsE : TIndexBits_vector(35 downto 0);

  signal sIso       : TIsoBits_vector(7 downto 0);
  signal oMuons     : TGMTMu_vector(7 downto 0);
  signal oMuons_reg : TGMTMu_vector(8*OUTPUT_QUAD_ASSIGNMENT'length - 1 downto 0);

  signal sMuIdxBits     : TIndexBits_vector (7 downto 0);
  signal sMuIdxBits_reg : TIndexBits_vector (8*OUTPUT_QUAD_ASSIGNMENT'length - 1 downto 0);

  signal sIntermediateMuonsB         : TGMTMu_vector(7 downto 0);
  signal sIntermediateMuonsO         : TGMTMu_vector(7 downto 0);
  signal sIntermediateMuonsE         : TGMTMu_vector(7 downto 0);
  signal sIntermediateMuonsB_reg     : TGMTMu_vector(7 downto 0);
  signal sIntermediateMuonsO_reg     : TGMTMu_vector(7 downto 0);
  signal sIntermediateMuonsE_reg     : TGMTMu_vector(7 downto 0);

  signal sQ : ldata(q'range);

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

  bgo_delay_reg : entity work.ipbus_reg_setable
    generic map(
      N_REG => 1,
      INIT  => std_logic_vector(to_unsigned(BGO_DELAY, 32))
    )
    port map(
      clk       => clk,
      reset     => rst,
      ipbus_in  => ipbw(N_SLV_BGO_DELAY_REG),
      ipbus_out => ipbr(N_SLV_BGO_DELAY_REG),
      q         => sBGoDelay_reg_v
    );

  sBGoDelay <= unsigned(std_logic_vector(sBGoDelay_reg_v(0)(5 downto 0)));

  -- Generating BCres signal 4 clocks early due to delays. (1 clock in below logic + 3 clocks in muon_counter_reset_gen)
  delay_bgos : process(clk_payload)
    variable bctrAdjusted : unsigned(11 downto 0);
  begin  -- process delay_bgos
    if clk_payload'event and clk_payload = '1' then  -- rising clock edge
      if unsigned(ctrs(4).bctr) < sBGoDelay+4 then
        bctrAdjusted := to_unsigned(3564, ctrs(4).bctr'length)+unsigned(ctrs(4).bctr)-sBGoDelay-4;
      else
        bctrAdjusted := unsigned(ctrs(4).bctr)-sBGoDelay-4;
      end if;

      if bctrAdjusted = 0 then
        sBCres <= '1';
      else
        sBCres <= '0';
      end if;
    end if;
  end process delay_bgos;

  muon_counter_reset_gen : entity work.muon_counter_reset
    port map (
      clk_ipb     => clk,
      rst         => rst_payload,
      ipb_in      => ipbw(N_SLV_MUON_COUNTER_RESET),
      ipb_out     => ipbr(N_SLV_MUON_COUNTER_RESET),
      ttc_command => ctrs(4).ttc_cmd,  -- Using ctrs from one of the two central clock regions
      iBCres      => sBCres,  -- Using delayed BC0 to synchronize with 'data orbit'
      clk40       => clk_payload,
      mu_ctr_rst  => sMuCtrReset
    );

  disable_bmtf_inputs_reg : entity work.ipbus_reg_v
    generic map(
      N_REG => 1
    )
    port map(
      clk => clk,
      reset => rst,
      ipbus_in => ipbw(N_SLV_BMTF_DISABLE_REG),
      ipbus_out => ipbr(N_SLV_BMTF_DISABLE_REG),
      q => sBmtfDisable
    );
  disable_omtf_inputs_reg : entity work.ipbus_reg_v
    generic map(
      N_REG => 1
    )
    port map(
      clk => clk,
      reset => rst,
      ipbus_in => ipbw(N_SLV_OMTF_DISABLE_REG),
      ipbus_out => ipbr(N_SLV_OMTF_DISABLE_REG),
      q => sOmtfDisable
    );
  disable_emtf_inputs_reg : entity work.ipbus_reg_v
    generic map(
      N_REG => 1
    )
    port map(
      clk => clk,
      reset => rst,
      ipbus_in => ipbw(N_SLV_EMTF_DISABLE_REG),
      ipbus_out => ipbr(N_SLV_EMTF_DISABLE_REG),
      q => sEmtfDisable
    );
  disable_calo_inputs_reg : entity work.ipbus_reg_v
    generic map(
      N_REG => 1
    )
    port map(
      clk => clk,
      reset => rst,
      ipbus_in => ipbw(N_SLV_CALO_DISABLE_REG),
      ipbus_out => ipbr(N_SLV_CALO_DISABLE_REG),
      q => sCaloDisable
    );

  sMuonDisable <= sEmtfDisable(0)(11 downto 6) & sOmtfDisable(0)(11 downto 6) & sBmtfDisable(0)(11 downto 0) & sOmtfDisable(0)(5 downto 0) & sEmtfDisable(0)(5 downto 0);

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
      iBGoDelay    => sBGoDelay,
      mu_ctr_rst   => sMuCtrReset,
      clk240       => clk_p,
      clk40        => clk_payload,
      d            => d(NCHAN-1 downto 0),
      iDisable     => sMuonDisable,
      oMuons       => sMuons,
      oTracks      => sTracks,
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
      iBGoDelay => sBGoDelay,
      clk240    => clk_p,
      clk40     => clk_payload,
      d         => d(NCHAN-1 downto 0),
      iDisable  => sCaloDisable(0)(NUM_CALO_CHANS-1 downto 0),
      oEnergies => sEnergies,
      oValid    => sValid_energies
      );

  -----------------------------------------------------------------------------
  -- End 240 MHz domain.
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- Begin 40 MHz domain.
  -----------------------------------------------------------------------------

  delay_valid_bit : process(clk_payload)
  begin  -- process delay_valid_bit
    if clk_payload'event and clk_payload = '1' then  -- rising clock edge
      sValid_buffer(0)                           <= sValid_muons;
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

  sMuonsB <= sMuons((BMTF_HIGH+1)*3-1 downto BMTF_LOW*NUM_MUONS_IN);
  sMuonsO <= sMuons((OMTF_NEG_HIGH+1)*3-1 downto OMTF_NEG_LOW*NUM_MUONS_IN) & sMuons((OMTF_POS_HIGH+1)*3-1 downto OMTF_POS_LOW*NUM_MUONS_IN);
  sMuonsE <= sMuons((EMTF_NEG_HIGH+1)*3-1 downto EMTF_NEG_LOW*NUM_MUONS_IN) & sMuons((EMTF_POS_HIGH+1)*3-1 downto EMTF_POS_LOW*NUM_MUONS_IN);

  sTracksB <= sTracks(BMTF_HIGH downto BMTF_LOW);
  sTracksO <= sTracks(OMTF_NEG_HIGH downto OMTF_NEG_LOW) & sTracks(OMTF_POS_HIGH downto OMTF_POS_LOW);
  sTracksE <= sTracks(EMTF_NEG_HIGH downto EMTF_NEG_LOW) & sTracks(EMTF_POS_HIGH downto EMTF_POS_LOW);

  sIndexBitsB <= sIndexBits((BMTF_HIGH+1)*3-1 downto BMTF_LOW*NUM_MUONS_IN);
  sIndexBitsO <= sIndexBits((OMTF_NEG_HIGH+1)*3-1 downto OMTF_NEG_LOW*NUM_MUONS_IN) & sIndexBits((OMTF_POS_HIGH+1)*3-1 downto OMTF_POS_LOW*NUM_MUONS_IN);
  sIndexBitsE <= sIndexBits((EMTF_NEG_HIGH+1)*3-1 downto EMTF_NEG_LOW*NUM_MUONS_IN) & sIndexBits((EMTF_POS_HIGH+1)*3-1 downto EMTF_POS_LOW*NUM_MUONS_IN);

  sCaloIndexBitsB <= sCaloIndexBits((BMTF_HIGH+1)*3-1 downto BMTF_LOW*NUM_MUONS_IN);
  sCaloIndexBitsO <= sCaloIndexBits((OMTF_NEG_HIGH+1)*3-1 downto OMTF_NEG_LOW*NUM_MUONS_IN) & sCaloIndexBits((OMTF_POS_HIGH+1)*3-1 downto OMTF_POS_LOW*NUM_MUONS_IN);
  sCaloIndexBitsE <= sCaloIndexBits((EMTF_NEG_HIGH+1)*3-1 downto EMTF_NEG_LOW*NUM_MUONS_IN) & sCaloIndexBits((EMTF_POS_HIGH+1)*3-1 downto EMTF_POS_LOW*NUM_MUONS_IN);

  sSortRanksB <= sSortRanks((BMTF_HIGH+1)*3-1 downto BMTF_LOW*NUM_MUONS_IN);
  sSortRanksO <= sSortRanks((OMTF_NEG_HIGH+1)*3-1 downto OMTF_NEG_LOW*NUM_MUONS_IN) & sSortRanks((OMTF_POS_HIGH+1)*3-1 downto OMTF_POS_LOW*NUM_MUONS_IN);
  sSortRanksE <= sSortRanks((EMTF_NEG_HIGH+1)*3-1 downto EMTF_NEG_LOW*NUM_MUONS_IN) & sSortRanks((EMTF_POS_HIGH+1)*3-1 downto EMTF_POS_LOW*NUM_MUONS_IN);

  sEnergies_fin(sEnergies_fin'high-4 downto 0) <= sEnergies;
  sEnergies_fin(sEnergies_fin'high-3)          <= (others => "00000");
  sEnergies_fin(sEnergies_fin'high-2)          <= (others => "00000");
  sEnergies_fin(sEnergies_fin'high-1)          <= (others => "00000");
  sEnergies_fin(sEnergies_fin'high)            <= (others => "00000");

  uGMT : entity work.GMT
    port map (
      iMuonsB           => sMuonsB,
      iMuonsO           => sMuonsO,
      iMuonsE           => sMuonsE,
      iTracksB          => sTracksB,
      iTracksO          => sTracksO,
      iTracksE          => sTracksE,
      iSortRanksB       => sSortRanksB,
      iSortRanksO       => sSortRanksO,
      iSortRanksE       => sSortRanksE,
      iIdxBitsB         => sIndexBitsB,
      iIdxBitsO         => sIndexBitsO,
      iIdxBitsE         => sIndexBitsE,
      iCaloIdxBitsB     => sCaloIndexBitsB,
      iCaloIdxBitsO     => sCaloIndexBitsO,
      iCaloIdxBitsE     => sCaloIndexBitsE,

      iEnergies => sEnergies_fin,

      oIntermediateMuonsB     => sIntermediateMuonsB,
      oIntermediateMuonsO     => sIntermediateMuonsO,
      oIntermediateMuonsE     => sIntermediateMuonsE,
      oIntermediateSortRanksB => open,
      oIntermediateSortRanksO => open,
      oIntermediateSortRanksE => open,

      oMuIdxBits => sMuIdxBits,

      oMuons => oMuons,
      oIso   => sIso,

      mu_ctr_rst   => sMuCtrReset(4),
      clk          => clk_payload,
      clk_ipb      => clk,
      sinit        => rst_payload,
      rst_loc      => rst_loc,
      ipb_in       => ipbw(N_SLV_UGMT),
      ipb_out      => ipbr(N_SLV_UGMT)
      );

  generate_lemo_signals : entity work.generate_lemo_signals
    port map (
      clk_ipb   => clk,
      ipb_in    => ipbw(N_SLV_GENERATE_LEMO_SIGNALS),
      ipb_out   => ipbr(N_SLV_GENERATE_LEMO_SIGNALS),
      clk       => clk_payload,
      rst       => rst_payload,
      iMuons    => oMuons,
      iBGoDelay => sBGoDelay,
      iBctr     => ctrs(4).bctr,  -- Using ctrs from one of the two central clock regions
      iValid    => sValid_muons,
      oTrigger  => sTrigger,
      gpio      => gpio,
      gpio_en   => gpio_en
      );

  gmt_out_reg : process (clk_payload)
  begin  -- process gmt_out_reg
    if clk_payload'event and clk_payload = '1' then  -- rising clock edge
      for i in OUTPUT_QUAD_ASSIGNMENT'range loop 
        oMuons_reg(8*i+7 downto 8*i)     <= oMuons;
        sMuIdxBits_reg(8*i+7 downto 8*i) <= sMuIdxBits;
      end loop;

      sIntermediateMuonsO_reg <= sIntermediateMuonsO;
      sIntermediateMuonsB_reg <= sIntermediateMuonsB;
      sIntermediateMuonsE_reg <= sIntermediateMuonsE;

      sTrigger_reg <= sTrigger;
    end if;
  end process gmt_out_reg;

  -----------------------------------------------------------------------------
  -- End 40 MHz domain.
  -----------------------------------------------------------------------------

  -- Now pass result from uGMT back in serialized fashion.
  -----------------------------------------------------------------------------
  -- Begin 240 MHz domain.
  -----------------------------------------------------------------------------

  spy_buffer : entity work.spy_buffer_control
    port map (
      clk_ipb  => clk,
      rst      => rst,
      ipb_in   => ipbw(N_SLV_SPY_BUFFER_CONTROL),
      ipb_out  => ipbr(N_SLV_SPY_BUFFER_CONTROL),
      clk40    => clk_payload,
      clk240   => clk_p,
      iTrigger => sTrigger_reg,
      q        => sQ(NUM_OUT_CHANS-1 downto 0)
      );

  serialize : entity work.serializer_stage
    port map (
      clk240               => clk_p,
      clk40                => clk_payload,
      rst                  => rst_loc,
      iValidMuons          => sValid_buffer(sValid_buffer'high),
      iValidEnergies       => sValid_energies,
      iMuons               => oMuons_reg,
      iMuIdxBits           => sMuIdxBits_reg,
      iIso                 => sIso,
      iIntermediateMuonsB  => sIntermediateMuonsB_reg,
      iIntermediateMuonsO  => sIntermediateMuonsO_reg,
      iIntermediateMuonsE  => sIntermediateMuonsE_reg,
      q                    => sQ
      );

  q <= sQ;

end rtl;
