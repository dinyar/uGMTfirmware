library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

use work.mp7_data_types.all;
use work.ipbus.all;
use work.ipbus_dpram_dist;
use work.ipbus_decode_isolation_mem_absolute.all;

use work.GMTTypes.all;

entity iso_check_abs is
  port (
    clk_ipb   : in  std_logic;
    rst       : in  std_logic;
    ipb_in    : in  ipb_wbus;
    ipb_out   : out ipb_rbus;
    clk       : in  std_logic;
    iAreaSums : in  TCaloArea_vector (7 downto 0);
    oIsoBits  : out std_logic_vector(7 downto 0)
    );

end iso_check_abs;

architecture Behavioral of iso_check_abs is
  signal sel_lut : std_logic_vector(2 downto 0);
  signal ipbw    : ipb_wbus_array(N_SLAVES-1 downto 0);
  signal ipbr    : ipb_rbus_array(N_SLAVES-1 downto 0);

  signal sLutOutput : TLutBuf(oIsoBits'range);

  signal ipbusWe_vector : std_logic_vector(iAreaSums'range);

begin

  -- IPbus address decode
  fabric : entity work.ipbus_fabric_sel
    generic map(
      NSLV      => N_SLAVES,
      SEL_WIDTH => IPBUS_SEL_WIDTH
      )
    port map(
      ipb_in          => ipb_in,
      ipb_out         => ipb_out,
      sel             => ipbus_sel_isolation_mem_absolute(ipb_in.ipb_addr),
      ipb_to_slaves   => ipbw,
      ipb_from_slaves => ipbr
      );


  iso_check_loop : for i in oIsoBits'range generate
    abs_iso_check : entity work.ipbus_dpram_dist
        generic map (
          ADDR_WIDTH => 5,
          WORD_WIDTH => 1
          )
        port map (
          clk     => clk_ipb,
          rst     => rst,
          ipb_in  => ipbw(i),
          ipb_out => ipbr(i),
          rclk    => clk,
          q       => oIsoBits(i downto i),
          addr    => std_logic_vector(iAreaSums(i))
          );
--    oIsoBits(i) <= sLutOutput(i)(0);
  end generate iso_check_loop;

end Behavioral;
