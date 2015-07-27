library IEEE;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;
use work.GMTTypes.all;

entity GhostCheckerUnit is
  port (mu1    : in  TMuonAddress;
        qual1  : in  unsigned(3 downto 0);
        mu2    : in  TMuonAddress;
        qual2  : in  unsigned(3 downto 0);
        ghost1 : out std_logic;
        ghost2 : out std_logic);
end GhostCheckerUnit;

architecture Behavioral of GhostCheckerUnit is
  signal matchedStations : natural range 0 to 4 := 0;  -- counts the number of matched stations
begin

  -- Template for future TF-specific implementations.
  P : process(mu1, mu2, qual1, qual2, matchedstations)
  begin
    ghost1 <= '0';
    ghost2 <= '0';
  end process;

end Behavioral;

