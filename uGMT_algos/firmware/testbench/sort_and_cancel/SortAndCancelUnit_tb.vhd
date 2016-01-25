library std;
use std.env.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.GMTTypes.all;
use work.tb_helpers.all;
use STD.TEXTIO.all;

entity testbench is
end testbench;

architecture behavior of testbench is

  constant verbose : boolean := false;

  type TIntermediateMu_buf is array (integer range <>) of TGMTMu_vector(7 downto 0);
  type TSortRank_buf is array (integer range <>) of TSortRank10_vector(7 downto 0);

  constant div240          : integer   := 12;
  constant div40           : integer   := 2;
  constant half_period_240 : time      := 25000 ps / div240;
  constant half_period_40  : time      := 6*half_period_240;
  signal   clk240          : std_logic := '1';
  signal   clk40           : std_logic := '1';
  signal   rst             : std_logic := '0';
  signal   rst_loc         : std_logic_vector(17 downto 0) := (others => '0');

  signal iMuonsB             : TGMTMu_vector(35 downto 0);
  signal iMuonsO             : TGMTMu_vector(35 downto 0);
  signal iMuonsE             : TGMTMu_vector(35 downto 0);
  signal iMuonsRPCb          : TGMTMuRPC_vector(3 downto 0);
  signal iMuonsRPCf          : TGMTMuRPC_vector(3 downto 0);
  signal iTracksB            : TGMTMuTracks_vector(11 downto 0);
  signal iTracksO            : TGMTMuTracks_vector(11 downto 0);
  signal iTracksE            : TGMTMuTracks_vector(11 downto 0);
  signal iSortRanksB         : TSortRank10_vector(35 downto 0);
  signal iSortRanksO         : TSortRank10_vector(35 downto 0);
  signal iSortRanksE         : TSortRank10_vector(35 downto 0);
  signal iIdxBitsB           : TIndexBits_vector(35 downto 0);
  signal iIdxBitsO           : TIndexBits_vector(35 downto 0);
  signal iIdxBitsE           : TIndexBits_vector(35 downto 0);
  signal oIntermediateMuonsB : TGMTMu_vector(7 downto 0);
  signal oIntermediateMuonsO : TGMTMu_vector(7 downto 0);
  signal oIntermediateMuonsE : TGMTMu_vector(7 downto 0);
  signal oSortRanksB         : TSortRank10_vector(7 downto 0);
  signal oSortRanksO         : TSortRank10_vector(7 downto 0);
  signal oSortRanksE         : TSortRank10_vector(7 downto 0);
  signal oIdxBits            : TIndexBits_vector(7 downto 0);
  signal oMuPt               : TMuonPT_vector(7 downto 0);
  signal oMuons              : TGMTMu_vector(7 downto 0);
begin

  -- Component Instantiation
  uut : entity work.SortAndCancelUnit
    port map(
      iMuonsB                 => iMuonsB,
      iMuonsO                 => iMuonsO,
      iMuonsE                 => iMuonsE,
      iMuonsRPCb              => iMuonsRPCb,
      iMuonsRPCf              => iMuonsRPCf,
      iSortRanksRPCb          => (others => "0000000000"),
      iSortRanksRPCf          => (others => "0000000000"),
      iEmptyRPCb              => (others => '0'),
      iEmptyRPCf              => (others => '0'),
      iIdxBitsRPCb            => (others => "0000000"),
      iIdxBitsRPCf            => (others => "0000000"),
      iTracksB                => iTracksB,
      iTracksO                => iTracksO,
      iTracksE                => iTracksE,
      iSortRanksB             => iSortRanksB,
      iSortRanksO             => iSortRanksO,
      iSortRanksE             => iSortRanksE,
      iIdxBitsB               => iIdxBitsB,
      iIdxBitsO               => iIdxBitsO,
      iIdxBitsE               => iIdxBitsE,
      oIntermediateMuonsB     => oIntermediateMuonsB,
      oIntermediateMuonsO     => oIntermediateMuonsO,
      oIntermediateMuonsE     => oIntermediateMuonsE,
      oIntermediateSortRanksB => oSortRanksB,
      oIntermediateSortRanksO => oSortRanksO,
      oIntermediateSortRanksE => oSortRanksE,
      oIdxBits                => oIdxBits,
      oMuPt                   => oMuPt,
      oMuons                  => oMuons,
      mu_ctr_rst              => '0', 
      clk                     => clk40,
      clk_ipb                 => clk240,
      sinit                   => rst,
      rst_loc                 => rst_loc,
      ipb_in.ipb_addr         => (others => '0'),
      ipb_in.ipb_wdata        => (others => '0'),
      ipb_in.ipb_strobe       => '0',
      ipb_in.ipb_write        => '0',
      ipb_out                 => open
      );

  -- Clocks
  clk240 <= not clk240 after half_period_240;
  clk40  <= not clk40  after half_period_40;

  --  Test Bench Statements
  tb : process
    file F                               : text open read_mode is "ugmt_testfile.dat";
    file FO                              : text open write_mode is "../results/SortAndCancel_tb.results";
    variable L, LO                       : line;
    variable event                       : TGMTMuEvent;
    constant SORTER_LATENCY              : integer                        := 5;
    variable event_buffer                : TGMTMuEvent_vec(SORTER_LATENCY-1 downto 0);
    -- Delay is one more than in sorter unit due to the delay in the serializer.
    constant INTERMEDIATE_DELAY          : integer                        := 3;
    variable vIntermediateB_buffer       : TIntermediateMu_buf(INTERMEDIATE_DELAY-1 downto 0);
    variable vIntermediateO_buffer       : TIntermediateMu_buf(INTERMEDIATE_DELAY-1 downto 0);
    variable vIntermediateE_buffer       : TIntermediateMu_buf(INTERMEDIATE_DELAY-1 downto 0);
    variable vSortRankB_buffer           : TSortRank_buf(INTERMEDIATE_DELAY-1 downto 0);
    variable vSortRankO_buffer           : TSortRank_buf(INTERMEDIATE_DELAY-1 downto 0);
    variable vSortRankE_buffer           : TSortRank_buf(INTERMEDIATE_DELAY-1 downto 0);
    variable vMuons, vIntB, vIntO, vIntE : TGMTMu_vector(oMuons'range);
    variable vDummySortRanks             : TSortRank10_vector(7 downto 0) := (others => "0000000000");
    variable fin_id                      : string(1 to 4)                 := string'("FINM");
    variable int_id                      : string(1 to 4)                 := string'("INTM");
    variable iEvent                      : integer                        := 0;
    variable tmpError                    : integer;
    variable cntError                    : integer                        := 0;
    variable remainingEvents             : integer                        := SORTER_LATENCY-2;
  begin

    -- Reset event buffer
    for iEvent in event_buffer'range loop
      event_buffer(iEvent).iEvent := -1;
      for i in event_buffer(iEvent).muons_bmtf'range loop
        event_buffer(iEvent).muons_bmtf(i).phi        := "0000000000";
        event_buffer(iEvent).muons_bmtf(i).eta        := "000000000";
        event_buffer(iEvent).muons_bmtf(i).pt         := "000000000";
        event_buffer(iEvent).muons_bmtf(i).qual       := "0000";
        event_buffer(iEvent).muons_bmtf(i).sign       := '0';
        event_buffer(iEvent).muons_bmtf(i).sign_valid := '0';
        event_buffer(iEvent).muons_omtf(i).phi        := "0000000000";
        event_buffer(iEvent).muons_omtf(i).eta        := "000000000";
        event_buffer(iEvent).muons_omtf(i).pt         := "000000000";
        event_buffer(iEvent).muons_omtf(i).qual       := "0000";
        event_buffer(iEvent).muons_omtf(i).sign       := '0';
        event_buffer(iEvent).muons_omtf(i).sign_valid := '0';
        event_buffer(iEvent).muons_emtf(i).phi        := "0000000000";
        event_buffer(iEvent).muons_emtf(i).eta        := "000000000";
        event_buffer(iEvent).muons_emtf(i).pt         := "000000000";
        event_buffer(iEvent).muons_emtf(i).qual       := "0000";
        event_buffer(iEvent).muons_emtf(i).sign       := '0';
        event_buffer(iEvent).muons_emtf(i).sign_valid := '0';
        event_buffer(iEvent).sortRanks_bmtf(i)        := "0000000000";
        event_buffer(iEvent).sortRanks_omtf(i)        := "0000000000";
        event_buffer(iEvent).sortRanks_emtf(i)        := "0000000000";
        event_buffer(iEvent).empty_bmtf(i)            := '1';
        event_buffer(iEvent).empty_omtf(i)            := '1';
        event_buffer(iEvent).empty_emtf(i)            := '1';
        event_buffer(iEvent).idxBits_bmtf(i)          := (others => '0');
        event_buffer(iEvent).idxBits_omtf(i)          := (others => '0');
        event_buffer(iEvent).idxBits_emtf(i)          := (others => '0');
      end loop;
      for i in event_buffer(iEvent).expectedMuons'range loop
        event_buffer(iEvent).expectedMuons(i).phi         := "0000000000";
        event_buffer(iEvent).expectedMuons(i).eta         := "000000000";
        event_buffer(iEvent).expectedMuons(i).pt          := "000000000";
        event_buffer(iEvent).expectedMuons(i).qual        := "0000";
        event_buffer(iEvent).expectedMuons(i).sign        := '0';
        event_buffer(iEvent).expectedMuons(i).sign_valid  := '0';
        event_buffer(iEvent).expectedIntMuB(i).phi        := "0000000000";
        event_buffer(iEvent).expectedIntMuB(i).eta        := "000000000";
        event_buffer(iEvent).expectedIntMuB(i).pt         := "000000000";
        event_buffer(iEvent).expectedIntMuB(i).qual       := "0000";
        event_buffer(iEvent).expectedIntMuB(i).sign       := '0';
        event_buffer(iEvent).expectedIntMuB(i).sign_valid := '0';
        event_buffer(iEvent).expectedIntMuO(i).phi        := "0000000000";
        event_buffer(iEvent).expectedIntMuO(i).eta        := "000000000";
        event_buffer(iEvent).expectedIntMuO(i).pt         := "000000000";
        event_buffer(iEvent).expectedIntMuO(i).qual       := "0000";
        event_buffer(iEvent).expectedIntMuO(i).sign       := '0';
        event_buffer(iEvent).expectedIntMuO(i).sign_valid := '0';
        event_buffer(iEvent).expectedIntMuE(i).phi        := "0000000000";
        event_buffer(iEvent).expectedIntMuE(i).eta        := "000000000";
        event_buffer(iEvent).expectedIntMuE(i).pt         := "000000000";
        event_buffer(iEvent).expectedIntMuE(i).qual       := "0000";
        event_buffer(iEvent).expectedIntMuE(i).sign       := '0';
        event_buffer(iEvent).expectedIntMuE(i).sign_valid := '0';
        event_buffer(iEvent).expectedSrtRnksB(i)          := (others => '0');
        event_buffer(iEvent).expectedSrtRnksO(i)          := (others => '0');
        event_buffer(iEvent).expectedSrtRnksE(i)          := (others => '0');
      end loop;  -- i
      for i in iTracksB'range loop
        for j in iTracksB(0)'range loop
          event_buffer(iEvent).tracks_bmtf(i)(j).eta  := "000000000";
          event_buffer(iEvent).tracks_bmtf(i)(j).phi  := "00000000";
          event_buffer(iEvent).tracks_bmtf(i)(j).qual := "0000";
          event_buffer(iEvent).tracks_omtf(i)(j).eta  := "000000000";
          event_buffer(iEvent).tracks_omtf(i)(j).phi  := "00000000";
          event_buffer(iEvent).tracks_omtf(i)(j).qual := "0000";
          event_buffer(iEvent).tracks_emtf(i)(j).eta  := "000000000";
          event_buffer(iEvent).tracks_emtf(i)(j).phi  := "00000000";
          event_buffer(iEvent).tracks_emtf(i)(j).qual := "0000";
        end loop;  -- j
      end loop;  -- i
    end loop;  -- event
    -- Reset intermediate buffer
    for iInt in vIntermediateB_buffer'range loop
      for iMu in vIntermediateB_buffer(iInt)'range loop
        vIntermediateB_buffer(iInt)(iMu).phi        := "0000000000";
        vIntermediateB_buffer(iInt)(iMu).eta        := "000000000";
        vIntermediateB_buffer(iInt)(iMu).pt         := "000000000";
        vIntermediateB_buffer(iInt)(iMu).qual       := "0000";
        vIntermediateB_buffer(iInt)(iMu).sign       := '0';
        vIntermediateB_buffer(iInt)(iMu).sign_valid := '0';
        vIntermediateO_buffer(iInt)(iMu).phi        := "0000000000";
        vIntermediateO_buffer(iInt)(iMu).eta        := "000000000";
        vIntermediateO_buffer(iInt)(iMu).pt         := "000000000";
        vIntermediateO_buffer(iInt)(iMu).qual       := "0000";
        vIntermediateO_buffer(iInt)(iMu).sign       := '0';
        vIntermediateO_buffer(iInt)(iMu).sign_valid := '0';
        vIntermediateE_buffer(iInt)(iMu).phi        := "0000000000";
        vIntermediateE_buffer(iInt)(iMu).eta        := "000000000";
        vIntermediateE_buffer(iInt)(iMu).pt         := "000000000";
        vIntermediateE_buffer(iInt)(iMu).qual       := "0000";
        vIntermediateE_buffer(iInt)(iMu).sign       := '0';
        vIntermediateE_buffer(iInt)(iMu).sign_valid := '0';
        vSortRankB_buffer(iInt)(iMu)                := "0000000000";
        vSortRankO_buffer(iInt)(iMu)                := "0000000000";
        vSortRankE_buffer(iInt)(iMu)                := "0000000000";
      end loop;  -- iMu
    end loop;  -- iInt

    wait for 20*half_period_40;  -- wait until global set/reset completes
    -- Add user defined stimulus here
    while remainingEvents > 0 loop
      tmpError := 99999999;
      if not endfile(F) then
        ReadMuEvent(F, iEvent, event);

        -- Filling uGMT
        iMuonsB     <= event.muons_bmtf;
        iMuonsO     <= event.muons_omtf;
        iMuonsE     <= event.muons_emtf;
        iTracksB    <= event.tracks_bmtf;
        iTracksO    <= event.tracks_omtf;
        iTracksE    <= event.tracks_emtf;
        iSortRanksB <= event.sortRanks_bmtf;
        iSortRanksO <= event.sortRanks_omtf;
        iSortRanksE <= event.sortRanks_emtf;
        iIdxBitsB   <= event.idxBits_bmtf;
        iIdxBitsO   <= event.idxBits_omtf;
        iIdxBitsE   <= event.idxBits_emtf;

        event_buffer(0) := event;

      else
        remainingEvents := remainingEvents-1;
      end if;

      event_buffer(SORTER_LATENCY-1 downto 1)                    := event_buffer(SORTER_LATENCY-2 downto 0);
      vIntermediateB_buffer(0)                                   := oIntermediateMuonsB;
      vIntermediateO_buffer(0)                                   := oIntermediateMuonsO;
      vIntermediateE_buffer(0)                                   := oIntermediateMuonsE;
      vIntermediateB_buffer(vIntermediateB_buffer'high downto 1) := vIntermediateB_buffer(vIntermediateB_buffer'high-1 downto 0);
      vIntermediateO_buffer(vIntermediateO_buffer'high downto 1) := vIntermediateO_buffer(vIntermediateO_buffer'high-1 downto 0);
      vIntermediateE_buffer(vIntermediateE_buffer'high downto 1) := vIntermediateE_buffer(vIntermediateE_buffer'high-1 downto 0);
      vSortRankB_buffer(0)                                       := oSortRanksB;
      vSortRankO_buffer(0)                                       := oSortRanksO;
      vSortRankE_buffer(0)                                       := oSortRanksE;
      vSortRankB_buffer(vSortRankB_buffer'high downto 1)         := vSortRankB_buffer(vSortRankB_buffer'high-1 downto 0);
      vSortRankO_buffer(vSortRankO_buffer'high downto 1)         := vSortRankO_buffer(vSortRankO_buffer'high-1 downto 0);
      vSortRankE_buffer(vSortRankE_buffer'high downto 1)         := vSortRankE_buffer(vSortRankE_buffer'high-1 downto 0);
      vMuons                                                     := oMuons;

      ValidateSorterOutput(vMuons, vIntermediateB_buffer(vIntermediateB_buffer'high), vIntermediateO_buffer(vIntermediateO_buffer'high), vIntermediateE_buffer(vIntermediateE_buffer'high), vSortRankB_buffer(vSortRankB_buffer'high), vSortRankO_buffer(vSortRankO_buffer'high), vSortRankE_buffer(vSortRankE_buffer'high), event_buffer(SORTER_LATENCY-1), FO, tmpError);
      cntError := cntError+tmpError;

      if verbose or (tmpError > 0) then
        if tmpError > 0 then
          write(LO, string'("@@@ ERROR in event "));
        else
          write(LO, string'("@@@ Dumping event "));
        end if;
        write(LO, event_buffer(SORTER_LATENCY-1).iEvent);
        writeline (FO, LO);

        DumpMuEvent(event_buffer(SORTER_LATENCY-1), FO);
        DumpMuons(vIntermediateB_buffer(vIntermediateB_buffer'high), vSortRankB_buffer(vSortRankB_buffer'high), FO, int_id);
        DumpMuons(vIntermediateO_buffer(vIntermediateO_buffer'high), vSortRankO_buffer(vSortRankO_buffer'high), FO, int_id);
        DumpMuons(vIntermediateE_buffer(vIntermediateE_buffer'high), vSortRankE_buffer(vSortRankE_buffer'high), FO, int_id);
        DumpMuons(vMuons, vDummySortRanks, FO, fin_id);
        write(LO, string'(""));
        writeline (FO, LO);
      end if;

      wait for 2*half_period_40;
      iEvent := iEvent+1;
    end loop;
    write(LO, string'("!!!!! Number of events with errors: "));
    write(LO, cntError);
    writeline(FO, LO);
    finish(0);
  end process tb;
  --  End Test Bench

end;
