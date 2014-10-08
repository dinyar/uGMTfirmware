library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

use work.mp7_data_types.all;
use work.ipbus.all;

use work.GMTTypes.all;

entity extrapolate_eta is
  port (
    clk_ipb                  : in  std_logic;
    rst                      : in  std_logic;
    ipb_in                   : in  ipb_wbus;
    ipb_out                  : out ipb_rbus;
    clk                      : in  std_logic;
    iEtaExtrapolationAddress : in  TEtaExtrapolationAddress(35 downto 0);
    oDeltaEta                : out TDelta_vector(35 downto 0)
    );
end extrapolate_eta;

architecture Behavioral of extrapolate_eta is
  signal sel_lut_group : std_logic_vector(5 downto 0);

  signal ipbusWe_vector : std_logic_vector(iEtaExtrapolationAddress'range);

  signal ipbw : ipb_wbus_array(iEtaExtrapolationAddress'range);
  signal ipbr : ipb_rbus_array(iEtaExtrapolationAddress'range);

  signal sLutOutput : TLutBuf(iEtaExtrapolationAddress'range);

begin
  -----------------------------------------------------------------------------
  -- ipbus address decode
  -----------------------------------------------------------------------------
  -- Use bits before beginning of addresses that are required for later
  -- addressing (i.e. addresses inside LUTs)
  -- Need to address 36 LUTs -> 6 bits needed.
  -- 10 bits used for addressing -> will use 15th to 10th bits.
  sel_lut_group <= std_logic_vector(unsigned(ipb_in.ipb_addr(15 downto 10)));

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

  extrapolation : for i in iEtaExtrapolationAddress'range generate

    ---------------------------------------------------------------------------
    -- eta extrapolation
    --
    -- 7 bits of eta (only interested in forward regions)
    -- 5 bits of pT -> max pT of 15.5 GeV
    -- (high pT muons will be regarded as straight lines)
    ---------------------------------------------------------------------------

    --eta_extrapolation : entity work.ipbus_dpram
    --  generic map (
    --    ADDR_WIDTH => 13)
    --  port map (
    --    clk     => clk_ipb,
    --    rst     => rst,
    --    ipb_in  => ipbw(i),
    --    ipb_out => ipbr(i),
    --    rclk    => clk,
    --    q       => sLutOutput(i),
    --    addr    => iEtaExtrapolationAddress(i)
    --    );
    ipbusWe_vector(i) <= ipbw(i).ipb_write and ipbw(i).ipb_strobe;
    eta_extrapolation : entity work.eta_extrapolation_mem
      port map (
        clka   => clk,
        wea    => "0",
        addra  => iEtaExtrapolationAddress(i),
        dina   => (others => '0'),
        douta  => sLutOutput(i)(3 downto 0),
        clkb   => clk_ipb,
        web(0) => ipbusWe_vector(i),
        addrb  => ipbw(i).ipb_addr(12 downto 0),
        dinb   => ipbw(i).ipb_wdata(3 downto 0),
        doutb  => ipbr(i).ipb_rdata(3 downto 0)
        );
    oDeltaEta(i) <= signed(sLutOutput(i)(3 downto 0));
  end generate extrapolation;

end Behavioral;

