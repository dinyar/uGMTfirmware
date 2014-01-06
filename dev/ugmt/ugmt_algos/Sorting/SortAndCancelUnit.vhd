-- Sort and Cancel unit

library ieee;
use ieee.std_logic_1164.all;
use ieee.NUMERIC_STD.all;
library Types;
use Types.GMTTypes.all;

entity SortAndCancelUnit is
  generic (
    rpc_merging : boolean := false);        -- whether RPC merging should be done.
  port (
    iMuonsB : in TGMTMu_vector(0 to 35);
    iMuonsO : in TGMTMu_vector(0 to 35);
    iMuonsF : in TGMTMu_vector(0 to 35);

    -- For RPC merging.
    iMuonsRPCb     : in TGMTMuRPC_vector(3 downto 0);
    iMuonsRPCf     : in TGMTMuRPC_vector(3 downto 0);
    iSortRanksRPCb : in TSortRank10_vector(3 downto 0);
    iSortRanksRPCf : in TSortRank10_vector(3 downto 0);
    iEmptyRPCb     : in std_logic_vector(3 downto 0);
    iEmptyRPCf     : in std_logic_vector(3 downto 0);
    iIdxBitsRPCb   : in TIndexBits_vector(3 downto 0);
    iIdxBitsRPCf   : in TIndexBits_vector(3 downto 0);

    iTracksB : in TGMTMuTracks_vector(0 to 11);
    iTracksO : in TGMTMuTracks_vector(0 to 11);
    iTracksF : in TGMTMuTracks_vector(0 to 11);

    -- I'm assuming I can assign rank and check for empty during rcv stage.
    iSortRanksB : in TSortRank10_vector(0 to 35);
    iSortRanksO : in TSortRank10_vector(0 to 35);
    iSortRanksF : in TSortRank10_vector(0 to 35);

    iEmptyB : in std_logic_vector(0 to 35);
    iEmptyO : in std_logic_vector(0 to 35);
    iEmptyF : in std_logic_vector(0 to 35);

    iIdxBitsB : in TIndexBits_vector(0 to 35);
    iIdxBitsO : in TIndexBits_vector(0 to 35);
    iIdxBitsF : in TIndexBits_vector(0 to 35);

    oIdxBits : out TIndexBits_vector(7 downto 0);
    oMuons   : out TGMTMu_vector(7 downto 0);

    -- Clock and control
    clk   : in std_logic;
    sinit : in std_logic);
end;

architecture behavioral of SortAndCancelUnit is
  -- Declare sorter+CU here.
  component CancelOutUnit_Single
    generic (
      num_wedges : natural;
      num_tracks : natural);
    port (
      iWedges : in  TGMTMuTracks_vector(0 to num_wedges-1);
      oCancel : out std_logic_vector(0 to num_wedges*num_tracks-1);
      clk     : in  std_logic
      );
  end component;

  component CancelOutUnit_BO
    port (
      iWedges_Ovl : in  TGMTMuTracks_vector(0 to 5);
      iWedges_B   : in  TGMTMuTracks_vector(0 to 11);
      oCancel_Ovl : out std_logic_vector(0 to 17);
      oCancel_B   : out std_logic_vector(0 to 35);
      clk         : in  std_logic
      );
  end component;
  component CancelOutUnit_FO
    port (
      iWedges_Ovl : in  TGMTMuTracks_vector(0 to 5);
      iWedges_F   : in  TGMTMuTracks_vector(0 to 5);
      oCancel_Ovl : out std_logic_vector(0 to 17);
      oCancel_F   : out std_logic_vector(0 to 17);
      clk         : in  std_logic
      );
  end component;

  component SortStage0
    generic (
      sorter_lat_Start : integer := 6);
    port (
      iSortRanks : in  TSortRank10_vector(0 to 35);
      iEmpty     : in  std_logic_vector(0 to 35);
      iCancel_A  : in  std_logic_vector(0 to 35);
      iCancel_B  : in  std_logic_vector(0 to 35);
      iCancel_C  : in  std_logic_vector(0 to 35);
      iMuons     : in  TGMTMu_vector(0 to 35);
      iIdxBits   : in  TIndexBits_vector(0 to 35);
      oMuons     : out TGMTMu_vector(0 to 7);
      oSortRanks : out TSortRank10_vector(0 to 7);
      oEmpty     : out std_logic_vector(0 to 7);
      oIdxBits   : out TIndexBits_vector(0 to 7);
      clk        : in  std_logic;
      sinit      : in  std_logic
      );
  end component;

  component HalfSortStage0
    generic (
      sorter_lat_Start : integer := 6);
    port (
      iSortRanks : in  TSortRank10_vector(0 to 17);
      iEmpty     : in  std_logic_vector(0 to 17);
      iCancel_A  : in  std_logic_vector(0 to 17);
      iCancel_B  : in  std_logic_vector(0 to 17);
      iCancel_C  : in  std_logic_vector(0 to 17);
      iMuons     : in  TGMTMu_vector(0 to 17);
      iIdxBits   : in  TIndexBits_vector(0 to 17);
      oMuons     : out TGMTMu_vector(0 to 3);
      oSortRanks : out TSortRank10_vector(0 to 3);
      oEmpty     : out std_logic_vector(0 to 3);
      oIdxBits   : out TIndexBits_vector(0 to 3);
      clk        : in  std_logic;
      sinit      : in  std_logic
      );
  end component;

  component SortStage1 is
    port (
      iSortRanksB : in TSortRank10_vector(0 to 7);
      iEmptyB     : in std_logic_vector(0 to 7);
      iIdxBitsB   : in TIndexBits_vector(0 to 7);
      iMuonsB     : in TGMTMu_vector(0 to 7);

      iSortRanksO : in TSortRank10_vector(0 to 7);
      iEmptyO     : in std_logic_vector(0 to 7);
      iIdxBitsO   : in TIndexBits_vector(0 to 7);
      iMuonsO     : in TGMTMu_vector(0 to 7);

      iSortRanksF : in TSortRank10_vector(0 to 7);
      iEmptyF     : in std_logic_vector(0 to 7);
      iIdxBitsF   : in TIndexBits_vector(0 to 7);
      iMuonsF     : in TGMTMu_vector(0 to 7);

      oIdxBits : out TIndexBits_vector(7 downto 0);  -- Sent to IsoAU.
      oMuons   : out TGMTMu_vector(7 downto 0);


      -- Clock and control
      clk   : in std_logic;
      sinit : in std_logic
      );
  end component;


  component SortStage1_RPC
    port (
      iSortRanksB       : in TSortRank10_vector(0 to 7);
      iEmptyB           : in std_logic_vector(0 to 7);
      iIdxBitsB         : in TIndexBits_vector(0 to 7);
      iMuonsB           : in TGMTMu_vector(0 to 7);
      iSortRanksO       : in TSortRank10_vector(0 to 7);
      iEmptyO           : in std_logic_vector(0 to 7);
      iIdxBitsO         : in TIndexBits_vector(0 to 7);
      iMuonsO           : in TGMTMu_vector(0 to 7);
      iSortRanksF       : in TSortRank10_vector(0 to 7);
      iEmptyF           : in std_logic_vector(0 to 7);
      iIdxBitsF         : in TIndexBits_vector(0 to 7);
      iMuonsF           : in TGMTMu_vector(0 to 7);
      -- Need the following for RPC merging:
      iSortRanksMergedB : in TSortRank10_vector(3 downto 0);
      iEmptyMergedB     : in std_logic_vector(3 downto 0);
      iIdxBitsMergedB   : in TIndexBits_vector(3 downto 0);
      iMuonsMergedB     : in TGMTMu_vector(3 downto 0);
      iCancelB          : in std_logic_vector(7 downto 0);
      iCancelO_B        : in std_logic_vector(7 downto 0);
      iSortRanksMergedF : in TSortRank10_vector(3 downto 0);
      iEmptyMergedF     : in std_logic_vector(3 downto 0);
      iIdxBitsMergedF   : in TIndexBits_vector(3 downto 0);
      iMuonsMergedF     : in TGMTMu_vector(3 downto 0);
      iCancelO_A        : in std_logic_vector(7 downto 0);
      iCancelF          : in std_logic_vector(7 downto 0);

      oIdxBits : out TIndexBits_vector(7 downto 0);
      oMuons   : out TGMTMu_vector(7 downto 0);
      clk      : in  std_logic;
      sinit    : in  std_logic
      );
  end component;

  -- RPC merging stuff.
  component MatchQualityUnit
    port (
      iMuonsRPC    : in  TGMTMuRPC_vector(3 downto 0);
      iMuonsBrlFwd : in  TGMTMu_vector(35 downto 0);
      iMuonsOvl    : in  TGMTMu_vector(35 downto 0);
      oMQMatrix    : out TMQMatrix;
      clk          : in  std_logic;
      sinit        : in  std_logic);
  end component;

  component PairFindingUnit
    port (
      iMQMatrix : in  TMQMatrix;
      oPairs    : out TPairVector(3 downto 0);
      clk       : in  std_logic;
      sinit     : in  std_logic);
  end component;

  component MatchingUnit
    port (
      iSortRanksBrlFwd : in  TSortRank10_vector(7 downto 0);
      iEmptyBrlFwd     : in  std_logic_vector(7 downto 0);
      iIdxBitsBrlFwd   : in  TIndexBits_vector(7 downto 0);
      iMuonsBrlFwd     : in  TGMTMu_vector(7 downto 0);
      iSortRanksOvl    : in  TSortRank10_vector(7 downto 0);
      iEmptyOvl        : in  std_logic_vector(7 downto 0);
      iIdxBitsOvl      : in  TIndexBits_vector(7 downto 0);
      iMuonsOvl        : in  TGMTMu_vector(7 downto 0);
      iPairVec         : in  TPairVector(3 downto 0);
      oSortRanks       : out TSortRank10_vector(3 downto 0);
      oEmpty           : out std_logic_vector(3 downto 0);
      oIdxBits         : out TIndexBits_vector(3 downto 0);
      oMuons           : out TGMTMu_vector(3 downto 0);
      oCancelBrlFwd    : out std_logic_vector(7 downto 0);
      oCancelOvl       : out std_logic_vector(7 downto 0);
      clk              : in  std_logic;
      sinit            : in  std_logic);
  end component;

  component MergerUnit
    port (
      iMuonsTF      : in  TGMTMu_vector(3 downto 0);
      iSortRanksTF  : in  TSortRank10_vector(3 downto 0);
      iEmptyTF      : in  std_logic_vector(3 downto 0);
      iIdxBitsTF    : in  TIndexBits_vector(3 downto 0);
      iMuonsRPC     : in  TGMTMuRPC_vector(3 downto 0);
      iSortRanksRPC : in  TSortRank10_vector(3 downto 0);
      iEmptyRPC     : in  std_logic_vector(3 downto 0);
      iIdxBitsRPC   : in  TIndexBits_vector(3 downto 0);
      oSortRanks    : out TSortRank10_vector(3 downto 0);
      oEmpty        : out std_logic_vector(3 downto 0);
      oIdxBits      : out TIndexBits_vector(3 downto 0);
      oMuons        : out TGMTMu_vector(3 downto 0);  -- merged muons
      clk           : in  std_logic;
      sinit         : in  std_logic);
  end component;

  signal sMuonsO_plus  : TGMTMu_vector(0 to 17);
  signal sMuonsO_minus : TGMTMu_vector(0 to 17);
  signal sMuonsF_plus  : TGMTMu_vector(0 to 17);
  signal sMuonsF_minus : TGMTMu_vector(0 to 17);

  signal sTracksO_plus  : TGMTMuTracks_vector(0 to 5);
  signal sTracksO_minus : TGMTMuTracks_vector(0 to 5);
  signal sTracksF_plus  : TGMTMuTracks_vector(0 to 5);
  signal sTracksF_minus : TGMTMuTracks_vector(0 to 5);

  signal sSortRanksO_plus       : TSortRank10_vector(0 to 17);
  signal sEmptyO_plus           : std_logic_vector(0 to 17);
  signal sIdxBitsO_plus         : TIndexBits_vector(0 to 17);
  signal sSortedMuonsO_plus     : TGMTMu_vector(0 to 3);
  signal sSortedIdxBitsO_plus   : TIndexBits_vector(0 to 3);
  signal sSortedSortRanksO_plus : TSortRank10_vector(0 to 3);
  signal sSortedEmptyO_plus     : std_logic_vector(0 to 3);

  signal sSortRanksO_minus       : TSortRank10_vector(0 to 17);
  signal sEmptyO_minus           : std_logic_vector(0 to 17);
  signal sIdxBitsO_minus         : TIndexBits_vector(0 to 17);
  signal sSortedMuonsO_minus     : TGMTMu_vector(0 to 3);
  signal sSortedIdxBitsO_minus   : TIndexBits_vector(0 to 3);
  signal sSortedSortRanksO_minus : TSortRank10_vector(0 to 3);
  signal sSortedEmptyO_minus     : std_logic_vector(0 to 3);

  signal sSortRanksF_plus       : TSortRank10_vector(0 to 17);
  signal sEmptyF_plus           : std_logic_vector(0 to 17);
  signal sIdxBitsF_plus         : TIndexBits_vector(0 to 17);
  signal sSortedMuonsF_plus     : TGMTMu_vector(0 to 3);
  signal sSortedIdxBitsF_plus   : TIndexBits_vector(0 to 3);
  signal sSortedSortRanksF_plus : TSortRank10_vector(0 to 3);
  signal sSortedEmptyF_plus     : std_logic_vector(0 to 3);

  signal sSortRanksF_minus       : TSortRank10_vector(0 to 17);
  signal sEmptyF_minus           : std_logic_vector(0 to 17);
  signal sIdxBitsF_minus         : TIndexBits_vector(0 to 17);
  signal sSortedMuonsF_minus     : TGMTMu_vector(0 to 3);
  signal sSortedIdxBitsF_minus   : TIndexBits_vector(0 to 3);
  signal sSortedSortRanksF_minus : TSortRank10_vector(0 to 3);
  signal sSortedEmptyF_minus     : std_logic_vector(0 to 3);

  signal sCancelB              : std_logic_vector(0 to 35);
  signal sCancelO_plus         : std_logic_vector(0 to 17);
  signal sCancelO_minus        : std_logic_vector(0 to 17);
  signal sCancelF_plus         : std_logic_vector(0 to 17);
  signal sCancelF_minus        : std_logic_vector(0 to 17);
  signal sCancelBO_B_plus      : std_logic_vector(0 to 35);
  signal sCancelBO_B_minus     : std_logic_vector(0 to 35);
  signal sCancelBO_O_plus      : std_logic_vector(0 to 17);
  signal sCancelBO_O_minus     : std_logic_vector(0 to 17);
  signal sCancelFO_F_plus      : std_logic_vector(0 to 17);
  signal sCancelFO_F_minus     : std_logic_vector(0 to 17);
  signal sCancelFO_O_plus      : std_logic_vector(0 to 17);
  signal sCancelFO_O_minus     : std_logic_vector(0 to 17);
  signal sCancelBO_O_plus_reg  : std_logic_vector(0 to 17);
  signal sCancelBO_O_minus_reg : std_logic_vector(0 to 17);
  signal sCancelFO_F_plus_reg  : std_logic_vector(0 to 17);
  signal sCancelFO_F_minus_reg : std_logic_vector(0 to 17);
  signal sCancelFO_O_plus_reg  : std_logic_vector(0 to 17);
  signal sCancelFO_O_minus_reg : std_logic_vector(0 to 17);
  signal sCancelB_reg          : std_logic_vector(0 to 35);
  signal sCancelO_plus_reg     : std_logic_vector(0 to 17);
  signal sCancelO_minus_reg    : std_logic_vector(0 to 17);
  signal sCancelF_plus_reg     : std_logic_vector(0 to 17);
  signal sCancelF_minus_reg    : std_logic_vector(0 to 17);
  signal sCancelBO_B_reg       : std_logic_vector(0 to 35);

  signal sMuonsB     : TGMTMu_vector(0 to 7);
  signal sIdxBitsB   : TIndexBits_vector(0 to 7);
  signal sSortRanksB : TSortRank10_vector(0 to 7);
  signal sEmptyB     : std_logic_vector(0 to 7);
  signal sMuonsO     : TGMTMu_vector(0 to 7);
  signal sIdxBitsO   : TIndexBits_vector(0 to 7);
  signal sSortRanksO : TSortRank10_vector(0 to 7);
  signal sEmptyO     : std_logic_vector(0 to 7);
  signal sMuonsF     : TGMTMu_vector(0 to 7);
  signal sIdxBitsF   : TIndexBits_vector(0 to 7);
  signal sSortRanksF : TSortRank10_vector(0 to 7);
  signal sEmptyF     : std_logic_vector(0 to 7);

  signal sSortRanksB_reg : TSortRank10_vector(0 to 7);
  signal sSortRanksO_reg : TSortRank10_vector(0 to 7);
  signal sSortRanksF_reg : TSortRank10_vector(0 to 7);
  signal sEmptyB_reg     : std_logic_vector(0 to 7);
  signal sEmptyO_reg     : std_logic_vector(0 to 7);
  signal sEmptyF_reg     : std_logic_vector(0 to 7);

  signal sIdxBitsB_reg : TIndexBits_vector(0 to 7);
  signal sIdxBitsO_reg : TIndexBits_vector(0 to 7);
  signal sIdxBitsF_reg : TIndexBits_vector(0 to 7);
  signal sMuonsB_reg   : TGMTMu_vector(0 to 7);
  signal sMuonsO_reg   : TGMTMu_vector(0 to 7);
  signal sMuonsF_reg   : TGMTMu_vector(0 to 7);

  signal sSortRanksB_store : TSortRank10_vector(0 to 7);
  signal sSortRanksO_store : TSortRank10_vector(0 to 7);
  signal sSortRanksF_store : TSortRank10_vector(0 to 7);
  signal sEmptyB_store     : std_logic_vector(0 to 7);
  signal sEmptyO_store     : std_logic_vector(0 to 7);
  signal sEmptyF_store     : std_logic_vector(0 to 7);

  signal sIdxBitsB_store : TIndexBits_vector(0 to 7);
  signal sIdxBitsO_store : TIndexBits_vector(0 to 7);
  signal sIdxBitsF_store : TIndexBits_vector(0 to 7);
  signal sMuonsB_store   : TGMTMu_vector(0 to 7);
  signal sMuonsO_store   : TGMTMu_vector(0 to 7);
  signal sMuonsF_store   : TGMTMu_vector(0 to 7);

  signal sSortRanksB_store2 : TSortRank10_vector(0 to 7);
  signal sSortRanksO_store2 : TSortRank10_vector(0 to 7);
  signal sSortRanksF_store2 : TSortRank10_vector(0 to 7);
  signal sEmptyB_store2     : std_logic_vector(0 to 7);
  signal sEmptyO_store2     : std_logic_vector(0 to 7);
  signal sEmptyF_store2     : std_logic_vector(0 to 7);

  signal sIdxBitsB_store2 : TIndexBits_vector(0 to 7);
  signal sIdxBitsO_store2 : TIndexBits_vector(0 to 7);
  signal sIdxBitsF_store2 : TIndexBits_vector(0 to 7);
  signal sMuonsB_store2   : TGMTMu_vector(0 to 7);
  signal sMuonsO_store2   : TGMTMu_vector(0 to 7);
  signal sMuonsF_store2   : TGMTMu_vector(0 to 7);

  signal sMuons       : TGMTMu_vector(0 to 7);
  signal sMuons_store : TGMTMu_vector(0 to 7);
  signal sMuons_reg   : TGMTMu_vector(0 to 7);

  -- RPC merging stuff
  signal iMuonsRPCf_reg    : TGMTMuRPC_vector(3 downto 0);
  signal iMuonsRPCf_store  : TGMTMuRPC_vector(3 downto 0);
  signal iMuonsRPCf_store2 : TGMTMuRPC_vector(3 downto 0);
  signal iMuonsRPCb_reg    : TGMTMuRPC_vector(3 downto 0);
  signal iMuonsRPCb_store  : TGMTMuRPC_vector(3 downto 0);
  signal iMuonsRPCb_store2 : TGMTMuRPC_vector(3 downto 0);

  signal sMQMatrixF             : TMQMatrix;
  signal sMQMatrixF_reg         : TMQMatrix;
  signal sPairVecF              : TPairVector(3 downto 0);
  signal sPairVecF_reg          : TPairVector(3 downto 0);
  signal sMatchedMuonsF         : TGMTMu_vector(3 downto 0);
  signal sCancelF_matched       : std_logic_vector(7 downto 0);
  signal sCancelO_matched_A     : std_logic_vector(7 downto 0);
  signal sMatchedMuonsF_reg     : TGMTMu_vector(3 downto 0);
  signal sCancelF_matched_reg   : std_logic_vector(7 downto 0);
  signal sCancelO_matched_A_reg : std_logic_vector(7 downto 0);
  signal sSortRanksMergedF      : TSortRank10_vector(3 downto 0);
  signal sEmptyMergedF          : std_logic_vector(3 downto 0);
  signal sIdxBitsMergedF        : TIndexBits_vector(3 downto 0);
  signal sMergedMuonsF          : TGMTMu_vector(3 downto 0);
  signal sSortRanksMergedF_reg  : TSortRank10_vector(3 downto 0);
  signal sEmptyMergedF_reg      : std_logic_vector(3 downto 0);
  signal sIdxBitsMergedF_reg    : TIndexBits_vector(3 downto 0);
  signal sMergedMuonsF_reg      : TGMTMu_vector(3 downto 0);
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
  signal sMatchedSortRanksF_reg : TSortRank10_vector(3 downto 0);
  signal sMatchedSortRanksF     : TSortRank10_vector(3 downto 0);
  signal sMatchedEmptyF_reg     : std_logic_vector(3 downto 0);
  signal sMatchedEmptyF         : std_logic_vector(3 downto 0);
  signal sMatchedIdxBitsF_reg   : TIndexBits_vector(3 downto 0);
  signal sMatchedIdxBitsF       : TIndexBits_vector(3 downto 0);
  signal sSortRanksRPCf_reg     : TSortRank10_vector(3 downto 0);
  signal sEmptyRPCf_reg         : std_logic_vector(3 downto 0);
  signal sIdxBitsRPCf_reg       : TIndexBits_vector(3 downto 0);

begin
  sMuonsO_plus      <= iMuonsO(0 to 17);
  sMuonsO_minus     <= iMuonsO(18 to 35);
  sMuonsF_plus      <= iMuonsF(0 to 17);
  sMuonsF_minus     <= iMuonsF(18 to 35);
  sTracksO_plus     <= iTracksO(0 to 5);
  sTracksO_minus    <= iTracksO(6 to 11);
  sTracksF_plus     <= iTracksF(0 to 5);
  sTracksF_minus    <= iTracksF(6 to 11);
  sSortRanksO_plus  <= iSortRanksO(0 to 17);
  sSortRanksO_minus <= iSortRanksO(18 to 35);
  sSortRanksF_plus  <= iSortRanksF(0 to 17);
  sSortRanksF_minus <= iSortRanksF(18 to 35);
  sEmptyO_plus      <= iEmptyO(0 to 17);
  sEmptyO_minus     <= iEmptyO(18 to 35);
  sEmptyF_plus      <= iEmptyF(0 to 17);
  sEmptyF_minus     <= iEmptyF(18 to 35);
  sIdxBitsO_plus    <= iIdxBitsO(0 to 17);
  sIdxBitsO_minus   <= iIdxBitsO(18 to 35);
  sIdxBitsF_plus    <= iIdxBitsF(0 to 17);
  sIdxBitsF_minus   <= iIdxBitsF(18 to 35);

  -- Calculate match quality between RPC and TF muons.
  generate_mq_unit : if rpc_merging generate
    mq_fwd : MatchQualityUnit
      port map (
        iMuonsRPC    => iMuonsRPCf,
        iMuonsBrlFwd => iMuonsF,
        iMuonsOvl    => iMuonsO,
        oMQMatrix    => sMQMatrixF,
        clk          => clk,
        sinit        => sinit);

    mq_brl : MatchQualityUnit
      port map (
        iMuonsRPC    => iMuonsRPCb,
        iMuonsBrlFwd => iMuonsB,
        iMuonsOvl    => iMuonsO,
        oMQMatrix    => sMQMatrixB,
        clk          => clk,
        sinit        => sinit);
  end generate generate_mq_unit;

  -- Send all muons into CU units
  -- one unit for each wedge -> each unit needs to compare 2 Ovl mu with
  -- 2+2 other mu
  -- If match found then cancel out (non-)ovl mu (configurable?)
  cou_bo_plus : CancelOutUnit_BO
    port map (
      iWedges_Ovl => sTracksO_plus,
      iWedges_B   => iTracksB,
      oCancel_Ovl => sCancelBO_O_plus,
      oCancel_B   => sCancelBO_B_plus,
      clk         => clk);
  cou_bo_minus : CancelOutUnit_BO
    port map (
      iWedges_Ovl => sTracksO_minus,
      iWedges_B   => iTracksB,
      oCancel_Ovl => sCancelBO_O_minus,
      oCancel_B   => sCancelBO_B_minus,
      clk         => clk);

  cou_fo_plus : CancelOutUnit_FO
    port map (
      iWedges_Ovl => sTracksO_plus,
      iWedges_F   => sTracksF_plus,
      oCancel_Ovl => sCancelFO_O_plus,
      oCancel_F   => sCancelFO_F_plus,
      clk         => clk);
  cou_fo_minus : CancelOutUnit_FO
    port map (
      iWedges_Ovl => sTracksO_minus,
      iWedges_F   => sTracksF_minus,
      oCancel_Ovl => sCancelFO_O_minus,
      oCancel_F   => sCancelFO_F_minus,
      clk         => clk);

  cou_b : CancelOutUnit_Single
    generic map (
      num_wedges => 12,
      num_tracks => 3)
    port map (
      iWedges => iTracksB,
      oCancel => sCancelB,
      clk     => clk);
  cou_o_plus : CancelOutUnit_Single
    generic map (
      num_wedges => 6,
      num_tracks => 3)
    port map (
      iWedges => sTracksO_plus,
      oCancel => sCancelO_plus,
      clk     => clk);
  cou_o_minus : CancelOutUnit_Single
    generic map (
      num_wedges => 6,
      num_tracks => 3)
    port map (
      iWedges => sTracksO_minus,
      oCancel => sCancelO_minus,
      clk     => clk);
  cou_f_plus : CancelOutUnit_Single
    generic map (
      num_wedges => 6,
      num_tracks => 3)
    port map (
      iWedges => sTracksF_plus,
      oCancel => sCancelF_plus,
      clk     => clk);
  cou_f_minus : CancelOutUnit_Single
    generic map (
      num_wedges => 6,
      num_tracks => 3)
    port map (
      iWedges => sTracksF_minus,
      oCancel => sCancelF_minus,
      clk     => clk);

  -- Register cancel-out bits and pair vector here.
  -- type   : sequential
  -- inputs : clk, sinit, sCancelBO, sCancelFO, sCancelB, sCancelO, sCancelF,
  -- sPairVecB, sPairVecF
  -- outputs: sCancelBO_reg, sCancelFO_reg, sCancelB_reg, sCancelO_reg,
  -- sCancelF_reg, sPairVecB_reg, sPairVecF_reg
  register_cobits_pairs : process (clk)
  begin  -- process register_cobits
    if clk'event and clk = '1' then     -- rising clock edge
      sCancelBO_B_reg       <= sCancelBO_B_plus or sCancelBO_B_minus;
      sCancelBO_O_plus_reg  <= sCancelBO_O_plus;
      sCancelBO_O_minus_reg <= sCancelBO_O_minus;
      sCancelFO_F_plus_reg  <= sCancelFO_F_plus;
      sCancelFO_F_minus_reg <= sCancelFO_F_minus;
      sCancelFO_O_plus_reg  <= sCancelFO_O_plus;
      sCancelFO_O_minus_reg <= sCancelFO_O_minus;
      sCancelB_reg          <= sCancelB;
      sCancelO_plus_reg     <= sCancelO_plus;
      sCancelO_minus_reg    <= sCancelO_minus;
      sCancelF_plus_reg     <= sCancelF_plus;
      sCancelF_minus_reg    <= sCancelF_minus;

      -- For RPC merging
      sMQMatrixB_reg <= sMQMatrixB;
      sMQMatrixF_reg <= sMQMatrixF;

      iMuonsRPCf_store <= iMuonsRPCf;
      iMuonsRPCb_store <= iMuonsRPCb;
    end if;
  end process register_cobits_pairs;

  -- Sort muons separately first, have ports for CU info
  sortB : SortStage0
    port map (
      iSortRanks => iSortRanksB,
      iEmpty     => iEmptyB,
      iCancel_A  => sCancelB_reg,
      iCancel_B  => sCancelBO_B_reg,
      iCancel_C  => (others => '0'),
      iMuons     => iMuonsB,
      iIdxBits   => iIdxBitsB,
      oMuons     => sMuonsB,
      oIdxBits   => sIdxBitsB,
      oSortRanks => sSortRanksB,
      oEmpty     => sEmptyB,
      clk        => clk,
      sinit      => sinit);
  sortO_plus : HalfSortStage0
    port map (
      iSortRanks => sSortRanksO_plus,
      iEmpty     => sEmptyO_plus,
      iCancel_A  => sCancelO_plus_reg,
      iCancel_B  => sCancelFO_O_plus_reg,
      iCancel_C  => sCancelBO_O_plus_reg,
      iMuons     => sMuonsO_plus,
      iIdxBits   => sIdxBitsO_plus,
      oMuons     => sSortedMuonsO_plus,
      oIdxBits   => sSortedIdxBitsO_plus,
      oSortRanks => sSortedSortRanksO_plus,
      oEmpty     => sSortedEmptyO_plus,
      clk        => clk,
      sinit      => sinit);
  sortO_minus : HalfSortStage0
    port map (
      iSortRanks => sSortRanksO_minus,
      iEmpty     => sEmptyO_minus,
      iCancel_A  => sCancelO_minus_reg,
      iCancel_B  => sCancelFO_O_minus_reg,
      iCancel_C  => sCancelBO_O_minus_reg,
      iMuons     => sMuonsO_minus,
      iIdxBits   => sIdxBitsO_minus,
      oMuons     => sSortedMuonsO_minus,
      oIdxBits   => sSortedIdxBitsO_minus,
      oSortRanks => sSortedSortRanksO_minus,
      oEmpty     => sSortedEmptyO_minus,
      clk        => clk,
      sinit      => sinit);
  sortF_plus : HalfSortStage0
    port map (
      iSortRanks => sSortRanksF_plus,
      iEmpty     => sEmptyF_plus,
      iCancel_A  => sCancelF_plus_reg,
      iCancel_B  => sCancelFO_F_plus_reg,
      iCancel_C  => (others => '0'),
      iMuons     => sMuonsF_plus,
      iIdxBits   => sIdxBitsF_plus,
      oMuons     => sSortedMuonsF_plus,
      oIdxBits   => sSortedIdxBitsF_plus,
      oSortRanks => sSortedSortRanksF_plus,
      oEmpty     => sSortedEmptyF_plus,
      clk        => clk,
      sinit      => sinit);
  sortF_minus : HalfSortStage0
    port map (
      iSortRanks => sSortRanksF_minus,
      iEmpty     => sEmptyF_minus,
      iCancel_A  => sCancelF_minus_reg,
      iCancel_B  => sCancelFO_F_minus_reg,
      iCancel_C  => (others => '0'),
      iMuons     => sMuonsF_minus,
      iIdxBits   => sIdxBitsF_minus,
      oMuons     => sSortedMuonsF_minus,
      oIdxBits   => sSortedIdxBitsF_minus,
      oSortRanks => sSortedSortRanksF_minus,
      oEmpty     => sSortedEmptyF_minus,
      clk        => clk,
      sinit      => sinit);

  gen_pair_finding_unit : if rpc_merging generate
    -- Find pairs based on MQ matrix between RPC and TF muons.
    pair_finding_fwd : PairFindingUnit
      port map (
        iMQMatrix => sMQMatrixF_reg,
        oPairs    => sPairVecF,
        clk       => clk,
        sinit     => sinit);

    pair_finding_brl : PairFindingUnit
      port map (
        iMQMatrix => sMQMatrixB_reg,
        oPairs    => sPairVecB,
        clk       => clk,
        sinit     => sinit);
  end generate gen_pair_finding_unit;

  reg_pairs : process (clk)
  begin  -- process reg_pairs
    if clk'event and clk = '1' then     -- rising clock edge
      sSortRanksB_store <= sSortRanksB;
      sSortRanksO_store <= sSortedSortRanksO_plus & sSortedSortRanksO_minus;
      sSortRanksF_store <= sSortedSortRanksF_plus & sSortedSortRanksF_minus;
      sEmptyB_store     <= sEmptyB;
      sEmptyO_store     <= sSortedEmptyO_plus & sSortedEmptyO_minus;
      sEmptyF_store     <= sSortedEmptyF_plus & sSortedEmptyF_minus;
      sIdxBitsB_store   <= sIdxBitsB;
      sIdxBitsO_store   <= sSortedIdxBitsO_plus & sSortedIdxBitsO_minus;
      sIdxBitsF_store   <= sSortedIdxBitsF_plus & sSortedIdxBitsF_minus;
      sMuonsB_store     <= sMuonsB;
      sMuonsO_store     <= sSortedMuonsO_plus & sSortedMuonsO_minus;
      sMuonsF_store     <= sSortedMuonsF_plus & sSortedMuonsF_minus;


      -- For RPC merging
      sPairVecB_reg <= sPairVecB;
      sPairVecF_reg <= sPairVecF;

      iMuonsRPCf_store2 <= iMuonsRPCf_store;
      iMuonsRPCb_store2 <= iMuonsRPCb_store;
    end if;
  end process reg_pairs;

  gen_matching_unit : if rpc_merging generate
    -- For RPC merging
    match_fwd : MatchingUnit
      port map (
        iSortRanksBrlFwd => sSortRanksF_store,
        iEmptyBrlFwd     => sEmptyF_store,
        iIdxBitsBrlFwd   => sIdxBitsF_store,
        iMuonsBrlFwd     => sMuonsF_store,
        iSortRanksOvl    => sSortRanksO_store,
        iEmptyOvl        => sEmptyO_store,
        iIdxBitsOvl      => sIdxBitsO_store,
        iMuonsOvl        => sMuonsO_store,
        iPairVec         => sPairVecF_reg,
        oSortRanks       => sMatchedSortRanksF,
        oEmpty           => sMatchedEmptyF,
        oIdxBits         => sMatchedIdxBitsF,
        oMuons           => sMatchedMuonsF,
        oCancelBrlFwd    => sCancelF_matched,
        oCancelOvl       => sCancelO_matched_A,
        clk              => clk,
        sinit            => sinit);

    match_brl : MatchingUnit
      port map (
        iSortRanksBrlFwd => sSortRanksB_store,
        iEmptyBrlFwd     => sEmptyB_store,
        iIdxBitsBrlFwd   => sIdxBitsB_store,
        iMuonsBrlFwd     => sMuonsB_store,
        iSortRanksOvl    => sSortRanksO_store,
        iEmptyOvl        => sEmptyO_store,
        iIdxBitsOvl      => sIdxBitsO_store,
        iMuonsOvl        => sMuonsO_store,
        iPairVec         => sPairVecB_reg,
        oSortRanks       => sMatchedSortRanksB,
        oEmpty           => sMatchedEmptyB,
        oIdxBits         => sMatchedIdxBitsB,
        oMuons           => sMatchedMuonsB,
        oCancelBrlFwd    => sCancelB_matched,
        oCancelOvl       => sCancelO_matched_B,
        clk              => clk,
        sinit            => sinit);
  end generate gen_matching_unit;

  -- Register muons after exiting stage 0 sorter.
  p1 : process (clk)
  begin  -- process p1
    if clk'event and clk = '1' then     -- rising clock edge
      sSortRanksB_store2 <= sSortRanksB_store;
      sSortRanksO_store2 <= sSortRanksO_store;
      sSortRanksF_store2 <= sSortRanksF_store;
      sEmptyB_store2     <= sEmptyB_store;
      sEmptyO_store2     <= sEmptyO_store;
      sEmptyF_store2     <= sEmptyF_store;
      sIdxBitsB_store2   <= sIdxBitsB_store;
      sIdxBitsO_store2   <= sIdxBitsO_store;
      sIdxBitsF_store2   <= sIdxBitsF_store;
      sMuonsB_store2     <= sMuonsB_store;
      sMuonsO_store2     <= sMuonsO_store;
      sMuonsF_store2     <= sMuonsF_store;

      -- For RPC merging
      sMatchedMuonsF_reg     <= sMatchedMuonsF;
      sCancelF_matched_reg   <= sCancelF_matched;
      sCancelO_matched_A_reg <= sCancelO_matched_A;
      sMatchedMuonsB_reg     <= sMatchedMuonsB;
      sCancelB_matched_reg   <= sCancelB_matched;
      sCancelO_matched_B_reg <= sCancelO_matched_B;

      sMatchedSortRanksB_reg <= sMatchedSortRanksB;
      sMatchedEmptyB_reg     <= sMatchedEmptyB;
      sMatchedIdxBitsB_reg   <= sMatchedIdxBitsB;
      sSortRanksRPCb_reg     <= iSortRanksRPCb;
      sEmptyRPCb_reg         <= iEmptyRPCb;
      sIdxBitsRPCb_reg       <= iIdxBitsRPCb;
      sMatchedSortRanksF_reg <= sMatchedSortRanksF;
      sMatchedEmptyF_reg     <= sMatchedEmptyF;
      sMatchedIdxBitsF_reg   <= sMatchedIdxBitsF;
      sSortRanksRPCf_reg     <= iSortRanksRPCf;
      sEmptyRPCf_reg         <= iEmptyRPCf;
      sIdxBitsRPCf_reg       <= iIdxBitsRPCf;

      iMuonsRPCf_reg <= iMuonsRPCf_store2;
      iMuonsRPCb_reg <= iMuonsRPCb_store2;
    end if;
  end process p1;

  gen_merger_unit : if rpc_merging generate
    -- For RPC merging
    merger_fwd : MergerUnit
      port map (
        iMuonsTF      => sMatchedMuonsF_reg,
        iSortRanksTF  => sMatchedSortRanksF_reg,
        iEmptyTF      => sMatchedEmptyF_reg,
        iIdxBitsTF    => sMatchedIdxBitsF_reg,
        iMuonsRPC     => iMuonsRPCf_reg,
        iSortRanksRPC => sSortRanksRPCf_reg,
        iEmptyRPC     => sEmptyRPCf_reg,
        iIdxBitsRPC   => sIdxBitsRPCf_reg,
        oSortRanks    => sSortRanksMergedF,
        oEmpty        => sEmptyMergedF,
        oIdxBits      => sIdxBitsMergedF,
        oMuons        => sMergedMuonsF,
        clk           => clk,
        sinit         => sinit);

    merger_brl : MergerUnit
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

  reg_merged_mu : process (clk)
  begin  -- process reg_merged_mu
    if clk'event and clk = '1' then     -- rising clock edge
      sSortRanksB_reg <= sSortRanksB_store2;
      sSortRanksO_reg <= sSortRanksO_store2;
      sSortRanksF_reg <= sSortRanksF_store2;
      sEmptyB_reg     <= sEmptyB_store2;
      sEmptyO_reg     <= sEmptyO_store2;
      sEmptyF_reg     <= sEmptyF_store2;
      sIdxBitsB_reg   <= sIdxBitsB_store2;
      sIdxBitsO_reg   <= sIdxBitsO_store2;
      sIdxBitsF_reg   <= sIdxBitsF_store2;
      sMuonsB_reg     <= sMuonsB_store2;
      sMuonsO_reg     <= sMuonsO_store2;
      sMuonsF_reg     <= sMuonsF_store2;

      sSortRanksMergedF_reg <= sSortRanksMergedF;
      sEmptyMergedF_reg     <= sEmptyMergedF;
      sIdxBitsMergedF_reg   <= sIdxBitsMergedF;
      sMergedMuonsF_reg     <= sMergedMuonsF;

      sSortRanksMergedB_reg <= sSortRanksMergedB;
      sEmptyMergedB_reg     <= sEmptyMergedB;
      sIdxBitsMergedB_reg   <= sIdxBitsMergedB;
      sMergedMuonsB_reg     <= sMergedMuonsB;
    end if;
  end process reg_merged_mu;

  -- Sort final muons together.
  gen_sorting_with_merged_muons : if rpc_merging generate
    sort_final : SortStage1_RPC
      port map (
        iSortRanksB       => sSortRanksB_reg,
        iEmptyB           => sEmptyB_reg,
        iIdxBitsB         => sIdxBitsB_reg,
        iMuonsB           => sMuonsB_reg,
        iSortRanksO       => sSortRanksO_reg,
        iEmptyO           => sEmptyO_reg,
        iIdxBitsO         => sIdxBitsO_reg,
        iMuonsO           => sMuonsO_reg,
        iSortRanksF       => sSortRanksF_reg,
        iEmptyF           => sEmptyF_reg,
        iIdxBitsF         => sIdxBitsF_reg,
        iMuonsF           => sMuonsF_reg,
        iSortRanksMergedB => sSortRanksMergedB_reg,
        iEmptyMergedB     => sEmptyMergedB_reg,
        iIdxBitsMergedB   => sIdxBitsMergedB_reg,
        iMuonsMergedB     => sMergedMuonsB_reg,
        iSortRanksMergedF => sSortRanksMergedF_reg,
        iEmptyMergedF     => sEmptyMergedF_reg,
        iIdxBitsMergedF   => sIdxBitsMergedF_reg,
        iMuonsMergedF     => sMergedMuonsF_reg,
        iCancelB          => sCancelB_matched_reg,
        iCancelO_A        => sCancelO_matched_A_reg,
        iCancelO_B        => sCancelO_matched_B_reg,
        iCancelF          => sCancelF_matched_reg,
        oIdxBits          => oIdxBits,  -- Goes out to IsoAU.
        oMuons            => sMuons,
        clk               => clk,
        sinit             => sinit);
  end generate gen_sorting_with_merged_muons;

  gen_sorting_without_merged_muons : if not rpc_merging generate
    sort_final : SortStage1
      port map (
        iSortRanksB => sSortRanksB_reg,
        iEmptyB     => sEmptyB_reg,
        iIdxBitsB   => sIdxBitsB_reg,
        iMuonsB     => sMuonsB_reg,
        iSortRanksO => sSortRanksO_reg,
        iEmptyO     => sEmptyO_reg,
        iIdxBitsO   => sIdxBitsO_reg,
        iMuonsO     => sMuonsO_reg,
        iSortRanksF => sSortRanksF_reg,
        iEmptyF     => sEmptyF_reg,
        iIdxBitsF   => sIdxBitsF_reg,
        iMuonsF     => sMuonsF_reg,
        oIdxBits    => oIdxBits,        -- Goes out to IsoAU.
        oMuons      => sMuons,
        clk         => clk,
        sinit       => sinit);
  end generate gen_sorting_without_merged_muons;

  mu_store : process (clk)
  begin  -- process mu_store
    if clk'event and clk = '1' then     -- rising clock edge
      sMuons_store <= sMuons;
    end if;
  end process mu_store;

  -- TODO: Make this *actually* require 1/2 BX!
  -- Requires 1/2 BX
  final_mu_reg : process (clk)
  begin  -- process final_mu_reg
    if clk'event and clk = '1' then     -- rising clock edge
      sMuons_reg <= sMuons_store;
    end if;
  end process final_mu_reg;

  -- TODO: Move this register into GMT.vhd to replace final register there.
  -- purpose: Need to wait for 0.5 BX for ISO bits.
  -- outputs: oMuons
  final_reg : process (clk)
  begin  -- process final_reg
    if clk'event and clk = '1' then     -- rising clock edge
      for i in oMuons'range loop
        oMuons(i).sysign <= sMuons_reg(i).sysign;
        oMuons(i).eta    <= sMuons_reg(i).eta;
        oMuons(i).qual   <= sMuons_reg(i).qual;
        oMuons(i).pt     <= sMuons_reg(i).pt;
        oMuons(i).phi    <= sMuons_reg(i).phi;
      end loop;  -- i
    end if;
  end process final_reg;
end architecture behavioral;
