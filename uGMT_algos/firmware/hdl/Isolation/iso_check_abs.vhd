library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

use work.mp7_data_types.all;
use work.ipbus.all;
use work.ipbus_dpram_dist;
use work.ipbus_decode_isolation_mem_absolute.all;

use work.GMTTypes.all;
use work.ugmt_constants.all;

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
  signal ipbw    : ipb_wbus_array(N_SLAVES-1 downto 0);
  signal ipbr    : ipb_rbus_array(N_SLAVES-1 downto 0);
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
          DATA_FILE  => "AbsIsoCheckMem.mif",
          ADDR_WIDTH => ABS_ISO_ADDR_WIDTH,
          WORD_WIDTH => ABS_ISO_WORD_SIZE
          )
        port map (
          clk     => clk_ipb,
          ipb_in  => ipbw(i),
          ipb_out => ipbr(i),
          rclk    => clk,
          q       => oIsoBits(i downto i),
          addr    => std_logic_vector(iAreaSums(i))
          );
  end generate iso_check_loop;

end Behavioral;
