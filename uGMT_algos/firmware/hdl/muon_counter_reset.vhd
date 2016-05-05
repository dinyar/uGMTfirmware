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
  port (
    clk_ipb              : in  std_logic;
    rst                  : in  std_logic;
    ipb_in               : in  ipb_wbus;
    ipb_out              : out ipb_rbus;
    ttc_command          : in  ttc_cmd_t;
    delayed_ttc_command  : in  ttc_cmd_t; -- BC0 received late by ~master latency. Delayed this signal by (orbit-master lastency) to fix.
    clk40                : in  std_logic;
    mu_ctr_rst           : out std_logic_vector(N_REGION - 1 downto 0)
    );
end muon_counter_reset;

architecture Behavioral of muon_counter_reset is

  signal ipbw : ipb_wbus_array(N_SLAVES - 1 downto 0);
  signal ipbr : ipb_rbus_array(N_SLAVES - 1 downto 0);

  -- Registers to control manual resets
  signal sManualResetSel  : ipb_reg_v(0 downto 0);
  signal sManualResetCtrl : ipb_reg_v(0 downto 0);

  signal sDelayedReset : std_logic := '0';
  signal sRegReset     : std_logic := '0';

  signal receivedOC0 : std_logic := '0';

  signal lumi_section_ended : std_logic := '0';
  signal sLumiSectionReset  : std_logic := '0';

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
        clk       => clk_ipb,
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
          clk       => clk_ipb,
          reset     => sRegReset,
          ipbus_in  => ipbw(N_SLV_MANUAL_RESET_CTRL),
          ipbus_out => ipbr(N_SLV_MANUAL_RESET_CTRL),
          q         => sManualResetCtrl
      );

  gen_lumi_section_ended : process (clk40)
    variable orbit_ctr : integer := 0;
  begin  -- process gen_lumi_section_ended
    if clk40'event and clk40 = '1' then  -- rising clock edge
      if rst = '1' then
        --General reset
        lumi_section_ended <= '1';
        orbit_ctr          := 0;
      elsif ttc_command = TTC_BCMD_OC0 then
        -- Received OC0 at BX 2000. Need to wait for BC0.
        receivedOC0        <= '1';
        lumi_section_ended <= '0';
      elsif orbit_ctr = LS_LENGTH_IN_ORBITS then
        -- Reached end of lumi section. Resetting muon counters.
        lumi_section_ended <= '1';
        orbit_ctr          := 0;
      elsif delayed_ttc_command = TTC_BCMD_BC0 then
        if receivedOC0 = '1' then
          -- End of orbit and OC0 received. Going to reset everything.
          lumi_section_ended <= '0';
          receivedOC0        <= '0';
          orbit_ctr          := 0;
        else
          -- End of orbit, increasing orbit counter.
          lumi_section_ended <= '0';
          orbit_ctr          := orbit_ctr+1;
        end if;
      else
        -- Holding reset signal at '0'.
        lumi_section_ended <= '0';
      end if;
    end if;
  end process gen_lumi_section_ended;

  gen_lumi_section_reset : process (clk40)
  begin  -- process gen_lumi_section_reset
    if clk40'event and clk40 = '1' then  -- rising clock edge
      if (delayed_ttc_command = TTC_BCMD_BC0) and (receivedOC0 = '1') then
        sLumiSectionReset  <= '1';
      else
        sLumiSectionReset  <= '0';
      end if;
    end if;
  end process gen_lumi_section_reset;

  count_lumi_sections : entity work.ipbus_permanent_counter
    port map(
      clk          => clk40,
      reset        => sLumiSectionReset,
      ipbus_in     => ipbw(N_SLV_LUMI_SECTION_CNT),
      ipbus_out    => ipbr(N_SLV_LUMI_SECTION_CNT),
      incr_counter => lumi_section_ended
      );

  select_source : process (clk40)
  begin -- process select_source
    if clk40'event and clk40 = '1' then -- rising clock edge
      -- Creating "single shot" from this register.
      sDelayedReset <= sManualResetCtrl(0)(0);

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
