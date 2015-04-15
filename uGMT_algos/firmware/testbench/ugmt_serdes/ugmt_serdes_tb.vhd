library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.GMTTypes.all;
use work.tb_helpers.all;
use STD.TEXTIO.all;
use ieee.std_logic_textio.all;
use work.mp7_data_types.all;
use work.ugmt_constants.all;

entity testbench is
end testbench;

architecture behavior of testbench is

  constant verbose : boolean := false;

  constant div240          : integer   := 12;
  constant div40           : integer   := 2;
  constant half_period_240 : time      := 25000 ps / div240;
  constant half_period_40  : time      := 25000 ps / div40;
  signal   clk240          : std_logic := '1';
  signal   clk40           : std_logic := '1';
  signal   rst             : std_logic := '0';

  signal iD              : ldata(71 downto 0);
  signal oQ              : ldata(71 downto 0);

begin

    uut : entity work.ugmt_serdes
      generic map (
        NCHAN     => 72,
        VALID_BIT => '1'
        )
      port map (
        clk_ipb           => clk240,
        rst               => rst,
        ipb_in.ipb_addr   => (others => '0'),
        ipb_in.ipb_wdata  => (others => '0'),
        ipb_in.ipb_strobe => '0',
        ipb_in.ipb_write  => '0',
        ipb_out           => open,
        clk240            => clk240,
        clk40             => clk40,
        d                 => iD,
        q                 => oQ
        );

  -- Clocks
  clk240 <= not clk240 after half_period_240;
  clk40  <= not clk40  after half_period_40;

  tb : process
    file F                   : text open read_mode is "ugmt_testfile.dat";
    variable L, LO           : line;
    constant uGMT_LATENCY    : integer := 11;
    variable event           : TGMTEvent;
    variable event_buffer    : TGMTEvent_vec(uGMT_LATENCY-1 downto 0);
    variable iEvent          : integer := 0;
    variable tmpError        : integer;
    variable cntError        : integer := 0;
    variable remainingEvents : integer := uGMT_LATENCY-2;
    variable vOutput         : TTransceiverBuffer;

  begin  -- process tb

  write (LO, string'("******************* Reset event buffer ********************** "));
  writeline (OUTPUT, LO);
    -- Reset event buffer
    for i in event_buffer'range loop
        for j in event_buffer(i).iD'range loop
            for k in event_buffer(i).iD(j)'range loop
                event_buffer(i).iD(j)(k).data   := (others => '0');
                event_buffer(i).iD(j)(k).valid  := '0';
                event_buffer(i).iD(j)(k).strobe := '1';
            end loop;  -- k
        end loop;  -- j
    end loop;  -- i

    wait for 50 ns;  -- wait until global set/reset completes

    write (LO, string'("******************* start of tests  ********************** "));
    writeline (OUTPUT, LO);
    -- Add user defined stimulus here
    while remainingEvents > 0 loop
      tmpError := 99999999;
      if not endfile(F) then
        write(LO, string'("++ reading event "));
        write(LO, iEvent);
        write(LO, string'("...."));
        writeline (OUTPUT, LO);
        ReadEvent(F, iEvent, event);

        -- Filling uGMT
        for cnt in 0 to 5 loop
          wait for half_period_240;
          wait for half_period_240;
          iD <= event.iD(cnt);
          vOutput(cnt) := oQ;
        end loop;  -- cnt

        event_buffer(0) := event;

      else
          for cnt in 0 to 5 loop
            wait for half_period_240;
            wait for half_period_240;
            for i in iD'range loop
              iD(i).data   <= (others => '0');
              iD(i).valid  <= '1';
              iD(i).strobe <= '1';
            end loop;  -- i

            vOutput(cnt) := oQ;

          end loop;  -- cnt

          remainingEvents := remainingEvents-1;
      end if;

      event_buffer(uGMT_LATENCY-1 downto 1) := event_buffer(uGMT_LATENCY-2 downto 0);

      ValidateGMTOutput(vOutput, event_buffer(uGMT_LATENCY-1), tmpError);
      cntError := cntError+tmpError;

      if verbose or (tmpError > 0) then
        DumpEvent(event_buffer(uGMT_LATENCY-1));
        write(LO, string'(""));
        writeline (OUTPUT, LO);
        write(LO, string'("### Dumping sim output :"));
        writeline (OUTPUT, LO);
        DumpFrames(vOutput);
        write(LO, string'(""));
        writeline (OUTPUT, LO);
        write(LO, string'(""));
        writeline (OUTPUT, LO);
      end if;

      iEvent := iEvent+1;
    end loop;
    write(LO, string'("!!!!! Number of events with errors: "));
    write(LO, cntError);
    writeline(OUTPUT, LO);
    wait;                               -- will wait forever
  end process tb;

end;
