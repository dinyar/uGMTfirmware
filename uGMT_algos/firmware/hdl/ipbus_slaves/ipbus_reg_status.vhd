-- ipbus_reg_status
--
-- Generic ipbus status register bank
--
-- Dave Newbold, March 2011
-- Dinyar Rabady, July 2015

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.ipbus.all;
use work.ipbus_reg_types.all;

entity ipbus_reg_status is
  generic(
    N_REG : positive := 1
  );
  port(
    ipbus_in: in ipb_wbus;
    ipbus_out: out ipb_rbus;
    clk: in std_logic; -- Algorithm clock!
    reset: in std_logic;
    d: in ipb_reg_v(N_REG - 1 downto 0);
    q: out ipb_reg_v(N_REG - 1 downto 0)
  );

end ipbus_reg_status;

architecture rtl of ipbus_reg_status is

  constant ADDR_WIDTH: integer := calc_width(N_REG);

  signal reg: ipb_reg_v(N_REG - 1 downto 0);
  signal ri: ipb_reg_v(2 ** ADDR_WIDTH - 1 downto 0);
  signal sel: integer range 0 to 2 ** ADDR_WIDTH - 1 := 0;

begin

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        reg <= (others => (others => '0'));
      else
        reg <= d;
      end if;
    end if;
  end process;

  ri(N_REG - 1 downto 0) <= reg;
  ri(2 ** ADDR_WIDTH - 1 downto N_REG) <= (others => (others => '0'));

  ipbus_out.ipb_rdata <= ri(sel);
  ipbus_out.ipb_ack <= ipbus_in.ipb_strobe;
  ipbus_out.ipb_err <= '0';

  q <= reg;

end rtl;
