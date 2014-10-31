library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

use work.mp7_data_types.all;
use work.ipbus.all;

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
  signal ipbw    : ipb_wbus_array(oIsoBits'range);
  signal ipbr    : ipb_rbus_array(oIsoBits'range);

  signal sLutOutput : TLutBuf(oIsoBits'range);

  signal ipbusWe_vector : std_logic_vector(iAreaSums'range);
begin
  -----------------------------------------------------------------------------
  -- ipbus address decode
  -----------------------------------------------------------------------------
  -- Use bits before beginning of addresses that are required for later
  -- addressing (i.e. addresses inside LUTs)
  -- Need to address 8 LUTs -> 3 bits needed.
  -- 1 bit used for addressing -> will use 3th to 1th bits.
  sel_lut <= std_logic_vector(unsigned(ipb_in.ipb_addr(3 downto 1)));

  fabric : entity work.ipbus_fabric_sel
    generic map(
      NSLV      => 8,
      SEL_WIDTH => 3)
    port map(
      ipb_in          => ipb_in,
      ipb_out         => ipb_out,
      sel             => sel_lut,
      ipb_to_slaves   => ipbw,
      ipb_from_slaves => ipbr
      );

  
  iso_check_loop : for i in oIsoBits'range generate
    ipbusWe_vector(i) <= ipbw(i).ipb_write and ipbw(i).ipb_strobe;
    abs_iso_check : entity work.abs_iso_mem
      port map (
        clk      => clk_ipb,
        we       => ipbusWe_vector(i),
        a        => ipbw(i).ipb_addr(4 downto 0),
        d        => ipbw(i).ipb_wdata(0 downto 0),
        qspo     => ipbr(i).ipb_rdata(0 downto 0),
        qdpo_clk => clk,
        dpra     => std_logic_vector(iAreaSums(i)),
        qdpo     => oIsoBits(i downto i)
        );
--    oIsoBits(i) <= sLutOutput(i)(0);
  end generate iso_check_loop;

end Behavioral;

