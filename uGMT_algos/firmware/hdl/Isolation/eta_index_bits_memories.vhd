library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

use work.mp7_data_types.all;
use work.ipbus.all;
use work.ipbus_decode_idx_bit_mems_eta.all;

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
        sel             => ipbus_sel_idx_bit_mems_eta(ipb_in.ipb_addr),
        ipb_to_slaves   => ipbw,
        ipb_from_slaves => ipbr
        );

  convert_coords_to_index_bits : for i in iCoords'range generate
    ipbusWe_vector(i) <= ipbw(i).ipb_write and ipbw(i).ipb_strobe;
--    eta_idx_bits_mem : entity work.eta_sel_mem
--      port map (
--        clka   => clk,
--        addra  => std_logic_vector(iCoords(i)),
--        dina   => (others => '0'),
--        douta  => sLutOutput(i)(4 downto 0),
--        wea    => "0",
--        clkb   => clk_ipb,
--        web(0) => ipbusWe_vector(i),
--        addrb  => ipbw(i).ipb_addr(6 downto 0),
--        dinb   => ipbw(i).ipb_wdata(19 downto 0),
--        doutb  => ipbr(i).ipb_rdata(19 downto 0)
--        );
    eta_idx_bits_mem : entity work.eta_index_bits_mem
      port map (
          clk_ipb => clk_ipb,
          rst     => rst,
          ipb_in  => ipbw(i),
          ipb_out => ipbr(i),
          clk     => clk,
          q       => sLutOutput(i)(4 downto 0),
          addr    => std_logic_vector(iCoords(i))
          );
    oCaloIdxBits(i) <= unsigned(sLutOutput(i)(4 downto 0));
  end generate convert_coords_to_index_bits;

end Behavioral;
