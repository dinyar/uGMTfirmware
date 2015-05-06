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
  signal   clk40           : std_logic := '1';
  signal   rst             : std_logic := '0';

  signal iD              : ldata(NINCHAN-1 downto 0);
  signal sMuons          : TGMTMu_vector(107 downto 0);
  signal sTracks         : TGMTMuTracks_vector(35 downto 0);
  signal sSortRanks      : TSortRank10_vector(107 downto 0);
  signal sEmpty          : std_logic_vector(107 downto 0);
  signal sValid_muons    : std_logic;
  signal sEnergies       : TCaloRegionEtaSlice_vector(NUM_CALO_CHANS-1 downto 0);
  signal sValid_energies : std_logic;

  signal dummyCtrs : ttc_stuff_array(N_REGION - 1 downto 0);

begin

    uut_muons : entity work.deserializer_stage_muons
      generic map (
        NCHAN     => NINCHAN,
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
        ctrs              => dummyCtrs,
        clk240            => clk240,
        clk40             => clk40,
        d                 => iD(NINCHAN-1 downto 0),
        oMuons            => sMuons,
        oTracks           => sTracks,
        oEmpty            => sEmpty,
        oSortRanks        => sSortRanks,
        oValid            => sValid_muons
        );

    uut_energies : entity work.deserializer_stage_energies
      generic map (
        NCHAN     => NINCHAN,
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
        ctrs              => dummyCtrs,
        clk240            => clk240,
        clk40             => clk40,
        d                 => iD(NINCHAN-1 downto 0),
        oEnergies         => sEnergies,
        oValid            => sValid_energies
        );

  -- Clocks
  clk240 <= not clk240 after half_period_240;
  clk40  <= not clk40  after half_period_40;

  tb : process
    file F                        : text open read_mode is "ugmt_testfile.dat";
    file FO                       : text open write_mode is "../results/deserializer_tb.results";
    variable L, LO                : line;
    constant DESERIALIZER_LATENCY : integer := 3;
    variable event                : TGMTInEvent;
    variable event_buffer         : TGMTInEvent_vec(DESERIALIZER_LATENCY-1 downto 0);
    variable iEvent               : integer := 0;
    variable tmpError             : integer;
    variable cntError             : integer := 0;
    variable remainingEvents      : integer := DESERIALIZER_LATENCY-2;
    variable vMuons               : TGMTMu_vector(107 downto 0);
    variable vTracks              : TGMTMuTracks_vector(35 downto 0);
    variable vSortRanks           : TSortRank10_vector(107 downto 0);
    variable vEmpty               : std_logic_vector(107 downto 0);
    variable vValid_muons         : std_logic;
    variable vEnergies            : TCaloRegionEtaSlice_vector(NUM_CALO_CHANS-1 downto 0);
    variable vValid_energies      : std_logic;
    variable in_id                : string(1 to 3) := "INS";


  begin  -- process tb

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

    -- TODO: Is this needed?
    wait for 4*half_period_40;  -- wait until global set/reset completes

    while remainingEvents > 0 loop
      tmpError := 99999999;
      if not endfile(F) then
        ReadInEvent(F, iEvent, event);

        -- Filling deserializers
        for cnt in 0 to 5 loop
          iD <= event.iD(cnt);
          wait for 2*half_period_240;
        end loop;  -- cnt

        event_buffer(0) := event;

      else
          for cnt in 0 to 5 loop
            for i in iD'range loop
              iD(i).data   <= (others => '0');
              iD(i).valid  <= '1';
              iD(i).strobe <= '1';
            end loop;  -- i
            wait for 2*half_period_240;
          end loop;  -- cnt

          remainingEvents := remainingEvents-1;
      end if;

      event_buffer(DESERIALIZER_LATENCY-1 downto 1) := event_buffer(DESERIALIZER_LATENCY-2 downto 0);

      vMuons          := sMuons;
      vTracks         := sTracks;
      vSortRanks      := sSortRanks;
      vEmpty          := sEmpty;
      vValid_muons    := sValid_muons;
      vEnergies       := sEnergies;
      vValid_energies := sValid_energies;

      ValidateDeserializerOutput(vMuons, vTracks, vSortRanks, vEmpty, vValid_muons, vEnergies, vValid_energies, event_buffer(DESERIALIZER_LATENCY-1), FO, tmpError);
      cntError := cntError+tmpError;

      if verbose or (tmpError > 0) then
        if tmpError > 0 then
          write(LO, string'("@@@ ERROR in event "));
        else
          write(LO, string'("@@@ Dumping event "));
        end if;
        write(LO, event_buffer(DESERIALIZER_LATENCY-1).iEvent);
        writeline (FO, LO);

        DumpInEvent(event_buffer(DESERIALIZER_LATENCY-1), FO);
        write(LO, string'(""));
        writeline (FO, LO);
        write(LO, string'("### Dumping sim output :"));
        writeline (FO, LO);
        DumpValidBits(vValid_muons, vValid_energies, FO);
        DumpMuons(vMuons, vSortRanks, vEmpty, FO, in_id);
        DumpEnergyValues(vEnergies, FO);
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
