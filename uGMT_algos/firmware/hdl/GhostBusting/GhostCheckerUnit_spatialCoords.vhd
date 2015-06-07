library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

use work.mp7_data_types.all;
use work.ipbus.all;
use work.ipbus_dpram_dist;

use work.GMTTypes.all;
use work.ugmt_constants.all;

entity GhostCheckerUnit_spatialCoords is
  generic (
    DATA_FILE        : string;
    LOCAL_PHI_OFFSET : signed(8 downto 0)
    );
  port (
    clk_ipb : in  std_logic;
    rst     : in  std_logic;
    ipb_in  : in  ipb_wbus;
    ipb_out : out ipb_rbus;
    eta1    : in  signed(8 downto 0);
    phi1    : in  signed(7 downto 0);
    qual1   : in  unsigned(3 downto 0);
    eta2    : in  signed(8 downto 0);
    phi2    : in  signed(7 downto 0);
    qual2   : in  unsigned(3 downto 0);
    ghost1  : out std_logic;
    ghost2  : out std_logic;
    clk     : in  std_logic
    );
end GhostCheckerUnit_spatialCoords;

architecture Behavioral of GhostCheckerUnit_spatialCoords is
  signal ipbusWe     : std_logic;
  signal deltaEta    : signed(9 downto 0);
  signal deltaPhi    : signed(8 downto 0);
  signal deltaEtaRed : unsigned(3 downto 0);
  signal deltaPhiRed : unsigned(2 downto 0);
  signal lutInput    : std_logic_vector(6 downto 0);
  signal match       : std_logic_vector(0 downto 0);
begin
  ipbusWe <= ipb_in.ipb_write and ipb_in.ipb_strobe;

  deltaEta    <= abs(resize(eta1, 10) - resize(eta2, 10));
  deltaPhi    <= abs(resize(phi1, 9) - (LOCAL_PHI_OFFSET + resize(phi2, 9)));

  deltaEtaRed <= resize(unsigned(deltaEta), 4);
  deltaPhiRed <= resize(unsigned(deltaPhi), 3);
  lutInput    <= std_logic_vector(deltaEtaRed) & std_logic_vector(deltaPhiRed);

  match_qual_calc : entity work.ipbus_dpram_dist
      generic map (
        DATA_FILE  => DATA_FILE,
        ADDR_WIDTH => COU_MEM_ADDR_WIDTH,
        WORD_WIDTH => COU_MEM_WORD_SIZE
        )
      port map (
        clk     => clk_ipb,
        -- rst     => rst,
        ipb_in  => ipb_in,
        ipb_out => ipb_out,
        rclk    => clk,
        q       => match,
        addr    => lutInput
        );

  check_ghosts : process (match, qual1, qual2, deltaPhi, deltaEta)
  begin  -- process check_ghosts
    -- If the muons are 'far enough' apart we don't check the LUT output.
    if deltaPhi(7 downto 3) /= (4 downto 0 => '0') or deltaEta(8 downto 4) /= (4 downto 0 => '0') then
      ghost1 <= '0';
      ghost2 <= '0';
    elsif match = "1" then
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
