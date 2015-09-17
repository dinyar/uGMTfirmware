library ieee;
use ieee.std_logic_1164.all;
use ieee.NUMERIC_STD.all;
use work.GMTTypes.all;

use work.ipbus.all;
use work.ipbus_reg_types.all;
use work.ipbus_decode_spy_buffer_control.all;

use work.mp7_ttc_decl.all;

entity spy_buffer_control is
  port (
    clk_ipb  : in  std_logic;
    ipb_in   : in  ipb_wbus;
    ipb_out  : out ipb_rbus;
    clk240   : in  std_logic;
    rst      : in  std_logic;
    iTrigger : in  std_logic;
    q        : in  ldata(3 downto 0) -- Will store just the output muons.
    );
end entity spy_buffer_control;

architecture behavioral of spy_buffer_control is

  constant SPY_BUFFER_DEPTH : natural := 9;

  signal ipbw : ipb_wbus_array(N_SLAVES - 1 downto 0);
  signal ipbr : ipb_rbus_array(N_SLAVES - 1 downto 0);

  signal mu_present : std_logic := '0';

  signal muon_word_counter : natural range 0 to (2**SPY_BUFFER_DEPTH)-1 := 0;

  signal sMuons_reg : TGMTMu_vector(7 downto 0);

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
      sel             => ipbus_sel_spy_buffer_control(ipb_in.ipb_addr),
      ipb_to_slaves   => ipbw,
      ipb_from_slaves => ipbr
    );

  sync_trigger : process(clk)
  begin  -- process sync_trigger
    if clk'event and clk = '1' then  -- rising clock edge
      -- TODO: Delay trigger signal here to coincide with muon.
    end if;
  end process sync_trigger;

  inc_muon_word_counter : process (clk)
  begin  -- process inc_muon_word_counter
    if clk40'event and clk40 = '1' then  -- rising clock edge
      if iTrigger = '1' then
        if muon_word_counter < (2**SPY_BUFFER_DEPTH)-1 then
          muon_word_counter <= muon_word_counter+1;
        else
          muon_word_counter <= 0;
        end if;
      end if;
    end if;
  end process inc_muon_word_counter;

  fill_spy_buffer : if iTrigger = '1' generate
    loop_over_muons : for i in q'range generate
      spy_buffer : entity work.ipbus_dpram
        generic map (
          ADDR_WIDTH => SPY_BUFFER_DEPTH
          )
        port map (
          clk     => clk_ipb,
          rst     => rst,
          ipb_in  => ipbw(N_SLV_SPY_BUFFER_0+i),
          ipb_out => ipbr(N_SLV_SPY_BUFFER_0+i),
          rclk    => clk240,
          addr    => muon_word_counter,
          d       => q(i),
          q       => open
          );
    end generate loop_over_muons;
  end generate fill_spy_buffer;

end architecture behavioral;
