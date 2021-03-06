library std;
use std.env.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.GMTTypes.all;
use work.tb_helpers.all;
use STD.TEXTIO.all;
use ieee.std_logic_textio.all;

use work.mp7_brd_decl.all;
use work.mp7_data_types.all;

use work.ugmt_constants.all;

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
  signal   rst             : std_logic_vector(N_REGION - 1 downto 0) := (others => '0');

  signal iValid              : std_logic := '0';
  signal iMuons              : TGMTMu_vector(OUTPUT_QUAD_ASSIGNMENT'length*NUM_OUT_CHANS*NUM_MUONS_OUT-1 downto 0);
  signal iExtrapolatedPhi    : TPhi_vector(OUTPUT_QUAD_ASSIGNMENT'length*NUM_OUT_CHANS*NUM_MUONS_OUT-1 downto 0);
  signal iExtrapolatedEta    : TEta_vector(OUTPUT_QUAD_ASSIGNMENT'length*NUM_OUT_CHANS*NUM_MUONS_OUT-1 downto 0);
  signal iIso                : TIsoBits_vector(7 downto 0);
  signal iMuIdxBits          : TIndexBits_vector(OUTPUT_QUAD_ASSIGNMENT'length*NUM_OUT_CHANS*NUM_MUONS_OUT-1 downto 0);
  signal iIntermediateMuonsB : TGMTMu_vector(7 downto 0);
  signal iIntermediateMuonsO : TGMTMu_vector(7 downto 0);
  signal iIntermediateMuonsE : TGMTMu_vector(7 downto 0);
  signal oQ                  : ldata(71 downto 0);

begin

  uut : entity work.serializer_stage
    port map (
      clk240              => clk240,
      clk40               => clk40,
      rst                 => rst,
      iValidMuons         => iValid,
      iValidEnergies      => iValid,
      iMuons              => iMuons,
      iExtrapolatedPhi    => iExtrapolatedPhi,
      iExtrapolatedEta    => iExtrapolatedEta,
      iIso                => iIso,
      iMuIdxBits          => iMuIdxBits,
      iIntermediateMuonsB => iIntermediateMuonsB,
      iIntermediateMuonsO => iIntermediateMuonsO,
      iIntermediateMuonsE => iIntermediateMuonsE,
      q                   => oQ);

  -- Clocks
  clk240 <= not clk240 after half_period_240;
  clk40  <= not clk40  after half_period_40;

  tb : process
    file F                      : text open read_mode is "ugmt_testfile.dat";
    file FO                     : text open write_mode is "../results/serializer_tb.results";
    variable L, LO              : line;
    constant SERIALIZER_LATENCY : integer := 4;
    variable event              : TGMTOutEvent;
    variable event_buffer       : TGMTOutEvent_vec(SERIALIZER_LATENCY-1 downto 0);
    variable iEvent             : integer := 0;
    variable tmpError           : integer;
    variable cntError           : integer := 0;
    variable remainingEvents    : integer := SERIALIZER_LATENCY-2;
    variable vOutput            : TExtendedTransceiverBuffer;
    variable vValidOutput       : TTransceiverBuffer;

  begin  -- process tb

    -- Reset event buffer
    for i in event_buffer'range loop
      event_buffer(i).iEvent := -1;
      for iMu in event_buffer(i).muons'range loop
        event_buffer(i).muons(iMu)           := ('0', '0', "000000000", '0', "0000", "000000000", "0000000000", '0');
        event_buffer(i).extrapolatedPhi(iMu) := "0000000000";
        event_buffer(i).extrapolatedEta(iMu) := "000000000";
        event_buffer(i).iso(iMu)             := "00";
      end loop;  -- iMu
    end loop;  -- i
    iValid <= '0';

    rst    <= (others => '1');
    -- wait for 3*half_period_40;
    wait for 19*half_period_240;
    rst    <= (others => '0');
    -- wait for 2*half_period_40;  -- wait until global set/reset completes
    wait for 11*half_period_240;  -- wait until global set/reset completes

    while remainingEvents > 0 loop
      tmpError := 99999999;
      if not endfile(F) then
        ReadOutEvent(F, iEvent, event);

        -- Filling serializer
        iValid              <= '1';
        for i in OUTPUT_QUAD_ASSIGNMENT'range loop
          iMuons(8*i+7 downto 8*i)           <= event_buffer(1).muons;
          iExtrapolatedPhi(8*i+7 downto 8*i) <= event_buffer(1).extrapolatedPhi;
          iExtrapolatedEta(8*i+7 downto 8*i) <= event_buffer(1).extrapolatedEta;
          iMuIdxBits(8*i+7 downto 8*i)       <= event_buffer(1).idxBits;
        end loop;
        iIso                <= event_buffer(1).iso;
        iIntermediateMuonsB <= event_buffer(1).intMuons_bmtf;
        iIntermediateMuonsO <= event_buffer(1).intMuons_omtf;
        iIntermediateMuonsE <= event_buffer(1).intMuons_emtf;

        event_buffer(0) := event;
      else
        for i in OUTPUT_QUAD_ASSIGNMENT'range loop
          iMuons(8*i+7 downto 8*i)           <= event_buffer(1).muons;
          iExtrapolatedPhi(8*i+7 downto 8*i) <= event_buffer(1).extrapolatedPhi;
          iExtrapolatedEta(8*i+7 downto 8*i) <= event_buffer(1).extrapolatedEta;
          iMuIdxBits(8*i+7 downto 8*i)       <= event_buffer(1).idxBits;
        end loop;
        iIso                <= event_buffer(1).iso;
        iIntermediateMuonsB <= event_buffer(1).intMuons_bmtf;
        iIntermediateMuonsO <= event_buffer(1).intMuons_omtf;
        iIntermediateMuonsE <= event_buffer(1).intMuons_emtf;
        remainingEvents     := remainingEvents-1;
      end if;

      vOutput(4 downto 0) := vOutput(vOutput'high downto vOutput'high-4);
      for cnt in 0 to 5 loop
        wait for 2*half_period_240;
        vOutput(cnt+5) := oQ;
      end loop;  -- cnt

      event_buffer(SERIALIZER_LATENCY-1 downto 1) := event_buffer(SERIALIZER_LATENCY-2 downto 0);

      vValidOutput := TTransceiverBuffer(vOutput(5 downto 0));
      ValidateSerializerOutput(vValidOutput, event_buffer(SERIALIZER_LATENCY-1), FO, tmpError);
      cntError := cntError+tmpError;

      if verbose or (tmpError > 0) then
        if tmpError > 0 then
          write(LO, string'("@@@ ERROR in event "));
        else
          write(LO, string'("@@@ Dumping event "));
        end if;
        write(LO, event_buffer(SERIALIZER_LATENCY-1).iEvent);
        writeline (FO, LO);

        DumpOutEvent(event_buffer(SERIALIZER_LATENCY-1), FO);
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
