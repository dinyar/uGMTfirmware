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
  signal   clk240          : std_logic := '0';
  signal   clk40           : std_logic := '0';
  signal   rst             : std_logic := '0';

  signal iMuonsB             : TGMTMu_vector(35 downto 0);
  signal iMuonsO             : TGMTMu_vector(35 downto 0);
  signal iMuonsF             : TGMTMu_vector(35 downto 0);
  signal iMuonsRPCb          : TGMTMuRPC_vector(3 downto 0);
  signal iMuonsRPCf          : TGMTMuRPC_vector(3 downto 0);
  signal iTracksB            : TGMTMuTracks_vector(11 downto 0);
  signal iTracksO            : TGMTMuTracks_vector(11 downto 0);
  signal iTracksF            : TGMTMuTracks_vector(11 downto 0);
  signal iSortRanksB         : TSortRank10_vector(35 downto 0);
  signal iSortRanksO         : TSortRank10_vector(35 downto 0);
  signal iSortRanksF         : TSortRank10_vector(35 downto 0);
  signal iEmptyB             : std_logic_vector(35 downto 0);
  signal iEmptyO             : std_logic_vector(35 downto 0);
  signal iEmptyF             : std_logic_vector(35 downto 0);
  signal iIdxBitsB           : TIndexBits_vector(35 downto 0);
  signal iIdxBitsO           : TIndexBits_vector(35 downto 0);
  signal iIdxBitsF           : TIndexBits_vector(35 downto 0);
  signal oIntermediateMuonsB : TGMTMu_vector(7 downto 0);
  signal oIntermediateMuonsO : TGMTMu_vector(7 downto 0);
  signal oIntermediateMuonsF : TGMTMu_vector(7 downto 0);
  signal oSortRanksB         : TSortRank10_vector(7 downto 0);
  signal oSortRanksO         : TSortRank10_vector(7 downto 0);
  signal oSortRanksF         : TSortRank10_vector(7 downto 0);
  signal oIdxBits            : TIndexBits_vector(7 downto 0);
  signal oMuPt               : TMuonPT_vector(7 downto 0);
  signal oMuons              : TGMTMu_vector(7 downto 0);
begin

  -- Component Instantiation
  uut : entity work.SortAndCancelUnit
    port map(
      iMuonsB                 => iMuonsB,
      iMuonsO                 => iMuonsO,
      iMuonsF                 => iMuonsF,
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
      iTracksF                => iTracksF,
      iSortRanksB             => iSortRanksB,
      iSortRanksO             => iSortRanksO,
      iSortRanksF             => iSortRanksF,
      iEmptyB                 => iEmptyB,
      iEmptyO                 => iEmptyO,
      iEmptyF                 => iEmptyF,
      iIdxBitsB               => iIdxBitsB,
      iIdxBitsO               => iIdxBitsO,
      iIdxBitsF               => iIdxBitsF,
      oIntermediateMuonsB     => oIntermediateMuonsB,
      oIntermediateMuonsO     => oIntermediateMuonsO,
      oIntermediateMuonsF     => oIntermediateMuonsF,
      oIntermediateSortRanksB => oSortRanksB,
      oIntermediateSortRanksO => oSortRanksO,
      oIntermediateSortRanksF => oSortRanksF,
      oIdxBits                => oIdxBits,
      oMuPt                   => oMuPt,
      oMuons                  => oMuons,
      clk                     => clk40,
      clk_ipb                 => clk240,
      sinit                   => rst,
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
    constant SORTER_LATENCY              : integer                        := 6;
    variable event_buffer                : TGMTMuEvent_vec(SORTER_LATENCY-1 downto 0);
    -- Delay is one more than in sorter unit due to the delay in the serializer.
    constant INTERMEDIATE_DELAY          : integer                        := 3;
    variable vIntermediateB_buffer       : TIntermediateMu_buf(INTERMEDIATE_DELAY-1 downto 0);
    variable vIntermediateO_buffer       : TIntermediateMu_buf(INTERMEDIATE_DELAY-1 downto 0);
    variable vIntermediateF_buffer       : TIntermediateMu_buf(INTERMEDIATE_DELAY-1 downto 0);
    variable vSortRankB_buffer           : TSortRank_buf(INTERMEDIATE_DELAY-1 downto 0);
    variable vSortRankO_buffer           : TSortRank_buf(INTERMEDIATE_DELAY-1 downto 0);
    variable vSortRankF_buffer           : TSortRank_buf(INTERMEDIATE_DELAY-1 downto 0);
    variable vMuons, vIntB, vIntO, vIntF : TGMTMu_vector(oMuons'range);
    variable vDummySortRanks             : TSortRank10_vector(7 downto 0) := (others => "0000000000");
    variable fin_id                      : string(1 to 3)                 := string'("FIN");
    variable int_id                      : string(1 to 3)                 := string'("INT");
    variable iEvent                      : integer                        := 0;
    variable tmpError                    : integer;
    variable cntError                    : integer                        := 0;
    variable remainingEvents             : integer                        := SORTER_LATENCY-2;
  begin

    -- Reset event buffer
    for iEvent in event_buffer'range loop
      event_buffer(iEvent).iEvent := -1;
      for i in event_buffer(iEvent).muons_brl'range loop
        event_buffer(iEvent).muons_brl(i).phi    := "0000000000";
        event_buffer(iEvent).muons_brl(i).eta    := "000000000";
        event_buffer(iEvent).muons_brl(i).pt     := "000000000";
        event_buffer(iEvent).muons_brl(i).qual   := "0000";
        event_buffer(iEvent).muons_brl(i).sysign := "00";
        event_buffer(iEvent).muons_ovl(i).phi    := "0000000000";
        event_buffer(iEvent).muons_ovl(i).eta    := "000000000";
        event_buffer(iEvent).muons_ovl(i).pt     := "000000000";
        event_buffer(iEvent).muons_ovl(i).qual   := "0000";
        event_buffer(iEvent).muons_ovl(i).sysign := "00";
        event_buffer(iEvent).muons_fwd(i).phi    := "0000000000";
        event_buffer(iEvent).muons_fwd(i).eta    := "000000000";
        event_buffer(iEvent).muons_fwd(i).pt     := "000000000";
        event_buffer(iEvent).muons_fwd(i).qual   := "0000";
        event_buffer(iEvent).muons_fwd(i).sysign := "00";
        event_buffer(iEvent).sortRanks_brl(i)    := "0000000000";
        event_buffer(iEvent).sortRanks_ovl(i)    := "0000000000";
        event_buffer(iEvent).sortRanks_fwd(i)    := "0000000000";
        event_buffer(iEvent).empty_brl(i)        := '1';
        event_buffer(iEvent).empty_ovl(i)        := '1';
        event_buffer(iEvent).empty_fwd(i)        := '1';
        event_buffer(iEvent).idxBits_brl(i)      := (others => '0');
        event_buffer(iEvent).idxBits_ovl(i)      := (others => '0');
        event_buffer(iEvent).idxBits_fwd(i)      := (others => '0');
      end loop;
      for i in event_buffer(iEvent).expectedMuons'range loop
        event_buffer(iEvent).expectedMuons(i).phi     := "0000000000";
        event_buffer(iEvent).expectedMuons(i).eta     := "000000000";
        event_buffer(iEvent).expectedMuons(i).pt      := "000000000";
        event_buffer(iEvent).expectedMuons(i).qual    := "0000";
        event_buffer(iEvent).expectedMuons(i).sysign  := "00";
        event_buffer(iEvent).expectedIntMuB(i).phi    := "0000000000";
        event_buffer(iEvent).expectedIntMuB(i).eta    := "000000000";
        event_buffer(iEvent).expectedIntMuB(i).pt     := "000000000";
        event_buffer(iEvent).expectedIntMuB(i).qual   := "0000";
        event_buffer(iEvent).expectedIntMuB(i).sysign := "00";
        event_buffer(iEvent).expectedIntMuO(i).phi    := "0000000000";
        event_buffer(iEvent).expectedIntMuO(i).eta    := "000000000";
        event_buffer(iEvent).expectedIntMuO(i).pt     := "000000000";
        event_buffer(iEvent).expectedIntMuO(i).qual   := "0000";
        event_buffer(iEvent).expectedIntMuO(i).sysign := "00";
        event_buffer(iEvent).expectedIntMuF(i).phi    := "0000000000";
        event_buffer(iEvent).expectedIntMuF(i).eta    := "000000000";
        event_buffer(iEvent).expectedIntMuF(i).pt     := "000000000";
        event_buffer(iEvent).expectedIntMuF(i).qual   := "0000";
        event_buffer(iEvent).expectedIntMuF(i).sysign := "00";
        event_buffer(iEvent).expectedSrtRnksB(i)      := (others => '0');
        event_buffer(iEvent).expectedSrtRnksO(i)      := (others => '0');
        event_buffer(iEvent).expectedSrtRnksF(i)      := (others => '0');
      end loop;  -- i
      for i in iTracksB'range loop
        for j in iTracksB(0)'range loop
          event_buffer(iEvent).tracks_brl(i)(j).eta  := "000000000";
          event_buffer(iEvent).tracks_brl(i)(j).phi  := "00000000";
          event_buffer(iEvent).tracks_brl(i)(j).qual := "0000";
          event_buffer(iEvent).tracks_ovl(i)(j).eta  := "000000000";
          event_buffer(iEvent).tracks_ovl(i)(j).phi  := "00000000";
          event_buffer(iEvent).tracks_ovl(i)(j).qual := "0000";
          event_buffer(iEvent).tracks_fwd(i)(j).eta  := "000000000";
          event_buffer(iEvent).tracks_fwd(i)(j).phi  := "00000000";
          event_buffer(iEvent).tracks_fwd(i)(j).qual := "0000";
        end loop;  -- j
      end loop;  -- i
    end loop;  -- event
    -- Reset intermediate buffer
    for iInt in vIntermediateB_buffer'range loop
      for iMu in vIntermediateB_buffer(iInt)'range loop
        vIntermediateB_buffer(iInt)(iMu).phi    := "0000000000";
        vIntermediateB_buffer(iInt)(iMu).eta    := "000000000";
        vIntermediateB_buffer(iInt)(iMu).pt     := "000000000";
        vIntermediateB_buffer(iInt)(iMu).qual   := "0000";
        vIntermediateB_buffer(iInt)(iMu).sysign := "00";
        vIntermediateO_buffer(iInt)(iMu).phi    := "0000000000";
        vIntermediateO_buffer(iInt)(iMu).eta    := "000000000";
        vIntermediateO_buffer(iInt)(iMu).pt     := "000000000";
        vIntermediateO_buffer(iInt)(iMu).qual   := "0000";
        vIntermediateO_buffer(iInt)(iMu).sysign := "00";
        vIntermediateF_buffer(iInt)(iMu).phi    := "0000000000";
        vIntermediateF_buffer(iInt)(iMu).eta    := "000000000";
        vIntermediateF_buffer(iInt)(iMu).pt     := "000000000";
        vIntermediateF_buffer(iInt)(iMu).qual   := "0000";
        vIntermediateF_buffer(iInt)(iMu).sysign := "00";
        vSortRankB_buffer(iInt)(iMu)            := "0000000000";
        vSortRankO_buffer(iInt)(iMu)            := "0000000000";
        vSortRankF_buffer(iInt)(iMu)            := "0000000000";
      end loop;  -- iMu
    end loop;  -- iInt

    wait for 20*half_period_40;  -- wait until global set/reset completes
    -- Add user defined stimulus here
    while remainingEvents > 0 loop
      tmpError := 99999999;
      if not endfile(F) then
        ReadMuEvent(F, iEvent, event);

        -- Filling uGMT
        iMuonsB     <= event.muons_brl;
        iMuonsO     <= event.muons_ovl;
        iMuonsF     <= event.muons_fwd;
        iTracksB    <= event.tracks_brl;
        iTracksO    <= event.tracks_ovl;
        iTracksF    <= event.tracks_fwd;
        iSortRanksB <= event.sortRanks_brl;
        iSortRanksO <= event.sortRanks_ovl;
        iSortRanksF <= event.sortRanks_fwd;
        iEmptyB     <= event.empty_brl;
        iEmptyO     <= event.empty_ovl;
        iEmptyF     <= event.empty_fwd;
        iIdxBitsB   <= event.idxBits_brl;
        iIdxBitsO   <= event.idxBits_ovl;
        iIdxBitsF   <= event.idxBits_fwd;

        event_buffer(0) := event;

      else
        remainingEvents := remainingEvents-1;
      end if;

      event_buffer(SORTER_LATENCY-1 downto 1)                    := event_buffer(SORTER_LATENCY-2 downto 0);
      vIntermediateB_buffer(0)                                   := oIntermediateMuonsB;
      vIntermediateO_buffer(0)                                   := oIntermediateMuonsO;
      vIntermediateF_buffer(0)                                   := oIntermediateMuonsF;
      vIntermediateB_buffer(vIntermediateB_buffer'high downto 1) := vIntermediateB_buffer(vIntermediateB_buffer'high-1 downto 0);
      vIntermediateO_buffer(vIntermediateO_buffer'high downto 1) := vIntermediateO_buffer(vIntermediateO_buffer'high-1 downto 0);
      vIntermediateF_buffer(vIntermediateF_buffer'high downto 1) := vIntermediateF_buffer(vIntermediateF_buffer'high-1 downto 0);
      vSortRankB_buffer(0)                                       := oSortRanksB;
      vSortRankO_buffer(0)                                       := oSortRanksO;
      vSortRankF_buffer(0)                                       := oSortRanksF;
      vSortRankB_buffer(vSortRankB_buffer'high downto 1)         := vSortRankB_buffer(vSortRankB_buffer'high-1 downto 0);
      vSortRankO_buffer(vSortRankO_buffer'high downto 1)         := vSortRankO_buffer(vSortRankO_buffer'high-1 downto 0);
      vSortRankF_buffer(vSortRankF_buffer'high downto 1)         := vSortRankF_buffer(vSortRankF_buffer'high-1 downto 0);
      vMuons                                                     := oMuons;

      ValidateSorterOutput(vMuons, vIntermediateB_buffer(vIntermediateB_buffer'high), vIntermediateO_buffer(vIntermediateO_buffer'high), vIntermediateF_buffer(vIntermediateF_buffer'high), vSortRankB_buffer(vSortRankB_buffer'high), vSortRankO_buffer(vSortRankO_buffer'high), vSortRankF_buffer(vSortRankF_buffer'high), event_buffer(SORTER_LATENCY-1), FO, tmpError);
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
        DumpMuons(vIntermediateF_buffer(vIntermediateF_buffer'high), vSortRankF_buffer(vSortRankF_buffer'high), FO, int_id);
        DumpMuons(vMuons, vDummySortRanks, FO, fin_id);
        write(LO, string'(""));
        writeline (FO, LO);
      end if;


      wait for 25 ns;
      iEvent := iEvent+1;
    end loop;
    write(LO, string'("!!!!! Number of events with errors: "));
    write(LO, cntError);
    writeline(FO, LO);
    finish(0);
  end process tb;
  --  End Test Bench

end;
