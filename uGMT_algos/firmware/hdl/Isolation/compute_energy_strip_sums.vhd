library IEEE;
use IEEE.STD_LOGIC_1164.all;

use IEEE.NUMERIC_STD.all;

use work.GMTTypes.all;

entity compute_energy_strip_sums is
  port (iEnergies      : in  TCaloRegionEtaSlice_vector;
        oStripEnergies : out TCaloStripEtaSlice_vector;
        clk            : in  std_logic;
        sinit          : in  std_logic);
end compute_energy_strip_sums;

architecture Behavioral of compute_energy_strip_sums is
begin
  -----------------------------------------------------------------------------
  -- Calculate all possible 5x1 sums in constant eta.
  -----------------------------------------------------------------------------
  calc_strips : process (iEnergies)
  begin  -- process calc_strips
    -- Assuming that I'm receiving two additional slices in eta compared to
    -- muon system:
    -- * Need to offset eta value by +2.
    -- * Eta does not need to wrap around at edges.    
    for i in iEnergies'low+2 to iEnergies'high-2 loop
      for j in iEnergies(0)'range loop
        -- Need space for 5x 5 bit numbers (32 values) => 160 values must be
        -- stored in 8 bit.
        oStripEnergies(i-2)(j) <= "00000000" +
                                  --iEnergies(i-2)(j) +
                                  --iEnergies(i-1)(j) +
                                  iEnergies(i)(j); -- +
                                  --iEnergies(i+1)(j) +
                                  --iEnergies(i+2)(j);
      end loop;  -- j
    end loop;  -- i
  end process calc_strips;
end Behavioral;

