library IEEE;
use IEEE.STD_LOGIC_1164.all;

use IEEE.NUMERIC_STD.all;

library types;
use types.GMTTypes.all;

entity compute_complete_sums is
  port (iStripEnergies : in  TCaloStripEtaSlice_vector;
        iCaloIdxBitsB  : in  TCaloSelBit_vector(35 downto 0);
        iCaloIdxBitsO  : in  TCaloSelBit_vector(35 downto 0);
        iCaloIdxBitsF  : in  TCaloSelBit_vector(35 downto 0);
        iMuIdxBits     : in  TIndexBits_vector(7 downto 0);
        oAreaSums      : out TCaloArea_vector(7 downto 0);
        clk            : in  std_logic;
        sinit          : in  std_logic);
end compute_complete_sums;

architecture Behavioral of compute_complete_sums is
  type TSelectedEtaSlice is array (4 downto 0) of TCaloStripEnergy;
  type TSelectedEtaSlice_vector is array (integer range <>) of TSelectedEtaSlice;

  signal sStripEnergies_reg        : TCaloStripEtaSlice_vector;
  signal sMergedCaloIdxBits        : TCaloSelBit_vector(107 downto 0);
  signal sCaloIdxBits              : TCaloSelBit_vector(7 downto 0);
  signal sCaloIdxBits_reg          : TCaloSelBit_vector(7 downto 0);
  signal sReducedStripEnergies     : TSelectedEtaSlice_vector(7 downto 0);
  signal sReducedStripEnergies_reg : TSelectedEtaSlice_vector(7 downto 0);
begin
  sMergedCaloIdxBits <= iCaloIdxBitsB & iCaloIdxBitsO & iCaloIdxBitsF;

  -- purpose: Pick out those calo index bits that belong to muons exiting sort
  -- stage 1.
  -- outputs: sCaloIdxBits
  assign_index_bits : process (sMergedCaloIdxBits, iMuIdxBits)
  begin  -- process assign_index_bits
    for i in sCaloIdxBits'range loop
      sCaloIdxBits(i) <= sMergedCaloIdxBits(to_integer(iMuIdxBits(i)));
    end loop;  -- i
  end process assign_index_bits;

  reg_calo_bits : process (clk, sinit)
  begin  -- process reg_calo_bits
    if clk'event and clk = '1' then     -- rising clock edge
      sCaloIdxBits_reg   <= sCaloIdxBits;
      sStripEnergies_reg <= iStripEnergies;
    end if;
  end process reg_calo_bits;

  -- purpose: Extract those strip energies that will be used for area sums.
  -- type   : combinational
  -- inputs : sCaloIdxBits_reg, sStripEnergies_reg
  -- outputs: sReducedStripEnergies
  extract_strip_energies : process (sCaloIdxBits_reg, sStripEnergies_reg)
  begin  -- process extract_strip_energies
    for i in scaloIdxBits_reg'range loop
      for j in 2 downto -2 loop
        sReducedStripEnergies(i)(j+2) <= sStripEnergies_reg(to_integer(sCaloIdxBits_reg(i).eta))((to_integer(sCaloIdxBits_reg(i).phi)+j) mod sStripEnergies_reg(0)'length);
      end loop;  -- j
    end loop;  -- i
  end process extract_strip_energies;

  -- purpose: Calculate energy sums of 5x5 areas around selected 2x2 regions.
  -- Assuming that 5x1 sums in constant eta have been calculated already.
  -- outputs: oAreaSums
  calc_area_sums : process (sReducedStripEnergies)
    variable vSum : TCaloAreaEnergy;
  begin  -- process calc_area_sums
    for i in sReducedStripEnergies'range loop
      vSum := (others => '0');
      for j in sReducedStripEnergies(i)'range loop
        vSum := vSum + sReducedStripEnergies(i)(j);
      end loop;  -- j
      oAreaSums(i) <= vSum;
    end loop;  -- i
  end process calc_area_sums;

end Behavioral;
