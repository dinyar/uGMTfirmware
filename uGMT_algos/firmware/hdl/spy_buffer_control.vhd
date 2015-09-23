library ieee;
use ieee.std_logic_1164.all;
use ieee.NUMERIC_STD.all;
use work.GMTTypes.all;

use work.mp7_data_types.all;

use work.ipbus.all;
use work.ipbus_reg_types.all;
use work.ipbus_decode_spy_buffer_control.all;

use work.mp7_ttc_decl.all;

entity spy_buffer_control is
  port (
    clk_ipb  : in  std_logic;
    ipb_in   : in  ipb_wbus;
    ipb_out  : out ipb_rbus;
    clk40    : in  std_logic;
    clk240   : in  std_logic;
    rst      : in  std_logic;
    iTrigger : in  std_logic;
    q        : in  ldata(3 downto 0) -- Will store just the output muons.
    );
end entity spy_buffer_control;

architecture behavioral of spy_buffer_control is

  constant SPY_BUFFER_DEPTH : natural := 12;

  signal ipbw : ipb_wbus_array(N_SLAVES - 1 downto 0);
  signal ipbr : ipb_rbus_array(N_SLAVES - 1 downto 0);

  constant DELAY_LATENCY : natural := 6;
  signal in_buf          : TQuadTransceiverBufferIn;

  signal mu_present : std_logic := '0';

  signal muon_word_counter : natural range 0 to (2**SPY_BUFFER_DEPTH)-1 := 0;
  signal muon_word_address : std_logic_vector(SPY_BUFFER_DEPTH-1 downto 0);

  type TMuonWordVector is array (natural range <>) of std_logic_vector(31 downto 0);
  signal capture_muon_words : TMuonWordVector(3 downto 0);

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

  fill_delay_line : process (clk240)
  begin  -- process fill_delay_line
    if clk240'event and clk240 = '1' then  -- rising clock edge
      in_buf(DELAY_LATENCY-1) <= q;
      in_buf(DELAY_LATENCY-2 downto 0) <= in_buf(DELAY_LATENCY-1 downto 1);
    end if;
  end process fill_delay_line;

  inc_muon_word_counter : process (clk240)
  begin  -- process inc_muon_word_counter
    if clk240'event and clk240 = '1' then  -- rising clock edge
      if iTrigger = '1' then
        -- Fill with muon data.
        for i in q'range loop
          capture_muon_words(i) <= in_buf(0)(i).data;
        end loop;
        -- Increment address pointer
        if muon_word_counter < (2**SPY_BUFFER_DEPTH)-1 then
          muon_word_counter <= muon_word_counter+1;
        else
          muon_word_counter <= 0;
        end if;
      else
        -- Fill with zeros and don't increment address pointer.
        for i in q'range loop
          capture_muon_words(i) <= (others => '0');
        end loop;
      end if;
    end if;
  end process inc_muon_word_counter;

  muon_word_address <= std_logic_vector(to_unsigned(muon_word_counter, muon_word_address'length));

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
        we      => '1',
        addr    => muon_word_address,
        d       => capture_muon_words(i),
        q       => open
        );
  end generate loop_over_muons;

end architecture behavioral;
