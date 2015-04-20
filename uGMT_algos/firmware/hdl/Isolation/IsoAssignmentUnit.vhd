library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use work.mp7_data_types.all;
use work.ipbus.all;
use work.ipbus_decode_isolation.all;

use work.GMTTypes.all;

entity IsoAssignmentUnit is
  port (
    iEnergies            : in  TCaloRegionEtaSlice_vector;
    iMuonsB              : in  TGMTMu_vector (35 downto 0);
    iMuonsO              : in  TGMTMu_vector (35 downto 0);
    iMuonsF              : in  TGMTMu_vector (35 downto 0);
    iMuIdxBits           : in  TIndexBits_vector (7 downto 0);
    iFinalMuPt           : in  TMuonPT_vector(7 downto 0);
    oIsoBits             : out TIsoBits_vector (7 downto 0);
    oFinalEnergies       : out TCaloArea_vector(7 downto 0);
    oFinalCaloIdxBits    : out TCaloIndexBit_vector(7 downto 0); -- Debugging output
    oExtrapolatedCoordsB : out TSpatialCoordinate_vector(35 downto 0);
    oExtrapolatedCoordsO : out TSpatialCoordinate_vector(35 downto 0);
    oExtrapolatedCoordsF : out TSpatialCoordinate_vector(35 downto 0);
    oMuIdxBits           : out TIndexBits_vector (7 downto 0);
    oFinalMuPt           : out TMuonPT_vector(7 downto 0);
    clk                  : in  std_logic;
    clk_ipb              : in  std_logic;
    sinit                : in  std_logic;
    ipb_in               : in  ipb_wbus;
    ipb_out              : out ipb_rbus
    );
end IsoAssignmentUnit;

architecture Behavioral of IsoAssignmentUnit is

  -- IPbus
  signal ipbw : ipb_wbus_array(N_SLAVES - 1 downto 0);
  signal ipbr : ipb_rbus_array(N_SLAVES - 1 downto 0);

  type TEnergiesBuf is array (integer range <> ) of TCaloRegionEtaSlice_vector(iEnergies'range);
  signal sEnergies_buf : TEnergiesBuf(2 downto 0); -- TODO: Move delay to constants file.

  signal sVertexCoordsB       : TSpatialCoordinate_vector(0 to 35);
  signal sVertexCoordsO       : TSpatialCoordinate_vector(0 to 35);
  signal sVertexCoordsF       : TSpatialCoordinate_vector(0 to 35);
  signal sVertexCoordsB_store : TSpatialCoordinate_vector(0 to 35);
  signal sVertexCoordsO_store : TSpatialCoordinate_vector(0 to 35);
  signal sVertexCoordsF_store : TSpatialCoordinate_vector(0 to 35);
  signal sVertexCoordsB_reg   : TSpatialCoordinate_vector(0 to 35);
  signal sVertexCoordsO_reg   : TSpatialCoordinate_vector(0 to 35);
  signal sVertexCoordsF_reg   : TSpatialCoordinate_vector(0 to 35);

  signal sCaloIdxBitsB     : TCaloIndexBit_vector(35 downto 0);
  signal sCaloIdxBitsO     : TCaloIndexBit_vector(35 downto 0);
  signal sCaloIdxBitsF     : TCaloIndexBit_vector(35 downto 0);
  signal sCaloIdxBitsB_reg : TCaloIndexBit_vector(35 downto 0);
  signal sCaloIdxBitsO_reg : TCaloIndexBit_vector(35 downto 0);
  signal sCaloIdxBitsF_reg : TCaloIndexBit_vector(35 downto 0);

  signal sPileUp        : unsigned(6 downto 0);
  signal sPileUp_reg    : unsigned(6 downto 0);
  signal sPileUp_store  : unsigned(6 downto 0);
  signal sPileUp_store2 : unsigned(6 downto 0);

  signal sStripEnergies : TCaloStripEtaSlice_vector;

  signal sAreaSums         : TCaloArea_vector(7 downto 0);
  signal sSelectedEnergies : TCaloArea_vector(7 downto 0);

  signal sIsoBitsB : std_logic_vector(0 to 35);
  signal sIsoBitsO : std_logic_vector(0 to 35);
  signal sIsoBitsF : std_logic_vector(0 to 35);

  -- For intermediates
  type TEnergyBuffer is array (integer range <>) of TCaloArea_vector(7 downto 0);
  constant ENERGY_INTERMEDIATE_DELAY : natural := 4;  -- Delay to sync
                                                      -- energies  with
                                                      -- final muons.
  signal sFinalEnergies_buffer       : TEnergyBuffer(ENERGY_INTERMEDIATE_DELAY-1 downto 0);

  type TCoordsBuffer is array (integer range <>) of TSpatialCoordinate_vector(35 downto 0);
  constant COORD_INTERMEDIATE_DELAY  : natural := 2;  -- Delay to sync extrapolated
                                                      -- coordinates with final muons.
  signal sExtrapolatedCoordsB_buffer : TCoordsBuffer(COORD_INTERMEDIATE_DELAY-1 downto 0);
  signal sExtrapolatedCoordsO_buffer : TCoordsBuffer(COORD_INTERMEDIATE_DELAY-1 downto 0);
  signal sExtrapolatedCoordsF_buffer : TCoordsBuffer(COORD_INTERMEDIATE_DELAY-1 downto 0);

  signal sVertexCoordsB_buffer : TCoordsBuffer(1 downto 0);
  signal sVertexCoordsO_buffer : TCoordsBuffer(1 downto 0);
  signal sVertexCoordsF_buffer : TCoordsBuffer(1 downto 0);

  signal sSelectedCaloIdxBits : TCaloIndexBit_vector(7 downto 0);
  signal sMuIdxBits_reg       : TIndexBits_vector(7 downto 0);


begin

  -----------------------------------------------------------------------------
  -- ipbus address decode
  -----------------------------------------------------------------------------
  -- IPbus address top-level decode
  fabric : entity work.ipbus_fabric_sel
    generic map(
      NSLV      => N_SLAVES,
      SEL_WIDTH => IPBUS_SEL_WIDTH
      )
    port map(
      ipb_in          => ipb_in,
      ipb_out         => ipb_out,
      sel             => ipbus_sel_isolation(ipb_in.ipb_addr),
      ipb_to_slaves   => ipbw,
      ipb_from_slaves => ipbr
      );

  -----------------------------------------------------------------------------
  -- Extrapolation, delay energies and extrapolated coordinates
  -----------------------------------------------------------------------------

  extrapolation : entity work.extrapolation_unit
    port map (
      iMuonsB              => iMuonsB,
      iMuonsO              => iMuonsO,
      iMuonsF              => iMuonsF,
      oExtrapolatedCoordsB => sVertexCoordsB_buffer(0),
      oExtrapolatedCoordsO => sVertexCoordsO_buffer(0),
      oExtrapolatedCoordsF => sVertexCoordsF_buffer(0),
      clk                  => clk,
      clk_ipb              => clk_ipb,
      rst                  => sinit,
      ipb_in               => ipbw(N_SLV_EXTRAPOLATION),
      ipb_out              => ipbr(N_SLV_EXTRAPOLATION)
      );

  energies_store : process (clk)
  begin  -- process energies_store
    if clk'event and clk = '1' then     -- rising clock edge
      sEnergies_buf(0) <= iEnergies;
      sEnergies_buf(sEnergies_buf'high downto 1) <= sEnergies_buf(sEnergies_buf'high-1 downto 0);
      sVertexCoordsB_buffer(sVertexCoordsB_buffer'high downto 1) <= sVertexCoordsB_buffer(sVertexCoordsB_buffer'high-1 downto 0);
      sVertexCoordsO_buffer(sVertexCoordsO_buffer'high downto 1) <= sVertexCoordsO_buffer(sVertexCoordsO_buffer'high-1 downto 0);
      sVertexCoordsF_buffer(sVertexCoordsF_buffer'high downto 1) <= sVertexCoordsF_buffer(sVertexCoordsF_buffer'high-1 downto 0);
    end if;
  end process energies_store;

  -----------------------------------------------------------------------------
  -- Second BX
  -----------------------------------------------------------------------------

  -- Uses one clk.
  -- TODO: Change to "NOT clk" => use falling edge.
  gen_idx_bits : entity work.generate_index_bits
    port map (
      iCoordsB      => sVertexCoordsB_buffer(sVertexCoordsB_buffer'high),
      iCoordsO      => sVertexCoordsO_buffer(sVertexCoordsO_buffer'high),
      iCoordsF      => sVertexCoordsF_buffer(sVertexCoordsF_buffer'high),
      oCaloIdxBitsB => sCaloIdxBitsB,
      oCaloIdxBitsO => sCaloIdxBitsO,
      oCaloIdxBitsF => sCaloIdxBitsF,
      clk           => clk,
      clk_ipb       => clk_ipb,
      rst           => sinit,
      ipb_in        => ipbw(N_SLV_IDX_GEN),
      ipb_out       => ipbr(N_SLV_IDX_GEN)
      );

  -----------------------------------------------------------------------------
  -- 3.5 BX
  -----------------------------------------------------------------------------

  --calc_energy_strip_sums : compute_energy_strip_sums
  --  port map (
  --    iEnergies      => sEnergies_reg,
  --    oStripEnergies => sStripEnergies,
  --    clk            => clk,
  --    sinit          => sinit);

  -- Has one register (receives sStripEnergies for second clk).
  calc_complete_sums : entity work.compute_complete_sums
    port map (
      iEnergies     => sEnergies_buf(sEnergies_buf'high),
      iCaloIdxBitsB => sCaloIdxBitsB,
      iCaloIdxBitsO => sCaloIdxBitsO,
      iCaloIdxBitsF => sCaloIdxBitsF,
      iMuIdxBits    => iMuIdxBits,
      oEnergies     => sSelectedEnergies,
      oCaloIdxBits  => sSelectedCaloIdxBits,
      clk           => clk,
      sinit         => sinit);

  -----------------------------------------------------------------------------
  -- 3.5th BX
  -----------------------------------------------------------------------------
  iso_lut : entity work.iso_check
    port map (
      iAreaSums => sSelectedEnergies,
      iMuonPt   => iFinalMuPt,
      oIsoBits  => oIsoBits,
      clk       => clk,
      clk_ipb   => clk_ipb,
      rst       => sinit,
      ipb_in    => ipbw(N_SLV_ISOLATION_CHECK),
      ipb_out   => ipbr(N_SLV_ISOLATION_CHECK)
      );


  p1 : process (clk)
  begin  -- process p1
    if clk'event and clk = '1' then     -- rising clock edge
      sFinalEnergies_buffer(0)                                         <= sSelectedEnergies;
      sFinalEnergies_buffer(ENERGY_INTERMEDIATE_DELAY-1 downto 1)      <= sFinalEnergies_buffer(ENERGY_INTERMEDIATE_DELAY-2 downto 0);
      sExtrapolatedCoordsB_buffer(0)                                   <= sVertexCoordsB_buffer(sVertexCoordsB_buffer'high);
      sExtrapolatedCoordsO_buffer(0)                                   <= sVertexCoordsO_buffer(sVertexCoordsO_buffer'high);
      sExtrapolatedCoordsF_buffer(0)                                   <= sVertexCoordsF_buffer(sVertexCoordsF_buffer'high);
      sExtrapolatedCoordsB_buffer(COORD_INTERMEDIATE_DELAY-1 downto 1) <= sExtrapolatedCoordsB_buffer(COORD_INTERMEDIATE_DELAY-2 downto 0);
      sExtrapolatedCoordsO_buffer(COORD_INTERMEDIATE_DELAY-1 downto 1) <= sExtrapolatedCoordsO_buffer(COORD_INTERMEDIATE_DELAY-2 downto 0);
      sExtrapolatedCoordsF_buffer(COORD_INTERMEDIATE_DELAY-1 downto 1) <= sExtrapolatedCoordsF_buffer(COORD_INTERMEDIATE_DELAY-2 downto 0);
    end if;
  end process p1;

  energy_reg : process (clk)
  begin  -- process energy_reg
    if clk'event and clk = '0' then     -- falling clock edge
    -- Sync selected energies with iso bits.
    oFinalEnergies       <= sSelectedEnergies;
    oFinalCaloIdxBits    <= sSelectedCaloIdxBits;
    oExtrapolatedCoordsB <= sExtrapolatedCoordsB_buffer(COORD_INTERMEDIATE_DELAY-1);
    oExtrapolatedCoordsO <= sExtrapolatedCoordsO_buffer(COORD_INTERMEDIATE_DELAY-1);
    oExtrapolatedCoordsF <= sExtrapolatedCoordsF_buffer(COORD_INTERMEDIATE_DELAY-1);
    sMuIdxBits_reg       <= iMuIdxBits;
    oMuIdxBits           <= sMuIdxBits_reg;
    oFinalMuPt           <= iFinalMuPt;
    end if;
  end process energy_reg;

end Behavioral;
