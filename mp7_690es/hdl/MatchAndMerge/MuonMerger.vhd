library IEEE;
use IEEE.STD_LOGIC_1164.all;
library Types;
use Types.GMTTypes.all;

entity MuonMerger is
  
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
    oMuon        : out TGMTMu;          -- merged muon
    clk          : in  std_logic;
    sinit        : in  std_logic);

end MuonMerger;

architecture behavioral of MuonMerger is
  signal sSortRank : TSortRank10;
  signal sEmpty    : std_logic;
  signal sIdxBits  : TIndexBits;
  signal sMuon     : TGMTMu;
begin  -- behavioral

  -- TODO: Missing actual merging!

  sSortRank <= iSortRankTF;
  sEmpty    <= iEmptyTF;
  sIdxBits  <= iIdxBitsTF;
  sMuon     <= iMuonTF;

  oSortRank <= sSortRank;
  oEmpty    <= sEmpty;
  oIdxBits  <= sIdxBits;
  oMuon     <= sMuon;
end behavioral;
