-- Register containing fixed value
--
-- Dave Newbold, August 2011
-- Dinyar Rabady, April 2016
--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.ipbus.all;

entity ipbus_reg_const is
  generic(
    INIT  : std_logic_vector(31 downto 0) := (others => '0')
  );
  port(
    ipbus_in  : in  ipb_wbus;
    ipbus_out : out ipb_rbus
  );

end ipbus_reg_const;

architecture rtl of ipbus_reg_const is

begin

  ipbus_out.ipb_rdata <= INIT;
  ipbus_out.ipb_ack   <= ipbus_in.ipb_strobe;
  ipbus_out.ipb_err   <= '0';

end rtl;
