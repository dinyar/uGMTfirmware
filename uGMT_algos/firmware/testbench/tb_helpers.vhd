library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
use WORK.GMTTypes.all;
use STD.TEXTIO.all;
use ieee.std_logic_textio.all;
use work.mp7_data_types.all;
use work.ugmt_constants.all;

package tb_helpers is

  constant N_SERIALIZER_CHAN : integer := NUM_OUT_CHANS+NUM_INTERM_MU_OUT_CHANS+NUM_INTERM_SRT_OUT_CHANS+NUM_INTERM_ENERGY_OUT_CHANS+NUM_EXTRAP_COORDS_OUT_CHANS;
  constant NINCHAN           : integer := 72;
  constant NOUTCHAN          : integer := NUM_OUT_CHANS;
  type     TTransceiverBuffer is array (2*NUM_MUONS_IN-1 downto 0) of ldata(NINCHAN-1 downto 0);

  type TGMTEvent is record
    iEvent         : integer;
    iD             : TTransceiverBuffer;
    expectedOutput : TTransceiverBuffer;
  end record;
  type TGMTEvent_vec is array (integer range <>) of TGMTEvent;

  type TGMTInEvent is record
    iEvent                 : integer;
    iD                     : TTransceiverBuffer;
    expectedMuons          : TGMTMu_vector(107 downto 0);
    expectedTracks         : TGMTMuTracks_vector(35 downto 0);
    expectedEmpty          : std_logic_vector(107 downto 0);
    expectedSortRanks      : TSortRank10_vector(107 downto 0);
    expectedValid_muons    : std_logic;
    expectedEnergies       : TCaloRegionEtaSlice_vector(NUM_CALO_CHANS-1 downto 0);
    expectedValid_energies : std_logic;
  end record;
  type TGMTInEvent_vec is array (integer range <>) of TGMTInEvent;

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
    expectedOutput   : TTransceiverBuffer;
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
    expectedIsoBits  : TIsoBits_vector(7 downto 0);
    expectedIntMuB   : TGMTMu_vector(7 downto 0);
    expectedIntMuO   : TGMTMu_vector(7 downto 0);
    expectedIntMuF   : TGMTMu_vector(7 downto 0);
    expectedSrtRnksB : TSortRank10_vector(7 downto 0);
    expectedSrtRnksO : TSortRank10_vector(7 downto 0);
    expectedSrtRnksF : TSortRank10_vector(7 downto 0);
  end record;
  type TGMTMuEvent_vec is array (integer range <>) of TGMTMuEvent;

  type TGMTCaloEvent is record
    iEvent : integer;
    energies : TCaloRegionEtaSlice_vector(27 downto 0);
  end record;
  type TGMTCaloEvent_vec is array (integer range <>) of TGMTCaloEvent;

  procedure ReadInEvent (
    file F          :     text;
    variable iEvent : in  integer;
    variable event  : out TGMTInEvent);

  procedure ReadOutEvent (
    file F          :     text;
    variable iEvent : in  integer;
    variable event  : out TGMTOutEvent);

  procedure ReadMuEvent (
    file F          :     text;
    variable iEvent : in  integer;
    variable event  : out TGMTMuEvent);

  procedure ReadCaloEvent (
    file F         :     text;
    variable iEvent : in integer;
    variable event : out TGMTCaloEvent);

 procedure ReadEvent (
   file F          :     text;
   variable iEvent : in  integer;
   variable event  : out TGMTEvent);

  procedure DumpEvent (
    variable event : in TGMTEvent;
    variable FO    : in text);

  procedure DumpInEvent (
    variable event : in TGMTInEvent;
    variable FO    : in text);

  procedure DumpOutEvent (
    variable event : in TGMTOutEvent;
    variable FO    : in text);

  procedure DumpFrames (
    variable tbuf : in TTransceiverBuffer;
    variable FO   : in text);

  procedure DumpMuEvent (
    variable event : in TGMTMuEvent;
    variable FO    : in text);

  procedure DumpCaloEvent (
    variable event : in TGMTCaloEvent;
    variable FO    : in text);

  procedure DumpEnergyValues (
    variable iEnergies : in TCaloRegionEtaSlice_vector(27 downto 0);
    variable FO        : in text);

  procedure DumpIsoBits (
    variable iIsoBits : in TIsoBits_vector(7 downto 0);
    variable FO       : in text;
    variable id       : in string(1 to 3));

  procedure DumpFinalPt (
    variable iFinalPt : in TMuonPT_vector;
    variable FO       : in text);

  procedure DumpSelectedEnergies (
    variable iEnergies : in TCaloArea_vector;
    variable FO        : in text);

  procedure DumpMuIdxBits (
    variable iIdxBits : in TIndexBits_vector;
    variable FO       : in text);

  procedure DumpCaloIdxBits (
    variable iIdxBits : in TCaloIndexBit_vector;
    variable FO       : in text);

  procedure DumpExtrapolatedCoordiantes (
    variable iExtrapolatedCoords : in TSpatialCoordinate_vector;
    variable FO                  : in text;
    variable id                  : in string(1 to 3));

  procedure DumpEventMuons (
    variable event : in TGMTMuEvent;
    variable FO    : in text);

  procedure DumpTracks (
    variable iTracks : in TGMTMuTracks_vector;
    variable FO      : in text;
    variable id      : in string(1 to 4));

  procedure DumpMuons (
    variable iMuons     : in TGMTMu_vector;
    variable iSortRanks : in TSortRank10_vector;
    variable FO         : in text;
    variable id         : in string(1 to 3));

  procedure DumpMuons (
    variable iMuons     : in TGMTMu_vector;
    variable iSortRanks : in TSortRank10_vector;
    variable iEmptyBits : in std_logic_vector;
    variable FO         : in text;
    variable id         : in string(1 to 3));

  procedure DumpValidBits (
    variable iValid_muons    : in std_logic;
    variable iValid_energies : in std_logic;
    variable FO              : in text);

  procedure ValidateIsolationOutput (
    variable iIsoBits : in  TIsoBits_vector(7 downto 0);
    variable muEvent  : in  TGMTMuEvent;
    variable FO       : in  text;
    variable errors   : out integer);

  procedure ValidateGMTOutput (
    variable iOutput : in  TTransceiverBuffer;
    variable event   : in  TGMTEvent;
    variable FO      : in  text;
    variable errors  : out integer);

  procedure ValidateDeserializerOutput (
    variable iMuons          : in  TGMTMu_vector(107 downto 0);
    variable iTracks         : in  TGMTMuTracks_vector(35 downto 0);
    variable iSrtRnks        : in  TSortRank10_vector(107 downto 0);
    variable iEmpty          : in  std_logic_vector(107 downto 0);
    variable iValid_muons    : in  std_logic;
    variable iEnergies       : in  TCaloRegionEtaSlice_vector(NUM_CALO_CHANS-1 downto 0);
    variable iValid_energies : in  std_logic;
    variable event           : in  TGMTInEvent;
    variable FO              : in  text;
    variable errors          : out integer);

  procedure ValidateSerializerOutput (
    variable iOutput : in  TTransceiverBuffer;
    variable event   : in  TGMTOutEvent;
    variable FO      : in  text;
    variable errors  : out integer);

  procedure ValidateSorterOutput (
    variable iFinalMus : in  TGMTMu_vector(7 downto 0);
    variable iEvent    : in  TGMTMuEvent;
    variable FO        : in  text;
    variable error     : out integer);

  procedure ValidateSorterOutput (
    variable iFinalMus : in  TGMTMu_vector(7 downto 0);
    variable iIntMusB  : in  TGMTMu_vector(7 downto 0);
    variable iIntMusO  : in  TGMTMu_vector(7 downto 0);
    variable iIntMusF  : in  TGMTMu_vector(7 downto 0);
    variable iSrtRnksB : in  TSortRank10_vector(7 downto 0);
    variable iSrtRnksO : in  TSortRank10_vector(7 downto 0);
    variable iSrtRnksF : in  TSortRank10_vector(7 downto 0);
    variable iEvent    : in  TGMTMuEvent;
    variable FO        : in  text;
    variable error     : out integer);
end;

package body tb_helpers is

  procedure ReadInputMuon (
    variable L        : inout line;
    variable id       : in    string(1 to 3);
    variable muon     : out   TGMTMu;
    variable sortRank : out   TSortRank10;
    variable emptyBit : out   std_logic;
    variable isoBit   : out   TIsoBits
    ) is
    variable cable_no    : integer;
    variable sign, vsign : bit;
    variable eta         : integer;
    variable qual        : integer;
    variable pt          : integer;
    variable phi         : integer;
    variable rank        : integer;
    variable empty       : bit;
    variable iso         : integer;

    variable dummy : string(1 to 4);
  begin  -- ReadInputMuon
    read(L, dummy);

    read(L, cable_no);
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

    if id = string'("OUT") then
      read(L, iso);
      isoBit := std_logic_vector(to_unsigned(iso, 2));
    end if;
  end ReadInputMuon;

  procedure ReadInputMuon (
    variable L        : inout line;
    variable muon     : out   TGMTMu;
    variable sortRank : out   TSortRank10;
    variable emptyBit : out   std_logic
    ) is
    variable dummyIso : TIsoBits;
    variable dummyid  : string(1 to 3) := "XXX";
  begin  -- ReadInputMuon
    ReadInputMuon(L, dummyid, muon, sortRank, emptyBit, dummyIso);
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
    track(0).phi  := to_signed(phi1, 8);
    read(L, qual1);
    track(0).qual := to_unsigned(qual1, 4);

    read(L, eta2);
    track(1).eta  := to_signed(eta2, 9);
    read(L, phi2);
    track(1).phi  := to_signed(phi2, 8);
    read(L, qual2);
    track(1).qual := to_unsigned(qual2, 4);

    read(L, eta3);
    track(2).eta  := to_signed(eta3, 9);
    read(L, phi3);
    track(2).phi  := to_signed(phi3, 8);
    read(L, qual3);
    track(2).qual := to_unsigned(qual3, 4);

  end ReadTrack;

  procedure ReadInputFrame (
    variable L       : inout line;
    variable oOutput : out   ldata) is
    variable word  : std_logic_vector(31 downto 0);
    variable valid : bit;
    variable dummy : string(1 to 7);
  begin  -- ReadInputFrame
    read(L, dummy);

    for iWord in oOutput'low to oOutput'high loop
      oOutput(iWord).strobe := '1';
      read(L, valid);
      oOutput(iWord).valid := to_stdulogic(valid);
      hread(L, word);
      oOutput(iWord).data  := word;
    end loop;  -- iWord
  end ReadInputFrame;

  procedure ReadEtaSlice (
      variable L       : inout line;
      variable oEnergies : out TCaloRegionEtaSlice(35 downto 0)) is
      variable vEnergy : integer;
      variable dummy : string(1 to 6);
  begin
      read(L, dummy);

      for iEnergy in oEnergies'low to oEnergies'high loop
        read(L, vEnergy);
        oEnergies(iEnergy) := to_unsigned(vEnergy, 5);
      end loop;
  end ReadEtaSlice;

  procedure ReadEvent (
    file F          :     text;
    variable iEvent : in  integer;
    variable event  : out TGMTEvent) is
    variable L          : line;
    variable inFrameNo  : integer := 0;
    variable outFrameNo : integer := 0;
  begin -- ReadEvent
    event.iEvent := iEvent;

    while (inFrameNo < 6) or (outFrameNo < 6) loop
      readline(F, L);

      if L.all'length = 0 then
        next;
      elsif(L.all(1 to 1) = "#") then
        next;
      elsif L.all(1 to 3) = "EVT" then
        -- TODO: Parse this maybe?
        next;
    elsif L.all(1 to 3) = "IFR" then
        ReadInputFrame(L, event.iD(inFrameNo));
        inFrameNo := inFrameNo+1;
    elsif L.all(1 to 3) = "OFR" then
        ReadInputFrame(L, event.expectedOutput(outFrameNo));
        outFrameNo := outFrameNo+1;
      end if;
    end loop;
  end ReadEvent;

  procedure ReadInEvent (
    file F          :     text;
    variable iEvent : in  integer;
    variable event  : out TGMTInEvent) is
    variable L             : line;
    variable muNo          : integer := 0;
    variable wedgeNo       : integer := 0;
    variable srtRnkNo      : integer := 0;
    variable emptyNo       : integer := 0;
    variable frameNo       : integer := 0;
    variable energyNo      : integer := 0;
  begin  -- ReadInEvent
    event.iEvent := iEvent;

    while (muNo < 108) or (frameNo < 6) or (wedgeNo < 36) or (energyNo < 28) loop
      readline(F, L);

      if L.all'length = 0 then
        next;
      elsif(L.all(1 to 1) = "#") then
        next;
      elsif L.all(1 to 3) = "EVT" then
        -- TODO: Parse this maybe?
        next;
    --   elsif L.all(1 to 4) = "BTRK" or L.all(1 to 4) = "OTRK" or L.all(1 to 4) = "FTRK" then
      elsif L.all(2 to 4) = "TRK" then
        ReadTrack(L, event.expectedTracks(wedgeNo));
        wedgeNo    := wedgeNo+1;
    elsif L.all(1 to 3) = "BAR" or L.all(1 to 3) = "OVL" or L.all(1 to 3) = "FWD" then
        ReadInputMuon(L, event.expectedMuons(muNo), event.expectedSortRanks(muNo), event.expectedEmpty(muNo));
        muNo := muNo+1;
    elsif L.all(1 to 3) = "IFR" then
        ReadInputFrame(L, event.iD(frameNo));
        frameNo := frameNo+1;
      elsif L.all(1 to 4) = "CALO" then
        ReadEtaSlice(L, event.expectedEnergies(energyNo));
        energyNo := energyNo+1;
      end if;
    end loop;
  end ReadInEvent;

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

    while (muFinNo < 8) or (muIntBNo < 8) or (muIntONo < 8) or (muIntFNo < 8) or (frameNo < 6) loop
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
        ReadInputMuon(L, L.all(1 to 3), event.muons(muFinNo), dummySortRank, dummyEmpty, event.iso(muFinNo));
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
    elsif L.all(1 to 3) = "OFR" then
        ReadInputFrame(L, event.expectedOutput(frameNo));
        frameNo := frameNo+1;
      end if;
    end loop;
  end ReadOutEvent;

  procedure ReadCaloEvent (
    file F            : text;
    variable iEvent   : in integer;
    variable event    : out TGMTCaloEvent) is
    variable L        : line;
    variable energyNo : integer := 0;
  begin
    event.iEvent := iEvent;

    while(energyNo < 28) loop
        readline(F, L);
        if L.all'length = 0 then
          next;
        elsif(L.all(1 to 1) = "#") then
          next;
        elsif L.all(1 to 3) = "EVT" then
          -- TODO: Parse this maybe?
          next;
        elsif L.all(1 to 4) = "CALO" then
          ReadEtaSlice(L, event.energies(energyNo));
          energyNo := energyNo+1;
        end if;
    end loop;
  end ReadCaloEvent;

  -- procedure ReadEvent (
  --  file F         :     text;
  --  variable event : out TGMTEvent) is
  -- begin
  -- end ReadEvent;

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
    variable finId         : string(1 to 3)                := "OUT";
    variable bimId        : string(1 to 3)                 := "BIM";
    variable oimId        : string(1 to 3)                 := "OIM";
    variable fimId        : string(1 to 3)                 := "FIM";
    variable dummySrtRnk   : TSortRank10;
    variable dummyEmptyBit : std_logic;
    variable dummyIsoBits  : TIsoBits;
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
        ReadInputMuon(L, finId, event.expectedMuons(finMuNo), dummySrtRnk, dummyEmptyBit, event.expectedIsoBits(finMuNo));
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

  procedure DumpEnergyValues (
    variable iEnergies : in TCaloRegionEtaSlice_vector(27 downto 0);
    variable FO        : in text) is
    variable L1        : line;
  begin
      for iSlice in iEnergies'low to iEnergies'high loop
        write(L1, string'("CALO"));
        write(L1, iSlice);
        write(L1, string'(": "));
        for iEnergy in iEnergies(iSlice)'low to iEnergies(iSlice)'high loop
            write(L1, to_integer(iEnergies(iSlice)(iEnergy)));
            write(L1, string'(" "));
        end loop;
        writeline(FO, L1);
      end loop;

      write(L1, string'(""));
      writeline(FO, L1);
  end DumpEnergyValues;

  procedure DumpCaloEvent (
    variable event : in TGMTCaloEvent;
    variable FO    : in text) is
    variable L1    : line;
  begin -- DumpCaloEvent
    if event.iEvent /= -1 then
        write(L1, string'("++++++++++++++++++++ Dump of event "));
        write(L1, event.iEvent);
        write(L1, string'(": ++++++++++++++++++++"));
        writeline(FO, L1);

        write(L1, string'("### Dumping energy sums: "));
        writeline(FO, L1);
        DumpEnergyValues(event.energies, FO);
    end if;
  end DumpCaloEvent;

  procedure DumpFrames (
    variable tbuf : in TTransceiverBuffer;
    variable FO   : in text) is
    variable L    : line;
  begin  -- DumpFrames
    for iFrame in tbuf'low to tbuf'high loop
      write(L, string'("FRM"));
      write(L, iFrame);
      write(L, string'("    "));
      for iChan in tbuf(iFrame)'low to tbuf(iFrame)'high loop
        write(L, tbuf(iFrame)(iChan).valid);
        write(L, string'(" "));
        hwrite(L, tbuf(iFrame)(iChan).data);
        write(L, string'("    "));
      end loop;  -- iChan
      writeline(FO, L);
    end loop;  -- iFrame
  end DumpFrames;

  procedure DumpEvent (
    variable event : in TGMTEvent;
    variable FO    : in text) is
    variable L1    : line;
  begin  -- DumpEvent
    if event.iEvent /= -1 then
      write(L1, string'("++++++++++++++++++++ Dump of event "));
      write(L1, event.iEvent);
      write(L1, string'(": ++++++++++++++++++++"));
      writeline(FO, L1);

      write(L1, string'("### Dumping input frames: "));
      writeline(FO, L1);
      DumpFrames(event.iD, FO);
      write(L1, string'("### Dumping expected output: "));
      writeline(FO, L1);
      DumpFrames(event.expectedOutput, FO);
    end if;
  end DumpEvent;

  procedure DumpInEvent (
    variable event : in TGMTInEvent;
    variable FO    : in  text) is
    variable L1    : line;
    variable in_id : string(1 to 3)                 := "INE";
  begin  -- DumpInEvent
    if event.iEvent /= -1 then
      write(L1, string'("++++++++++++++++++++ Dump of event "));
      write(L1, event.iEvent);
      write(L1, string'(": ++++++++++++++++++++"));
      writeline(FO, L1);

      write(L1, string'("### Dumping input frames: "));
      writeline(FO, L1);
      DumpFrames(event.iD, FO);
      write(L1, string'("### Dumping expected output: "));
      writeline(FO, L1);
      DumpMuons(event.expectedMuons, event.expectedSortRanks, event.expectedEmpty, FO, in_id);
      DumpEnergyValues(event.expectedEnergies, FO);
    end if;
  end DumpInEvent;

  procedure DumpOutEvent (
    variable event           : in TGMTOutEvent;
    variable FO              : in text) is
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
      writeline(FO, L1);

      write(L1, string'("### Dumping final muons: "));
      writeline(FO, L1);
      DumpMuons(event.muons, vDummySortRanks, FO, fin_id);
      write(L1, string'("### Dumping intermediate muons: "));
      writeline(FO, L1);
      DumpMuons(event.intMuons_brl, event.intSortRanks_brl, FO, brl_id);
      DumpMuons(event.intMuons_ovl, event.intSortRanks_ovl, FO, ovl_id);
      DumpMuons(event.intMuons_fwd, event.intSortRanks_fwd, FO, fwd_id);
      write(L1, string'("### Dumping expected output: "));
      writeline(FO, L1);
      DumpFrames(event.expectedOutput, FO);
      -- TODO: Missing final energies, extrapolated coordinates and iso bits.
    end if;
  end DumpOutEvent;

  procedure DumpMuEvent (
    variable event     : in TGMTMuEvent;
    variable FO        : in text) is
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
      writeline(FO, L1);
      DumpEventMuons(event, FO);

      DumpTracks(event.tracks_brl, FO, brlTrk_id);
      DumpTracks(event.tracks_ovl, FO, ovlTrk_id);
      DumpTracks(event.tracks_fwd, FO, fwdTrk_id);
    end if;
  end DumpMuEvent;

  procedure DumpEventMuons (
    variable event  : in TGMTMuEvent;
    variable FO     : in text) is
    variable L1     : line;
    variable brl_id : string(1 to 3) := "BRL";
    variable ovl_id : string(1 to 3) := "OVL";
    variable fwd_id : string(1 to 3) := "FWD";
  begin -- DumpEventMuons
      if event.iEvent /= -1 then
        write(L1, string'("++++++++++++++++++++ Dump of input muons: "));
        writeline(FO, L1);
        DumpMuons(event.muons_brl, event.sortRanks_brl, FO, brl_id);
        DumpMuons(event.muons_ovl, event.sortRanks_ovl, FO, ovl_id);
        DumpMuons(event.muons_fwd, event.sortRanks_fwd, FO, fwd_id);
      end if;
  end DumpEventMuons;

  procedure DumpIsoBits (
    variable iIsoBits : in TIsoBits_vector(7 downto 0);
    variable FO       : in text;
    variable id       : in string(1 to 3)) is
    variable L1            : line;
  begin
    write(L1, string'("++++++++++++++++++++ Dump of Iso bits from "));
    write(L1, id);
    write(L1, string'(": "));
    writeline(FO, L1);
    for i in iIsoBits'low to iIsoBits'high loop
        write(L1, to_integer(unsigned(iIsoBits(i))));
        write(L1, string'(" "));
    end loop;
    writeline(FO, L1);
    write(L1, string'(""));
    writeline(FO, L1);
  end DumpIsoBits;

  procedure DumpFinalPt (
    variable iFinalPt : in TMuonPT_vector;
    variable FO       : in text) is
    variable L1 : line;
  begin
    write(L1, string'("++++++++++++++++++++ Dump of final pT values: "));
    writeline(FO, L1);
    for i in iFinalPt'low to iFinalPt'high loop
        write(L1, to_integer(iFinalPt(i)));
        write(L1, string'(" "));
    end loop;
    writeline(FO, L1);
    write(L1, string'(""));
    writeline(FO, L1);
  end DumpFinalPt;

  procedure DumpSelectedEnergies (
    variable iEnergies : in TCaloArea_vector;
    variable FO        : in  text) is
    variable L1 : line;
  begin
    write(L1, string'("++++++++++++++++++++ Dump of selected energy sums: "));
    writeline(FO, L1);
    for i in iEnergies'low to iEnergies'high loop
        write(L1, to_integer(iEnergies(i)));
        write(L1, string'(" "));
    end loop;
    writeline(FO, L1);
    write(L1, string'(""));
    writeline(FO, L1);
  end DumpSelectedEnergies;

  procedure DumpMuIdxBits (
    variable iIdxBits : in TIndexBits_vector;
    variable FO       : in text) is
    variable L1       : line;
  begin
    write(L1, string'("++++++++++++++++++++ Dump of final muon index bits: "));
    writeline(FO, L1);
    write(L1, string'("# MuNo   Idx"));
    writeline(FO, L1);
    for i in iIdxBits'low to iIdxBits'high loop
        write(L1, string'("  "));
        write(L1, i);
        write(L1, string'("    "));
        write(L1, to_integer(iIdxBits(i)));
        writeline(FO, L1);
    end loop;
    write(L1, string'(""));
    writeline(FO, L1);
  end DumpMuIdxBits;

  procedure DumpCaloIdxBits (
    variable iIdxBits : in TCaloIndexBit_vector;
    variable FO       : in text) is
    variable L1       : line;
  begin
    write(L1, string'("++++++++++++++++++++ Dump of selected calo index bits: "));
    writeline(FO, L1);
    write(L1, string'("# MuNo   Phi   Eta"));
    writeline(FO, L1);
    for i in iIdxBits'low to iIdxBits'high loop
        write(L1, string'("  "));
        write(L1, i);
        write(L1, string'("    "));
        write(L1, to_integer(iIdxBits(i).phi));
        write(L1, string'("    "));
        write(L1, to_integer(iIdxBits(i).eta));
        writeline(FO, L1);
    end loop;
    write(L1, string'(""));
    writeline(FO, L1);
  end DumpCaloIdxBits;

  procedure DumpExtrapolatedCoordiantes (
    variable iExtrapolatedCoords : in TSpatialCoordinate_vector;
    variable FO                  : in text;
    variable id                  : in string(1 to 3)) is
    variable L1                  : line;
  begin
    write(L1, string'("++++++++++++++++++++ Dump of extrapolated coordinates from "));
    write(L1, id);
    write(L1, string'(": "));
    writeline(FO, L1);
    write(L1, string'(" # MuNo        Phi        Eta"));
    writeline(FO, L1);
    for i in iExtrapolatedCoords'range loop
        write(L1, string'("   "));
        write(L1, i);
        write(L1, string'("          "));
        write(L1, to_integer(iExtrapolatedCoords(i).phi));
        write(L1, string'("        "));
        write(L1, to_integer(iExtrapolatedCoords(i).eta));
        writeline(FO, L1);
    end loop;
    write(L1, string'(""));
    writeline(FO, L1);
  end DumpExtrapolatedCoordiantes;

  procedure DumpTracks (
    variable iTracks : in TGMTMuTracks_vector;
    variable FO      : in text;
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
        writeline(FO, L1);
      end if;
    end loop;  -- iTrack
    write(L1, string'(""));
    writeline(FO, L1);
  end DumpTracks;

  procedure DumpMuon (
    noMu               : in integer;
    variable iMu       : in TGMTMu;
    variable iSortRank : in TSortRank10;
    variable iEmpty    : in std_logic;
    variable FO        : in text;
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
    -- If we're looking at an input muon the empty bit is of interest.
    if id = string'("INS") or id = string'("INE") then
        write(L1, string'(" "));
        write(L1, to_bit(iEmpty));
    end if;
    -- For final muons no sort rank information is available and is thus
    -- faked by the testbench. We therefore won't display it.
    if id /= string'("OUT") then
      write(L1, string'(" "));
      write(L1, to_integer(unsigned(iSortRank)));
    end if;
    writeline(FO, L1);
  end DumpMuon;

  procedure DumpMuon (
    noMu               : in integer;
    variable iMu       : in TGMTMu;
    variable iSortRank : in TSortRank10;
    variable FO        : in text;
    variable id        : in string(1 to 3)) is
    variable L1 : line;
    variable dummyEmpty : std_logic := '0';
  begin  -- DumpMuon
    DumpMuon(noMu, iMu, iSortRank, dummyEmpty, FO, id);
  end DumpMuon;

  procedure DumpMuons (
    variable iMuons     : in TGMTMu_vector;
    variable iSortRanks : in TSortRank10_vector;
    variable FO         : in text;
    variable id         : in string(1 to 3)) is
    variable L1 : line;
  begin  -- DumpMuons
    for iMu in iMuons'range loop
      DumpMuon(iMu, iMuons(iMu), iSortRanks(iMu), FO, id);
    end loop;  -- iMu
    write(L1, string'(""));
    writeline(FO, L1);
  end DumpMuons;

  procedure DumpMuons (
    variable iMuons     : in TGMTMu_vector;
    variable iSortRanks : in TSortRank10_vector;
    variable iEmptyBits : in std_logic_vector;
    variable FO         : in text;
    variable id         : in string(1 to 3)) is
    variable L1 : line;
  begin  -- DumpMuons
    for iMu in iMuons'range loop
      DumpMuon(iMu, iMuons(iMu), iSortRanks(iMu), iEmptyBits(iMu), FO, id);
    end loop;  -- iMu
    write(L1, string'(""));
    writeline(FO, L1);
  end DumpMuons;

  procedure DumpValidBits (
    variable iValid_muons    : in std_logic;
    variable iValid_energies : in std_logic;
    variable FO              : in text) is
    variable L1 : line;
  begin  -- DumpValidBits
    write(L1, string'("Valid bit from muons: "));
    write(L1, to_bit(iValid_muons));
    write(L1, string'(". Valid bit from calo: "));
    write(L1, to_bit(iValid_energies));
    write(L1, string'(""));
    writeline(FO, L1);
  end DumpValidBits;

  procedure CheckMuon (
    noMu                : in  integer;
    variable iMu        : in  TGMTMu;
    variable iEmuMu     : in  TGMTMu;
    variable iSrtRnk    : in  TSortRank10;
    variable iEmuSrtRnk : in  TSortRank10;
    variable id         : in  string(1 to 3);
    variable FO         : in  text;
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
      writeline(FO, LO);
      write(LO, string'("!!! Comparison: "));
      writeline(FO, LO);
      DumpMuon(noMu, iMu, iSrtRnk, FO, id);
      DumpMuon(noMu, iEmuMu, iEmuSrtRnk, FO, idEmu);
      write(LO, string'(""));
      writeline(FO, LO);
    end if;
  end CheckMuon;

  procedure CheckMuons (
    variable iMus        : in  TGMTMu_vector;
    variable iEmuMus     : in  TGMTMu_vector;
    variable iSrtRnks    : in  TSortRank10_vector;
    variable iEmuSrtRnks : in  TSortRank10_vector;
    variable id          : in  string(1 to 3);
    variable FO          : in  text;
    variable errors      : out integer) is
    variable LO       : line;
    variable vErrors  : integer := 0;
    variable tmpError : integer;
  begin  -- CheckMuons
    errors := 0;
    for i in iMus'range loop
      tmpError := 0;
      CheckMuon(i, iMus(i), iEmuMus(i), iSrtRnks(i), iEmuSrtRnks(i), id, FO, tmpError);
      vErrors  := vErrors+tmpError;
    end loop;  -- i
    errors := vErrors;
  end CheckMuons;

  procedure CheckMuons (
    variable iMus    : in  TGMTMu_vector;
    variable iEmuMus : in  TGMTMu_vector;
    variable id      : in  string(1 to 3);
    variable FO      : in  text;
    variable errors  : out integer) is
    variable LO          : line;
    variable vErrors     : integer     := 0;
    variable tmpError    : integer;
    variable dummySrtRnk : TSortRank10 := (others => '0');
  begin  -- CheckMuons
    errors := 0;
    for i in iMus'range loop
      tmpError := 0;
      CheckMuon(i, iMus(i), iEmuMus(i), dummySrtRnk, dummySrtRnk, id, FO, tmpError);
      vErrors  := vErrors+tmpError;
    end loop;  -- i
    errors := vErrors;
  end CheckMuons;

  procedure CheckSortRanks (
    variable iSrtRnks    : in  TSortRank10_vector;
    variable iEmuSrtRnks : in  TSortRank10_vector;
    variable id          : in  string(1 to 3);
    variable FO          : in  text;
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
        writeline(FO, LO);
        write(LO, string'("!!! Simulation output: "));
        write(LO, to_integer(unsigned(iSrtRnks(i))));
        writeline(FO, LO);
        write(LO, string'("!!!   Expected output: "));
        write(LO, to_integer(unsigned(iEmuSrtRnks(i))));
        writeline(FO, LO);
        write(LO, string'(""));
        writeline(FO, LO);
      end if;
    end loop;  --i
    errors := vErrors;
  end CheckSortRanks;

  procedure CheckEmptyBits (
    variable iEmpty      : in  std_logic_vector;
    variable iEmuEmpty   : in  std_logic_vector;
    variable FO          : in  text;
    variable errors      : out integer) is
    variable LO      : line;
    variable vErrors : integer := 0;
  begin  -- CheckEmptyBits
    for i in iEmpty'range loop
      if iEmpty(i) /= iEmuEmpty(i) then
        vErrors := vErrors+1;

        write(LO, string'("!!!!!! Error in empty bit #"));
        write(LO, i);
        writeline(FO, LO);
        write(LO, string'("!!! Simulation output: "));
        write(LO, to_bit(iEmpty(i)));
        writeline(FO, LO);
        write(LO, string'("!!!   Expected output: "));
        write(LO, to_bit(iEmuEmpty(i)));
        writeline(FO, LO);
        write(LO, string'(""));
        writeline(FO, LO);
      end if;
    end loop;  --i
    errors := vErrors;
  end CheckEmptyBits;

  procedure CheckEnergies (
    variable iEnergies    : in  TCaloRegionEtaSlice_vector(NUM_CALO_CHANS-1 downto 0);
    variable iEmuEnergies : in  TCaloRegionEtaSlice_vector(NUM_CALO_CHANS-1 downto 0);
    variable FO           : in  text;
    variable errors       : out integer) is
    variable LO      : line;
    variable vErrors : integer := 0;
  begin  -- CheckEnergies
    for i in iEnergies'range loop
      for j in iEnergies(i)'range loop
        if iEnergies(i)(j) /= iEmuEnergies(i)(j) then
          vErrors := vErrors+1;

          write(LO, string'("!!!!!! Error in energy #"));
          write(LO, i);
          write(LO, string'(" "));
          write(LO, j);
          writeline(FO, LO);
          write(LO, string'("!!! Simulation output: "));
          write(LO, to_integer(iEnergies(i)(j)));
          writeline(FO, LO);
          write(LO, string'("!!!   Expected output: "));
          write(LO, to_integer(iEmuEnergies(i)(j)));
          writeline(FO, LO);
          write(LO, string'(""));
          writeline(FO, LO);
        end if;
      end loop;  --j
    end loop;  --i
    errors := vErrors;
  end CheckEnergies;

  procedure CheckFrame (
    variable iFrame    : in  ldata;
    variable iEmuFrame : in  ldata;
    variable FO        : in  text;
    variable errors    : out integer) is
    variable LO        :     line;
    variable vErrors   :     integer := 0;
  begin  -- CheckFrame

    for iChan in iFrame'range loop
      if iFrame(iChan) /= iEmuFrame(iChan) then
        vErrors := vErrors+1;

        write(LO, string'("Errors found in channel #"));
        write(LO, iChan);
        writeline(FO, LO);
        write(LO, string'("!!! Simulation output: "));
        write(LO, iFrame(iChan).valid);
        write(LO, string'(" "));
        hwrite(LO, iFrame(iChan).data);
        writeline(FO, LO);
        write(LO, string'("!!!   Expected output: "));
        write(LO, iEmuFrame(iChan).valid);
        write(LO, string'(" "));
        hwrite(LO, iEmuFrame(iChan).data);
        writeline(FO, LO);
      end if;
    end loop;  -- iChan

    errors := vErrors;
  end CheckFrame;

  procedure CheckValidBits (
    variable iValid_mu       : in  std_logic;
    variable iValid_energies : in  std_logic;
    variable FO              : in  text;
    variable errors          : out integer) is
    variable L1              : line;
  begin
    if iValid_mu /= iValid_energies then
      write(L1, string'("!!!!!! Valid bits inconsistent:"));
      writeline(FO, L1);
      DumpValidBits(iValid_mu, iValid_energies, FO);
    end if;
  end CheckValidBits;

  procedure ValidateIsolationOutput (
      variable iIsoBits : in TIsoBits_vector(7 downto 0);
      variable muEvent  : in TGMTMuEvent;
    variable FO         : in  text;
      variable errors   : out integer) is
      variable LO       : line;
      variable tmpError : integer := 0;
      variable vErrors  : integer := 0;
  begin
    if (muEvent.iEvent >= 0) then
        for i in iIsoBits'range loop
            if iIsoBits(i) /= muEvent.expectedIsoBits(i) then
                vErrors := vErrors + 1;

                write(LO, string'("!!!!!! Error in muon #"));
                write(LO, i);
                writeline(FO, LO);

                if iIsoBits(i)(0) /= muEvent.expectedIsoBits(i)(0) then
                    write(LO, string'("Absolute isolation: "));
                    writeline(FO, LO);
                    write(LO, string'("Simulation: "));
                    write(LO, iIsoBits(i)(0));
                    write(LO, string'("; expected: "));
                    write(LO, muEvent.expectedIsoBits(i)(0));
                    writeline(FO, LO);
                end if;
                if iIsoBits(i)(1) /= muEvent.expectedIsoBits(i)(1) then
                    write(LO, string'("Relative isolation: "));
                    writeline(FO, LO);
                    write(LO, string'("Simulation: "));
                    write(LO, iIsoBits(i)(1));
                    write(LO, string'("; expected: "));
                    write(LO, muEvent.expectedIsoBits(i)(1));
                    writeline(FO, LO);
                end if;
                writeline(FO, LO);
                write(LO, string'("!!! Simulation output: "));
                write(LO, to_integer(unsigned(iIsoBits(i))));
                writeline(FO, LO);
                write(LO, string'("!!!   Expected output: "));
                write(LO, to_integer(unsigned(muEvent.expectedIsoBits(i))));
                writeline(FO, LO);
                write(LO, string'(""));
                writeline(FO, LO);
            end if;
        end loop; -- i
        if vErrors > 0 then
          errors := 1;
        else
          errors := 0;
        end if;
    else
        errors := 0;
    end if;
  end ValidateIsolationOutput;

  procedure ValidateGMTOutput (
    variable iOutput  : in  TTransceiverBuffer;
    variable event    : in  TGMTEvent;
    variable FO       : in  text;
    variable errors   : out integer) is
    variable LO       :     line;
    variable tmpError :     integer := 0;
    variable vErrors  :     integer := 0;
  begin
      if (event.iEvent >= 0) then
        for iFrame in iOutput'range loop
        CheckFrame(iOutput(iFrame)(NUM_OUT_CHANS+NUM_INTERM_MU_OUT_CHANS - 1 downto 0), event.expectedOutput(iFrame)(NUM_OUT_CHANS+NUM_INTERM_MU_OUT_CHANS - 1 downto 0), FO, tmpError);
          if tmpError > 0 then
              write(LO, string'("!!!!!! of frame #"));
              write(LO, iFrame);
              writeline(FO, LO);
              write(LO, string'(""));
              writeline(FO, LO);
          end if;
          vErrors := vErrors + tmpError;
        end loop;  -- frame

        if vErrors > 0 then
          errors := 1;
        else
          errors := 0;
        end if;
      else
        errors := 0;
      end if;
  end ValidateGMTOutput;

  procedure ValidateDeserializerOutput (
    variable iMuons          : in  TGMTMu_vector(107 downto 0);
    variable iTracks         : in  TGMTMuTracks_vector(35 downto 0);
    variable iSrtRnks        : in  TSortRank10_vector(107 downto 0);
    variable iEmpty          : in  std_logic_vector(107 downto 0);
    variable iValid_muons    : in  std_logic;
    variable iEnergies       : in  TCaloRegionEtaSlice_vector(NUM_CALO_CHANS-1 downto 0);
    variable iValid_energies : in  std_logic;
    variable event           : in  TGMTInEvent;
    variable FO              : in  text;
    variable errors          : out integer) is
    variable LO       : line;
    variable tmpError : integer := 0;
    variable vErrors  : integer := 0;
    variable idInMus  : string(1 to 3) := "INM";
  begin
    if (event.iEvent >= 0) then
      tmpError := 0;
      CheckMuons(iMuons, event.expectedMuons, iSrtRnks, event.expectedSortRanks, idInMus, FO, tmpError);
      vErrors   := tmpError;
      tmpError := 0;
      CheckSortRanks(iSrtRnks, event.expectedSortRanks, idInMus, FO, tmpError);
      vErrors   := vErrors + tmpError;
      tmpError := 0;
      CheckEmptyBits(iEmpty, event.expectedEmpty, FO, tmpError);
      vErrors   := vErrors + tmpError;
      tmpError := 0;
      CheckValidBits(iValid_muons, iValid_energies, FO, tmpError);
      vErrors   := vErrors + tmpError;
      tmpError := 0;
      CheckEnergies(iEnergies, event.expectedEnergies, FO, tmpError);
      vErrors   := vErrors + tmpError;

      if vErrors = 0 then
        errors := 0;
      else
        errors := 1;
      end if;
    else
      errors := 0;
    end if;
  end ValidateDeserializerOutput;

  procedure ValidateSerializerOutput (
    variable iOutput : in  TTransceiverBuffer;
    variable event   : in  TGMTOutEvent;
    variable FO      : in  text;
    variable errors  : out integer) is
    variable LO       : line;
    variable tmpError : integer := 0;
    variable vErrors  : integer := 0;
  begin
    if (event.iEvent >= 0) then
      for iFrame in iOutput'range loop
        CheckFrame(iOutput(iFrame)(NUM_OUT_CHANS+NUM_INTERM_MU_OUT_CHANS-1 downto 0), event.expectedOutput(iFrame)(NUM_OUT_CHANS+NUM_INTERM_MU_OUT_CHANS-1 downto 0), FO, tmpError);
        if tmpError > 0 then
            write(LO, string'("!!!!!! of frame #"));
            write(LO, iFrame);
            writeline(FO, LO);
            write(LO, string'(""));
            writeline(FO, LO);
        end if;
        vErrors := vErrors + tmpError;
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
    variable iEvent    : in  TGMTMuEvent;
    variable FO        : in  text;
    variable error     : out integer) is
    variable LO       : line;
    variable vError   : integer        := 0;
    variable tmpError : integer        := 0;
    variable idFin    : string(1 to 3) := "FIN";
  begin
    if (iEvent.iEvent >= 0) then
      tmpError := 0;
      CheckMuons(iFinalMus, iEvent.expectedMuons, idFin, FO, tmpError);
      vError   := tmpError;
      tmpError := 0;

      if vError > 0 then
        error := 1;
      else
        error := 0;
      end if;
    else
      error := 0;
    end if;
  end ValidateSorterOutput;

  procedure ValidateSorterOutput (
    variable iFinalMus : in  TGMTMu_vector(7 downto 0);
    variable iIntMusB  : in  TGMTMu_vector(7 downto 0);
    variable iIntMusO  : in  TGMTMu_vector(7 downto 0);
    variable iIntMusF  : in  TGMTMu_vector(7 downto 0);
    variable iSrtRnksB : in  TSortRank10_vector(7 downto 0);
    variable iSrtRnksO : in  TSortRank10_vector(7 downto 0);
    variable iSrtRnksF : in  TSortRank10_vector(7 downto 0);
    variable iEvent    : in  TGMTMuEvent;
    variable FO        : in  text;
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
      tmpError := 0;
      CheckMuons(iFinalMus, iEvent.expectedMuons, idFin, FO, tmpError);
      vError   := tmpError;
      tmpError := 0;
      CheckMuons(iIntMusB, iEvent.expectedIntMuB, iSrtRnksB, iEvent.expectedSrtRnksB, idIntB, FO, tmpError);
      vError   := vError + tmpError;
      tmpError := 0;
      CheckMuons(iIntMusO, iEvent.expectedIntMuO, iSrtRnksO, iEvent.expectedSrtRnksO, idIntO, FO, tmpError);
      vError   := vError + tmpError;
      tmpError := 0;
      CheckMuons(iIntMusF, iEvent.expectedIntMuF, iSrtRnksF, iEvent.expectedSrtRnksF, idIntF, FO, tmpError);
      vError   := vError + tmpError;

      tmpError := 0;
      CheckSortRanks(iSrtRnksB, iEvent.expectedSrtRnksB, idIntB, FO, tmpError);
      vError   := vError + tmpError;
      tmpError := 0;
      CheckSortRanks(iSrtRnksO, iEvent.expectedSrtRnksO, idIntO, FO, tmpError);
      vError   := vError + tmpError;
      tmpError := 0;
      CheckSortRanks(iSrtRnksF, iEvent.expectedSrtRnksF, idIntF, FO, tmpError);
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
