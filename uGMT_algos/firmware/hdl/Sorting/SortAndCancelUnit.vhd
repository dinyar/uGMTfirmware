-- Sort and Cancel unit

library ieee;
use ieee.std_logic_1164.all;
use ieee.NUMERIC_STD.all;

use work.mp7_data_types.all;
use work.ipbus.all;
use work.ipbus_decode_sorting.all;

use work.GMTTypes.all;
use work.ugmt_constants.all;
use work.mp7_brd_decl.all;

entity SortAndCancelUnit is
  generic (
    rpc_merging : boolean := false      -- whether RPC merging should be done.
    );
  port (
    iMuonsB : in TGMTMu_vector(35 downto 0);
    iMuonsO : in TGMTMu_vector(35 downto 0);
    iMuonsE : in TGMTMu_vector(35 downto 0);

    -- For RPC merging.
    iMuonsRPCb     : in TGMTMuRPC_vector(3 downto 0);
    iMuonsRPCf     : in TGMTMuRPC_vector(3 downto 0);
    iSortRanksRPCb : in TSortRank10_vector(3 downto 0);
    iSortRanksRPCf : in TSortRank10_vector(3 downto 0);
    iEmptyRPCb     : in std_logic_vector(3 downto 0);
    iEmptyRPCf     : in std_logic_vector(3 downto 0);
    iIdxBitsRPCb   : in TIndexBits_vector(3 downto 0);
    iIdxBitsRPCf   : in TIndexBits_vector(3 downto 0);

    iTracksB : in TGMTMuTracks_vector(11 downto 0);
    iTracksO : in TGMTMuTracks_vector(11 downto 0);
    iTracksE : in TGMTMuTracks_vector(11 downto 0);

    -- I'm assuming I can assign rank and check for empty during rcv stage.
    iSortRanksB : in TSortRank10_vector(35 downto 0);
    iSortRanksO : in TSortRank10_vector(35 downto 0);
    iSortRanksE : in TSortRank10_vector(35 downto 0);

    iEmptyB : in std_logic_vector(35 downto 0);
    iEmptyO : in std_logic_vector(35 downto 0);
    iEmptyE : in std_logic_vector(35 downto 0);

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
    clk     : in  std_logic;
    clk_ipb : in  std_logic;
    sinit   : in  std_logic;
    rst_loc : in  std_logic_vector(N_REGION - 1 downto 0);
    ipb_in  : in  ipb_wbus;
    ipb_out : out ipb_rbus
    );
end;

architecture behavioral of SortAndCancelUnit is
  -- IPbus
  signal ipbw : ipb_wbus_array(N_SLAVES - 1 downto 0);
  signal ipbr : ipb_rbus_array(N_SLAVES - 1 downto 0);

  signal sMuonsO_plus  : TGMTMu_vector(17 downto 0);
  signal sMuonsO_minus : TGMTMu_vector(17 downto 0);
  signal sMuonsE_plus  : TGMTMu_vector(17 downto 0);
  signal sMuonsE_minus : TGMTMu_vector(17 downto 0);

  signal sTracksO_plus  : TGMTMuTracks_vector(5 downto 0);
  signal sTracksO_minus : TGMTMuTracks_vector(5 downto 0);
  signal sTracksE_plus  : TGMTMuTracks_vector(5 downto 0);
  signal sTracksE_minus : TGMTMuTracks_vector(5 downto 0);

  signal sSortRanksO_plus       : TSortRank10_vector(17 downto 0);
  signal sEmptyO_plus           : std_logic_vector(17 downto 0);
  signal sIdxBitsO_plus         : TIndexBits_vector(17 downto 0);
  signal sSortedMuonsO_plus     : TGMTMu_vector(3 downto 0);
  signal sSortedIdxBitsO_plus   : TIndexBits_vector(3 downto 0);
  signal sSortedSortRanksO_plus : TSortRank10_vector(3 downto 0);
  signal sSortedEmptyO_plus     : std_logic_vector(3 downto 0);

  signal sSortRanksO_minus       : TSortRank10_vector(17 downto 0);
  signal sEmptyO_minus           : std_logic_vector(17 downto 0);
  signal sIdxBitsO_minus         : TIndexBits_vector(17 downto 0);
  signal sSortedMuonsO_minus     : TGMTMu_vector(3 downto 0);
  signal sSortedIdxBitsO_minus   : TIndexBits_vector(3 downto 0);
  signal sSortedSortRanksO_minus : TSortRank10_vector(3 downto 0);
  signal sSortedEmptyO_minus     : std_logic_vector(3 downto 0);

  signal sSortRanksE_plus       : TSortRank10_vector(17 downto 0);
  signal sEmptyE_plus           : std_logic_vector(17 downto 0);
  signal sIdxBitsE_plus         : TIndexBits_vector(17 downto 0);
  signal sSortedMuonsE_plus     : TGMTMu_vector(3 downto 0);
  signal sSortedIdxBitsE_plus   : TIndexBits_vector(3 downto 0);
  signal sSortedSortRanksE_plus : TSortRank10_vector(3 downto 0);
  signal sSortedEmptyE_plus     : std_logic_vector(3 downto 0);

  signal sSortRanksE_minus       : TSortRank10_vector(17 downto 0);
  signal sEmptyE_minus           : std_logic_vector(17 downto 0);
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

  -- RPC merging stuff
  signal iMuonsRPCf_reg    : TGMTMuRPC_vector(3 downto 0);
  signal iMuonsRPCf_store  : TGMTMuRPC_vector(3 downto 0);
  signal iMuonsRPCf_store2 : TGMTMuRPC_vector(3 downto 0);
  signal iMuonsRPCb_reg    : TGMTMuRPC_vector(3 downto 0);
  signal iMuonsRPCb_store  : TGMTMuRPC_vector(3 downto 0);
  signal iMuonsRPCb_store2 : TGMTMuRPC_vector(3 downto 0);

  signal sMQMatrixF             : TMQMatrix;
  signal sMQMatrixE_reg         : TMQMatrix;
  signal sPairVecE              : TPairVector(3 downto 0);
  signal sPairVecE_reg          : TPairVector(3 downto 0);
  signal sMatchedMuonsE         : TGMTMu_vector(3 downto 0);
  signal sCancelE_matched       : std_logic_vector(7 downto 0);
  signal sCancelO_matched_A     : std_logic_vector(7 downto 0);
  signal sMatchedMuonsE_reg     : TGMTMu_vector(3 downto 0);
  signal sCancelE_matched_reg   : std_logic_vector(7 downto 0);
  signal sCancelO_matched_A_reg : std_logic_vector(7 downto 0);
  signal sSortRanksMergedE      : TSortRank10_vector(3 downto 0);
  signal sEmptyMergedE          : std_logic_vector(3 downto 0);
  signal sIdxBitsMergedE        : TIndexBits_vector(3 downto 0);
  signal sMergedMuonsE          : TGMTMu_vector(3 downto 0);
  signal sSortRanksMergedE_reg  : TSortRank10_vector(3 downto 0);
  signal sEmptyMergedE_reg      : std_logic_vector(3 downto 0);
  signal sIdxBitsMergedE_reg    : TIndexBits_vector(3 downto 0);
  signal sMergedMuonsE_reg      : TGMTMu_vector(3 downto 0);
  signal sMQMatrixB             : TMQMatrix;
  signal sMQMatrixB_reg         : TMQMatrix;
  signal sPairVecB              : TPairVector(3 downto 0);
  signal sPairVecB_reg          : TPairVector(3 downto 0);
  signal sMatchedMuonsB         : TGMTMu_vector(3 downto 0);
  signal sCancelB_matched       : std_logic_vector(7 downto 0);
  signal sCancelO_matched_B     : std_logic_vector(7 downto 0);
  signal sMatchedMuonsB_reg     : TGMTMu_vector(3 downto 0);
  signal sCancelB_matched_reg   : std_logic_vector(7 downto 0);
  signal sCancelO_matched_B_reg : std_logic_vector(7 downto 0);
  signal sSortRanksMergedB      : TSortRank10_vector(3 downto 0);
  signal sEmptyMergedB          : std_logic_vector(3 downto 0);
  signal sIdxBitsMergedB        : TIndexBits_vector(3 downto 0);
  signal sMergedMuonsB          : TGMTMu_vector(3 downto 0);
  signal sSortRanksMergedB_reg  : TSortRank10_vector(3 downto 0);
  signal sEmptyMergedB_reg      : std_logic_vector(3 downto 0);
  signal sIdxBitsMergedB_reg    : TIndexBits_vector(3 downto 0);
  signal sMergedMuonsB_reg      : TGMTMu_vector(3 downto 0);

  signal sMatchedSortRanksB_reg : TSortRank10_vector(3 downto 0);
  signal sMatchedSortRanksB     : TSortRank10_vector(3 downto 0);
  signal sMatchedEmptyB_reg     : std_logic_vector(3 downto 0);
  signal sMatchedEmptyB         : std_logic_vector(3 downto 0);
  signal sMatchedIdxBitsB_reg   : TIndexBits_vector(3 downto 0);
  signal sMatchedIdxBitsB       : TIndexBits_vector(3 downto 0);
  signal sSortRanksRPCb_reg     : TSortRank10_vector(3 downto 0);
  signal sEmptyRPCb_reg         : std_logic_vector(3 downto 0);
  signal sIdxBitsRPCb_reg       : TIndexBits_vector(3 downto 0);
  signal sMatchedSortRanksE_reg : TSortRank10_vector(3 downto 0);
  signal sMatchedSortRanksE     : TSortRank10_vector(3 downto 0);
  signal sMatchedEmptyE_reg     : std_logic_vector(3 downto 0);
  signal sMatchedEmptyE         : std_logic_vector(3 downto 0);
  signal sMatchedIdxBitsE_reg   : TIndexBits_vector(3 downto 0);
  signal sMatchedIdxBitsE       : TIndexBits_vector(3 downto 0);
  signal sSortRanksRPCf_reg     : TSortRank10_vector(3 downto 0);
  signal sEmptyRPCf_reg         : std_logic_vector(3 downto 0);
  signal sIdxBitsRPCf_reg       : TIndexBits_vector(3 downto 0);

  -- For intermediates
  constant MU_INTERMEDIATE_DELAY : natural := 1;  -- Delay to sync
                                                  -- intermediates with
                                                  -- final muons.
  type     TMuonBuffer is array (integer range <>) of TGMTMu_vector(7 downto 0);
  signal   sIntermediateMuonB_buffer : TMuonBuffer(MU_INTERMEDIATE_DELAY-1 downto 0);
  signal   sIntermediateMuonO_buffer : TMuonBuffer(MU_INTERMEDIATE_DELAY-1 downto 0);
  signal   sIntermediateMuonE_buffer : TMuonBuffer(MU_INTERMEDIATE_DELAY-1 downto 0);
  type     TSortRankBuffer is array (integer range <>) of TSortRank10_vector(7 downto 0);
  signal   sIntermediateSortRankB_buffer : TSortRankBuffer(MU_INTERMEDIATE_DELAY-1 downto 0);
  signal   sIntermediateSortRankO_buffer : TSortRankBuffer(MU_INTERMEDIATE_DELAY-1 downto 0);
  signal   sIntermediateSortRankE_buffer : TSortRankBuffer(MU_INTERMEDIATE_DELAY-1 downto 0);

  signal sIntermediateMuonsB     : TGMTMu_vector(7 downto 0);
  signal sIntermediateMuonsO     : TGMTMu_vector(7 downto 0);
  signal sIntermediateMuonsE     : TGMTMu_vector(7 downto 0);
  signal sIntermediateSortRanksB : TSortRank10_vector(7 downto 0);
  signal sIntermediateSortRanksO : TSortRank10_vector(7 downto 0);
  signal sIntermediateSortRanksE : TSortRank10_vector(7 downto 0);
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
  sEmptyO_plus      <= iEmptyO(17 downto 0);
  sEmptyO_minus     <= iEmptyO(35 downto 18);
  sEmptyE_plus      <= iEmptyE(17 downto 0);
  sEmptyE_minus     <= iEmptyE(35 downto 18);
  sIdxBitsO_plus    <= iIdxBitsO(17 downto 0);
  sIdxBitsO_minus   <= iIdxBitsO(35 downto 18);
  sIdxBitsE_plus    <= iIdxBitsE(17 downto 0);
  sIdxBitsE_minus   <= iIdxBitsE(35 downto 18);

  -- Calculate match quality between RPC and TF muons.
  generate_mq_unit : if rpc_merging generate
    mq_emtf : entity work.MatchQualityUnit
      port map (
        iMuonsRPC      => iMuonsRPCf,
        iMuonsBmtfEmtf => iMuonsE,
        iMuonsOmtf     => iMuonsO,
        oMQMatrix      => sMQMatrixF,
        clk            => clk,
        sinit          => sinit
        );

    mq_bmtf : entity work.MatchQualityUnit
      port map (
        iMuonsRPC    => iMuonsRPCb,
        iMuonsBmtfEmtf => iMuonsB,
        iMuonsOmtf    => iMuonsO,
        oMQMatrix    => sMQMatrixB,
        clk          => clk,
        sinit        => sinit
        );
  end generate generate_mq_unit;

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
      ipb_in  => ipbw(N_SLV_COU_BMTF),
      ipb_out => ipbr(N_SLV_COU_BMTF),
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
  cou_f_plus : entity work.CancelOutUnit_Single
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
  cou_f_minus : entity work.CancelOutUnit_Single
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
  -- Register cancel-out bits and pair vector here.
  -- type   : sequential
  -- inputs : clk, sinit, sCancelBO, sCancelFO, sCancelB, sCancelO, sCancelF,
  -- sPairVecB, sPairVecE
  -- outputs: sCancelBO_reg, sCancelEO_reg, sCancelB_reg, sCancelO_reg,
  -- sCancelE_reg, sPairVecB_reg, sPairVecE_reg
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

      -- For RPC merging
      sMQMatrixB_reg <= sMQMatrixB;
      sMQMatrixE_reg <= sMQMatrixF;

      iMuonsRPCf_store <= iMuonsRPCf;
      iMuonsRPCb_store <= iMuonsRPCb;
    end if;
  end process register_cobits_pairs;

  -- Sort muons separately first, have ports for CU info
  sortB : entity work.SortStage0
    port map (
      iSortRanks => iSortRanksB,
      iEmpty     => iEmptyB,
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
      iEmpty     => sEmptyO_plus,
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
      iEmpty     => sEmptyO_minus,
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
      iEmpty     => sEmptyE_plus,
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
      iEmpty     => sEmptyE_minus,
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

  sIntermediateMuonsB     <= sSortedMuonsB;
  sIntermediateMuonsO     <= sSortedMuonsO_minus & sSortedMuonsO_plus;
  sIntermediateMuonsE     <= sSortedMuonsE_minus & sSortedMuonsE_plus;
  sIntermediateSortRanksB <= sSortedSortRanksB;
  sIntermediateSortRanksO <= sSortedSortRanksO_minus & sSortedSortRanksO_plus;
  sIntermediateSortRanksE <= sSortedSortRanksE_minus & sSortedSortRanksE_plus;

  gen_pair_finding_unit : if rpc_merging generate
    -- Find pairs based on MQ matrix between RPC and TF muons.
    pair_finding_emtf : entity work.PairFindingUnit
      port map (
        iMQMatrix => sMQMatrixE_reg,
        oPairs    => sPairVecE,
        clk       => clk,
        sinit     => sinit);

    pair_finding_bmtf : entity work.PairFindingUnit
      port map (
        iMQMatrix => sMQMatrixB_reg,
        oPairs    => sPairVecB,
        clk       => clk,
        sinit     => sinit);
  end generate gen_pair_finding_unit;

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


      -- For RPC merging
      --sPairVecB_reg <= sPairVecB;
      --sPairVecE_reg <= sPairVecE;

      --iMuonsRPCf_store2 <= iMuonsRPCf_store;
      --iMuonsRPCb_store2 <= iMuonsRPCb_store;
    end if;
  end process reg_pairs;

  gen_matching_unit : if rpc_merging generate
    -- For RPC merging
    match_emtf : entity work.MatchingUnit
      port map (
        iSortRanksBmtfEmtf => sSortRanksE_store,
        iEmptyBmtfEmtf     => sEmptyE_store,
        iIdxBitsBmtfEmtf   => sIdxBitsE_store,
        iMuonsBmtfEmtf     => sMuonsE_store,
        iSortRanksOmtf     => sSortRanksO_store,
        iEmptyOmtf         => sEmptyO_store,
        iIdxBitsOmtf       => sIdxBitsO_store,
        iMuonsOmtf         => sMuonsO_store,
        iPairVec           => sPairVecE_reg,
        oSortRanks         => sMatchedSortRanksE,
        oEmpty             => sMatchedEmptyE,
        oIdxBits           => sMatchedIdxBitsE,
        oMuons             => sMatchedMuonsE,
        oCancelBmtfEmtf    => sCancelE_matched,
        oCancelOmtf         => sCancelO_matched_A,
        clk                => clk,
        sinit              => sinit);

    match_bmtf : entity work.MatchingUnit
      port map (
        iSortRanksBmtfEmtf => sSortRanksB_store,
        iEmptyBmtfEmtf     => sEmptyB_store,
        iIdxBitsBmtfEmtf   => sIdxBitsB_store,
        iMuonsBmtfEmtf     => sMuonsB_store,
        iSortRanksOmtf    => sSortRanksO_store,
        iEmptyOmtf        => sEmptyO_store,
        iIdxBitsOmtf      => sIdxBitsO_store,
        iMuonsOmtf        => sMuonsO_store,
        iPairVec         => sPairVecB_reg,
        oSortRanks       => sMatchedSortRanksB,
        oEmpty           => sMatchedEmptyB,
        oIdxBits         => sMatchedIdxBitsB,
        oMuons           => sMatchedMuonsB,
        oCancelBmtfEmtf    => sCancelB_matched,
        oCancelOmtf       => sCancelO_matched_B,
        clk              => clk,
        sinit            => sinit);
  end generate gen_matching_unit;

  gen_merger_unit : if rpc_merging generate
    -- For RPC merging
    merger_emtf : entity work.MergerUnit
      port map (
        iMuonsTF      => sMatchedMuonsE_reg,
        iSortRanksTF  => sMatchedSortRanksE_reg,
        iEmptyTF      => sMatchedEmptyE_reg,
        iIdxBitsTF    => sMatchedIdxBitsE_reg,
        iMuonsRPC     => iMuonsRPCf_reg,
        iSortRanksRPC => sSortRanksRPCf_reg,
        iEmptyRPC     => sEmptyRPCf_reg,
        iIdxBitsRPC   => sIdxBitsRPCf_reg,
        oSortRanks    => sSortRanksMergedE,
        oEmpty        => sEmptyMergedE,
        oIdxBits      => sIdxBitsMergedE,
        oMuons        => sMergedMuonsE,
        clk           => clk,
        sinit         => sinit);

    merger_bmtf : entity work.MergerUnit
      port map (
        iMuonsTF      => sMatchedMuonsB_reg,
        iSortRanksTF  => sMatchedSortRanksB_reg,
        iEmptyTF      => sMatchedEmptyB_reg,
        iIdxBitsTF    => sMatchedIdxBitsB_reg,
        iMuonsRPC     => iMuonsRPCb_reg,
        iSortRanksRPC => sSortRanksRPCb_reg,
        iEmptyRPC     => sEmptyRPCb_reg,
        iIdxBitsRPC   => sIdxBitsRPCb_reg,
        oSortRanks    => sSortRanksMergedB,
        oEmpty        => sEmptyMergedB,
        oIdxBits      => sIdxBitsMergedB,
        oMuons        => sMergedMuonsB,
        clk           => clk,
        sinit         => sinit);
  end generate gen_merger_unit;

  -- Sort final muons together.
  gen_sorting_with_merged_muons : if rpc_merging generate
    sort_final : entity work.SortStage1_RPC
      port map (
        iSortRanksB       => sSortedSortRanksB_reg,
        iEmptyB           => sSortedEmptyB_reg,
        iIdxBitsB         => sSortedIdxBitsB_reg,
        iMuonsB           => sSortedMuonsB_reg,
        iSortRanksO       => sSortedSortRanksO_reg,
        iEmptyO           => sSortedEmptyO_reg,
        iIdxBitsO         => sSortedIdxBitsO_reg,
        iMuonsO           => sSortedMuonsO_reg,
        iSortRanksE       => sSortedSortRanksE_reg,
        iEmptyE           => sSortedEmptyE_reg,
        iIdxBitsE         => sSortedIdxBitsE_reg,
        iMuonsE           => sSortedMuonsE_reg,
        iSortRanksMergedB => sSortRanksMergedB_reg,
        iEmptyMergedB     => sEmptyMergedB_reg,
        iIdxBitsMergedB   => sIdxBitsMergedB_reg,
        iMuonsMergedB     => sMergedMuonsB_reg,
        iSortRanksMergedE => sSortRanksMergedE_reg,
        iEmptyMergedE     => sEmptyMergedE_reg,
        iIdxBitsMergedE   => sIdxBitsMergedE_reg,
        iMuonsMergedE     => sMergedMuonsE_reg,
        iCancelB          => sCancelB_matched_reg,
        iCancelO_A        => sCancelO_matched_A_reg,
        iCancelO_B        => sCancelO_matched_B_reg,
        iCancelE          => sCancelE_matched_reg,
        oIdxBits          => oIdxBits,  -- Goes out to IsoAU.
        oMuons            => sFinalMuons,
        clk               => clk,
        sinit             => sinit);
  end generate gen_sorting_with_merged_muons;

  gen_sorting_without_merged_muons : if not rpc_merging generate
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
        oIdxBits    => oIdxBits,        -- Goes out to IsoAU.
        oMuons      => sFinalMuons
        );

  end generate gen_sorting_without_merged_muons;

  final_mu_reg : process (clk)
  begin  -- process final_mu_reg
    if clk'event and clk = '0' then     -- falling clock edge
      sIntermediateMuonB_buffer(0)                                    <= sIntermediateMuonsB;
      sIntermediateMuonO_buffer(0)                                    <= sIntermediateMuonsO;
      sIntermediateMuonE_buffer(0)                                    <= sIntermediateMuonsE;
--      sIntermediateMuonB_buffer(MU_INTERMEDIATE_DELAY-1 downto 1)     <= sIntermediateMuonB_buffer(MU_INTERMEDIATE_DELAY-2 downto 0);
--      sIntermediateMuonO_buffer(MU_INTERMEDIATE_DELAY-1 downto 1)     <= sIntermediateMuonO_buffer(MU_INTERMEDIATE_DELAY-2 downto 0);
--      sIntermediateMuonE_buffer(MU_INTERMEDIATE_DELAY-1 downto 1)     <= sIntermediateMuonE_buffer(MU_INTERMEDIATE_DELAY-2 downto 0);
--      sIntermediateSortRankB_buffer(0)                                <= sIntermediateSortRanksB;
--      sIntermediateSortRankO_buffer(0)                                <= sIntermediateSortRanksO;
--      sIntermediateSortRankE_buffer(0)                                <= sIntermediateSortRanksE;
--      sIntermediateSortRankB_buffer(MU_INTERMEDIATE_DELAY-1 downto 1) <= sIntermediateSortRankB_buffer(MU_INTERMEDIATE_DELAY-2 downto 0);
--      sIntermediateSortRankO_buffer(MU_INTERMEDIATE_DELAY-1 downto 1) <= sIntermediateSortRankO_buffer(MU_INTERMEDIATE_DELAY-2 downto 0);
--      sIntermediateSortRankE_buffer(MU_INTERMEDIATE_DELAY-1 downto 1) <= sIntermediateSortRankE_buffer(MU_INTERMEDIATE_DELAY-2 downto 0);

      sFinalMuons_reg <= sFinalMuons;
    end if;
  end process final_mu_reg;

  extract_mu_pt : for i in sFinalMuons_reg'range generate
    oMuPt(i) <= sFinalMuons_reg(i).pt;
  end generate extract_mu_pt;

  oMuons <= sFinalMuons_reg;

  oIntermediateMuonsB     <= sIntermediateMuonB_buffer(MU_INTERMEDIATE_DELAY-1);
  oIntermediateMuonsO     <= sIntermediateMuonO_buffer(MU_INTERMEDIATE_DELAY-1);
  oIntermediateMuonsE     <= sIntermediateMuonE_buffer(MU_INTERMEDIATE_DELAY-1);
  oIntermediateSortRanksB <= sIntermediateSortRankB_buffer(MU_INTERMEDIATE_DELAY-1);
  oIntermediateSortRanksO <= sIntermediateSortRankO_buffer(MU_INTERMEDIATE_DELAY-1);
  oIntermediateSortRanksE <= sIntermediateSortRankE_buffer(MU_INTERMEDIATE_DELAY-1);

end architecture behavioral;
