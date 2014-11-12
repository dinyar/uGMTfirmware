library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
use WORK.GMTTypes.all;
use STD.TEXTIO.all;
use ieee.std_logic_textio.all;
use work.mp7_data_types.all;
use work.ugmt_constants.all;

package tb_helpers is

  constant NOUTCHAN : integer := NUM_OUT_CHANS+NUM_INTERM_MU_OUT_CHANS+NUM_INTERM_SRT_OUT_CHANS+NUM_INTERM_ENERGY_OUT_CHANS+NUM_EXTRAP_COORDS_OUT_CHANS;
  constant NCHAN    : integer := NUM_OUT_CHANS+NUM_INTERM_MU_OUT_CHANS;
  type     TOutTransceiverBuffer is array (2*NUM_MUONS_IN-1 downto 0) of ldata(NCHAN-1 downto 0);

  type TGMTOutEvent is record
    iEvent           : integer;
    muons            : TGMTMu_vector(7 downto 0);
    iso              : TIsoBits_vector(7 downto 0);
    intMuons_brl     : TGMTMu_vector(7 downto 0);
    intMuons_ovl     : TGMTMu_vector(7 downto 0);
    intMuons_fwd     : TGMTMu_vector(7 downto 0);
    intSortRanks_brl : TSortRank10_vector(7 downto 0);
    intSortRanks_ovl : TSortRank10_vector(7 downto 0);
    intSortRanks_fwd : TSortRank10_vector(7 downto 0);
    finalEnergies    : TCaloArea_vector(7 downto 0);
    extrCoords_brl   : TSpatialCoordinate_vector(35 downto 0);
    extrCoords_ovl   : TSpatialCoordinate_vector(35 downto 0);
    extrCoords_fwd   : TSpatialCoordinate_vector(35 downto 0);
    expectedOutput   : TOutTransceiverBuffer;
  end record;
  type TGMTOutEvent_vec is array (integer range <>) of TGMTOutEvent;

  type TGMTMuEvent is record
    iEvent           : integer;
    muons_brl        : TGMTMu_vector(35 downto 0);
    muons_ovl        : TGMTMu_vector(35 downto 0);
    muons_fwd        : TGMTMu_vector(35 downto 0);
    tracks_brl       : TGMTMuTracks_vector(11 downto 0);
    tracks_ovl       : TGMTMuTracks_vector(11 downto 0);
    tracks_fwd       : TGMTMuTracks_vector(11 downto 0);
    sortRanks_brl    : TSortRank10_vector(35 downto 0);
    sortRanks_ovl    : TSortRank10_vector(35 downto 0);
    sortRanks_fwd    : TSortRank10_vector(35 downto 0);
    empty_brl        : std_logic_vector(35 downto 0);
    empty_ovl        : std_logic_vector(35 downto 0);
    empty_fwd        : std_logic_vector(35 downto 0);
    idxBits_brl      : TIndexBits_vector(35 downto 0);
    idxBits_ovl      : TIndexBits_vector(35 downto 0);
    idxBits_fwd      : TIndexBits_vector(35 downto 0);
    expectedMuons    : TGMTMu_vector(7 downto 0);
    expectedIntMuB   : TGMTMu_vector(7 downto 0);
    expectedIntMuO   : TGMTMu_vector(7 downto 0);
    expectedIntMuF   : TGMTMu_vector(7 downto 0);
    expectedSrtRnksB : TSortRank10_vector(7 downto 0);
    expectedSrtRnksO : TSortRank10_vector(7 downto 0);
    expectedSrtRnksF : TSortRank10_vector(7 downto 0);
  end record;
  type TGMTMuEvent_vec is array (integer range <>) of TGMTMuEvent;

  type TGMTCaloEvent is record
    energies : TCaloRegionEtaSlice_vector(27 downto 0);
  end record;
  type TGMTCaloEvent_vector is array (integer range <>) of TGMTCaloEvent;

  type TGMTEvent is record
    muons    : TGMTMuEvent;
    energies : TGMTCaloEvent;
  end record;
  type TGMTEvent_vector is array (integer range <>) of TGMTEvent;

  procedure ReadOutEvent (
    file F          :     text;
    variable iEvent : in  integer;
    variable event  : out TGMTOutEvent);

  procedure ReadMuEvent (
    file F          :     text;
    variable iEvent : in  integer;
    variable event  : out TGMTMuEvent);

  --procedure ReadCaloEvent (
  --  file F         :     text;
  --  variable event : out TGMTCaloEvent);

  --procedure ReadEvent (
  --  file F         :     text;
  --  variable event : out TGMTEvent);

  procedure DumpOutEvent (
    variable event : in TGMTOutEvent);

  procedure DumpOutput (
    variable tbuf : in TOutTransceiverBuffer);

  procedure DumpMuEvent (
    variable event : in TGMTMuEvent);

  --procedure DumpCaloEvent (
  --  variable event : in TGMTCaloEvent);

  --procedure DumpEvent (
  --  variable event : in TGMTEvent);

  procedure DumpTracks (
    variable iTracks : in TGMTMuTracks_vector;
    variable id      : in string(1 to 4));

  procedure DumpMuons (
    variable iMuons     : in TGMTMu_vector;
    variable iSortRanks : in TSortRank10_vector;
    variable id         : in string(1 to 3));

  procedure ValidateSerializerOutput (
    variable iOutput : in  TOutTransceiverBuffer;
    variable event   : in  TGMTOutEvent;
    variable errors  : out integer);

  procedure ValidateSorterOutput (
    variable iFinalMus : in  TGMTMu_vector(7 downto 0);
    variable iIntMusB  : in  TGMTMu_vector(7 downto 0);
    variable iIntMusO  : in  TGMTMu_vector(7 downto 0);
    variable iIntMusF  : in  TGMTMu_vector(7 downto 0);
    variable iSrtRnksB : in  TSortRank10_vector(7 downto 0);
    variable iSrtRnksO : in  TSortRank10_vector(7 downto 0);
    variable iSrtRnksF : in  TSortRank10_vector(7 downto 0);
    variable iEvent    : in  TGMTMuEvent;
    variable error     : out integer);
end;

package body tb_helpers is

  procedure ReadInputMuon (
    variable L        : inout line;
    variable muon     : out   TGMTMu;
    variable sortRank : out   TSortRank10;
    variable emptyBit : out   std_logic
    ) is
    variable cable_no    : integer;
    variable sign, vsign : bit;
    variable eta         : integer;
    variable qual        : integer;
    variable pt          : integer;
    variable phi         : integer;
    variable rank        : integer;
    variable empty       : bit;

    variable dummy : string(1 to 4);
  begin  -- ReadInputMuon
    read(L, dummy);

    read(L, cable_no);
    muon.valid  := '1';
    read(L, pt);
    muon.pt     := to_unsigned(pt, 9);
    read(L, phi);
    muon.phi    := to_unsigned(phi, 10);
    read(L, eta);
    muon.eta    := to_signed(eta, 9);
    read(L, sign);
    read(L, vsign);
    muon.sysign := to_stdulogic(vsign) & to_stdulogic(sign);
    read(L, qual);
    muon.qual   := to_unsigned(qual, 4);
    read(L, rank);
    sortRank    := std_logic_vector(to_unsigned(rank, 10));
    read(L, empty);
    emptyBit    := to_stdulogic(empty);

  end ReadInputMuon;

  procedure ReadTrack (
    variable L     : inout line;
    variable track : out   TGMTMuTracks3) is
    variable LO                  : line;
    variable eta1, eta2, eta3    : integer;
    variable phi1, phi2, phi3    : integer;
    variable qual1, qual2, qual3 : integer;

    variable dummy : string(1 to 5);
  begin  -- ReadTrack
    read(L, dummy);

    read(L, eta1);
    track(0).eta  := to_signed(eta1, 9);
    read(L, phi1);
    track(0).phi  := to_unsigned(phi1, 10);
    read(L, qual1);
    track(0).qual := to_unsigned(qual1, 4);

    read(L, eta2);
    track(1).eta  := to_signed(eta2, 9);
    read(L, phi2);
    track(1).phi  := to_unsigned(phi2, 10);
    read(L, qual2);
    track(1).qual := to_unsigned(qual2, 4);

    read(L, eta3);
    track(2).eta  := to_signed(eta3, 9);
    read(L, phi3);
    track(2).phi  := to_unsigned(phi3, 10);
    read(L, qual3);
    track(2).qual := to_unsigned(qual3, 4);

  end ReadTrack;

  procedure ReadInputFrame (
    variable L       : inout line;
    variable oOutput : out   ldata(NCHAN-1 downto 0)) is
    variable word  : std_logic_vector(31 downto 0);
    variable valid : bit;
    variable dummy : string(1 to 4);
  begin  -- ReadInputFrame
    read(L, dummy);

    for iWord in 0 to NCHAN-1 loop
      read(L, valid);
      oOutput(iWord).valid := to_stdulogic(valid);
      hread(L, word);
      oOutput(iWord).data  := word;
    end loop;  -- iWord
  end ReadInputFrame;

  procedure ReadOutEvent (
    file F          :     text;
    variable iEvent : in  integer;
    variable event  : out TGMTOutEvent) is
    variable L             : line;
    variable dummySortRank : TSortRank10;
    variable dummyEmpty    : std_logic;
    variable muNo          : integer := 0;
    variable muFinNo       : integer := 0;
    variable muIntBNo      : integer := 0;
    variable muIntONo      : integer := 0;
    variable muIntFNo      : integer := 0;
    variable frameNo       : integer := 0;
  begin  -- ReadOutEvent
    event.iEvent := iEvent;

    while muFinNo < 8 or muIntBNo < 8 or muIntONo < 8 or muIntFNo < 8 or frameNo < 6 loop
      readline(F, L);

      if L.all'length = 0 then
        next;
      elsif(L.all(1 to 1) = "#") then
        next;
      elsif L.all(1 to 3) = "EVT" then
        -- TODO: Parse this maybe?
        next;
      elsif L.all(1 to 3) = "OUT" then
        -- TODO: Read Iso bits.
        ReadInputMuon(L, event.muons(muFinNo), dummySortRank, dummyEmpty);
        muFinNo := muFinNo+1;
        muNo    := muNo+1;
      elsif L.all(1 to 4) = "BIMD" then
        ReadInputMuon(L, event.intMuons_brl(muIntBNo), event.intSortRanks_brl(muIntBNo), dummyEmpty);
        muIntBNo := muIntBNo+1;
        muNo     := muNo+1;
      elsif L.all(1 to 4) = "OIMD" then
        ReadInputMuon(L, event.intMuons_ovl(muIntONo), event.intSortRanks_ovl(muIntONo), dummyEmpty);
        muIntONo := muIntONo+1;
        muNo     := muNo+1;
      elsif L.all(1 to 4) = "FIMD" then
        ReadInputMuon(L, event.intMuons_fwd(muIntFNo), event.intSortRanks_fwd(muIntFNo), dummyEmpty);
        muIntFNo := muIntFNo+1;
        muNo     := muNo+1;
      elsif L.all(1 to 3) = "FRM" then
        ReadInputFrame(L, event.expectedOutput(frameNo));
        frameNo := frameNo+1;
      end if;
    end loop;
  end ReadOutEvent;

  -- TODO: Add procedure for reading calo inputs.
  procedure ReadMuEvent (
    file F          :     text;
    variable iEvent : in  integer;
    variable event  : out TGMTMuEvent) is
    variable L, L1         : line;
    variable muNo          : integer := 0;
    variable muBrlNo       : integer := 0;
    variable muOvlNo       : integer := 0;
    variable muFwdNo       : integer := 0;
    variable wedgeNo       : integer := 0;
    variable wedgeBrlNo    : integer := 0;
    variable wedgeOvlNo    : integer := 0;
    variable wedgeFwdNo    : integer := 0;
    variable muons         : TGMTMu_vector(107 downto 0);
    variable sortRanks     : TSortRank10_vector(107 downto 0);
    variable emptyBits     : std_logic_vector(107 downto 0);
    variable idxBits       : TIndexBits_vector(107 downto 0);
    variable dummySrtRnk   : TSortRank10;
    variable dummyEmptyBit : std_logic;
    variable finMuNo       : integer := 0;
    variable intMuBNo      : integer := 0;
    variable intMuONo      : integer := 0;
    variable intMuFNo      : integer := 0;
  begin  -- ReadMuEvent

    event.iEvent := iEvent;

    while (muNo < 108) or (wedgeNo < 36) or (finMuNo < 8) or (intMuBNo < 8) or (intMuONo < 8) or (intMuFNo < 8) loop
      readline(F, L);

      if L.all'length = 0 then
        next;
      elsif(L.all(1 to 1) = "#") then
        next;
      elsif L.all(1 to 3) = "EVT" then
                                        -- TODO: Parse this maybe?
        next;
      elsif L.all(1 to 3) = "BAR" then
        ReadInputMuon(L, event.muons_brl(muBrlNo), event.sortRanks_brl(muBrlNo), event.empty_brl(muBrlNo));
        event.idxBits_brl(muBrlNo) := to_unsigned(muNo, 7);
        muBrlNo                    := muBrlNo+1;
        muNo                       := muNo+1;
      elsif L.all(1 to 3) = "OVL" then
        ReadInputMuon(L, event.muons_ovl(muOvlNo), event.sortRanks_ovl(muOvlNo), event.empty_ovl(muOvlNo));
        event.idxBits_ovl(muOvlNo) := to_unsigned(muNo, 7);
        muOvlNo                    := muOvlNo+1;
        muNo                       := muNo+1;
      elsif L.all(1 to 3) = "FWD" then
        ReadInputMuon(L, event.muons_fwd(muFwdNo), event.sortRanks_fwd(muFwdNo), event.empty_fwd(muFwdNo));
        event.idxBits_fwd(muFwdNo) := to_unsigned(muNo, 7);
        muFwdNo                    := muFwdNo+1;
        muNo                       := muNo+1;
      elsif L.all(1 to 4) = "BTRK" then
        ReadTrack(L, event.tracks_brl(wedgeBrlNo));
        wedgeBrlNo := wedgeBrlNo+1;
        wedgeNo    := wedgeNo+1;
      elsif L.all(1 to 4) = "OTRK" then
        ReadTrack(L, event.tracks_ovl(wedgeOvlNo));
        wedgeOvlNo := wedgeOvlNo+1;
        wedgeNo    := wedgeNo+1;
      elsif L.all(1 to 4) = "FTRK" then
        ReadTrack(L, event.tracks_fwd(wedgeFwdNo));
        wedgeFwdNo := wedgeFwdNo+1;
        wedgeNo    := wedgeNo+1;
      elsif L.all(1 to 3) = "OUT" then
        ReadInputMuon(L, event.expectedMuons(finMuNo), dummySrtRnk, dummyEmptyBit);
        finMuNo := finMuNo+1;
      elsif L.all(1 to 4) = "BIMD" then
        ReadInputMuon(L, event.expectedIntMuB(intMuBNo), event.expectedSrtRnksB(intMuBNo), dummyEmptyBit);
        intMuBNo := intMuBNo+1;
      elsif L.all(1 to 4) = "OIMD" then
        ReadInputMuon(L, event.expectedIntMuO(intMuONo), event.expectedSrtRnksO(intMuONo), dummyEmptyBit);
        intMuONo := intMuONo+1;
      elsif L.all(1 to 4) = "FIMD" then
        ReadInputMuon(L, event.expectedIntMuF(intMuFNo), event.expectedSrtRnksF(intMuFNo), dummyEmptyBit);
        intMuFNo := intMuFNo+1;
      end if;
    end loop;
  end ReadMuEvent;

  procedure DumpOutEvent (
    variable event : in TGMTOutEvent) is
    variable L1              : line;
    variable fin_id          : string(1 to 3)                 := "OUT";
    variable brl_id          : string(1 to 3)                 := "INB";
    variable ovl_id          : string(1 to 3)                 := "INO";
    variable fwd_id          : string(1 to 3)                 := "INF";
    variable vDummySortRanks : TSortRank10_vector(7 downto 0) := (others => "0000000000");

  begin  -- DumpOutEvent
    if event.iEvent /= -1 then
      write(L1, string'("++++++++++++++++++++ Dump of event "));
      write(L1, event.iEvent);
      write(L1, string'(": ++++++++++++++++++++"));
      writeline(OUTPUT, L1);

      write(L1, string'("### Dumping final muons: "));
      writeline(OUTPUT, L1);
      DumpMuons(event.muons, vDummySortRanks, fin_id);
      write(L1, string'("### Dumping intermediate muons: "));
      writeline(OUTPUT, L1);
      DumpMuons(event.intMuons_brl, event.intSortRanks_brl, brl_id);
      DumpMuons(event.intMuons_ovl, event.intSortRanks_ovl, ovl_id);
      DumpMuons(event.intMuons_fwd, event.intSortRanks_fwd, fwd_id);
      write(L1, string'("### Dumping expected output: "));
      writeline(OUTPUT, L1);
      DumpOutput(event.expectedOutput);
      -- TODO: Missing final energies, extrapolated coordinates and iso bits.
    end if;
  end DumpOutEvent;

  procedure DumpOutput (
    variable tbuf : in TOutTransceiverBuffer) is
    variable L : line;
  begin  -- DumpOutput
    for iFrame in tbuf'range loop
      write(L, string'("FRM"));
      write(L, iFrame);
      write(L, string'("    "));
      for iChan in tbuf(iFrame)'range loop
        hwrite(L, tbuf(iFrame)(iChan).data);
        write(L, string'("    "));
      end loop;  -- iChan
      writeline(OUTPUT, L);
    end loop;  -- iFrame
  end DumpOutput;
  
  procedure DumpMuEvent (
    variable event : in TGMTMuEvent) is
    variable L1        : line;
    variable brl_id    : string(1 to 3) := "BRL";
    variable ovl_id    : string(1 to 3) := "OVL";
    variable fwd_id    : string(1 to 3) := "FWD";
    variable brlTrk_id : string(1 to 4) := "BTRK";
    variable ovlTrk_id : string(1 to 4) := "OTRK";
    variable fwdTrk_id : string(1 to 4) := "FTRK";
  begin  -- DumpMuEvent
    if event.iEvent /= -1 then
      write(L1, string'("++++++++++++++++++++ Dump of event "));
      write(L1, event.iEvent);
      write(L1, string'(": ++++++++++++++++++++"));
      writeline(OUTPUT, L1);
      DumpMuons(event.muons_brl, event.sortRanks_brl, brl_id);
      DumpMuons(event.muons_ovl, event.sortRanks_ovl, ovl_id);
      DumpMuons(event.muons_fwd, event.sortRanks_fwd, fwd_id);

      DumpTracks(event.tracks_brl, brlTrk_id);
      DumpTracks(event.tracks_ovl, ovlTrk_id);
      DumpTracks(event.tracks_fwd, fwdTrk_id);

    end if;
  end DumpMuEvent;

  procedure DumpTracks (
    variable iTracks : in TGMTMuTracks_vector;
    variable id      : in string(1 to 4)) is
    variable L1            : line;
    variable display_track : boolean := false;
  begin  -- DumpTracks
    for iTrack in iTracks'range loop
      display_track := false;
      for i in 2 downto 0 loop
        if iTracks(iTrack)(i).phi /= (9 downto 0 => '0') and
          iTracks(iTrack)(i).eta /= (8 downto 0  => '0') and
          iTracks(iTrack)(i).qual /= (3 downto 0 => '0') then
          display_track := true;
        end if;
      end loop;  -- i

      if display_track = true then
        write(L1, id);
        write(L1, string'(" #"));
        write(L1, iTrack);
        write(L1, string'(" :"));
        for i in 2 downto 0 loop
          write(L1, string'(" "));
          write(L1, to_integer(iTracks(iTrack)(i).phi));
          write(L1, string'(" "));
          write(L1, to_integer(iTracks(iTrack)(i).eta));
          write(L1, string'(" "));
          write(L1, to_integer(iTracks(iTrack)(i).qual));
        end loop;  -- i
        writeline(OUTPUT, L1);
      end if;
    end loop;  -- iTrack
    write(L1, string'(""));
    writeline(OUTPUT, L1);
  end DumpTracks;

  procedure DumpMuon (
    noMu               : in integer;
    variable iMu       : in TGMTMu;
    variable iSortRank : in TSortRank10;
    variable id        : in string(1 to 3)) is
    variable L1 : line;
  begin  -- DumpMuon
    if iMu.pt = (8 downto 0 => '0') and iMu.phi = (9 downto 0 => '0') and iMu.eta = (8 downto 0 => '0') and iMu.sysign = "00" and iMu.qual = (3 downto 0 => '0') then
      return;
    end if;
    write(L1, id);
    write(L1, string'(" #"));
    write(L1, noMu);
    write(L1, string'(": "));
    write(L1, to_integer(iMu.pt));
    write(L1, string'(" "));
    write(L1, to_integer(iMu.phi));
    write(L1, string'(" "));
    write(L1, to_integer(iMu.eta));
    write(L1, string'(" "));
    write(L1, to_bit(iMu.sysign(0)));
    write(L1, string'(" "));
    write(L1, to_bit(iMu.sysign(1)));
    write(L1, string'(" "));
    write(L1, to_integer(iMu.qual));
    -- For final muons no sort rank information is available and is thus
    -- faked by the testbench. We therefore won't display it.
    if id /= string'("OUT") then
      write(L1, string'(" "));
      write(L1, to_integer(unsigned(iSortRank)));
    end if;
    writeline(OUTPUT, L1);
  end DumpMuon;

  procedure DumpMuons (
    variable iMuons     : in TGMTMu_vector;
    variable iSortRanks : in TSortRank10_vector;
    variable id         : in string(1 to 3)) is
    variable L1 : line;
  begin  -- DumpMuons
    for iMu in iMuons'range loop
      DumpMuon(iMu, iMuons(iMu), iSortRanks(iMu), id);
    end loop;  -- iMu
    write(L1, string'(""));
    writeline(OUTPUT, L1);
  end DumpMuons;

  procedure CheckMuon (
    noMu                : in  integer;
    variable iMu        : in  TGMTMu;
    variable iEmuMu     : in  TGMTMu;
    variable iSrtRnk    : in  TSortRank10;
    variable iEmuSrtRnk : in  TSortRank10;
    variable id         : in  string(1 to 3);
    variable error      : out integer) is
    variable LO    : line;
    variable idEmu : string(1 to 3) := "EMU";
  begin  -- CheckMuon
    error := 0;
    if iMu.phi /= iEmuMu.phi or iMu.eta /= iEmuMu.eta or iMu.pt /= iEmuMu.pt or iMu.sysign /= iEmuMu.sysign or iMu.qual /= iEmuMu.qual then
      error := 1;

      write(LO, string'("!!!!!! Error in "));
      write(LO, id);
      write(LO, string'(" muon #"));
      write(LO, noMu);
      writeline(OUTPUT, LO);
      write(LO, string'("!!! Comparison: "));
      writeline(OUTPUT, LO);
      DumpMuon(noMu, iMu, iSrtRnk, id);
      DumpMuon(noMu, iEmuMu, iEmuSrtRnk, idEmu);
      write(LO, string'(""));
      writeline(OUTPUT, LO);
    end if;
  end CheckMuon;
  
  procedure CheckMuons (
    variable iMus        : in  TGMTMu_vector;
    variable iEmuMus     : in  TGMTMu_vector;
    variable iSrtRnks    : in  TSortRank10_vector;
    variable iEmuSrtRnks : in  TSortRank10_vector;
    variable id          : in  string(1 to 3);
    variable errors      : out integer) is
    variable LO       : line;
    variable vErrors  : integer := 0;
    variable tmpError : integer;
  begin  -- CheckMuons
    errors := 0;
    for i in iMus'range loop
      tmpError := 0;
      CheckMuon(i, iMus(i), iEmuMus(i), iSrtRnks(i), iEmuSrtRnks(i), id, tmpError);
      vErrors  := vErrors+tmpError;
    end loop;  -- i
    errors := vErrors;
  end CheckMuons;

  
  procedure CheckMuons (
    variable iMus    : in  TGMTMu_vector;
    variable iEmuMus : in  TGMTMu_vector;
    variable id      : in  string(1 to 3);
    variable errors  : out integer) is
    variable LO          : line;
    variable vErrors     : integer     := 0;
    variable tmpError    : integer;
    variable dummySrtRnk : TSortRank10 := (others => '0');
  begin  -- CheckMuons
    errors := 0;
    for i in iMus'range loop
      tmpError := 0;
      CheckMuon(i, iMus(i), iEmuMus(i), dummySrtRnk, dummySrtRnk, id, tmpError);
      vErrors  := vErrors+tmpError;
    end loop;  -- i
    errors := vErrors;
  end CheckMuons;

  procedure CheckSortRanks (
    variable iSrtRnks    : in  TSortRank10_vector;
    variable iEmuSrtRnks : in  TSortRank10_vector;
    variable id          : in  string(1 to 3);
    variable errors      : out integer) is
    variable LO      : line;
    variable vErrors : integer := 0;
  begin  -- CheckSortRanks
    for i in iSrtRnks'range loop
      if iSrtRnks(i) /= iEmuSrtRnks(i) then
        vErrors := vErrors+1;

        write(LO, string'("!!!!!! Error in "));
        write(LO, id);
        write(LO, string'(" sort rank #"));
        write(LO, i);
        writeline(OUTPUT, LO);
        write(LO, string'("!!! Simulation output: "));
        write(LO, to_integer(unsigned(iSrtRnks(i))));
        writeline(OUTPUT, LO);
        write(LO, string'("!!!   Expected output: "));
        write(LO, to_integer(unsigned(iEmuSrtRnks(i))));
        writeline(OUTPUT, LO);
        write(LO, string'(""));
        writeline(OUTPUT, LO);
      end if;
    end loop;  --i
    errors := vErrors;
  end CheckSortRanks;

  procedure ValidateSerializerOutput (
    variable iOutput : in  TOutTransceiverBuffer;
    variable event   : in  TGMTOutEvent;
    variable errors  : out integer) is
    variable LO       : line;
    variable tmpError : integer := 0;
    variable vErrors  : integer := 0;
  begin
    if (event.iEvent >= 0) then
      write(LO, string'("@@@ Validating event "));
      write(LO, event.iEvent);
      write(LO, string'(" @@@"));
      writeline(OUTPUT, LO);
      write(LO, string'(""));
      writeline(OUTPUT, LO);

      for iFrame in iOutput'range loop
        for iChan in iOutput(iFrame)'range loop
          if iOutput(iFrame)(iChan) /= event.expectedOutput(iFrame)(iChan) then
            vErrors := vErrors+1;

            write(LO, string'("!!!!!! Error in frame #"));
            write(LO, iFrame);
            write(LO, string'(", channel #"));
            write(LO, iChan);
            writeline(OUTPUT, LO);
            write(LO, string'("!!! Simulation output: "));
            hwrite(LO, iOutput(iFrame)(iChan).data);
            writeline(OUTPUT, LO);
            write(LO, string'("!!!   Expected output: "));
            hwrite(LO, event.expectedOutput(iFrame)(iChan).data);
            writeline(OUTPUT, LO);
            write(LO, string'(""));
            writeline(OUTPUT, LO);
          end if;
        end loop;  -- iChan
      end loop;  -- frame

      if vErrors > 0 then
        errors := 1;
      else
        errors := 0;
      end if;
    else
      errors := 0;
    end if;
  end ValidateSerializerOutput;

  procedure ValidateSorterOutput (
    variable iFinalMus : in  TGMTMu_vector(7 downto 0);
    variable iIntMusB  : in  TGMTMu_vector(7 downto 0);
    variable iIntMusO  : in  TGMTMu_vector(7 downto 0);
    variable iIntMusF  : in  TGMTMu_vector(7 downto 0);
    variable iSrtRnksB : in  TSortRank10_vector(7 downto 0);
    variable iSrtRnksO : in  TSortRank10_vector(7 downto 0);
    variable iSrtRnksF : in  TSortRank10_vector(7 downto 0);
    variable iEvent    : in  TGMTMuEvent;
    variable error     : out integer) is
    variable LO       : line;
    variable vError   : integer        := 0;
    variable tmpError : integer        := 0;
    variable idFin    : string(1 to 3) := "FIN";
    variable idIntB   : string(1 to 3) := "IMB";
    variable idIntO   : string(1 to 3) := "IMO";
    variable idIntF   : string(1 to 3) := "IMF";
  begin
    if (iEvent.iEvent >= 0) then
      write(LO, string'("@@@ Validating event "));
      write(LO, iEvent.iEvent);
      write(LO, string'(" @@@"));
      writeline(OUTPUT, LO);
      write(LO, string'(""));
      writeline(OUTPUT, LO);

      tmpError := 0;
      CheckMuons(iFinalMus, iEvent.expectedMuons, idFin, tmpError);
      vError   := tmpError;
      tmpError := 0;
      CheckMuons(iIntMusB, iEvent.expectedIntMuB, iSrtRnksB, iEvent.expectedSrtRnksB, idIntB, tmpError);
      vError   := vError + tmpError;
      tmpError := 0;
      CheckMuons(iIntMusO, iEvent.expectedIntMuO, iSrtRnksO, iEvent.expectedSrtRnksO, idIntO, tmpError);
      vError   := vError + tmpError;
      tmpError := 0;
      CheckMuons(iIntMusF, iEvent.expectedIntMuF, iSrtRnksF, iEvent.expectedSrtRnksF, idIntF, tmpError);
      vError   := vError + tmpError;

      tmpError := 0;
      CheckSortRanks(iSrtRnksB, iEvent.expectedSrtRnksB, idIntB, tmpError);
      vError   := vError + tmpError;
      tmpError := 0;
      CheckSortRanks(iSrtRnksO, iEvent.expectedSrtRnksO, idIntO, tmpError);
      vError   := vError + tmpError;
      tmpError := 0;
      CheckSortRanks(iSrtRnksF, iEvent.expectedSrtRnksF, idIntF, tmpError);
      vError   := vError + tmpError;

      if vError > 0 then
        error := 1;
      else
        error := 0;
      end if;
    else
      error := 0;
    end if;
  end ValidateSorterOutput;
end tb_helpers;
