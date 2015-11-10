library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use work.mp7_data_types.all;
use work.ipbus.all;
use work.ipbus_decode_isolation.all;

use work.GMTTypes.all;

entity IsoAssignmentUnit is
  port (
    iEnergies         : in  TCaloRegionEtaSlice_vector;
    iMuonsB           : in  TGMTMu_vector (35 downto 0);
    iMuonsO           : in  TGMTMu_vector (35 downto 0);
    iMuonsE           : in  TGMTMu_vector (35 downto 0);
    iCaloIdxBitsB     : in TCaloIndexBit_vector(35 downto 0);
    iCaloIdxBitsO     : in TCaloIndexBit_vector(35 downto 0);
    iCaloIdxBitsE     : in TCaloIndexBit_vector(35 downto 0);
    iMuIdxBits        : in  TIndexBits_vector (7 downto 0);
    iFinalMuPt        : in  TMuonPT_vector(7 downto 0);
    oIsoBits          : out TIsoBits_vector (7 downto 0);
    oFinalEnergies    : out TCaloArea_vector(7 downto 0);
    oFinalCaloIdxBits : out TCaloIndexBit_vector(7 downto 0); -- Debugging output
    oMuIdxBits        : out TIndexBits_vector (7 downto 0);
    oFinalMuPt        : out TMuonPT_vector(7 downto 0);
    clk               : in  std_logic;
    clk_ipb           : in  std_logic;
    sinit             : in  std_logic;
    ipb_in            : in  ipb_wbus;
    ipb_out           : out ipb_rbus
    );
end IsoAssignmentUnit;

architecture Behavioral of IsoAssignmentUnit is

  -- IPbus
  signal ipbw : ipb_wbus_array(N_SLAVES - 1 downto 0);
  signal ipbr : ipb_rbus_array(N_SLAVES - 1 downto 0);

  signal sSelectedEnergies     : TCaloArea_vector(107 downto 0);
  signal sSelectedEnergies_reg : TCaloArea_vector(107 downto 0);
  signal sFinalEnergies        : TCaloArea_vector(7 downto 0);

  -- For intermediates
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

  preselect_sums : entity work.preselect_sums
    port map (
      iEnergies     => iEnergies,
      iCaloIdxBitsB => iCaloIdxBitsB,
      iCaloIdxBitsO => iCaloIdxBitsO,
      iCaloIdxBitsE => iCaloIdxBitsE,
      oEnergies     => sSelectedEnergies,
      clk           => clk,
      sinit         => sinit);

  preselected_sums_reg : process (clk)
  begin  -- process preselected_sums_reg
    if clk'event and clk = '1' then     -- rising clock edge
      -- Sync selected energies with iso bits.
      sSelectedEnergies_reg <= sSelectedEnergies;
    end if;
  end process preselected_sums_reg;

  -- MISSING: Select final energies with mu idx bits (like in calc complete sums, incl reg)
  preselect_sums : entity work.preselect_sums
    port map (
      iEnergies     => sSelectedEnergies_reg,
      iMuIdxBits    => iMuIdxBits,
      oEnergies     => sFinalEnergies,
      clk           => clk,
      sinit         => sinit);


  iso_lut : entity work.iso_check
    port map (
      iAreaSums => sFinalEnergies,
      iMuonPt   => iFinalMuPt,
      oIsoBits  => oIsoBits,
      clk       => clk,
      clk_ipb   => clk_ipb,
      rst       => sinit,
      ipb_in    => ipbw(N_SLV_ISOLATION_CHECK),
      ipb_out   => ipbr(N_SLV_ISOLATION_CHECK)
      );

  energy_reg : process (clk)
  begin  -- process energy_reg
    if clk'event and clk = '0' then     -- falling clock edge
    -- Sync selected energies with iso bits.
    oFinalEnergies       <= sSelectedEnergies;
    sMuIdxBits_reg       <= iMuIdxBits;
    oMuIdxBits           <= sMuIdxBits_reg;
    oFinalMuPt           <= iFinalMuPt;
    end if;
  end process energy_reg;

end Behavioral;
