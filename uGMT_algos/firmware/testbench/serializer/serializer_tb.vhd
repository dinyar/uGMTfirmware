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

  signal iMuons                  : TGMTMu_vector(7 downto 0);
  signal iIso                    : TIsoBits_vector(7 downto 0);
  signal iIntermediateMuonsB     : TGMTMu_vector(7 downto 0);
  signal iIntermediateMuonsO     : TGMTMu_vector(7 downto 0);
  signal iIntermediateMuonsF     : TGMTMu_vector(7 downto 0);
  signal iIntermediateSortRanksB : TSortRank10_vector(7 downto 0);
  signal iIntermediateSortRanksO : TSortRank10_vector(7 downto 0);
  signal iIntermediateSortRanksF : TSortRank10_vector(7 downto 0);
  signal iFinalEnergies          : TCaloArea_vector(7 downto 0);
  signal iExtrapolatedCoordsB    : TSpatialCoordinate_vector(35 downto 0);
  signal iExtrapolatedCoordsO    : TSpatialCoordinate_vector(35 downto 0);
  signal iExtrapolatedCoordsF    : TSpatialCoordinate_vector(35 downto 0);
  signal oQ                      : ldata(NOUTCHAN-1 downto 0);
  signal oOutput                 : TOutTransceiverBuffer;

begin

  uut : entity work.serializer_stage
    port map (
      clk240               => clk240,
      clk40                => clk40,
      sMuons               => iMuons,
      sIso                 => iIso,
      iIntermediateMuonsB  => iIntermediateMuonsB,
      iIntermediateMuonsO  => iIntermediateMuonsO,
      iIntermediateMuonsF  => iIntermediateMuonsF,
      iSortRanksB          => iIntermediateSortRanksB,
      iSortRanksO          => iIntermediateSortRanksO,
      iSortRanksF          => iIntermediateSortRanksF,
      iFinalEnergies       => iFinalEnergies,
      iExtrapolatedCoordsB => iExtrapolatedCoordsB,
      iExtrapolatedCoordsO => iExtrapolatedCoordsO,
      iExtrapolatedCoordsF => iExtrapolatedCoordsF,
      q                    => oQ);

  -- Clocks
  clk240 <= not clk240 after half_period_240;
  clk40  <= not clk40  after half_period_40;

  tb : process
    file F                      : text open read_mode is "ugmt_testfile.dat";
    variable L, LO              : line;
    constant SERIALIZER_LATENCY : integer := 2;
    variable event              : TGMTOutEvent;
    variable event_buffer       : TGMTOutEvent_vec(SERIALIZER_LATENCY downto 0);
    variable iEvent             : integer := 0;
    variable tmpError           : integer;
    variable cntError           : integer := 0;
    variable remainingEvents    : integer := SERIALIZER_LATENCY-1;
    variable vOutput            : TOutTransceiverBuffer;

  begin  -- process tb

    -- Reset event buffer
    for iMu in event_buffer(1).muons'range loop
      event_buffer(1).muons(iMu) := ('0', "00", "000000000", "0000", "000000000", "0000000000");
      event_buffer(1).iso(iMu)   := "00";
    end loop;  -- iMu


    wait for 250 ns;  -- wait until global set/reset completes
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
        ReadOutEvent(F, iEvent, event);

        -- Filling serializer
        iMuons                  <= event_buffer(1).muons;
        iIso                    <= event_buffer(1).iso;
        iIntermediateMuonsB     <= event.intMuons_brl;
        iIntermediateMuonsO     <= event.intMuons_ovl;
        iIntermediateMuonsF     <= event.intMuons_fwd;
        iIntermediateSortRanksB <= event.intSortRanks_brl;
        iIntermediateSortRanksO <= event.intSortRanks_ovl;
        iIntermediateSortRanksF <= event.intSortRanks_fwd;
        iFinalEnergies          <= (others => "00000");
        iExtrapolatedCoordsB    <= (others => ("000000000", "0000000000"));
        iExtrapolatedCoordsO    <= (others => ("000000000", "0000000000"));
        iExtrapolatedCoordsF    <= (others => ("000000000", "0000000000"));

        event_buffer(0) := event;

      else
        remainingEvents := remainingEvents-1;
      end if;

      for cnt in 0 to 5 loop
        oOutput(cnt) <= oQ(NCHAN-1 downto 0);

        wait for half_period_240;
        wait for half_period_240;

      end loop;  -- cnt

      vOutput := oOutput;

      event_buffer(SERIALIZER_LATENCY downto 1) := event_buffer(SERIALIZER_LATENCY-1 downto 0);

      ValidateSerializerOutput(vOutput, event_buffer(SERIALIZER_LATENCY), tmpError);
      cntError := cntError+tmpError;

      if verbose or (tmpError > 0) then
        DumpOutEvent(event_buffer(SERIALIZER_LATENCY));
        write(LO, string'(""));
        writeline (OUTPUT, LO);
        write(LO, string'("### Dumping sim output :"));
        writeline (OUTPUT, LO);
        DumpOutput(vOutput);
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
