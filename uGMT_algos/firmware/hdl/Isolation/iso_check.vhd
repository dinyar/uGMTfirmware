library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

use work.mp7_data_types.all;
use work.ipbus.all;
use work.ipbus_decode_isolation_assignment.all;

use work.ugmt_constants.all;
use work.GMTTypes.all;

entity iso_check is
  port (
    iAreaSums : in  TCaloArea_vector (7 downto 0);
    iMuonPT   : in  TMuonPT_vector(7 downto 0);
    oIsoBits  : out TIsoBits_vector (7 downto 0);
    clk       : in  std_logic;
    clk_ipb   : in  std_logic;
    rst       : in  std_logic;
    ipb_in    : in  ipb_wbus;
    ipb_out   : out ipb_rbus
    );
end iso_check;

architecture Behavioral of iso_check is
  signal notClk : std_logic;

  -- IPbus
  signal ipbw : ipb_wbus_array(N_SLAVES - 1 downto 0);
  signal ipbr : ipb_rbus_array(N_SLAVES - 1 downto 0);

  signal sAbsIsoBits : std_logic_vector(7 downto 0);
  signal sRelIsoBits : std_logic_vector(7 downto 0);

  signal sMuonPT_reg : TMuonPT_vector(7 downto 0);
begin
  notClk <= not clk;

  -- IPbus address decode
  fabric : entity work.ipbus_fabric_sel
    generic map(
      NSLV      => N_SLAVES,
      SEL_WIDTH => IPBUS_SEL_WIDTH
      )
    port map(
      ipb_in          => ipb_in,
      ipb_out         => ipb_out,
      sel             => ipbus_sel_isolation_assignment(ipb_in.ipb_addr),
      ipb_to_slaves   => ipbw,
      ipb_from_slaves => ipbr
      );

  abs_iso_check : entity work.iso_check_abs
    port map (
      clk_ipb   => clk_ipb,
      rst       => rst,
      ipb_in    => ipbw(N_SLV_ABS_ISO),
      ipb_out   => ipbr(N_SLV_ABS_ISO),
      clk       => notClk,
      iAreaSums => iAreaSums,
      oIsoBits  => sAbsIsoBits
      );
  rel_iso_check : entity work.iso_check_rel
    port map (
      clk_ipb   => clk_ipb,
      rst       => rst,
      ipb_in    => ipbw(N_SLV_REL_ISO),
      ipb_out   => ipbr(N_SLV_REL_ISO),
      clk       => notClk,
      iAreaSums => iAreaSums,
      iMuonPT   => iMuonPT,
      oIsoBits  => sRelIsoBits
      );

  reg_pt : process (clk)
  begin  -- process reg_pt
    if clk'event and clk = '0' then     -- falling clock edge
      sMuonPT_reg <= iMuonPT;
    end if;
  end process reg_pt;

  assign_iso_bits : process (sMuonPT_reg, sAbsIsoBits, sRelIsoBits)
  begin  -- process assign_iso_bits
    for i in oIsoBits'range loop
      if sMuonPT_reg(i) = (sMuonPT_reg(i)'range => '0') then
        oIsoBits(i)(ABS_ISO_BIT) <= '0';
        oIsoBits(i)(REL_ISO_BIT) <= '0';
      else
        oIsoBits(i)(ABS_ISO_BIT) <= sAbsIsoBits(i);
        oIsoBits(i)(REL_ISO_BIT) <= sRelIsoBits(i);
      end if;
    end loop;  -- i
  end process assign_iso_bits;

end Behavioral;
