-- Sort and Cancel unit

library ieee;
use ieee.std_logic_1164.all;
use ieee.NUMERIC_STD.all;

use work.mp7_data_types.all;
use work.ipbus.all;
use work.ipbus_reg_types.all;
use work.ipbus_decode_sorting.all;

use work.GMTTypes.all;
use work.ugmt_constants.all;
use work.mp7_brd_decl.all;

entity SortAndCancelUnit is
  port (
    iMuonsB : in TGMTMu_vector(35 downto 0);
    iMuonsO : in TGMTMu_vector(35 downto 0);
    iMuonsE : in TGMTMu_vector(35 downto 0);

    iTracksB : in TGMTMuTracks_vector(11 downto 0);
    iTracksO : in TGMTMuTracks_vector(11 downto 0);
    iTracksE : in TGMTMuTracks_vector(11 downto 0);

    iSortRanksB : in TSortRank10_vector(35 downto 0);
    iSortRanksO : in TSortRank10_vector(35 downto 0);
    iSortRanksE : in TSortRank10_vector(35 downto 0);

    iIdxBitsB : in TIndexBits_vector(35 downto 0);
    iIdxBitsO : in TIndexBits_vector(35 downto 0);
    iIdxBitsE : in TIndexBits_vector(35 downto 0);

    oIntermediateMuonsB     : out TGMTMu_vector(7 downto 0);
    oIntermediateMuonsO     : out TGMTMu_vector(7 downto 0);
    oIntermediateMuonsE     : out TGMTMu_vector(7 downto 0);
    oIntermediateSortRanksB : out TSortRank10_vector(7 downto 0);
    oIntermediateSortRanksO : out TSortRank10_vector(7 downto 0);
    oIntermediateSortRanksE : out TSortRank10_vector(7 downto 0);

    oIdxBits : out TIndexBits_vector(7 downto 0);
    oMuPt    : out TMuonPT_vector(7 downto 0);
    oMuons   : out TGMTMu_vector(7 downto 0);

    -- Clock and control
    mu_ctr_rst : in  std_logic;
    clk        : in  std_logic;
    clk_ipb    : in  std_logic;
    sinit      : in  std_logic;
    rst_loc    : in  std_logic_vector(N_REGION - 1 downto 0);
    ipb_in     : in  ipb_wbus;
    ipb_out    : out ipb_rbus
    );
end;

architecture behavioral of SortAndCancelUnit is
  -- IPbus
  signal ipbw : ipb_wbus_array(N_SLAVES - 1 downto 0);
  signal ipbr : ipb_rbus_array(N_SLAVES - 1 downto 0);

  signal ipbw_dummy : ipb_wbus;

  signal sMuonsO_plus  : TGMTMu_vector(17 downto 0);
  signal sMuonsO_minus : TGMTMu_vector(17 downto 0);
  signal sMuonsE_plus  : TGMTMu_vector(17 downto 0);
  signal sMuonsE_minus : TGMTMu_vector(17 downto 0);

  signal sTracksO_plus  : TGMTMuTracks_vector(5 downto 0);
  signal sTracksO_minus : TGMTMuTracks_vector(5 downto 0);
  signal sTracksE_plus  : TGMTMuTracks_vector(5 downto 0);
  signal sTracksE_minus : TGMTMuTracks_vector(5 downto 0);

  signal sSortRanksO_plus       : TSortRank10_vector(17 downto 0);
  signal sIdxBitsO_plus         : TIndexBits_vector(17 downto 0);
  signal sSortedMuonsO_plus     : TGMTMu_vector(3 downto 0);
  signal sSortedIdxBitsO_plus   : TIndexBits_vector(3 downto 0);
  signal sSortedSortRanksO_plus : TSortRank10_vector(3 downto 0);
  signal sSortedEmptyO_plus     : std_logic_vector(3 downto 0);

  signal sSortRanksO_minus       : TSortRank10_vector(17 downto 0);
  signal sIdxBitsO_minus         : TIndexBits_vector(17 downto 0);
  signal sSortedMuonsO_minus     : TGMTMu_vector(3 downto 0);
  signal sSortedIdxBitsO_minus   : TIndexBits_vector(3 downto 0);
  signal sSortedSortRanksO_minus : TSortRank10_vector(3 downto 0);
  signal sSortedEmptyO_minus     : std_logic_vector(3 downto 0);

  signal sSortRanksE_plus       : TSortRank10_vector(17 downto 0);
  signal sIdxBitsE_plus         : TIndexBits_vector(17 downto 0);
  signal sSortedMuonsE_plus     : TGMTMu_vector(3 downto 0);
  signal sSortedIdxBitsE_plus   : TIndexBits_vector(3 downto 0);
  signal sSortedSortRanksE_plus : TSortRank10_vector(3 downto 0);
  signal sSortedEmptyE_plus     : std_logic_vector(3 downto 0);

  signal sSortRanksE_minus       : TSortRank10_vector(17 downto 0);
  signal sIdxBitsE_minus         : TIndexBits_vector(17 downto 0);
  signal sSortedMuonsE_minus     : TGMTMu_vector(3 downto 0);
  signal sSortedIdxBitsE_minus   : TIndexBits_vector(3 downto 0);
  signal sSortedSortRanksE_minus : TSortRank10_vector(3 downto 0);
  signal sSortedEmptyE_minus     : std_logic_vector(3 downto 0);

  signal sCancelB              : std_logic_vector(35 downto 0);
  signal sCancelO_plus         : std_logic_vector(17 downto 0);
  signal sCancelO_minus        : std_logic_vector(17 downto 0);
  signal sCancelE_plus         : std_logic_vector(17 downto 0);
  signal sCancelE_minus        : std_logic_vector(17 downto 0);
  signal sCancelBO_B_plus      : std_logic_vector(35 downto 0);
  signal sCancelBO_B_minus     : std_logic_vector(35 downto 0);
  signal sCancelBO_B           : std_logic_vector(35 downto 0);
  signal sCancelBO_O_plus      : std_logic_vector(17 downto 0);
  signal sCancelBO_O_minus     : std_logic_vector(17 downto 0);
  signal sCancelEO_E_plus      : std_logic_vector(17 downto 0);
  signal sCancelEO_E_minus     : std_logic_vector(17 downto 0);
  signal sCancelEO_O_plus      : std_logic_vector(17 downto 0);
  signal sCancelEO_O_minus     : std_logic_vector(17 downto 0);
  signal sCancelBO_O_plus_reg  : std_logic_vector(17 downto 0);
  signal sCancelBO_O_minus_reg : std_logic_vector(17 downto 0);
  signal sCancelEO_E_plus_reg  : std_logic_vector(17 downto 0);
  signal sCancelEO_E_minus_reg : std_logic_vector(17 downto 0);
  signal sCancelEO_O_plus_reg  : std_logic_vector(17 downto 0);
  signal sCancelEO_O_minus_reg : std_logic_vector(17 downto 0);
  signal sCancelB_reg          : std_logic_vector(35 downto 0);
  signal sCancelO_plus_reg     : std_logic_vector(17 downto 0);
  signal sCancelO_minus_reg    : std_logic_vector(17 downto 0);
  signal sCancelE_plus_reg     : std_logic_vector(17 downto 0);
  signal sCancelE_minus_reg    : std_logic_vector(17 downto 0);

  signal sSortedMuonsB     : TGMTMu_vector(7 downto 0);
  signal sSortedIdxBitsB   : TIndexBits_vector(7 downto 0);
  signal sSortedSortRanksB : TSortRank10_vector(7 downto 0);
  signal sSortedEmptyB     : std_logic_vector(7 downto 0);

  signal sSortedSortRanksB_reg : TSortRank10_vector(7 downto 0);
  signal sSortedSortRanksO_reg : TSortRank10_vector(7 downto 0);
  signal sSortedSortRanksE_reg : TSortRank10_vector(7 downto 0);
  signal sSortedEmptyB_reg     : std_logic_vector(7 downto 0);
  signal sSortedEmptyO_reg     : std_logic_vector(7 downto 0);
  signal sSortedEmptyE_reg     : std_logic_vector(7 downto 0);

  signal sSortedIdxBitsB_reg : TIndexBits_vector(7 downto 0);
  signal sSortedIdxBitsO_reg : TIndexBits_vector(7 downto 0);
  signal sSortedIdxBitsE_reg : TIndexBits_vector(7 downto 0);
  signal sSortedMuonsB_reg   : TGMTMu_vector(7 downto 0);
  signal sSortedMuonsO_reg   : TGMTMu_vector(7 downto 0);
  signal sSortedMuonsE_reg   : TGMTMu_vector(7 downto 0);

  signal sSortRanksB_store : TSortRank10_vector(7 downto 0);
  signal sSortRanksO_store : TSortRank10_vector(7 downto 0);
  signal sSortRanksE_store : TSortRank10_vector(7 downto 0);
  signal sEmptyB_store     : std_logic_vector(7 downto 0);
  signal sEmptyO_store     : std_logic_vector(7 downto 0);
  signal sEmptyE_store     : std_logic_vector(7 downto 0);

  signal sIdxBitsB_store : TIndexBits_vector(7 downto 0);
  signal sIdxBitsO_store : TIndexBits_vector(7 downto 0);
  signal sIdxBitsE_store : TIndexBits_vector(7 downto 0);
  signal sMuonsB_store   : TGMTMu_vector(7 downto 0);
  signal sMuonsO_store   : TGMTMu_vector(7 downto 0);
  signal sMuonsE_store   : TGMTMu_vector(7 downto 0);

  signal sSortRanksB_store2 : TSortRank10_vector(7 downto 0);
  signal sSortRanksO_store2 : TSortRank10_vector(7 downto 0);
  signal sSortRanksE_store2 : TSortRank10_vector(7 downto 0);
  signal sEmptyB_store2     : std_logic_vector(7 downto 0);
  signal sEmptyO_store2     : std_logic_vector(7 downto 0);
  signal sEmptyE_store2     : std_logic_vector(7 downto 0);

  signal sIdxBitsB_store2 : TIndexBits_vector(7 downto 0);
  signal sIdxBitsO_store2 : TIndexBits_vector(7 downto 0);
  signal sIdxBitsE_store2 : TIndexBits_vector(7 downto 0);
  signal sMuonsB_store2   : TGMTMu_vector(7 downto 0);
  signal sMuonsO_store2   : TGMTMu_vector(7 downto 0);
  signal sMuonsE_store2   : TGMTMu_vector(7 downto 0);

  signal sFinalMuons     : TGMTMu_vector(7 downto 0);
  signal sFinalMuons_reg : TGMTMu_vector(7 downto 0);

  signal sIdxBits : TIndexBits_vector(7 downto 0);

  -- For muon counters
  -- TODO: Possibly delay this signal by 2 BX more? Would be nice to have it synced with inputs.
  signal muon_counter_reset_reg : std_logic;

  constant NUM_LOCAL_SORTERS : natural := 5; -- Number of local sorters.
  -- One counter per local sorter (BMTF, OMTF+/-, EMTF +/-)
  type TEmtpyBits_vector is array (NUM_LOCAL_SORTERS-1 downto 0) of std_logic_vector(7 downto 0);
  signal sSortedEmptyBits     : TEmtpyBits_vector;
  signal sSortedEmptyBits_reg : TEmtpyBits_vector;

  type TLocalMuonCounter is array (NUM_LOCAL_SORTERS-1 downto 0) of unsigned(3 downto 0);
  type TMuonCounter is array (NUM_LOCAL_SORTERS-1 downto 0) of unsigned(31 downto 0);
  signal sMuonCounters       : TMuonCounter;
  signal sMuonCounters_store : ipb_reg_v(NUM_LOCAL_SORTERS-1 downto 0);

begin

  -- IPbus address decode
  fabric : entity work.ipbus_fabric_sel
    generic map(
      NSLV      => N_SLAVES,
      SEL_WIDTH => IPBUS_SEL_WIDTH
      )
    port map(
      ipb_in          => ipb_in,
      ipb_out         => ipb_out,
      sel             => ipbus_sel_sorting(ipb_in.ipb_addr),
      ipb_to_slaves   => ipbw,
      ipb_from_slaves => ipbr
      );

  sMuonsO_plus      <= iMuonsO(17 downto 0);
  sMuonsO_minus     <= iMuonsO(35 downto 18);
  sMuonsE_plus      <= iMuonsE(17 downto 0);
  sMuonsE_minus     <= iMuonsE(35 downto 18);
  sTracksO_plus     <= iTracksO(5 downto 0);
  sTracksO_minus    <= iTracksO(11 downto 6);
  sTracksE_plus     <= iTracksE(5 downto 0);
  sTracksE_minus    <= iTracksE(11 downto 6);
  sSortRanksO_plus  <= iSortRanksO(17 downto 0);
  sSortRanksO_minus <= iSortRanksO(35 downto 18);
  sSortRanksE_plus  <= iSortRanksE(17 downto 0);
  sSortRanksE_minus <= iSortRanksE(35 downto 18);
  sIdxBitsO_plus    <= iIdxBitsO(17 downto 0);
  sIdxBitsO_minus   <= iIdxBitsO(35 downto 18);
  sIdxBitsE_plus    <= iIdxBitsE(17 downto 0);
  sIdxBitsE_minus   <= iIdxBitsE(35 downto 18);

  -- Send all muons into CU units
  -- one unit for each wedge -> each unit needs to compare 2 OMTF mu with
  -- 2+2 other mu
  cou_bo_plus : entity work.CancelOutUnit_BO
    generic map (
        CANCEL_OUT_TYPE  => CANCEL_OUT_TYPE_BO,
        DATA_FILE        => CANCEL_OUT_DATA_FILE_BO_POS,
        LOCAL_PHI_OFFSET => LOCAL_PHI_OFFSET_BMTF
        )
    port map (
      clk_ipb     => clk_ipb,
      rst         => rst_loc(COU_BO_POS),
      ipb_in      => ipbw(N_SLV_COU_BO_POS),
      ipb_out     => ipbr(N_SLV_COU_BO_POS),
      iWedges_O   => sTracksO_plus,
      iWedges_B   => iTracksB,
      oCancel_O   => sCancelBO_O_plus,
      oCancel_B   => sCancelBO_B_plus,
      clk         => clk
      );
  cou_bo_minus : entity work.CancelOutUnit_BO
    generic map (
      CANCEL_OUT_TYPE  => CANCEL_OUT_TYPE_BO,
      DATA_FILE        => CANCEL_OUT_DATA_FILE_BO_NEG,
      LOCAL_PHI_OFFSET => LOCAL_PHI_OFFSET_BMTF
      )
    port map (
      clk_ipb     => clk_ipb,
      rst         => rst_loc(COU_BO_NEG),
      ipb_in      => ipbw(N_SLV_COU_BO_NEG),
      ipb_out     => ipbr(N_SLV_COU_BO_NEG),
      iWedges_O   => sTracksO_minus,
      iWedges_B   => iTracksB,
      oCancel_O   => sCancelBO_O_minus,
      oCancel_B   => sCancelBO_B_minus,
      clk         => clk
      );

  cou_eo_plus : entity work.CancelOutUnit_EO
    generic map (
      CANCEL_OUT_TYPE  => CANCEL_OUT_TYPE_EO,
      DATA_FILE        => CANCEL_OUT_DATA_FILE_EO_POS,
      LOCAL_PHI_OFFSET => LOCAL_PHI_OFFSET_OMTF_EMTF
      )
    port map (
      clk_ipb     => clk_ipb,
      rst         => rst_loc(COU_EO_POS),
      ipb_in      => ipbw(N_SLV_COU_EO_POS),
      ipb_out     => ipbr(N_SLV_COU_EO_POS),
      iWedges_O   => sTracksO_plus,
      iWedges_E   => sTracksE_plus,
      oCancel_O   => sCancelEO_O_plus,
      oCancel_E   => sCancelEO_E_plus,
      clk         => clk
      );
  cou_eo_minus : entity work.CancelOutUnit_EO
    generic map (
      CANCEL_OUT_TYPE  => CANCEL_OUT_TYPE_EO,
      DATA_FILE        => CANCEL_OUT_DATA_FILE_EO_NEG,
      LOCAL_PHI_OFFSET => LOCAL_PHI_OFFSET_OMTF_EMTF
      )
    port map (
      clk_ipb     => clk_ipb,
      rst         => rst_loc(COU_EO_NEG),
      ipb_in      => ipbw(N_SLV_COU_EO_NEG),
      ipb_out     => ipbr(N_SLV_COU_EO_NEG),
      iWedges_O   => sTracksO_minus,
      iWedges_E   => sTracksE_minus,
      oCancel_O   => sCancelEO_O_minus,
      oCancel_E   => sCancelEO_E_minus,
      clk         => clk
      );

  cou_b : entity work.CancelOutUnit_Single
    generic map (
      CANCEL_OUT_TYPE  => CANCEL_OUT_TYPE_BMTF,
      DATA_FILE        => CANCEL_OUT_DATA_FILE_BMTF,
      num_wedges       => 12,
      num_tracks       => 3,
      LOCAL_PHI_OFFSET => LOCAL_PHI_OFFSET_BMTF
      )
    port map (
      clk_ipb => clk_ipb,
      rst     => rst_loc(COU_BMTF),
      ipb_in  => ipbw_dummy,
      ipb_out => open,
      iWedges => iTracksB,
      oCancel => sCancelB,
      clk     => clk
      );
  cou_o_plus : entity work.CancelOutUnit_Single
    generic map (
      CANCEL_OUT_TYPE  => CANCEL_OUT_TYPE_OMTF,
      DATA_FILE        => CANCEL_OUT_DATA_FILE_OMTF_POS,
      num_wedges       => 6,
      num_tracks       => 3,
      LOCAL_PHI_OFFSET => LOCAL_PHI_OFFSET_OMTF_EMTF
      )
    port map (
      clk_ipb => clk_ipb,
      rst     => rst_loc(COU_OMTF_POS),
      ipb_in  => ipbw(N_SLV_COU_OMTF_POS),
      ipb_out => ipbr(N_SLV_COU_OMTF_POS),
      iWedges => sTracksO_plus,
      oCancel => sCancelO_plus,
      clk     => clk
      );
  cou_o_minus : entity work.CancelOutUnit_Single
    generic map (
      CANCEL_OUT_TYPE  => CANCEL_OUT_TYPE_OMTF,
      DATA_FILE        => CANCEL_OUT_DATA_FILE_OMTF_NEG,
      num_wedges       => 6,
      num_tracks       => 3,
      LOCAL_PHI_OFFSET => LOCAL_PHI_OFFSET_OMTF_EMTF
      )
    port map (
      clk_ipb => clk_ipb,
      rst     => rst_loc(COU_OMTF_NEG),
      ipb_in  => ipbw(N_SLV_COU_OMTF_NEG),
      ipb_out => ipbr(N_SLV_COU_OMTF_NEG),
      iWedges => sTracksO_minus,
      oCancel => sCancelO_minus,
      clk     => clk
      );
  cou_e_plus : entity work.CancelOutUnit_Single
    generic map (
      CANCEL_OUT_TYPE  => CANCEL_OUT_TYPE_EMTF,
      DATA_FILE        => CANCEL_OUT_DATA_FILE_EMTF_POS,
      num_wedges       => 6,
      num_tracks       => 3,
      LOCAL_PHI_OFFSET => LOCAL_PHI_OFFSET_OMTF_EMTF
      )
    port map (
      clk_ipb => clk_ipb,
      rst     => rst_loc(COU_EMTF_POS),
      ipb_in  => ipbw(N_SLV_COU_EMTF_POS),
      ipb_out => ipbr(N_SLV_COU_EMTF_POS),
      iWedges => sTracksE_plus,
      oCancel => sCancelE_plus,
      clk     => clk
      );
  cou_e_minus : entity work.CancelOutUnit_Single
    generic map (
      CANCEL_OUT_TYPE  => CANCEL_OUT_TYPE_EMTF,
      DATA_FILE        => CANCEL_OUT_DATA_FILE_EMTF_NEG,
      num_wedges       => 6,
      num_tracks       => 3,
      LOCAL_PHI_OFFSET => LOCAL_PHI_OFFSET_OMTF_EMTF
      )
    port map (
      clk_ipb => clk_ipb,
      rst     => rst_loc(COU_EMTF_NEG),
      ipb_in  => ipbw(N_SLV_COU_EMTF_NEG),
      ipb_out => ipbr(N_SLV_COU_EMTF_NEG),
      iWedges => sTracksE_minus,
      oCancel => sCancelE_minus,
      clk     => clk
      );

  sCancelBO_B <= sCancelBO_B_plus or sCancelBO_B_minus;

  register_cobits_pairs : process (clk)
  begin  -- process register_cobits
    if clk'event and clk = '1' then     -- rising clock edge
      sCancelBO_O_plus_reg  <= sCancelBO_O_plus;
      sCancelBO_O_minus_reg <= sCancelBO_O_minus;
      sCancelEO_E_plus_reg  <= sCancelEO_E_plus;
      sCancelEO_E_minus_reg <= sCancelEO_E_minus;
      sCancelEO_O_plus_reg  <= sCancelEO_O_plus;
      sCancelEO_O_minus_reg <= sCancelEO_O_minus;
      sCancelB_reg          <= sCancelB;
      sCancelO_plus_reg     <= sCancelO_plus;
      sCancelO_minus_reg    <= sCancelO_minus;
      sCancelE_plus_reg     <= sCancelE_plus;
      sCancelE_minus_reg    <= sCancelE_minus;

    end if;
  end process register_cobits_pairs;

  -- Sort muons separately first, have ports for CU info
  sortB : entity work.SortStage0
    port map (
      iSortRanks => iSortRanksB,
      iCancel_A  => sCancelB,
      iCancel_B  => sCancelBO_B,
      iCancel_C  => (others => '0'),
      iMuons     => iMuonsB,
      iIdxBits   => iIdxBitsB,
      oMuons     => sSortedMuonsB,
      oIdxBits   => sSortedIdxBitsB,
      oSortRanks => sSortedSortRanksB,
      oEmpty     => sSortedEmptyB,
      clk        => clk,
      sinit      => sinit);
  sortO_plus : entity work.HalfSortStage0
    port map (
      iSortRanks => sSortRanksO_plus,
      iCancel_A  => sCancelO_plus,
      iCancel_B  => sCancelEO_O_plus,
      iCancel_C  => sCancelBO_O_plus,
      iMuons     => sMuonsO_plus,
      iIdxBits   => sIdxBitsO_plus,
      oMuons     => sSortedMuonsO_plus,
      oIdxBits   => sSortedIdxBitsO_plus,
      oSortRanks => sSortedSortRanksO_plus,
      oEmpty     => sSortedEmptyO_plus,
      clk        => clk,
      sinit      => sinit);
  sortO_minus : entity work.HalfSortStage0
    port map (
      iSortRanks => sSortRanksO_minus,
      iCancel_A  => sCancelO_minus,
      iCancel_B  => sCancelEO_O_minus,
      iCancel_C  => sCancelBO_O_minus,
      iMuons     => sMuonsO_minus,
      iIdxBits   => sIdxBitsO_minus,
      oMuons     => sSortedMuonsO_minus,
      oIdxBits   => sSortedIdxBitsO_minus,
      oSortRanks => sSortedSortRanksO_minus,
      oEmpty     => sSortedEmptyO_minus,
      clk        => clk,
      sinit      => sinit);
  sortE_plus : entity work.HalfSortStage0
    port map (
      iSortRanks => sSortRanksE_plus,
      iCancel_A  => sCancelE_plus,
      iCancel_B  => sCancelEO_E_plus,
      iCancel_C  => (others => '0'),
      iMuons     => sMuonsE_plus,
      iIdxBits   => sIdxBitsE_plus,
      oMuons     => sSortedMuonsE_plus,
      oIdxBits   => sSortedIdxBitsE_plus,
      oSortRanks => sSortedSortRanksE_plus,
      oEmpty     => sSortedEmptyE_plus,
      clk        => clk,
      sinit      => sinit);
  sortE_minus : entity work.HalfSortStage0
    port map (
      iSortRanks => sSortRanksE_minus,
      iCancel_A  => sCancelE_minus,
      iCancel_B  => sCancelEO_E_minus,
      iCancel_C  => (others => '0'),
      iMuons     => sMuonsE_minus,
      iIdxBits   => sIdxBitsE_minus,
      oMuons     => sSortedMuonsE_minus,
      oIdxBits   => sSortedIdxBitsE_minus,
      oSortRanks => sSortedSortRanksE_minus,
      oEmpty     => sSortedEmptyE_minus,
      clk        => clk,
      sinit      => sinit);

  sSortedEmptyBits(0) <= sSortedEmptyB;
  sSortedEmptyBits(1) <= "1111" & sSortedEmptyO_plus;
  sSortedEmptyBits(2) <= "1111" & sSortedEmptyO_minus;
  sSortedEmptyBits(3) <= "1111" & sSortedEmptyE_plus;
  sSortedEmptyBits(4) <= "1111" & sSortedEmptyE_minus;

  -- TODO: Add muon counters here
  count_mus : process(clk)
    variable muonCount : TLocalMuonCounter;
  begin
    if clk'event and clk = '1' then  -- rising clock edge
      muon_counter_reset_reg <= mu_ctr_rst;

      sSortedEmptyBits_reg <= sSortedEmptyBits;

      -- Counting how many non-empty muons we have.
      for i in sSortedEmptyBits_reg'range loop
        muonCount(i) := (others => '0');
        for j in sSortedEmptyBits_reg(i)'range loop
          if sSortedEmptyBits_reg(i)(j) = '0' then
            muonCount(i) := muonCount(i)+to_unsigned(1, muonCount(i)'length);
          end if;
        end loop;

        -- Add above sum to register.
        if muon_counter_reset_reg = '1' then
          -- Reset muon counter after storing its contents in register.
          sMuonCounters_store(i) <= std_logic_vector(sMuonCounters(i));
          sMuonCounters(i) <= resize(muonCount(i), sMuonCounters(i)'length);
        else
          sMuonCounters(i) <= sMuonCounters(i) + resize(muonCount(i), sMuonCounters(i)'length);
        end if;
      end loop;
    end if;
  end process;

  gen_ipb_registers : for i in NUM_LOCAL_SORTERS-1 downto 0 generate
    muon_counter : entity work.ipbus_reg_status
      generic map(
        N_REG => 1
        )
      port map(
        ipbus_in  => ipbw(N_SLV_MUON_COUNTER_BMTF+i),
        ipbus_out => ipbr(N_SLV_MUON_COUNTER_BMTF+i),
        clk       => clk_ipb,
        reset     => sinit,
        d         => sMuonCounters_store(i downto i),
        q         => open
        );
  end generate gen_ipb_registers;

  reg_pairs : process (clk)
  begin  -- process reg_pairs
    if clk'event and clk = '0' then     -- falling clock edge
      sSortedSortRanksB_reg <= sSortedSortRanksB;
      sSortedSortRanksO_reg <= sSortedSortRanksO_minus & sSortedSortRanksO_plus;
      sSortedSortRanksE_reg <= sSortedSortRanksE_minus & sSortedSortRanksE_plus;
      sSortedEmptyB_reg     <= sSortedEmptyB;
      sSortedEmptyO_reg     <= sSortedEmptyO_minus & sSortedEmptyO_plus;
      sSortedEmptyE_reg     <= sSortedEmptyE_minus & sSortedEmptyE_plus;
      sSortedIdxBitsB_reg   <= sSortedIdxBitsB;
      sSortedIdxBitsO_reg   <= sSortedIdxBitsO_minus & sSortedIdxBitsO_plus;
      sSortedIdxBitsE_reg   <= sSortedIdxBitsE_minus & sSortedIdxBitsE_plus;
      sSortedMuonsB_reg     <= sSortedMuonsB;
      sSortedMuonsO_reg     <= sSortedMuonsO_minus & sSortedMuonsO_plus;
      sSortedMuonsE_reg     <= sSortedMuonsE_minus & sSortedMuonsE_plus;
    end if;
  end process reg_pairs;

  sort_final : entity work.SortStage1
    port map (
      iSortRanksB => sSortedSortRanksB_reg,
      iEmptyB     => sSortedEmptyB_reg,
      iIdxBitsB   => sSortedIdxBitsB_reg,
      iMuonsB     => sSortedMuonsB_reg,
      iSortRanksO => sSortedSortRanksO_reg,
      iEmptyO     => sSortedEmptyO_reg,
      iIdxBitsO   => sSortedIdxBitsO_reg,
      iMuonsO     => sSortedMuonsO_reg,
      iSortRanksE => sSortedSortRanksE_reg,
      iEmptyE     => sSortedEmptyE_reg,
      iIdxBitsE   => sSortedIdxBitsE_reg,
      iMuonsE     => sSortedMuonsE_reg,
      oIdxBits    => sIdxBits,        -- Goes out to IsoAU.
      oMuons      => sFinalMuons
      );

  final_mu_reg : process (clk)
  begin  -- process final_mu_reg
    if clk'event and clk = '0' then     -- falling clock edge
      sFinalMuons_reg <= sFinalMuons;
    end if;
  end process final_mu_reg;

  extract_mu_pt : for i in sFinalMuons_reg'range generate
    oMuPt(i) <= sFinalMuons_reg(i).pt;
  end generate extract_mu_pt;

  oMuons   <= sFinalMuons_reg;
  oIdxBits <= sIdxBits;

  oIntermediateMuonsB     <= sSortedMuonsB_reg;
  oIntermediateMuonsO     <= sSortedMuonsO_reg;
  oIntermediateMuonsE     <= sSortedMuonsE_reg;
  oIntermediateSortRanksB <= sSortedSortRanksB_reg;
  oIntermediateSortRanksO <= sSortedSortRanksO_reg;
  oIntermediateSortRanksE <= sSortedSortRanksE_reg;

end architecture behavioral;
