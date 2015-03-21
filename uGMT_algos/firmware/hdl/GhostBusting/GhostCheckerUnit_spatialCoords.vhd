library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

use work.mp7_data_types.all;
use work.ipbus.all;
use work.ipbus_dpram_dist;

use work.GMTTypes.all;

entity GhostCheckerUnit_spatialCoords is
  generic (
    DATA_FILE: string
    );
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
  signal sEtaH       : signed(8 downto 0);
  signal sEtaL       : signed(8 downto 0);
  signal deltaEta    : signed(9 downto 0);
  signal sPhiH       : unsigned(9 downto 0);
  signal sPhiL       : unsigned(9 downto 0);
  signal deltaPhi    : unsigned(9 downto 0);
  signal deltaEtaRed : unsigned(0 to 3);
  signal deltaPhiRed : unsigned(0 to 2);
  signal lutInput    : std_logic_vector(6 downto 0);
  signal match       : std_logic_vector(0 downto 0);
begin
  ipbusWe <= ipb_in.ipb_write and ipb_in.ipb_strobe;

  eta_assignment : process (eta1, eta2)
  begin  -- process eta_assignment
    if eta1 >= eta2 then
      sEtaH <= eta1;
      sEtaL <= eta2;
    else
      sEtaH <= eta2;
      sEtaL <= eta1;
    end if;
  end process eta_assignment;
  deltaEta <= resize(sEtaH, 10) - resize(sEtaL, 10);
  phi_assignment : process (phi1, phi2)
  begin  -- process phi_assignment
    if phi1 >= phi2 then
      sPhiH <= phi1;
      sPhiL <= phi2;
    else
      sPhiH <= phi2;
      sPhiL <= phi1;
    end if;
  end process phi_assignment;
  deltaPhi    <= sPhiH - sPhiL;
  deltaEtaRed <= resize(unsigned(abs(deltaEta)), 4);
  deltaPhiRed <= resize(unsigned(deltaPhi), 3);
  lutInput    <= std_logic_vector(deltaEtaRed) & std_logic_vector(deltaPhiRed);

  match_qual_calc : entity work.ipbus_dpram_dist
      generic map (
        DATA_FILE  => DATA_FILE,
        ADDR_WIDTH => 7,
        WORD_WIDTH => 1
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
--  match_qual_calc : entity work.cancel_out_mem
--    port map (
--      clk      => clk_ipb,
--      we       => ipbusWe,
--      a        => ipb_in.ipb_addr(6 downto 0),
--      d        => ipb_in.ipb_wdata(0 downto 0),
--      spo      => ipb_out.ipb_rdata(0 downto 0),
--      qdpo_clk => clk,
--      dpra     => lutInput,
--      dpo      => match
--      );

  check_ghosts : process (match, qual1, qual2, deltaPhi, deltaEta)
  begin  -- process check_ghosts
    if deltaPhi(9 downto 3) /= (6 downto 0 => '0') or deltaEta(8 downto 4) /= (4 downto 0 => '0') then
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
