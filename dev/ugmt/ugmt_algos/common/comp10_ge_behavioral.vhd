LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY comp10_ge IS
   PORT(
      a : IN   std_logic_vector(9 downto 0);
      b : IN   std_logic_vector(9 downto 0);
      a_ge_b : OUT std_logic
      );
END ENTITY comp10_ge;

--
ARCHITECTURE behavioral OF comp10_ge IS
BEGIN
   comparator_proc: process( a, b)
      begin
         if (a >= b) then
            a_ge_b <= '1';
         else
            a_ge_b <= '0';
         end if;
      end process comparator_proc;
END ARCHITECTURE behavioral;

