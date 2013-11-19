library IEEE;
use IEEE.STD_LOGIC_1164.all;

use IEEE.NUMERIC_STD.all;

entity GhostCheckerUnit_spatialCoords is
  port (
    eta1   : in  signed(0 to 8);
    phi1   : in  unsigned(0 to 9);
    qual1  : in  unsigned(0 to 3);
    eta2   : in  signed(0 to 8);
    phi2   : in  unsigned(0 to 9);
    qual2  : in  unsigned(0 to 3);
    ghost1 : out std_logic;
    ghost2 : out std_logic;
    clk    : in  std_logic);
end GhostCheckerUnit_spatialCoords;

architecture Behavioral of GhostCheckerUnit_spatialCoords is
  component match_qual_lut
    port (
      clka  : in  std_logic;
      wea   : in  std_logic_vector(0 downto 0);
      addra : in  std_logic_vector(6 downto 0);
      dina  : in  std_logic_vector(3 downto 0);
      douta : out std_logic_vector(3 downto 0);
      clkb  : in  std_logic;
      enb   : in  std_logic;
      web   : in  std_logic_vector(0 downto 0);
      addrb : in  std_logic_vector(6 downto 0);
      dinb  : in  std_logic_vector(3 downto 0);
      doutb : out std_logic_vector(3 downto 0)
      );
  end component;

  signal deltaEta    : signed(0 to 9);
  signal deltaPhi    : signed(0 to 10);
  signal deltaEtaRed : unsigned(0 to 3);
  signal deltaPhiRed : unsigned(0 to 2);
  signal matchQual   : unsigned(0 to 3);
begin
  deltaEta    <= resize(eta1, 10) - resize(eta2, 10);
  deltaPhi    <= signed(resize(phi1, 11)) - signed(resize(phi2, 11));
  deltaEtaRed <= resize(unsigned(abs(deltaEta)), 4);
  deltaPhiRed <= resize(unsigned(abs(deltaPhi)), 3);

  match_qual_calc : match_qual_lut
    port map (
      clka            => not clk,
      wea             => "0",
      addra           => std_logic_vector(deltaEtaRed) & std_logic_vector(deltaPhiRed),
      dina            => (others => '0'),
      unsigned(douta) => matchQual,
      clkb            => not clk,
      enb             => '0',
      web             => "0",
      addrb           => (others => '0'),
      dinb            => (others => '0'),
      doutb           => open
      );


  -- purpose: Determines whether muons are actually duplicates depending on spatial coordinates.
  -- type   : combinational
  -- inputs : deltaEta, deltaPhi
  -- outputs: ghost
  check_ghosts : process (matchQual, qual1, qual2)
  begin  -- process check_ghosts
    if to_integer(matchQual) < 4 then
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
