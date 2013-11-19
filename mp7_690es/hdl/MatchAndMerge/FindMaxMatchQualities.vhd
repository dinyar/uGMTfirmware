library IEEE;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;
library Types;
use Types.GMTTypes.all;

entity FindMaxMatchQualities is
  
  port (
    iMQMatrix     : in  TMQMatrix;
    iDisableCol   : in  std_logic_vector(3 downto 0);
    iDisableRow   : in  std_logic_vector(71 downto 0);
    oColumnMaxima : out TRowColIndex_vector(3 downto 0);
    oRowMaxima    : out TRowColIndex_vector(71 downto 0));

end FindMaxMatchQualities;

architecture behavioral of FindMaxMatchQualities is

begin  -- behavioral

  find_maxima : process (iMQMatrix, iDisableCol, iDisableRow)
    variable curMax : unsigned(3 downto 0);
  begin  -- process find_maxima
    -- Check whether item is maximum in its row and col.
    -- First find max in its column.
    for i in 3 downto 0 loop
      oColumnMaxima(i) <= (others => '0');
      curMax := (others => '0');
      for j in 71 downto 0 loop
        if iMQMatrix(i, j) > curMax and
          iDisableCol(i) = '0' and
          iDisableRow(j) = '0'
        then
          curMax           := iMQMatrix(i, j);
          oColumnMaxima(i) <= to_unsigned(j, oColumnMaxima(0)'length);
        end if;
      end loop;  -- j
    end loop;  -- i

    -- Now find max in its row.
    for i in 71 downto 0 loop
      oRowMaxima(i) <= (others => '0');
      curMax := (others => '0');
      for j in 3 downto 0 loop
        -- 'Greater than' ensures that muon with lower index wins in case of
        -- equal match qualities. (Lower index means higher TF rank.)
        if iMQMatrix(j, i) > curMax and
          iDisableCol(j) = '0' and
          iDisableRow(i) = '0'
        then
          curMax        := iMQMatrix(j, i);
          oRowMaxima(i) <= to_unsigned(j, oRowMaxima(0)'length);
        end if;
      end loop;  -- j
    end loop;  -- i
  end process find_maxima;

end behavioral;
