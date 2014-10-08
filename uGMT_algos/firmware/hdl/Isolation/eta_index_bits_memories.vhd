library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

use work.mp7_data_types.all;
use work.ipbus.all;

use work.GMTTypes.all;

entity eta_index_bits_memories is
  port (
    clk_ipb      : in  std_logic;
    rst          : in  std_logic;
    ipb_in       : in  ipb_wbus;
    ipb_out      : out ipb_rbus;
    clk          : in  std_logic;
    oCaloIdxBits : out TEtaCaloIdxBit_vector(35 downto 0);
    iCoords      : in  TEtaCoordinate_vector(35 downto 0)
    );
end eta_index_bits_memories;

architecture Behavioral of eta_index_bits_memories is
  signal sel_lut_group : std_logic_vector(5 downto 0);

  signal ipbusWe_vector : std_logic_vector(iCoords'range);

  signal ipbw : ipb_wbus_array(iCoords'range);
  signal ipbr : ipb_rbus_array(iCoords'range);

  signal sLutOutput : TLutBuf(iCoords'range);
  
begin

  -- Use bits before beginning of addresses that are required for later
  -- addressing (i.e. addresses inside LUTs and possible substructure)
  -- Need to address 36 muons -> 6 bits 
  -- 8 bits used for addressing by phi mem -> will use 13th to 8th bits.
  sel_lut_group <= std_logic_vector(unsigned(ipb_in.ipb_addr(13 downto 8)));

  fabric : entity work.ipbus_fabric_sel
    generic map(
      NSLV      => 36,
      SEL_WIDTH => 6)
    port map(
      ipb_in          => ipb_in,
      ipb_out         => ipb_out,
      sel             => sel_lut_group,
      ipb_to_slaves   => ipbw,
      ipb_from_slaves => ipbr
      ); 

  convert_coords_to_index_bits : for i in iCoords'range generate
    --eta_idx_bits_mem : entity work.ipbus_dpram
    --  generic map (
    --    ADDR_WIDTH => 9)
    --  port map (
    --    clk     => clk_ipb,
    --    rst     => rst,
    --    ipb_in  => ipbw(i),
    --    ipb_out => ipbr(i),
    --    rclk    => clk,
    --    addr    => std_logic_vector(iCoords(i)),
    --    q       => sLutOutput(i)
    --    );
    ipbusWe_vector(i) <= ipbw(i).ipb_write and ipbw(i).ipb_strobe;
    eta_idx_bits_mem : entity work.eta_sel_mem
      port map (
        clka   => clk_ipb,
        wea(0) => ipbusWe_vector(i),
        addra  => ipbw(i).ipb_addr(8 downto 0),
        dina   => ipbw(i).ipb_wdata(4 downto 0),
        douta  => ipbr(i).ipb_rdata(4 downto 0),
        clkb   => clk,
        addrb  => std_logic_vector(iCoords(i)),
        dinb   => (others => '0'),
        doutb  => sLutOutput(i)(4 downto 0),
        web    => "0"
        );
    oCaloIdxBits(i) <= unsigned(sLutOutput(i)(4 downto 0));
  end generate convert_coords_to_index_bits;

end Behavioral;

