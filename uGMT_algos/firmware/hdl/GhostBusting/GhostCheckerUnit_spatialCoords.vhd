library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

use work.mp7_data_types.all;
use work.ipbus.all;

use work.GMTTypes.all;

entity GhostCheckerUnit_spatialCoords is
  port (
    clk_ipb : in  std_logic;
    rst     : in  std_logic;
    ipb_in  : in  ipb_wbus;
    ipb_out : out ipb_rbus;
    eta1    : in  signed(8 downto 0);
    phi1    : in  unsigned(9 downto 0);
    qual1   : in  unsigned(3 downto 0);
    eta2    : in  signed(8 downto 0);
    phi2    : in  unsigned(9 downto 0);
    qual2   : in  unsigned(3 downto 0);
    ghost1  : out std_logic;
    ghost2  : out std_logic;
    clk     : in  std_logic
    );
end GhostCheckerUnit_spatialCoords;

architecture Behavioral of GhostCheckerUnit_spatialCoords is
  signal ipbusWe     : std_logic;
  signal deltaEta    : signed(0 to 9);
  signal deltaPhi    : signed(0 to 10);
  signal deltaEtaRed : unsigned(0 to 3);
  signal deltaPhiRed : unsigned(0 to 2);
  signal lutInput    : std_logic_vector(6 downto 0);
  signal match       : std_logic_vector(0 downto 0);
begin
  ipbusWe <= ipb_in.ipb_write and ipb_in.ipb_strobe;

  deltaEta    <= resize(eta1, 10) - resize(eta2, 10);
  -- TODO: Delta phi calculation is wrong! Have to take mod144 here also, check
  -- if I'm subtracting in correct "direction".
  deltaPhi    <= signed(resize(phi1, 11)) - signed(resize(phi2, 11));
  deltaEtaRed <= resize(unsigned(abs(deltaEta)), 4);
  deltaPhiRed <= resize(unsigned(abs(deltaPhi)), 3);
  lutInput    <= std_logic_vector(deltaEtaRed) & std_logic_vector(deltaPhiRed);


  match_qual_calc : entity work.matchingLUT_dist
    port map (
      qdpo_clk => clk_ipb,
      we       => ipbusWe,
      d        => ipb_in.ipb_wdata(0 downto 0),
      dpra     => ipb_in.ipb_addr(6 downto 0),
      qdpo     => ipb_out.ipb_rdata(0 downto 0),
      clk      => clk,
      qspo     => match,
      a        => lutInput
      );

  check_ghosts : process (match, qual1, qual2)
  begin  -- process check_ghosts
    if match = "1" then
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
  end process check_ghosts;
end Behavioral;
