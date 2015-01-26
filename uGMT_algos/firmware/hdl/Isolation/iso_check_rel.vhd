library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

use work.mp7_data_types.all;
use work.ipbus.all;

use work.GMTTypes.all;

entity iso_check_rel is
  port (
    clk_ipb   : in  std_logic;
    rst       : in  std_logic;
    ipb_in    : in  ipb_wbus;
    ipb_out   : out ipb_rbus;
    clk       : in  std_logic;
    iAreaSums : in  TCaloArea_vector (7 downto 0);
    iMuonPT   : in  TMuonPT_vector(7 downto 0);
    oIsoBits  : out std_logic_vector(7 downto 0)
    );
end iso_check_rel;

architecture Behavioral of iso_check_rel is
  signal sel_lut : std_logic_vector(2 downto 0);
  signal ipbw    : ipb_wbus_array(oIsoBits'range);
  signal ipbr    : ipb_rbus_array(oIsoBits'range);

  signal sLutOutput : TLutBuf(oIsoBits'range);

  subtype RelIsoInput is std_logic_vector(13 downto 0);
  type    RelIsoInput_vector is array (iAreaSums'range) of RelIsoInput;
  signal  sRelInputVec : RelIsoInput_vector;

  signal ipbusWe_vector : std_logic_vector(sRelInputVec'range);
begin
  -----------------------------------------------------------------------------
  -- ipbus address decode
  -----------------------------------------------------------------------------
  -- Use bits before beginning of addresses that are required for later
  -- addressing (i.e. addresses inside LUTs)
  -- Need to address 8 LUTs -> 3 bits needed.
  -- 9 bits used for addressing -> will use 11th to 9th bits.
  sel_lut <= std_logic_vector(unsigned(ipb_in.ipb_addr(11 downto 9)));

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
    sRelInputVec(i)   <= std_logic_vector(iMuonPT(i)) & std_logic_vector(iAreaSums(i));
    ipbusWe_vector(i) <= ipbw(i).ipb_write and ipbw(i).ipb_strobe;
    rel_iso_check : entity work.rel_iso_mem
      port map (
        clka   => clk,
        addra  => sRelInputVec(i),
        dina   => (others => '0'),
        douta  => oIsoBits(i downto i),
        wea    => "0",
        clkb   => clk_ipb,
        web(0) => ipbusWe_vector(i),
        addrb  => ipbw(i).ipb_addr(8 downto 0),
        dinb   => ipbw(i).ipb_wdata(31 downto 0),
        doutb  => ipbr(i).ipb_rdata(31 downto 0)
        );
--    oIsoBits(i) <= sLutOutput(i)(0);
  end generate iso_check_loop;
  
end Behavioral;

