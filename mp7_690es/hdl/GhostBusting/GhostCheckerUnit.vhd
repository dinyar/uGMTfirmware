library IEEE;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;
library Types;
use Types.GMTTypes.all;

entity GhostCheckerUnit is
  port (mu1    : in  TMuonAddress;
        qual1  : in  unsigned(0 to 3);
        mu2    : in  TMuonAddress;
        qual2  : in  unsigned(0 to 3);
        ghost1 : out std_logic;
        ghost2 : out std_logic);
end GhostCheckerUnit;

architecture Behavioral of GhostCheckerUnit is
  signal matchedStations : natural range 0 to 4 := 0;  -- counts the number of matched stations
begin
  P : process(mu1, mu2, qual1, qual2, matchedstations)
    variable tmp : natural range 0 to 4;
  begin
    tmp := 0;
    for i in 3 downto 0 loop
      if mu1(i) = mu2(i) then
        tmp := tmp+1;
      end if;
    end loop;  -- i
    matchedStations <= tmp;
    if matchedStations > 1 then
      if qual1 > qual2 then
        ghost1 <= '0';
        ghost2 <= '1';
      else
        ghost1 <= '1';
        ghost2 <= '0';
      end if;
    else
      ghost1 <= '0';
      ghost2 <= '0';
    end if;
  end process;

end Behavioral;

