library IEEE;
use IEEE.STD_LOGIC_1164.all;

use IEEE.NUMERIC_STD.all;

use work.GMTTypes.all;
use work.ugmt_constants.all;

entity select_final_sums is
  port (iEnergies      : in  TCaloRegionEtaSlice_vector;
        iMuIdxBits     : in  TIndexBits_vector(7 downto 0);
        oEnergies      : out TCaloArea_vector(7 downto 0);

        clk            : in  std_logic;
        sinit          : in  std_logic);
end select_final_sums;

architecture Behavioral of select_final_sums is
  signal sMuIdxBits_reg            : TIndexBits_vector(7 downto 0);
  signal sEnergies_reg             : TCaloRegionEtaSlice_vector(iEnergies'range);
begin

  reg_calo_bits : process (clk)
  begin  -- process reg_calo_bits
    if clk'event and clk = '0' then     -- falling clock edge
      sMuIdxBits_reg     <= iMuIdxBits;
      sEnergies_reg      <= iEnergies;
    end if;
  end process reg_calo_bits;

  extract_final_sums : process (sEnergies_reg, sMuIdxBits_reg)
  begin  -- process extract_final_sums
    for i in oEnergies'range loop
      oEnergies(i) <= sEnergies_reg(to_integer(sMuIdxBits_reg(i)));
    end loop;  -- i
end process extract_final_sums;

end Behavioral;
