library IEEE;
use IEEE.STD_LOGIC_1164.all;

use IEEE.NUMERIC_STD.all;

use work.GMTTypes.all;
use work.ugmt_constants.all;

entity preselect_sums is
  port (iEnergies      : in  TCaloRegionEtaSlice_vector;
        iCaloIdxBitsB  : in  TCaloIndexBit_vector(35 downto 0);
        iCaloIdxBitsO  : in  TCaloIndexBit_vector(35 downto 0);
        iCaloIdxBitsE  : in  TCaloIndexBit_vector(35 downto 0);
        oEnergies      : out TCaloArea_vector(107 downto 0);

        clk            : in  std_logic;
        sinit          : in  std_logic);
end preselect_sums;

architecture Behavioral of preselect_sums is
  signal iEnergies : TCaloRegionEtaSlice_vector(iEnergies'range);
  signal sCaloIdxBits  : TCaloIndexBit_vector(107 downto 0);
begin

  sCaloIdxBits <= iCaloIdxBitsE(35 downto 18) & iCaloIdxBitsO(35 downto 18) &
    iCaloIdxBitsB & iCaloIdxBitsO(17 downto 0) & iCaloIdxBitsE(17 downto 0);

  extract_strip_energies : process (sCaloIdxBits, iEnergies)
  begin  -- process extract_strip_energies
    for i in oEnergies'range loop
      oEnergies(i) <= iEnergies(to_integer(sCaloIdxBits(i).eta))((to_integer(sCaloIdxBits(i).phi)) mod iEnergies(0)'length);
    end loop;  -- i
  end process extract_strip_energies;

  oCaloIdxBits <= sCaloIdxBits;

end Behavioral;
