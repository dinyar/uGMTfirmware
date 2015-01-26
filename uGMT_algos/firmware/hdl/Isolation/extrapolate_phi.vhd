library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

use work.mp7_data_types.all;
use work.ipbus.all;

use work.GMTTypes.all;

entity extrapolate_phi is
  port (
    clk_ipb                  : in  std_logic;
    rst                      : in  std_logic;
    ipb_in                   : in  ipb_wbus;
    ipb_out                  : out ipb_rbus;
    clk                      : in  std_logic;
    iPhiExtrapolationAddress : in  TPhiExtrapolationAddress(35 downto 0);
    oDeltaPhi                : out TDelta_vector(35 downto 0)
    );
end extrapolate_phi;

architecture Behavioral of extrapolate_phi is
  signal sel_lut_group : std_logic_vector(5 downto 0);

  signal ipbusWe_vector : std_logic_vector(iPhiExtrapolationAddress'range);

  signal ipbw : ipb_wbus_array(iPhiExtrapolationAddress'range);
  signal ipbr : ipb_rbus_array(iPhiExtrapolationAddress'range);

  signal sLutOutput : TLutBuf(iPhiExtrapolationAddress'range);

begin
  -----------------------------------------------------------------------------
  -- ipbus address decode
  -----------------------------------------------------------------------------
  -- Use bits before beginning of addresses that are required for later
  -- addressing (i.e. addresses inside LUTs)
  -- Need to address 36 LUTs -> 6 bits needed.
  -- 11 bits used for addressing -> will use 16th to 11th bits.
  sel_lut_group <= std_logic_vector(unsigned(ipb_in.ipb_addr(16 downto 11)));

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

  extrapolation : for i in iPhiExtrapolationAddress'range generate
    ---------------------------------------------------------------------------
    -- phi extrapolation
    --
    -- 8 bits of eta (only need to know absolute distance from 0)
    -- 5 bits of pT (high pT muons will be regarded as straight lines)
    ---------------------------------------------------------------------------
    --phi_extrapolation : entity work.ipbus_dpram
    --  generic map (
    --    ADDR_WIDTH => 14)
    --  port map (
    --    clk     => clk_ipb,
    --    rst     => rst,
    --    ipb_in  => ipbw(i),
    --    ipb_out => ipbr(i),
    --    rclk    => clk,
    --    q       => sLutOutput(i),
    --    addr    => iPhiExtrapolationAddress(i)
    --    );
    ipbusWe_vector(i) <= ipbw(i).ipb_write and ipbw(i).ipb_strobe;
    phi_extrapolation : entity work.phi_extrapolation_mem
      port map (
        clka   => clk,
        wea    => "0",
        addra  => std_logic_vector(iPhiExtrapolationAddress(i)),
        dina   => (others => '0'),
        douta  => sLutOutput(i)(3 downto 0),
        clkb   => clk_ipb,
        web(0) => ipbusWe_vector(i),
        addrb  => ipbw(i).ipb_addr(10 downto 0),
        dinb   => ipbw(i).ipb_wdata(31 downto 0),
        doutb  => ipbr(i).ipb_rdata(31 downto 0)
        );
    oDeltaPhi(i) <= signed(sLutOutput(i)(3 downto 0));
  end generate extrapolation;
  
end Behavioral;

