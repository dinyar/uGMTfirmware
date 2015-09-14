library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

use work.mp7_data_types.all;
use work.ipbus.all;
use work.ipbus_reg_types.all;
use work.ipbus_decode_muon_counter_reset.all;

use work.mp7_ttc_decl.all;
use work.mp7_brd_decl.all;

use work.GMTTypes.all;
use work.ugmt_constants.all;

entity muon_counter_reset is
  generic (
    NCHAN     : positive
    );
  port (
    clk_ipb      : in  std_logic;
    rst          : in  std_logic;
    ipb_in       : in  ipb_wbus;
    ipb_out      : out ipb_rbus;
    ttc_command  : in  ttc_cmd_t;
    clk240       : in  std_logic;
    clk40        : in  std_logic;
    mu_ctr_rst   : out std_logic_vector(N_REGION - 1 downto 0)
    );
end muon_counter_reset;

architecture Behavioral of muon_counter_reset is

  signal ipbw : ipb_wbus_array(N_SLAVES - 1 downto 0);
  signal ipbr : ipb_rbus_array(N_SLAVES - 1 downto 0);

  -- Registers to control manual resets
  signal sManualResetSel  : ipb_reg_v(0 downto 0);
  signal sManualResetCtrl : ipb_reg_v(0 downto 0);

  signal sDelayedReset : std_logic := 0;
  signal sRegReset     : std_logic := 0;

  signal lumi_section_ended : std_logic := 0;


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
      sel             => ipbus_sel_muon_counter_reset(ipb_in.ipb_addr),
      ipb_to_slaves   => ipbw,
      ipb_from_slaves => ipbr
    );


  sRegReset <= sDelayedReset or rst;

  manual_reset_select : entity work.ipbus_reg_v
    generic map(
        N_REG => 1
    )
    port map(
        clk       => clk,
        reset     => rst,
        ipbus_in  => ipbw(N_SLV_MANUAL_RESET_SEL),
        ipbus_out => ipbr(N_SLV_MANUAL_RESET_SEL),
        q         => sManualResetSel
    );
    manual_reset_ctrl : entity work.ipbus_reg_v
      generic map(
          N_REG => 1
      )
      port map(
          clk       => clk,
          reset     => sRegReset,
          ipbus_in  => ipbw(N_SLV_MANUAL_RESET_CTRL),
          ipbus_out => ipbr(N_SLV_MANUAL_RESET_CTRL),
          q         => sManualResetCtrl
      );

  -- TODO: Generate decoder logic

  gen_lumi_section_ended : process (clk40)
    variable orbit_ctr : integer := 0;
  begin  -- process gen_lumi_section_ended
    if clk40'event and clk40 = '1' then  -- rising clock edge
      if rst = '1' then
        lumi_section_ended <= '1';
        orbit_ctr          := 0;
      elsif ttc_command = TTC_BCMD_OC0 then -- TODO: Is this command delayed or do I have to do this here still?
        lumi_section_ended <= '1';
        orbit_ctr          := 0;
      elsif orbit_ctr = LS_LENGTH_IN_ORBITS then
        lumi_section_ended <= '1';
        orbit_ctr          := 0;
      elsif ttc_command = TTC_BCMD_BC0 then
        lumi_section_ended <= '0';
        orbit_ctr          := orbit_ctr+1;
      else
        lumi_section_ended <= '0';
      end if;
    end if;
  end process gen_lumi_section_ended;

  select_source : process (clk40)
  begin -- process select_source
    if clk40'event and clk40 = '1' then -- rising clock edge
      -- Creating "single shot" from this register.
      if sManualResetSel(0)(0) = '1' then
        sDelayedReset <= sManualResetCtrl(0)(0);
      end if;

      for i in N_REGION - 1 downto 0 loop
        if sManualResetSel(0)(0) = '1' then
          mu_ctr_rst(i) <= sManualResetCtrl(0)(0);
        else
          mu_ctr_rst(i) <= lumi_section_ended;
        end if;
      end loop;
    end if;
  end process select_source;

end Behavioral;
