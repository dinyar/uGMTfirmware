library IEEE;
use IEEE.STD_LOGIC_1164.all;

use IEEE.NUMERIC_STD.all;
library Types;
use Types.GMTTypes.all;

entity pile_up_computation is
  port (iEnergies : in  TCaloRegionEtaSlice_vector(31 downto 0);
        oPileUp   : out unsigned(6 downto 0);
        clk       : in  std_logic;
        sinit     : in  std_logic);
end pile_up_computation;

architecture Behavioral of pile_up_computation is
  subtype TEtaSliceEnergy is unsigned (0 to 8);  -- Stores energy sum for one
                                                 -- eta slice.
  type    TEtaSliceEnergy_vector is array (integer range <>) of TEtaSliceEnergy;

  -- purpose: Calculate sum of half the energy values in one eta slice
  function half_etaslice_loop (
    signal iSliceEnergies : TCaloRegionEtaSlice(17 downto 0))
    return TEtaSliceEnergy is
    variable vSum : TEtaSliceEnergy;
  begin  -- half_etaslice_loop
    vSum := (others => '0');

    for i in iSliceEnergies'range loop
      if iSliceEnergies(i) < 14 then
        vSum := vSum + iSliceEnergies(i)(iSliceEnergies(i)'high-3 to iSliceEnergies(i)'high);
      else
        vSum := vSum + 14;
      end if;
    end loop;  -- i

    return vSum;
  end half_etaslice_loop;

  signal sEnergies_reg              : TCaloRegionEtaSlice_vector(iEnergies'range);
  signal sEtaSliceEnergies_low      : TEtaSliceEnergy_vector(iEnergies'range);
  signal sEtaSliceEnergies_low_reg  : TEtaSliceEnergy_vector(iEnergies'range);
  signal sEtaSliceEnergies_high     : TEtaSliceEnergy_vector(iEnergies'range);
  signal sEtaSliceEnergies_high_reg : TEtaSliceEnergy_vector(iEnergies'range);
  signal sEtaSliceEnergies          : TEtaSliceEnergy_vector(iEnergies'range);
  signal sEtaSliceEnergies_reg      : TEtaSliceEnergy_vector(iEnergies'range);
  signal sFinalMean                 : unsigned(6 downto 0);  -- Need to store
                                                             -- 1152*4 bit/46
begin
  etaslice_loop : for i in iEnergies'range generate
    -- purpose: Sum energy of each half of each eta slice seperatly.
    -- outputs: sEtaSliceEnergies_low(i), sEtaSliceEnergies_high(i)
    sum_eta_slices : process (iEnergies(i))
    begin  -- process sum_eta_slices
      sEtaSliceEnergies_low(i)  <= half_etaslice_loop(iEnergies(i)(iEnergies(i)'high/2 downto iEnergies(i)'low));
      sEtaSliceEnergies_high(i) <= half_etaslice_loop(iEnergies(i)(iEnergies(i)'high downto iEnergies(i)'high/2+1));
    end process sum_eta_slices;
  end generate etaslice_loop;

  intermediate_slice_energies_reg : process (clk)
  begin  -- process intermediate_slice_energies_reg
    if clk'event and clk = '1' then     -- rising clock edge
      sEtaSliceEnergies_low_reg  <= sEtaSliceEnergies_low;
      sEtaSliceEnergies_high_reg <= sEtaSliceEnergies_high;
    end if;
  end process intermediate_slice_energies_reg;

  etaslice_loop_final : for i in sEtaSliceEnergies_low_reg'range generate
    sEtaSliceEnergies(i) <= sEtaSliceEnergies_low_reg(i) + sEtaSliceEnergies_high_reg(i);
  end generate etaslice_loop_final;

  -- purpose: Register eta slice sums
  slice_energies_reg : process (clk)
  begin  -- process slice_energies_reg
    if clk'event and clk = '1' then     -- rising clock edge
      sEtaSliceEnergies_reg <= sEtaSliceEnergies;
    end if;
  end process slice_energies_reg;

  -- purpose: Sum and average all values
  -- outputs: sFinalMean
  calc_mean : process (sEtaSliceEnergies_reg)
    variable vSum : unsigned(0 to 13);  -- Need to store result of
                                        -- 1008 * 7 Gev (for .5 stepsize).
  begin  -- process calc_mean
    vSum := (others => '0');
    for i in sEtaSliceEnergies_reg'range loop
      vSum := vSum + sEtaSliceEnergies_reg(i);
    end loop;  -- i
    sFinalMean <= resize(vSum/46, sFinalMean'length);  -- Actually need to
                                                       -- divide by 46.08 as
                                                       -- we're going to
                                                       -- subtract from 5x5
                                                       -- areas. 
  end process calc_mean;

  oPileUp <= sFinalMean;

end Behavioral;
