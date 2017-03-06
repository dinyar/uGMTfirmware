library IEEE;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;
use work.GMTTypes.all;

entity GhostCheckerUnit_EMTF is
  port (mu1    : in  TEMTFTrackAddress;
        qual1  : in  unsigned(3 downto 0);
        mu2    : in  TEMTFTrackAddress;
        qual2  : in  unsigned(3 downto 0);
        ghost1 : out std_logic;
        ghost2 : out std_logic;
        clk    : in  std_logic);
end GhostCheckerUnit_EMTF;

architecture Behavioral of GhostCheckerUnit_EMTF is
begin

  P : process(mu1, mu2, qual1, qual2)
    variable matchedStation : boolean := false;  -- whether a track segement was shared between two tracks
  begin
    matchedStation := false;
    if (mu1.chamberIDs(1) > 0 and mu2.chamberIDs(1) > 0 and
        mu1.chamberIDs(1) = (mu2.chamberIDs(1)+3) and
        mu1.chamberSegments(1) = mu2.chamberSegments(1)) then
      matchedStation := true;
    end if;

    for station in 2 to 4 loop
      if (mu1.chamberIDs(station) > 0 and mu2.chamberIDs(station) > 0 and
          mu1.chamberIDs(station) = (mu2.chamberIDs(station)+2) and
          mu1.chamberSegments(station) = mu2.chamberSegments(station)) then
        matchedStation := true;
      end if;
    end loop;

    if matchedStation = true then
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
