library IEEE;
use IEEE.STD_LOGIC_1164.all;

use IEEE.NUMERIC_STD.all;

library types;
use types.GMTTypes.all;

entity IsoAssignmentUnit is
  port (iEnergies  : in  TCaloRegionEtaSlice_vector;
        iMuonsB    : in  TGMTMu_vector (0 to 35);
        iMuonsO    : in  TGMTMu_vector (0 to 35);
        iMuonsF    : in  TGMTMu_vector (0 to 35);
        iMuIdxBits : in  TIndexBits_vector (7 downto 0);
        oIsoBits   : out TIsoBits_vector (7 downto 0);
        clk        : in  std_logic;
        sinit      : in  std_logic);
end IsoAssignmentUnit;

architecture Behavioral of IsoAssignmentUnit is
  component pile_up_computation is
    port (iEnergies : in  TCaloRegionEtaSlice_vector;
          oPileUp   : out unsigned(6 downto 0);
          clk       : in  std_logic;
          sinit     : in  std_logic);
  end component;

  component extrapolation_unit is
    port (iMuons              : in  TGMTMu_vector(0 to 35);
          oExtrapolatedCoords : out TSpatialCoordinate_vector(0 to 35);
          clk                 : in  std_logic;
          sinit               : in  std_logic);
  end component;

  component generate_index_bits is
    port (iCoordsB      : in  TSpatialCoordinate_vector(0 to 35);
          iCoordsO      : in  TSpatialCoordinate_vector(0 to 35);
          iCoordsF      : in  TSpatialCoordinate_vector(0 to 35);
          oCaloIdxBitsB : out TCaloSelBit_vector(35 downto 0);
          oCaloIdxBitsO : out TCaloSelBit_vector(35 downto 0);
          oCaloIdxBitsF : out TCaloSelBit_vector(35 downto 0);
          clk           : in  std_logic;
          sinit         : in  std_logic);
  end component;

  component compute_energy_strip_sums is
    port (iEnergies      : in  TCaloRegionEtaSlice_vector;
          oStripEnergies : out TCaloStripEtaSlice_vector;
          clk            : in  std_logic;
          sinit          : in  std_logic);
  end component;

  component compute_complete_sums is
    port (iStripEnergies : in  TCaloStripEtaSlice_vector;
          iCaloIdxBitsB  : in  TCaloSelBit_vector(35 downto 0);
          iCaloIdxBitsO  : in  TCaloSelBit_vector(35 downto 0);
          iCaloIdxBitsF  : in  TCaloSelBit_vector(35 downto 0);
          iMuIdxBits     : in  TIndexBits_vector(7 downto 0);
          oAreaSums      : out TCaloArea_vector(7 downto 0);
          clk            : in  std_logic;
          sinit          : in  std_logic);
  end component;

  component iso_check is
    port (iAreaSums : in  TCaloArea_vector(7 downto 0);
          iPileUp   : in  unsigned(6 downto 0);
          oIsoBits  : out TIsoBits_vector(7 downto 0);
          clk       : in  std_logic;
          sinit     : in  std_logic);
  end component;

  signal sEnergies_reg    : TCaloRegionEtaSlice_vector(iEnergies'range);
  signal sEnergies_store  : TCaloRegionEtaSlice_vector(iEnergies'range);
  signal sEnergies_store2 : TCaloRegionEtaSlice_vector(iEnergies'range);
  signal sEnergies_store3 : TCaloRegionEtaSlice_vector(iEnergies'range);

  signal sVertexCoordsB       : TSpatialCoordinate_vector(0 to 35);
  signal sVertexCoordsO       : TSpatialCoordinate_vector(0 to 35);
  signal sVertexCoordsF       : TSpatialCoordinate_vector(0 to 35);
  signal sVertexCoordsB_store : TSpatialCoordinate_vector(0 to 35);
  signal sVertexCoordsO_store : TSpatialCoordinate_vector(0 to 35);
  signal sVertexCoordsF_store : TSpatialCoordinate_vector(0 to 35);
  signal sVertexCoordsB_reg   : TSpatialCoordinate_vector(0 to 35);
  signal sVertexCoordsO_reg   : TSpatialCoordinate_vector(0 to 35);
  signal sVertexCoordsF_reg   : TSpatialCoordinate_vector(0 to 35);

  signal sCaloIdxBitsB     : TCaloSelBit_vector(35 downto 0);
  signal sCaloIdxBitsO     : TCaloSelBit_vector(35 downto 0);
  signal sCaloIdxBitsF     : TCaloSelBit_vector(35 downto 0);
  signal sCaloIdxBitsB_reg : TCaloSelBit_vector(35 downto 0);
  signal sCaloIdxBitsO_reg : TCaloSelBit_vector(35 downto 0);
  signal sCaloIdxBitsF_reg : TCaloSelBit_vector(35 downto 0);

  signal sPileUp        : unsigned(6 downto 0);
  signal sPileUp_reg    : unsigned(6 downto 0);
  signal sPileUp_store  : unsigned(6 downto 0);
  signal sPileUp_store2 : unsigned(6 downto 0);

  signal sStripEnergies : TCaloStripEtaSlice_vector;

  signal sAreaSums : TCaloArea_vector(7 downto 0);

  signal sIsoBitsB : std_logic_vector(0 to 35);
  signal sIsoBitsO : std_logic_vector(0 to 35);
  signal sIsoBitsF : std_logic_vector(0 to 35);
begin
  -----------------------------------------------------------------------------
  -- First BX
  -----------------------------------------------------------------------------
  extrapolate_barrel : extrapolation_unit
    port map (
      iMuons              => iMuonsB,
      oExtrapolatedCoords => sVertexCoordsB,
      clk                 => clk,
      sinit               => sinit);
  extrapolate_overlap : extrapolation_unit
    port map (
      iMuons              => iMuonsO,
      oExtrapolatedCoords => sVertexCoordsO,
      clk                 => clk,
      sinit               => sinit);
  extrapolate_forward : extrapolation_unit
    port map (
      iMuons              => iMuonsF,
      oExtrapolatedCoords => sVertexCoordsF,
      clk                 => clk,
      sinit               => sinit);

  -- Has two registers
  compute_pile_up : pile_up_computation
    port map (
      iEnergies => iEnergies,
      oPileUp   => sPileUp,
      clk       => clk,
      sinit     => sinit);

  energies_store : process (clk)
  begin  -- process energies_store
    if clk'event and clk = '1' then     -- rising clock edge
      sEnergies_store <= iEnergies;
    end if;
  end process energies_store;

  -----------------------------------------------------------------------------
  -- Delay pile-up, energies and coords for RPC merging by 2 BX
  -----------------------------------------------------------------------------

  delay_for_rpc_merging : process (clk)
  begin  -- process delay_for_rpc_merging
    if clk'event and clk = '1' then     -- rising clock edge
      sPileUp_store  <= sPileUp;
      sPileUp_store2 <= sPileUp_store;

      sEnergies_store2 <= sEnergies_store;
      sEnergies_store3 <= sEnergies_store2;

      sVertexCoordsF_store <= sVertexCoordsF;
      sVertexCoordsO_store <= sVertexCoordsO;
      sVertexCoordsB_store <= sVertexCoordsB;
      sVertexCoordsF_reg   <= sVertexCoordsF_store;
      sVertexCoordsO_reg   <= sVertexCoordsO_store;
      sVertexCoordsB_reg   <= sVertexCoordsB_store;

    end if;
  end process delay_for_rpc_merging;


  -----------------------------------------------------------------------------
  -- Second BX
  -----------------------------------------------------------------------------

  -- Uses one clk.
  -- TODO: Change to "NOT clk" => use falling edge.
  gen_idx_bits : generate_index_bits
    port map (
      iCoordsB      => sVertexCoordsB_reg,
      iCoordsO      => sVertexCoordsO_reg,
      iCoordsF      => sVertexCoordsF_reg,
      oCaloIdxBitsB => sCaloIdxBitsB,
      oCaloIdxBitsO => sCaloIdxBitsO,
      oCaloIdxBitsF => sCaloIdxBitsF,
      clk           => clk,
      sinit         => sinit);

  -- Register energy strip sums for the second time.
  -- TODO: Try to use falling edge for clock (need to also do this in
  -- SortAndCancel unit in this case!
  energies_reg : process (clk)
  begin  -- process energies_reg
    if clk'event and clk = '1' then     -- rising clock edge
      sEnergies_reg <= sEnergies_store3;
    end if;
  end process energies_reg;

  -----------------------------------------------------------------------------
  -- Third BX
  -----------------------------------------------------------------------------

  calc_energy_strip_sums : compute_energy_strip_sums
    port map (
      iEnergies      => sEnergies_reg,
      oStripEnergies => sStripEnergies,
      clk            => clk,
      sinit          => sinit);

  -- Has one register (receives sStripEnergies for second clk).
  calc_complete_sums : compute_complete_sums
    port map (
      iStripEnergies => sStripEnergies,
      iCaloIdxBitsB  => sCaloIdxBitsB,
      iCaloIdxBitsO  => sCaloIdxBitsO,
      iCaloIdxBitsF  => sCaloIdxBitsF,
      iMuIdxBits     => iMuIdxBits,
      oAreaSums      => sAreaSums,
      clk            => clk,
      sinit          => sinit);

  pu_reg : process (clk)
  begin  -- process pu_reg
    if clk'event and clk = '1' then     -- rising clock edge
      sPileUp_reg <= sPileUp_store2;
    end if;
  end process pu_reg;


  -----------------------------------------------------------------------------
  -- Fourth BX
  -----------------------------------------------------------------------------

  iso_lut : iso_check
    port map (
      iAreaSums => sAreaSums,
      iPileUp   => sPileUp_reg,
      oIsoBits  => oIsoBits,
      clk       => clk,
      sinit     => sinit);

  -- TODO: Final register in SaC unit should work on falling clock?
  -- TODO: In the end maybe use falling clock for 2nd and 3rd register, but
  -- rising clock again for final register?

end Behavioral;
