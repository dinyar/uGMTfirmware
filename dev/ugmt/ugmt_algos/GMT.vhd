library IEEE;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;
library Types;
use Types.GMTTypes.all;

entity GMT is
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

    iEnergies : in TCaloRegionEtaSlice_vector(31 downto 0);  -- The outer two
                                                             -- slices will be
                                                             -- set to '0'.
                                                             -- XST should
                                                             -- optimize logic
                                                             -- appropriately.

    oMuons : out TGMTMu_vector(7 downto 0);
    oIso   : out TIsoBits_vector(7 downto 0);

    clk   : in std_logic;
    sinit : in std_logic);
end GMT;

architecture Behavioral of GMT is

  -----------------------------------------------------------------------------
  -- components
  -----------------------------------------------------------------------------

  component IsoAssignmentUnit is
    port (
      iEnergies  : in  TCaloRegionEtaSlice_vector;
      iMuonsB    : in  TGMTMu_vector (0 to 35);
      iMuonsO    : in  TGMTMu_vector (0 to 35);
      iMuonsF    : in  TGMTMu_vector (0 to 35);
      iMuIdxBits : in  TIndexBits_vector (7 downto 0);
      oIsoBits   : out TIsoBits_vector (7 downto 0);
      clk        : in  std_logic;
      sinit      : in  std_logic);
  end component;

  component SortAndCancelUnit
    generic (
      rpc_merging : boolean);
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
      sinit : in std_logic
      );
  end component;

  -----------------------------------------------------------------------------
  -- signals
  -----------------------------------------------------------------------------

  signal sGMTCaloInfo_flat : std_logic_vector(0 to 6911);
  signal sEnergyDeposits   : TCaloRegionEtaSlice_vector(31 downto 0);

  signal sGMTMu_flat : std_logic_vector(0 to 3995);
  signal sMuonsInB   : TGMTMuIn_vector(0 to 35);
  signal sMuonsInO   : TGMTMuIn_vector(0 to 35);
  signal sMuonsInF   : TGMTMuIn_vector(0 to 35);
  signal sMuonsB     : TGMTMu_vector(0 to 35);
  signal sMuonsO     : TGMTMu_vector(0 to 35);
  signal sMuonsF     : TGMTMu_vector(0 to 35);

  signal sWedgeAddresses_flat : std_logic_vector(0 to 4319);
  signal sTracksB             : TGMTMuTracks_vector(0 to 11);
  signal sTracksO             : TGMTMuTracks_vector(0 to 11);
  signal sTracksF             : TGMTMuTracks_vector(0 to 11);

  signal sSortRanks_flat : std_logic_vector(0 to 1079);
  signal sSortRanksB     : TSortRank10_vector(0 to 35);
  signal sSortRanksO     : TSortRank10_vector(0 to 35);
  signal sSortRanksF     : TSortRank10_vector(0 to 35);

  signal sIdxBits_flat : std_logic_vector(0 to 755);
  signal sIdxBitsB     : TIndexBits_vector(0 to 35);
  signal sIdxBitsO     : TIndexBits_vector(0 to 35);
  signal sIdxBitsF     : TIndexBits_vector(0 to 35);

  signal sEmpty_flat : std_logic_vector(0 to 107);
  signal sEmptyB     : std_logic_vector(0 to 35);
  signal sEmptyO     : std_logic_vector(0 to 35);
  signal sEmptyF     : std_logic_vector(0 to 35);

  signal sIsoBits : TIsoBits_vector(7 downto 0);

  signal sMuIdxBits : TIndexBits_vector(7 downto 0);

  signal sMuons_spy    : std_logic_vector(0 to 295);
  signal sMuons_sorted : TGMTMu_vector(7 downto 0);

  -- For RPC merging.
  signal sMuonsRPCb     : TGMTMuRPC_vector(3 downto 0);
  signal sMuonsRPCf     : TGMTMuRPC_vector(3 downto 0);
  signal sSortRanksRPCb : TSortRank10_vector(3 downto 0);
  signal sSortRanksRPCf : TSortRank10_vector(3 downto 0);
  signal sEmptyRPCb     : std_logic_vector(3 downto 0);
  signal sEmptyRPCf     : std_logic_vector(3 downto 0);
  signal sIdxBitsRPCb   : TIndexBits_vector(3 downto 0);
  signal sIdxBitsRPCf   : TIndexBits_vector(3 downto 0);

begin

  

  -----------------------------------------------------------------------------
  -- calo stuff
  -----------------------------------------------------------------------------
  assign_iso : IsoAssignmentUnit
    port map (
      iEnergies  => iEnergies,
      iMuonsB    => sMuonsB,
      iMuonsO    => sMuonsO,
      iMuonsF    => sMuonsF,
      iMuIdxBits => sMuIdxBits,
      oIsoBits   => sIsoBits,
      clk        => clk,
      sinit      => sinit);
  -----------------------------------------------------------------------------
  -- sorters & COUs
  -----------------------------------------------------------------------------

  sort_and_cancel : SortAndCancelUnit
    generic map (
      rpc_merging => false)
    port map (
      iMuonsB        => iMuonsB,
      iMuonsO        => iMuonsO_plus & iMuonsO_minus,
      iMuonsF        => iMuonsF_plus & iMuonsF_minus,
      -- For RPC merging.
      iMuonsRPCb     => sMuonsRPCb,
      iMuonsRPCf     => sMuonsRPCf,
      iSortRanksRPCb => sSortRanksRPCb,
      iSortRanksRPCf => sSortRanksRPCf,
      iEmptyRPCb     => sEmptyRPCb,
      iEmptyRPCf     => sEmptyRPCf,
      iIdxBitsRPCb   => sIdxBitsRPCb,
      iIdxBitsRPCf   => sIdxBitsRPCf,

      iTracksB    => iTracksB,
      iTracksO    => iTracksO,
      iTracksF    => iTracksF,
      iSortRanksB => iSortRanksB,
      iSortRanksO => iSortRanksO_plus & iSortRanksO_minus,
      iSortRanksF => iSortRanksF_plus & iSortRanksF_minus,
      iEmptyB     => iEmptyB,
      iEmptyO     => iEmptyO_plus & iEmptyO_minus,
      iEmptyF     => iEmptyF_plus & iEmptyF_minus,
      iIdxBitsB   => iIdxBitsB,
      iIdxBitsO   => iIdxBitsO_plus & iIdxBitsO_minus,
      iIdxBitsF   => iIdxBitsF_plus & iIdxBitsF_minus,
      oIdxBits    => sMuIdxBits,
      oMuons      => sMuons_sorted,
      clk         => clk,
      sinit       => sinit);


  -- TODO: Is this last flip-flop needed?
  -----------------------------------------------------------------------------
  -- final flip-flop
  -----------------------------------------------------------------------------
  p1 : process (clk)
  begin  -- process p1
    if clk'event and clk = '1' then     -- rising clock edge
      oMuons <= sMuons_sorted;
      oIso   <= sIsoBits;
    end if;
  end process p1;

end Behavioral;
