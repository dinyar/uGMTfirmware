library ieee;
use ieee.std_logic_1164.all;
use ieee.NUMERIC_STD.all;
use work.GMTTypes.all;
use work.ipbus_decode_generate_lemo_signals.all;

entity generate_lemo_signals is
  port (
    clk_ipb : in  std_logic;
    ipb_in  : in  ipb_wbus;
    ipb_out : out ipb_rbus;
    clk     : in  std_logic;
    rst     : in  std_logic;
    iMuons  : in  TGMTMu_vector(7 downto 0);
    iBGOs   : in  ttc_cmd_t;
    iValid  : in  std_logic;
    gpio    : out std_logic_vector(29 downto 0);
    gpio_en : out std_logic_vector(29 downto 0)
    );
end entity generate_lemo_signals;

architecture behavioral of generate_lemo_signals is

  signal sRegisterPrescale : ipb_reg_v(0 downto 0);
  signal sPrescale         : unsigned(31 downto 0);
  signal prescale_counter  : unsigned(31 downto 0) := (others => '0');

  signal trigger_allowed : std_logic := '0';

begin  -- architecture behavioral

  -- IPbus address decode
  fabric : entity work.ipbus_fabric_sel
    generic map(
      NSLV      => N_SLAVES,
      SEL_WIDTH => IPBUS_SEL_WIDTH
      )
    port map(
      ipb_in          => ipb_in,
      ipb_out         => ipb_out,
      sel             => ipbus_sel_generate_lemo_signals(ipb_in.ipb_addr),
      ipb_to_slaves   => ipbw,
      ipb_from_slaves => ipbr
    );

  -- Not using these signals.
  gpio(29 downto 3)    <= (others => '0');
  gpio_en(29 downto 3) <= (others => '0');

  gpio_en(2 downto 0) <= "111";
  gpio(2) <= iValid;

  send_bc0 : process (clk)
  begin  -- process send_bc0
    if clk'event and clk = '1' then  -- rising clock edge
      if iBGOs = TTC_BCMD_BC0 then
        gpio(1) <= '1';
      else
        gpio(1) <= '0';
      end if;
    end if;
  end process send_bc0;

  prescale_register : entity work.ipbus_reg_setable
    generic map(
        N_REG => 1,
        INIT  => X"00000001"
    )
    port map(
        clk       => clk_ipb,
        reset     => rst,
        ipbus_in  => ipbw(N_SLV_PRESCALE),
        ipbus_out => ipbr(N_SLV_PRESCALE),
        q         => sRegisterPrescale
    );

  sPrescale <= unsigned(sRegisterPrescale(0));

  run_prescale : process(clk)
  begin  -- process run_prescale
    if clk'event and clk = '1' then  -- rising clock edge
      if prescale_counter < sPrescale then
        prescale_counter <= prescale_counter+1;
        trigger_allowed <= '0';
      else
        prescale_counter <= to_unsigned(1, prescale_counter'length);
        trigger_allowed <= '1';
      end if;
    end if;
  end process run_prescale;

  send_triggers : process(clk)
    variable mu_present : std_logic := '0';
  begin  -- process send_triggers
    if clk'event and clk = '1' then  -- rising clock edge
      mu_present := '0';
      for i in iMuons'range loop
        if iMuons(i).pt = (others => '0') then
          mu_present <= '0';
        else
          mu_present <= '1';
        end if;
      end loop;

      if (mu_present = '1') and (trigger_allowed = '1') then
        gpio(0) <= '1';
      else
        gpio(1) <= '0';
      end if;
    end if;
  end process send_triggers;

end architecture behavioral;
