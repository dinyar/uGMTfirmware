library IEEE;
use IEEE.STD_LOGIC_1164.all;
library Types;
use Types.GMTTypes.all;

entity MergerUnit is
  
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

end MergerUnit;

architecture behavioral of MergerUnit is

  component MuonMerger
    port (
      iMuonTF      : in  TGMTMu;
      iSortRankTF  : in  TSortRank10;
      iEmptyTF     : in  std_logic;
      iIdxBitsTF   : in  TIndexBits;
      iMuonRPC     : in  TGMTMuRPC;
      iSortRankRPC : in  TSortRank10;
      iEmptyRPC    : in  std_logic;
      iIdxBitsRPC  : in  TIndexBits;
      oSortRank    : out TSortRank10;
      oEmpty       : out std_logic;
      oIdxBits     : out TIndexBits;
      oMuon        : out TGMTMu;
      clk          : in  std_logic;
      sinit        : in  std_logic);
  end component;

  signal sMuons : TGMTMu_vector(3 downto 0);
  
begin  -- behavioral

  g1 : for i in iMuonsRPC'range generate
    muon_merging : MuonMerger
      port map (
        iMuonTF      => iMuonsTF(i),
        iSortRankTF  => iSortRanksTF(i),
        iEmptyTF     => iEmptyTF(i),
        iIdxBitsTF   => iIdxBitsTF(i),
        iMuonRPC     => iMuonsRPC(i),
        iSortRankRPC => iSortRanksRPC(i),
        iEmptyRPC    => iEmptyRPC(i),
        iIdxBitsRPC  => iIdxBitsRPC(i),
        oSortRank    => oSortRanks(i),
        oEmpty       => oEmpty(i),
        oIdxBits     => oIdxBits(i),
        oMuon        => sMuons(i),
        clk          => clk,
        sinit        => sinit);
  end generate g1;

  oMuons <= sMuons;

end behavioral;
