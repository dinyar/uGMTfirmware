library IEEE;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;

use work.mp7_data_types.all;
use work.ipbus.all;
use work.ipbus_decode_uGMT.all;

use work.GMTTypes.all;
use work.mp7_brd_decl.all;

entity GMT is
  port (
    iMuonsB       : in TGMTMu_vector(35 downto 0);
    iMuonsO       : in TGMTMu_vector(35 downto 0);
    iMuonsE       : in TGMTMu_vector(35 downto 0);
    iTracksB      : in TGMTMuTracks_vector(11 downto 0);
    iTracksO      : in TGMTMuTracks_vector(11 downto 0);
    iTracksE      : in TGMTMuTracks_vector(11 downto 0);
    iSortRanksB   : in TSortRank10_vector(35 downto 0);
    iSortRanksO   : in TSortRank10_vector(35 downto 0);
    iSortRanksE   : in TSortRank10_vector(35 downto 0);
    iIdxBitsB     : in TIndexBits_vector(35 downto 0);
    iIdxBitsO     : in TIndexBits_vector(35 downto 0);
    iIdxBitsE     : in TIndexBits_vector(35 downto 0);
    iCaloIdxBitsB : in TCaloIndexBit_vector(35 downto 0);
    iCaloIdxBitsO : in TCaloIndexBit_vector(35 downto 0);
    iCaloIdxBitsE : in TCaloIndexBit_vector(35 downto 0);

    iEnergies : in TCaloRegionEtaSlice_vector(31 downto 0);
    -- The outer two slices will be set to '0'. XST should optimize logic
    -- appropriately.

    oIntermediateMuonsB     : out TGMTMu_vector(7 downto 0);
    oIntermediateMuonsO     : out TGMTMu_vector(7 downto 0);
    oIntermediateMuonsE     : out TGMTMu_vector(7 downto 0);
    oIntermediateSortRanksB : out TSortRank10_vector(7 downto 0);
    oIntermediateSortRanksO : out TSortRank10_vector(7 downto 0);
    oIntermediateSortRanksE : out TSortRank10_vector(7 downto 0);
    oMuIdxBits              : out TIndexBits_vector (7 downto 0);

    oMuons : out TGMTMu_vector(7 downto 0);
    oIso   : out TIsoBits_vector(7 downto 0);

    mu_ctr_rst : in  std_logic;
    clk                : in  std_logic;
    clk_ipb            : in  std_logic;
    sinit              : in  std_logic;
    rst_loc            : in  std_logic_vector(N_REGION - 1 downto 0);
    ipb_in             : in  ipb_wbus;
    ipb_out            : out ipb_rbus
    );
end GMT;

architecture Behavioral of GMT is

  -----------------------------------------------------------------------------
  -- signals
  -----------------------------------------------------------------------------

  -- IPbus
  signal ipbw : ipb_wbus_array(N_SLAVES - 1 downto 0);
  signal ipbr : ipb_rbus_array(N_SLAVES - 1 downto 0);

  -- Core uGMT algos
  signal sIsoBits      : TIsoBits_vector(7 downto 0);
  signal sMuIdxBits    : TIndexBits_vector(7 downto 0);
  signal sFinalMuPt    : TMuonPT_vector(7 downto 0);
  signal sMuons_sorted : TGMTMu_vector(7 downto 0);

  -- For intermediates
  signal sIntermediateMuonsB     : TGMTMu_vector(7 downto 0);
  signal sIntermediateMuonsO     : TGMTMu_vector(7 downto 0);
  signal sIntermediateMuonsE     : TGMTMu_vector(7 downto 0);
  signal sIntermediateSortRanksB : TSortRank10_vector(7 downto 0);
  signal sIntermediateSortRanksO : TSortRank10_vector(7 downto 0);
  signal sIntermediateSortRanksE : TSortRank10_vector(7 downto 0);

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
      sel             => ipbus_sel_uGMT(ipb_in.ipb_addr),
      ipb_to_slaves   => ipbw,
      ipb_from_slaves => ipbr
      );

  -----------------------------------------------------------------------------
  -- calo stuff
  -----------------------------------------------------------------------------
  assign_iso : entity work.IsoAssignmentUnit
    port map (
      iEnergies     => iEnergies,
      iMuonsB       => iMuonsB,
      iMuonsO       => iMuonsO,
      iMuonsE       => iMuonsE,
      iCaloIdxBitsB => iCaloIdxBitsB,
      iCaloIdxBitsO => iCaloIdxBitsO,
      iCaloIdxBitsE => iCaloIdxBitsE,
      iMuIdxBits    => sMuIdxBits,
      iFinalMuPt    => sFinalMuPt,
      oIsoBits      => sIsoBits,
      clk           => clk,
      clk_ipb       => clk_ipb,
      sinit         => sinit,
      ipb_in        => ipbw(N_SLV_ISOLATION),
      ipb_out       => ipbr(N_SLV_ISOLATION)
      );

  -----------------------------------------------------------------------------
  -- sorters & COUs
  -----------------------------------------------------------------------------

  sort_and_cancel : entity work.SortAndCancelUnit
    port map (
      iMuonsB => iMuonsB,
      iMuonsO => iMuonsO,
      iMuonsE => iMuonsE,

      iTracksB                => iTracksB,
      iTracksO                => iTracksO,
      iTracksE                => iTracksE,
      iSortRanksB             => iSortRanksB,
      iSortRanksO             => iSortRanksO,
      iSortRanksE             => iSortRanksE,
      iIdxBitsB               => iIdxBitsB,
      iIdxBitsO               => iIdxBitsO,
      iIdxBitsE               => iIdxBitsE,
      oIntermediateMuonsB     => sIntermediateMuonsB,
      oIntermediateMuonsO     => sIntermediateMuonsO,
      oIntermediateMuonsE     => sIntermediateMuonsE,
      oIntermediateSortRanksB => sIntermediateSortRanksB,
      oIntermediateSortRanksO => sIntermediateSortRanksO,
      oIntermediateSortRanksE => sIntermediateSortRanksE,
      oIdxBits                => sMuIdxBits,
      oMuPt                   => sFinalMuPt,
      oMuons                  => sMuons_sorted,
      mu_ctr_rst              => mu_ctr_rst,
      clk                     => clk,
      clk_ipb                 => clk_ipb,
      sinit                   => sinit,
      rst_loc                 => rst_loc,
      ipb_in                  => ipbw(N_SLV_SORTING),
      ipb_out                 => ipbr(N_SLV_SORTING)
      );

  oIntermediateMuonsB     <= sIntermediateMuonsB;
  oIntermediateMuonsO     <= sIntermediateMuonsO;
  oIntermediateMuonsE     <= sIntermediateMuonsE;
  oIntermediateSortRanksB <= sIntermediateSortRanksB;
  oIntermediateSortRanksO <= sIntermediateSortRanksO;
  oIntermediateSortRanksE <= sIntermediateSortRanksE;

  -- Synchronize idx bits to final muons.
  final_mu_reg : process (clk)
  begin  -- process final_mu_reg
    if clk'event and clk = '0' then     -- falling clock edge
      oMuIdxBits <= sMuIdxBits;
    end if;
  end process final_mu_reg;

  oMuons <= sMuons_sorted;
  oIso   <= sIsoBits;

end Behavioral;
