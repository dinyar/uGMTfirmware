library IEEE;
use IEEE.STD_LOGIC_1164.all;

use IEEE.NUMERIC_STD.all;

use work.GMTTypes.all;

entity compute_complete_sums is
  port (iEnergies     : in  TCaloRegionEtaSlice_vector;
        iCaloIdxBitsB  : in  TCaloIndexBit_vector(35 downto 0);
        iCaloIdxBitsO  : in  TCaloIndexBit_vector(35 downto 0);
        iCaloIdxBitsF  : in  TCaloIndexBit_vector(35 downto 0);
        iMuIdxBits     : in  TIndexBits_vector(7 downto 0);
        oEnergies      : out TCaloArea_vector(7 downto 0);
        clk            : in  std_logic;
        sinit          : in  std_logic);
end compute_complete_sums;

architecture Behavioral of compute_complete_sums is
  type TSelectedEtaSlice is array (4 downto 0) of TCaloStripEnergy;
  type TSelectedEtaSlice_vector is array (integer range <>) of TSelectedEtaSlice;

  signal sMuIdxBits_reg            : TIndexBits_vector(7 downto 0);
  signal sEnergies_reg             : TCaloRegionEtaSlice_vector(iEnergies'range);
  signal sMergedCaloIdxBits        : TCaloIndexBit_vector(107 downto 0);
  signal sCaloIdxBits              : TCaloIndexBit_vector(7 downto 0);
  signal sCaloIdxBits_reg          : TCaloIndexBit_vector(7 downto 0);
  signal sReducedStripEnergies     : TSelectedEtaSlice_vector(7 downto 0);
  signal sReducedStripEnergies_reg : TSelectedEtaSlice_vector(7 downto 0);
begin

  reg_calo_bits : process (clk, sinit)
  begin  -- process reg_calo_bits
    if clk'event and clk = '0' then     -- falling clock edge
      sMergedCaloIdxBits <= iCaloIdxBitsB & iCaloIdxBitsO & iCaloIdxBitsF;
      sMuIdxBits_reg     <= iMuIdxBits;
      sEnergies_reg      <= iEnergies;
    end if;
  end process reg_calo_bits;

  -- purpose: Pick out those calo index bits that belong to muons exiting sort
  -- stage 1.
  -- outputs: sCaloIdxBits
  assign_index_bits : process (sMergedCaloIdxBits, sMuIdxBits_reg)
  begin  -- process assign_index_bits
    for i in sCaloIdxBits'range loop
      sCaloIdxBits(i) <= sMergedCaloIdxBits(to_integer(sMuIdxBits_reg(i)));
    end loop;  -- i
  end process assign_index_bits;
  
  extract_strip_energies : process (sCaloIdxBits, sEnergies_reg)
  begin  -- process extract_strip_energies
    for i in oEnergies'range loop
      oEnergies(i) <= sEnergies_reg(to_integer(sCaloIdxBits(i).eta))((to_integer(sCaloIdxBits(i).phi)+2) mod sEnergies_reg(0)'length);
    end loop;  -- i
  end process extract_strip_energies;
  
end Behavioral;
