library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

use work.mp7_data_types.all;
use work.ipbus.all;
use work.ipbus_dpram;

library types;
use types.GMTTypes.all;

entity phi_index_bits_mem is
  port (
    clk_ipb : in  std_logic;
    rst     : in  std_logic;
    ipb_in  : in  ipb_wbus;
    ipb_out : out ipb_rbus;
    clk     : in  std_logic;
    addr    : in  std_logic_vector(9 downto 0);
    q       : out std_logic_vector(5 downto 0));
end phi_index_bits_mem;

architecture Behavioral of phi_index_bits_mem is

begin
  phi_idx_bits_mem : entity work.ipbus_dpram
    generic map (
      ADDR_WIDTH => 10
      )
    port map (
      clk     => clk_ipb,
      rst     => rst,
      ipb_in  => ipb_in,
      ipb_out => ipb_out,
      rclk    => clk,
      q       => oCaloIdxBits,
      addr    => iCoords
      );
end Behavioral;
