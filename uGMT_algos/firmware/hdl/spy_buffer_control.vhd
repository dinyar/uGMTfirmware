-- TODO: DESCRIPTION HERE!
-- Expecting lower half (i.e. X downto 0) to contain output channels to be spied on.
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.NUMERIC_STD.all;
use work.GMTTypes.all;

use work.mp7_data_types.all;

entity spy_buffer_control is
  generic (
    ALGO_LATENCY   : natural := 6;  -- in 240 MHz clocks
    N_IN_CHANS     : natural := 0;  -- Number of input channels to be spied on
    N_SPIED_CHANS  : natural := 1   -- Total number of channels to be spied on
    );
  port (
    clk_p        : in  std_logic;
    iTrigger     : in  std_logic;
    spied_chans  : in  ldata(N_SPIED_CHANS-1 downto 0);
    q            : out ldata(N_SPIED_CHANS-1 downto 0)
    );
end entity spy_buffer_control;

architecture behavioral of spy_buffer_control is

  -- TODO: Function that computes width of buffer.
  type TInTransceiverBuffer is array (ALGO_LATENCY-1 downto 0) of ldata(71 downto 0);
  signal in_buf : TInTransceiverBuffer;

begin  -- architecture behavioral
  assert N_SPIED_CHANS >= N_IN_CHANS report "Number of spied channels have to be at least equal to number of input channels." severity failure;

  fill_delay_line : process (clk_p)
  begin  -- process fill_delay_line
    if clk_p'event and clk_p = '1' then  -- rising clock edge
      if N_IN_CHANS > 0 then
        in_buf(ALGO_LATENCY-1)(N_IN_CHANS-1 downto 0) <= spied_chans(N_IN_CHANS-1 downto 0);
        in_buf(ALGO_LATENCY-2 downto 0)               <= in_buf(ALGO_LATENCY-1 downto 1);
      end if;
    end if;
  end process fill_delay_line;

  propagate_to_buffers : process(in_buf, spied_chans, iTrigger)
  begin  -- process propagate_to_buffers
    if N_IN_CHANS > 0 then
      for iChan in N_IN_CHANS-1 downto 0 loop
        q(iChan).data   <= in_buf(0)(iChan).data;
        q(iChan).valid  <= in_buf(0)(iChan).valid;
        q(iChan).strobe <= iTrigger;
      end loop;
    end if;

    if N_SPIED_CHANS /= N_IN_CHANS then
      for iChan in N_SPIED_CHANS-1 downto N_IN_CHANS loop
        q(iChan).data   <= spied_chans(iChan).data;
        q(iChan).valid  <= spied_chans(iChan).valid;
        q(iChan).strobe <= iTrigger;
      end loop;
    end if;

  end process propagate_to_buffers;

end architecture behavioral;
