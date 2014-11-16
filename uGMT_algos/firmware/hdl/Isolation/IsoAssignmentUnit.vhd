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
    oExtrapolatedCoordsB : out TSpatialCoordinate_vector(35 downto 0);
    oExtrapolatedCoordsO : out TSpatialCoordinate_vector(35 downto 0);
    oExtrapolatedCoordsF : out TSpatialCoordinate_vector(35 downto 0);
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
  constant COORD_INTERMEDIATE_DELAY  : natural := 5;  -- Delay to sync extrapolated
                                        -- coordinates with final muons.
  signal sExtrapolatedCoordsB_buffer : TCoordsBuffer(COORD_INTERMEDIATE_DELAY-1 downto 0);
  signal sExtrapolatedCoordsO_buffer : TCoordsBuffer(COORD_INTERMEDIATE_DELAY-1 downto 0);
  signal sExtrapolatedCoordsF_buffer : TCoordsBuffer(COORD_INTERMEDIATE_DELAY-1 downto 0);
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
  -- First BX
  -----------------------------------------------------------------------------

  extrapolation : entity work.extrapolation_unit
    port map (
      iMuonsB              => iMuonsB,
      iMuonsO              => iMuonsO,
      iMuonsF              => iMuonsF,
      oExtrapolatedCoordsB => sVertexCoordsB,
      oExtrapolatedCoordsO => sVertexCoordsO,
      oExtrapolatedCoordsF => sVertexCoordsF,
      clk                  => clk,
      clk_ipb              => clk_ipb,
      rst                  => sinit,
      ipb_in               => ipbw(N_SLV_EXTRAPOLATION),
      ipb_out              => ipbr(N_SLV_EXTRAPOLATION)
      );

  -- TODO: Remove this.
  --assign_coords : process (iMuonsB, iMuonsO, iMuonsF)
  --begin  -- process assign_coords
  --  for i in iMuonsB'range loop
  --    sVertexCoordsB(i).eta <= signed(iMuonsB(i).eta);
  --    sVertexCoordsB(i).phi <= unsigned(iMuonsB(i).phi);
  --    sVertexCoordsO(i).eta <= signed(iMuonsO(i).eta);
  --    sVertexCoordsO(i).phi <= unsigned(iMuonsO(i).phi);
  --    sVertexCoordsF(i).eta <= signed(iMuonsF(i).eta);
  --    sVertexCoordsF(i).phi <= unsigned(iMuonsF(i).phi);
  --  end loop;  -- i
  --end process assign_coords;

  -- Has two registers
  --compute_pile_up : pile_up_computation
  --  port map (
  --    iEnergies => iEnergies,
  --    oPileUp   => sPileUp,
  --    clk       => clk,
  --    sinit     => sinit);

  energies_store : process (clk)
  begin  -- process energies_store
    if clk'event and clk = '1' then     -- rising clock edge
      sEnergies_store <= iEnergies;
    end if;
  end process energies_store;

  -----------------------------------------------------------------------------
  -- Delay pile-up, energies and coords for RPC merging by 2 BX
  -----------------------------------------------------------------------------

  --delay_for_rpc_merging : process (clk)
  --begin  -- process delay_for_rpc_merging
  --  if clk'event and clk = '1' then     -- rising clock edge
  --    sPileUp_store  <= sPileUp;
  --    sPileUp_store2 <= sPileUp_store;

  --    sEnergies_store2 <= sEnergies_store;
  --    sEnergies_store3 <= sEnergies_store2;

  --    sVertexCoordsF_store <= sVertexCoordsF;
  --    sVertexCoordsO_store <= sVertexCoordsO;
  --    sVertexCoordsB_store <= sVertexCoordsB;
  --    sVertexCoordsF_reg   <= sVertexCoordsF_store;
  --    sVertexCoordsO_reg   <= sVertexCoordsO_store;
  --    sVertexCoordsB_reg   <= sVertexCoordsB_store;

  --  end if;
  --end process delay_for_rpc_merging;


  -----------------------------------------------------------------------------
  -- Second BX
  -----------------------------------------------------------------------------

  -- Uses one clk.
  -- TODO: Change to "NOT clk" => use falling edge.
  gen_idx_bits : entity work.generate_index_bits
    port map (
      iCoordsB      => sVertexCoordsB,
      iCoordsO      => sVertexCoordsO,
      iCoordsF      => sVertexCoordsF,
      oCaloIdxBitsB => sCaloIdxBitsB,
      oCaloIdxBitsO => sCaloIdxBitsO,
      oCaloIdxBitsF => sCaloIdxBitsF,
      clk           => clk,
      clk_ipb       => clk_ipb,
      rst           => sinit,
      ipb_in        => ipbw(N_SLV_IDX_GEN),
      ipb_out       => ipbr(N_SLV_IDX_GEN)
      );

  -- Register energy strip sums for the second time.
  -- TODO: Try to use falling edge for clock (need to also do this in
  -- SortAndCancel unit in this case!
  energies_reg : process (clk)
  begin  -- process energies_reg
    if clk'event and clk = '1' then     -- rising clock edge
      sEnergies_reg <= sEnergies_store;
    end if;
  end process energies_reg;

  -----------------------------------------------------------------------------
  -- Third BX
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
      iEnergies     => sEnergies_reg,
      iCaloIdxBitsB => sCaloIdxBitsB,
      iCaloIdxBitsO => sCaloIdxBitsO,
      iCaloIdxBitsF => sCaloIdxBitsF,
      iMuIdxBits    => iMuIdxBits,
      oEnergies     => sSelectedEnergies,
      clk           => clk,
      sinit         => sinit);

  --pu_reg : process (clk)
  --begin  -- process pu_reg
  --  if clk'event and clk = '1' then     -- rising clock edge
  --    sPileUp_reg <= sPileUp_store2;
  --  end if;
  --end process pu_reg;


  -----------------------------------------------------------------------------
  -- Fourth BX
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
      sExtrapolatedCoordsB_buffer(0)                                   <= sVertexCoordsB;
      sExtrapolatedCoordsO_buffer(0)                                   <= sVertexCoordsO;
      sExtrapolatedCoordsF_buffer(0)                                   <= sVertexCoordsF;
      sExtrapolatedCoordsB_buffer(COORD_INTERMEDIATE_DELAY-1 downto 1) <= sExtrapolatedCoordsB_buffer(COORD_INTERMEDIATE_DELAY-2 downto 0);
      sExtrapolatedCoordsO_buffer(COORD_INTERMEDIATE_DELAY-1 downto 1) <= sExtrapolatedCoordsO_buffer(COORD_INTERMEDIATE_DELAY-2 downto 0);
      sExtrapolatedCoordsF_buffer(COORD_INTERMEDIATE_DELAY-1 downto 1) <= sExtrapolatedCoordsF_buffer(COORD_INTERMEDIATE_DELAY-2 downto 0);
    end if;
  end process p1;

  oFinalEnergies       <= sFinalEnergies_buffer(ENERGY_INTERMEDIATE_DELAY-1);
  oExtrapolatedCoordsB <= sExtrapolatedCoordsB_buffer(COORD_INTERMEDIATE_DELAY-1);
  oExtrapolatedCoordsO <= sExtrapolatedCoordsO_buffer(COORD_INTERMEDIATE_DELAY-1);
  oExtrapolatedCoordsF <= sExtrapolatedCoordsF_buffer(COORD_INTERMEDIATE_DELAY-1);
  
end Behavioral;
