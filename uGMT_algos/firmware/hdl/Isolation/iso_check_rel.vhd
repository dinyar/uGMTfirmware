library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

use work.mp7_data_types.all;
use work.ipbus.all;
use work.ipbus_decode_isolation_mem_relative.all;

use work.GMTTypes.all;
use work.ugmt_constants.all;

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
  signal ipbw    : ipb_wbus_array(N_SLAVES-1 downto 0);
  signal ipbr    : ipb_rbus_array(N_SLAVES-1 downto 0);

  subtype RelIsoInput is std_logic_vector(13 downto 0);
  type    RelIsoInput_vector is array (iAreaSums'range) of RelIsoInput;
  signal  sRelInputVec : RelIsoInput_vector;

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
      sel             => ipbus_sel_isolation_mem_relative(ipb_in.ipb_addr),
      ipb_to_slaves   => ipbw,
      ipb_from_slaves => ipbr
      );


  iso_check_loop : for i in oIsoBits'range generate
    sRelInputVec(i)   <= std_logic_vector(iMuonPT(i)) & std_logic_vector(iAreaSums(i));
    rel_iso_check : entity work.ipbus_dpram
        generic map (
          DATA_FILE  => "RelIsoCheckMem.dat",
          ADDR_WIDTH => REL_ISO_ADDR_WIDTH,
          WORD_WIDTH => REL_ISO_WORD_SIZE
          )
        port map (
            clk => clk_ipb,
            rst => rst,
            ipb_in => ipbw(i),
            ipb_out => ipbr(i),
            rclk => clk,
            q => oIsoBits(i downto i),
            addr => sRelInputVec(i)
        );
  end generate iso_check_loop;

end Behavioral;
