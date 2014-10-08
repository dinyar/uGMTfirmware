library IEEE;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;

use work.mp7_data_types.all;
use work.ipbus.all;
use work.ipbus_decode_uGMT.all;

use work.GMTTypes.all;

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

    iEnergies : in TCaloRegionEtaSlice_vector(31 downto 0);
    -- The outer two slices will be set to '0'. XST should optimize logic
    -- appropriately.

    oIntermediateMuonsB  : out TGMTMu_vector(7 downto 0);
    oIntermediateMuonsO  : out TGMTMu_vector(7 downto 0);
    oIntermediateMuonsF  : out TGMTMu_vector(7 downto 0);
    oSortRanksB          : out TSortRank10_vector(7 downto 0);
    oSortRanksO          : out TSortRank10_vector(7 downto 0);
    oSortRanksF          : out TSortRank10_vector(7 downto 0);
    oFinalEnergies       : out TCaloArea_vector(7 downto 0);
    oExtrapolatedCoordsB : out TSpatialCoordinate_vector(35 downto 0);
    oExtrapolatedCoordsO : out TSpatialCoordinate_vector(35 downto 0);
    oExtrapolatedCoordsF : out TSpatialCoordinate_vector(35 downto 0);

    oMuons : out TGMTMu_vector(7 downto 0);
    oIso   : out TIsoBits_vector(7 downto 0);

    clk     : in  std_logic;
    clk_ipb : in  std_logic;
    sinit   : in  std_logic;
    ipb_in  : in  ipb_wbus;
    ipb_out : out ipb_rbus
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
  signal sMuonsO       : TGMTMu_vector(35 downto 0);
  signal sMuonsF       : TGMTMu_vector(35 downto 0);
  signal sSortRanksO   : TSortRank10_vector(35 downto 0);
  signal sSortRanksF   : TSortRank10_vector(35 downto 0);
  signal sEmptyO       : std_logic_vector(35 downto 0);
  signal sEmptyF       : std_logic_vector(35 downto 0);
  signal sIdxBitsO     : TIndexBits_vector(35 downto 0);
  signal sIdxBitsF     : TIndexBits_vector(35 downto 0);
  signal sIsoBits      : TIsoBits_vector(7 downto 0);
  signal sMuIdxBits    : TIndexBits_vector(7 downto 0);
  signal sFinalMuPt    : TMuonPT_vector(7 downto 0);
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

  -- For intermediates

  signal   sFinalEnergies              : TCaloArea_vector(7 downto 0);
  type     TEnergyBuffer is array (integer range <>) of TCaloArea_vector(7 downto 0);
  constant ENERGY_INTERMEDIATE_DELAY   : natural := 4;  -- Delay to sync
                                                        -- energies  with
                                                        -- final muons.
  signal   sFinalEnergies_buffer       : TEnergyBuffer(ENERGY_INTERMEDIATE_DELAY-1 downto 0);
  signal   sExtrapolatedCoordsB        : TSpatialCoordinate_vector(35 downto 0);
  signal   sExtrapolatedCoordsO        : TSpatialCoordinate_vector(35 downto 0);
  signal   sExtrapolatedCoordsF        : TSpatialCoordinate_vector(35 downto 0);
  type     TCoordsBuffer is array (integer range <>) of TSpatialCoordinate_vector(35 downto 0);
  constant COORD_DELAY                 : natural := 5;  -- Delay to sync extrapolated
                                        -- coordinates with final muons.
  signal   sExtrapolatedCoordsB_buffer : TCoordsBuffer(COORD_DELAY-1 downto 0);
  signal   sExtrapolatedCoordsO_buffer : TCoordsBuffer(COORD_DELAY-1 downto 0);
  signal   sExtrapolatedCoordsF_buffer : TCoordsBuffer(COORD_DELAY-1 downto 0);

  signal sIntermediateMuonsB     : TGMTMu_vector(7 downto 0);
  signal sIntermediateMuonsO     : TGMTMu_vector(7 downto 0);
  signal sIntermediateMuonsF     : TGMTMu_vector(7 downto 0);
  signal sIntermediateSortRanksB : TSortRank10_vector(7 downto 0);
  signal sIntermediateSortRanksO : TSortRank10_vector(7 downto 0);
  signal sIntermediateSortRanksF : TSortRank10_vector(7 downto 0);

  constant MU_INTERMEDIATE_DELAY         : natural := 4;  -- Delay to sync
                                                          -- intermediates with
                                                          -- final muons.
  type     TMuonBuffer is array (integer range <>) of TGMTMu_vector(7 downto 0);
  signal   sIntermediateMuonB_buffer     : TMuonBuffer(MU_INTERMEDIATE_DELAY-1 downto 0);
  signal   sIntermediateMuonO_buffer     : TMuonBuffer(MU_INTERMEDIATE_DELAY-1 downto 0);
  signal   sIntermediateMuonF_buffer     : TMuonBuffer(MU_INTERMEDIATE_DELAY-1 downto 0);
  type     TSortRankBuffer is array (integer range <>) of TSortRank10_vector(7 downto 0);
  signal   sIntermediateSortRankB_buffer : TSortRankBuffer(MU_INTERMEDIATE_DELAY-1 downto 0);
  signal   sIntermediateSortRankO_buffer : TSortRankBuffer(MU_INTERMEDIATE_DELAY-1 downto 0);
  signal   sIntermediateSortRankF_buffer : TSortRankBuffer(MU_INTERMEDIATE_DELAY-1 downto 0);

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

  sMuonsO     <= iMuonsO_plus & iMuonsO_minus;
  sMuonsF     <= iMuonsF_plus & iMuonsF_minus;
  sSortRanksO <= iSortRanksO_plus & iSortRanksO_minus;
  sSortRanksF <= iSortRanksF_plus & iSortRanksF_minus;
  sEmptyO     <= iEmptyO_plus & iEmptyO_minus;
  sEmptyF     <= iEmptyF_plus & iEmptyF_minus;
  sIdxBitsO   <= iIdxBitsO_plus & iIdxBitsO_minus;
  sIdxBitsO   <= iIdxBitsO_plus & iIdxBitsO_minus;

  -----------------------------------------------------------------------------
  -- calo stuff
  -----------------------------------------------------------------------------
  assign_iso : entity work.IsoAssignmentUnit
    port map (
      iEnergies            => iEnergies,
      iMuonsB              => iMuonsB,
      iMuonsO              => sMuonsO,
      iMuonsF              => sMuonsF,
      iMuIdxBits           => sMuIdxBits,
      iFinalMuPt           => sFinalMuPt,
      oIsoBits             => sIsoBits,
      oFinalEnergies       => sFinalEnergies,
      oExtrapolatedCoordsB => sExtrapolatedCoordsB,
      oExtrapolatedCoordsO => sExtrapolatedCoordsO,
      oExtrapolatedCoordsF => sExtrapolatedCoordsF,
      clk                  => clk,
      clk_ipb              => clk_ipb,
      sinit                => sinit,
      ipb_in               => ipbw(N_SLV_ISOLATION),
      ipb_out              => ipbr(N_SLV_ISOLATION)
      );

  -----------------------------------------------------------------------------
  -- sorters & COUs
  -----------------------------------------------------------------------------

  sort_and_cancel : entity work.SortAndCancelUnit
    generic map (
      rpc_merging => false)
    port map (
      iMuonsB => iMuonsB,
      iMuonsO => sMuonsO,
      iMuonsF => sMuonsF,

      -- For RPC merging.
      iMuonsRPCb     => sMuonsRPCb,
      iMuonsRPCf     => sMuonsRPCf,
      iSortRanksRPCb => sSortRanksRPCb,
      iSortRanksRPCf => sSortRanksRPCf,
      iEmptyRPCb     => sEmptyRPCb,
      iEmptyRPCf     => sEmptyRPCf,
      iIdxBitsRPCb   => sIdxBitsRPCb,
      iIdxBitsRPCf   => sIdxBitsRPCf,

      iTracksB            => iTracksB,
      iTracksO            => iTracksO,
      iTracksF            => iTracksF,
      iSortRanksB         => iSortRanksB,
      iSortRanksO         => sSortRanksO,
      iSortRanksF         => sSortRanksF,
      iEmptyB             => iEmptyB,
      iEmptyO             => sEmptyO,
      iEmptyF             => sEmptyF,
      iIdxBitsB           => iIdxBitsB,
      iIdxBitsO           => sIdxBitsO,
      iIdxBitsF           => sIdxBitsF,
      oIntermediateMuonsB => sIntermediateMuonsB,
      oIntermediateMuonsO => sIntermediateMuonsO,
      oIntermediateMuonsF => sIntermediateMuonsF,
      oSortRanksB         => sIntermediateSortRanksB,
      oSortRanksO         => sIntermediateSortRanksO,
      oSortRanksF         => sIntermediateSortRanksF,
      oIdxBits            => sMuIdxBits,
      oMuPt               => sFinalMuPt,
      oMuons              => sMuons_sorted,
      clk                 => clk,
      clk_ipb             => clk_ipb,
      sinit               => sinit,
      ipb_in              => ipbw(N_SLV_SORTING),
      ipb_out             => ipbr(N_SLV_SORTING)
      );



  -- TODO: Do I need last flip-flop?
  -----------------------------------------------------------------------------
  -- final flip-flop
  -----------------------------------------------------------------------------
  p1 : process (clk)
  begin  -- process p1
    if clk'event and clk = '1' then     -- rising clock edge
      sIntermediateMuonB_buffer(0)                                    <= sIntermediateMuonsB;
      sIntermediateMuonO_buffer(0)                                    <= sIntermediateMuonsO;
      sIntermediateMuonF_buffer(0)                                    <= sIntermediateMuonsF;
      sIntermediateMuonB_buffer(MU_INTERMEDIATE_DELAY-1 downto 1)     <= sIntermediateMuonB_buffer(MU_INTERMEDIATE_DELAY-2 downto 0);
      sIntermediateMuonO_buffer(MU_INTERMEDIATE_DELAY-1 downto 1)     <= sIntermediateMuonO_buffer(MU_INTERMEDIATE_DELAY-2 downto 0);
      sIntermediateMuonF_buffer(MU_INTERMEDIATE_DELAY-1 downto 1)     <= sIntermediateMuonF_buffer(MU_INTERMEDIATE_DELAY-2 downto 0);
      sIntermediateSortRankB_buffer(0)                                <= sIntermediateSortRanksB;
      sIntermediateSortRankO_buffer(0)                                <= sIntermediateSortRanksO;
      sIntermediateSortRankF_buffer(0)                                <= sIntermediateSortRanksF;
      sIntermediateSortRankB_buffer(MU_INTERMEDIATE_DELAY-1 downto 1) <= sIntermediateSortRankB_buffer(MU_INTERMEDIATE_DELAY-2 downto 0);
      sIntermediateSortRankO_buffer(MU_INTERMEDIATE_DELAY-1 downto 1) <= sIntermediateSortRankO_buffer(MU_INTERMEDIATE_DELAY-2 downto 0);
      sIntermediateSortRankF_buffer(MU_INTERMEDIATE_DELAY-1 downto 1) <= sIntermediateSortRankF_buffer(MU_INTERMEDIATE_DELAY-2 downto 0);
      sFinalEnergies_buffer(0)                                        <= sFinalEnergies;
      sFinalEnergies_buffer(ENERGY_INTERMEDIATE_DELAY-1 downto 1)     <= sFinalEnergies_buffer(ENERGY_INTERMEDIATE_DELAY-2 downto 0);
      sExtrapolatedCoordsB_buffer(0)                                  <= sExtrapolatedCoordsB;
      sExtrapolatedCoordsO_buffer(0)                                  <= sExtrapolatedCoordsO;
      sExtrapolatedCoordsF_buffer(0)                                  <= sExtrapolatedCoordsF;
      sExtrapolatedCoordsB_buffer(COORD_DELAY-1 downto 1)             <= sExtrapolatedCoordsB_buffer(COORD_DELAY-2 downto 0);
      sExtrapolatedCoordsO_buffer(COORD_DELAY-1 downto 1)             <= sExtrapolatedCoordsO_buffer(COORD_DELAY-2 downto 0);
      sExtrapolatedCoordsF_buffer(COORD_DELAY-1 downto 1)             <= sExtrapolatedCoordsF_buffer(COORD_DELAY-2 downto 0);

      oMuons <= sMuons_sorted;
      oIso   <= sIsoBits;
    end if;
  end process p1;
  oIntermediateMuonsB  <= sIntermediateMuonB_buffer(MU_INTERMEDIATE_DELAY-1);
  oIntermediateMuonsO  <= sIntermediateMuonO_buffer(MU_INTERMEDIATE_DELAY-1);
  oIntermediateMuonsF  <= sIntermediateMuonF_buffer(MU_INTERMEDIATE_DELAY-1);
  oSortRanksB          <= sIntermediateSortRankB_buffer(MU_INTERMEDIATE_DELAY-1);
  oSortRanksO          <= sIntermediateSortRankO_buffer(MU_INTERMEDIATE_DELAY-1);
  oSortRanksF          <= sIntermediateSortRankF_buffer(MU_INTERMEDIATE_DELAY-1);
  oFinalEnergies       <= sFinalEnergies_buffer(ENERGY_INTERMEDIATE_DELAY-1);
  -- TODO: Connect outputs to buffers!!
  oExtrapolatedCoordsB <= sExtrapolatedCoordsB_buffer(COORD_DELAY-1);
  oExtrapolatedCoordsO <= sExtrapolatedCoordsO_buffer(COORD_DELAY-1);
  oExtrapolatedCoordsF <= sExtrapolatedCoordsF_buffer(COORD_DELAY-1);
  
end Behavioral;
