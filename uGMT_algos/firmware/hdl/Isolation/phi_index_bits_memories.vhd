library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

use work.mp7_data_types.all;
use work.ipbus.all;
use work.ipbus_decode_idx_bit_mems_phi.all;

use work.GMTTypes.all;

entity phi_index_bits_memories is
  port (
    clk_ipb      : in  std_logic;
    rst          : in  std_logic;
    ipb_in       : in  ipb_wbus;
    ipb_out      : out ipb_rbus;
    clk          : in  std_logic;
    oCaloIdxBits : out TPhiCaloIdxBit_vector(35 downto 0);
    iCoords      : in  TPhiCoordinate_vector(35 downto 0)
    );
end phi_index_bits_memories;

architecture Behavioral of phi_index_bits_memories is
  signal sel_lut_group : std_logic_vector(5 downto 0);

  signal ipbusWe_vector : std_logic_vector(iCoords'range);

  signal ipbw : ipb_wbus_array(N_SLAVES-1 downto 0);
  signal ipbr : ipb_rbus_array(N_SLAVES-1 downto 0);

  signal sLutOutput : TLutBuf(iCoords'range);

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
        sel             => ipbus_sel_idx_bit_mems_phi(ipb_in.ipb_addr),
        ipb_to_slaves   => ipbw,
        ipb_from_slaves => ipbr
        );


  convert_coords_to_index_bits : for i in iCoords'range generate
    ipbusWe_vector(i) <= ipbw(i).ipb_write and ipbw(i).ipb_strobe;
--    phi_idx_bits_mem : entity work.phi_sel_mem
--      port map (
--        clka   => clk,
--        addra  => std_logic_vector(iCoords(i)),
--        dina   => (others => '0'),
--        douta  => sLutOutput(i)(5 downto 0),
--        wea    => "0",
--        clkb   => clk_ipb,
--        web(0) => ipbusWe_vector(i),
--        addrb  => ipbw(i).ipb_addr(7 downto 0),
--        dinb   => ipbw(i).ipb_wdata(23 downto 0),
--        doutb  => ipbr(i).ipb_rdata(23 downto 0)
--        );
    phi_idx_bits_mem : entity work.phi_index_bits_mem
      port map (
      clk     => clk_ipb,
      rst     => rst,
      ipb_in  => ipbw(i),
      ipb_out => ipbr(i),
      rclk    => clk,
      q       => sLutOutput(i)(5 downto 0),
      addr    => std_logic_vector(iCoords(i))
      );
    oCaloIdxBits(i) <= unsigned(sLutOutput(i)(5 downto 0));
  end generate convert_coords_to_index_bits;

end Behavioral;
