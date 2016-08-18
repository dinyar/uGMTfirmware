library std;
use std.env.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.GMTTypes.all;
use work.tb_helpers.all;
use STD.TEXTIO.all;
use ieee.std_logic_textio.all;
use work.mp7_data_types.all;
use work.ugmt_constants.all;

use work.mp7_ttc_decl.all;
use work.mp7_brd_decl.all;

entity testbench is
end testbench;

architecture behavior of testbench is

  constant verbose : boolean := false;

  constant div240          : integer   := 12;
  constant div40           : integer   := 2;
  constant half_period_240 : time      := 25000 ps / div240;
  constant half_period_40  : time      := 6*half_period_240;
  signal   clk240          : std_logic := '1';
  signal   clk40           : std_logic := '0';
  signal   rst             : std_logic_vector(2 downto 0) := (others => '0');
  signal   rst_loc         : std_logic_vector(N_REGION - 1 downto 0) := (others => '0');

  signal iD       : ldata(71 downto 0);
  signal iD_muons : ldata(NUM_MU_CHANS downto 0);
  signal oQ       : ldata(71 downto 0);

  type TCaloTransceiverBuffer is array (integer range <>) of ldata(36-1 downto 0);
  -- Delay by 2 BX (2*6 frames)
  signal iD_buffer_calo : TCaloTransceiverBuffer(2*6-1 downto 0);

  signal dummyCtrs : ttc_stuff_array(N_REGION - 1 downto 0);

begin

    uut : entity work.mp7_payload
      port map (
        clk               => clk240,
        rst               => rst(0),
        ipb_in.ipb_addr   => (others => '0'),
        ipb_in.ipb_wdata  => (others => '0'),
        ipb_in.ipb_strobe => '0',
        ipb_in.ipb_write  => '0',
        ipb_out           => open,
        ctrs              => dummyCtrs,
        clk_p             => clk240,
        clk_payload(0)    => clk40,
        clk_payload(1)    => clk40,
        clk_payload(2)    => clk40,
        rst_payload       => rst,
        rst_loc           => rst_loc,
        clken_loc         => (others => '0'),
        d                 => iD,
        q                 => oQ
        );

  -- Clocks
  clk240 <= not clk240 after half_period_240;
  clk40  <= not clk40  after half_period_40;

  tb : process
    file F                   : text open read_mode  is "ugmt_testfile.dat";
    file FO                  : text open write_mode is "../results/ugmt_serdes_tb.results";
    variable L, LO           : line;
    constant uGMT_LATENCY    : integer := 7;
    variable event           : TGMTEvent;
    variable event_buffer    : TGMTEvent_vec(uGMT_LATENCY-1 downto 0);
    variable iEvent          : integer := 0;
    variable tmpError        : integer;
    variable cntError        : integer := 0;
    variable remainingEvents : integer := uGMT_LATENCY-2;
    variable vOutput         : TExtendedTransceiverBuffer;
    variable vValidOutput    : TTransceiverBuffer;

  begin  -- process tb
    -- Reset event buffer
    for i in event_buffer'range loop
        -- event_buffer(i).iEvent := -1;
        for j in event_buffer(i).iD'range loop
            for k in event_buffer(i).iD(j)'range loop
                event_buffer(i).iD(j)(k).data   := (others => '0');
                event_buffer(i).iD(j)(k).valid  := '0';
                event_buffer(i).iD(j)(k).strobe := '1';
            end loop;  -- k
        end loop;  -- j
    end loop;  -- i

    -- Choosing counter start value so that we see a reset due to the bctr at the beginning of the test.
    for i in dummyCtrs'range loop
      dummyCtrs(i).bctr <= std_logic_vector(to_unsigned(3506, dummyCtrs(i).bctr'length)); 
    end loop;

    rst     <= (others => '1');
    rst_loc <= (others => '1');
    wait for 7*half_period_240;
    rst_loc <= (others => '0');
    wait for 11*half_period_240;
    rst     <= (others => '0');
    for i in 0 to 9 loop
      wait for 2*half_period_40;  -- wait until global set/reset completes
      for i in dummyCtrs'range loop
        dummyCtrs(i).bctr <= std_logic_vector(unsigned(dummyCtrs(i).bctr) + "1");
      end loop;
    end loop;

    -- Add user defined stimulus here
    while remainingEvents > 0 loop
      tmpError := 99999999;
      if not endfile(F) then
        ReadEvent(F, iEvent, event);

        vOutput(4 downto 0) := vOutput(vOutput'high downto vOutput'high-4);
        -- Filling uGMT
        for cnt in 0 to 5 loop
          iD_buffer_calo(0)                            <= event.iD(cnt)(35 downto 0);
          iD_buffer_calo(iD_buffer_calo'high downto 1) <= iD_buffer_calo(iD_buffer_calo'high-1 downto 0);

          iD(71 downto 36) <= event.iD(cnt)(71 downto 36);
          iD(35 downto 0)  <= iD_buffer_calo(iD_buffer_calo'high);

          wait for 2*half_period_240;
          vOutput(cnt+5) := oQ;
        end loop;  -- cnt

        for i in dummyCtrs'range loop
          dummyCtrs(i).bctr <= std_logic_vector(unsigned(dummyCtrs(i).bctr) + "1");
        end loop;

        event_buffer(0) := event;

      else
        vOutput(4 downto 0) := vOutput(vOutput'high downto vOutput'high-4);
        for cnt in 0 to 5 loop
          iD_buffer_calo(iD_buffer_calo'high downto 1) <= iD_buffer_calo(iD_buffer_calo'high-1 downto 0);
          iD(35 downto 0)                              <= iD_buffer_calo(iD_buffer_calo'high);
          for i in 71 downto 36 loop
            iD(i).data   <= (others => '0');
            iD(i).valid  <= '1';
            iD(i).strobe <= '1';
          end loop;  -- i
          wait for 2*half_period_240;

          vOutput(cnt+5) := oQ;

        end loop;  -- cnt

        remainingEvents := remainingEvents-1;
      end if;

      event_buffer(uGMT_LATENCY-1 downto 1) := event_buffer(uGMT_LATENCY-2 downto 0);

      vValidOutput := TTransceiverBuffer(vOutput(2*NUM_MUONS_IN-1 downto 0));
      ValidateGMTOutput(vValidOutput, event_buffer(uGMT_LATENCY-1), FO, tmpError);
      cntError := cntError+tmpError;

      if verbose or (tmpError > 0) then
        if tmpError > 0 then
            write(LO, string'("@@@ ERROR in event "));
        else
            write(LO, string'("@@@ Dumping event "));
        end if;
        write(LO, event_buffer(uGMT_LATENCY-1).iEvent);
        writeline (FO, LO);

        DumpEvent(event_buffer(uGMT_LATENCY-1), FO);
        write(LO, string'(""));
        writeline (FO, LO);
        write(LO, string'("### Dumping sim output :"));
        writeline (FO, LO);
        DumpFrames(vValidOutput, FO);
        write(LO, string'(""));
        writeline (FO, LO);
        write(LO, string'(""));
        writeline (FO, LO);
      end if;

      iEvent := iEvent+1;
    end loop;
    write(LO, string'("!!!!! Number of events with errors: "));
    write(LO, cntError);
    writeline(FO, LO);
    finish(0);
  end process tb;

end;
