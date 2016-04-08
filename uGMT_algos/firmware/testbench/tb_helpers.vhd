library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
use WORK.GMTTypes.all;
use STD.TEXTIO.all;
use ieee.std_logic_textio.all;
use work.mp7_data_types.all;
use work.ugmt_constants.all;

package tb_helpers is

  constant N_SERIALIZER_CHAN : integer := NUM_OUT_CHANS+NUM_INTERM_MU_OUT_CHANS;
  constant NINCHAN           : integer := 72;
  constant NOUTCHAN          : integer := NUM_OUT_CHANS;
  type     TTransceiverBuffer is array (2*NUM_MUONS_IN-1 downto 0) of ldata(NINCHAN-1 downto 0);
  type     TExtendedTransceiverBuffer is array (2*2*NUM_MUONS_IN-1 downto 0) of ldata(NINCHAN-1 downto 0);

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
    iEvent            : integer;
    muons             : TGMTMu_vector(7 downto 0);
    iso               : TIsoBits_vector(7 downto 0);
    idxBits           : TIndexBits_vector(7 downto 0);
    intMuons_bmtf     : TGMTMu_vector(7 downto 0);
    intMuons_omtf     : TGMTMu_vector(7 downto 0);
    intMuons_emtf     : TGMTMu_vector(7 downto 0);
    intSortRanks_bmtf : TSortRank10_vector(7 downto 0);
    intSortRanks_omtf : TSortRank10_vector(7 downto 0);
    intSortRanks_emtf : TSortRank10_vector(7 downto 0);
    finalEnergies     : TCaloArea_vector(7 downto 0);
    extrCoords_bmtf   : TSpatialCoordinate_vector(35 downto 0);
    extrCoords_omtf   : TSpatialCoordinate_vector(35 downto 0);
    extrCoords_emtf   : TSpatialCoordinate_vector(35 downto 0);
    expectedOutput    : TTransceiverBuffer;
  end record;
  type TGMTOutEvent_vec is array (integer range <>) of TGMTOutEvent;

  type TGMTMuEvent is record
    iEvent            : integer;
    muons_bmtf        : TGMTMu_vector(35 downto 0);
    muons_omtf        : TGMTMu_vector(35 downto 0);
    muons_emtf        : TGMTMu_vector(35 downto 0);
    tracks_bmtf       : TGMTMuTracks_vector(11 downto 0);
    tracks_omtf       : TGMTMuTracks_vector(11 downto 0);
    tracks_emtf       : TGMTMuTracks_vector(11 downto 0);
    sortRanks_bmtf    : TSortRank10_vector(35 downto 0);
    sortRanks_omtf    : TSortRank10_vector(35 downto 0);
    sortRanks_emtf    : TSortRank10_vector(35 downto 0);
    empty_bmtf        : std_logic_vector(35 downto 0);
    empty_omtf        : std_logic_vector(35 downto 0);
    empty_emtf        : std_logic_vector(35 downto 0);
    idxBits_bmtf      : TIndexBits_vector(35 downto 0);
    idxBits_omtf     : TIndexBits_vector(35 downto 0);
    idxBits_emtf     : TIndexBits_vector(35 downto 0);
    expectedMuons     : TGMTMu_vector(7 downto 0);
    expectedIsoBits   : TIsoBits_vector(7 downto 0);
    expectedIntMuB    : TGMTMu_vector(7 downto 0);
    expectedIntMuO    : TGMTMu_vector(7 downto 0);
    expectedIntMuE    : TGMTMu_vector(7 downto 0);
    expectedSrtRnksB  : TSortRank10_vector(7 downto 0);
    expectedSrtRnksO  : TSortRank10_vector(7 downto 0);
    expectedSrtRnksE  : TSortRank10_vector(7 downto 0);
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
    variable id         : in string(1 to 4));

  procedure DumpMuons (
    variable iMuons     : in TGMTMu_vector;
    variable iSortRanks : in TSortRank10_vector;
    variable iEmptyBits : in std_logic_vector;
    variable FO         : in text;
    variable id         : in string(1 to 4));

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
    variable iIntMusE  : in  TGMTMu_vector(7 downto 0);
    variable iSrtRnksB : in  TSortRank10_vector(7 downto 0);
    variable iSrtRnksO : in  TSortRank10_vector(7 downto 0);
    variable iSrtRnksE : in  TSortRank10_vector(7 downto 0);
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
    variable isoBit   : out   TIsoBits;
    variable idxBits  : out   TIndexBits
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
    variable index       : integer;

    variable dummy : string(1 to 5);
  begin  -- ReadInputMuon
    read(L, dummy);

    read(L, cable_no);
    read(L, pt);
    muon.pt         := to_unsigned(pt, 9);
    read(L, phi);
    muon.phi        := to_unsigned(phi, 10);
    read(L, eta);
    muon.eta        := to_signed(eta, 9);
    read(L, sign);
    muon.sign       := to_stdulogic(sign);
    read(L, vsign);
    muon.sign_valid := to_stdulogic(vsign);
    read(L, qual);
    muon.qual       := to_unsigned(qual, 4);
    read(L, rank);
    sortRank        := std_logic_vector(to_unsigned(rank, 10));
    read(L, empty);
    emptyBit        := to_stdulogic(empty);

    if id = string'("OUT") then
      read(L, iso);
      isoBit  := std_logic_vector(to_unsigned(iso, 2));
      read(L, index);
      idxBits := to_unsigned(index, 7);
    end if;

    -- TODO: Handle halo bit once this has been added to testbench.
    muon.halo := '0';

  end ReadInputMuon;

  procedure ReadInputMuon (
    variable L        : inout line;
    variable muon     : out   TGMTMu;
    variable sortRank : out   TSortRank10;
    variable emptyBit : out   std_logic
    ) is
    variable dummyIso     : TIsoBits;
    variable dummyid      : string(1 to 3) := "XXX";
    variable dummyIdxBits : TIndexBits;
  begin  -- ReadInputMuon
    ReadInputMuon(L, dummyid, muon, sortRank, emptyBit, dummyIso, dummyIdxBits);
  end ReadInputMuon;

  procedure ReadTrack (
    variable L     : inout line;
    variable track : out   TGMTMuTracks3) is
    variable LO                              : line;
    variable eta1, eta2, eta3                : integer;
    variable phi1, phi2, phi3                : integer;
    variable qual1, qual2, qual3             : integer;
    variable sel1, sel2, sel3                : bit;
    variable detSide1, detSide2, detSide3    : integer;
    variable wheel1, wheel2, wheel3          : integer;
    variable station11, station12, station13 : integer;
    variable station21, station22, station23 : integer;
    variable station31, station32, station33 : integer;
    variable station41, station42, station43 : integer;
    variable empty1, empty2, empty3          : bit;

    variable tfID : string(1 to 5);
  begin  -- ReadTrack
    read(L, tfID);

    read(L, eta1);
    track(0).eta  := to_signed(eta1, 9);
    read(L, phi1);
    track(0).phi  := to_signed(phi1, 8);
    read(L, qual1);
    track(0).qual := to_unsigned(qual1, 4);
    if tfId(1 to 4) = "BTRK" then
      read(L, sel1);
      -- TODO: Add support for 4 track segments
      read(L, detSide1);
      track(0).bmtfAddress.detectorSide := std_logic_vector(to_unsigned(detSide1, 1));
      read(L, wheel1);
      track(0).bmtfAddress.wheelNo := to_unsigned(wheel1, 2);
      read(L, station11);
      track(0).bmtfAddress.addressStation0 := to_unsigned(station11, 2);
      read(L, station21);
      track(0).bmtfAddress.stationAddresses(0) := to_unsigned(station21, 4);
      read(L, station31);
      track(0).bmtfAddress.stationAddresses(1) := to_unsigned(station31, 4);
      read(L, station41);
      track(0).bmtfAddress.stationAddresses(2) := to_unsigned(station41, 4);
    end if;

    read(L, empty1);
    track(0).empty := to_stdulogic(empty1);

    read(L, eta2);
    track(1).eta  := to_signed(eta2, 9);
    read(L, phi2);
    track(1).phi  := to_signed(phi2, 8);
    read(L, qual2);
    track(1).qual := to_unsigned(qual2, 4);
    if tfId(1 to 4) = "BTRK" then
      read(L, sel2);
      -- TODO: Add support for 4 track segments
      read(L, detSide2);
      track(1).bmtfAddress.detectorSide := std_logic_vector(to_unsigned(detSide2, 1));
      read(L, wheel2);
      track(1).bmtfAddress.wheelNo := to_unsigned(wheel2, 2);
      read(L, station12);
      track(1).bmtfAddress.addressStation0 := to_unsigned(station12, 2);
      read(L, station22);
      track(1).bmtfAddress.stationAddresses(0) := to_unsigned(station22, 4);
      read(L, station32);
      track(1).bmtfAddress.stationAddresses(1) := to_unsigned(station32, 4);
      read(L, station42);
      track(1).bmtfAddress.stationAddresses(2) := to_unsigned(station42, 4);
    end if;
    read(L, empty2);
    track(1).empty := to_stdulogic(empty2);

    read(L, eta3);
    track(2).eta  := to_signed(eta3, 9);
    read(L, phi3);
    track(2).phi  := to_signed(phi3, 8);
    read(L, qual3);
    track(2).qual := to_unsigned(qual3, 4);
    if tfId(1 to 4) = "BTRK" then
      read(L, sel3);
      -- TODO: Add support for 4 track segments
      read(L, detSide3);
      track(2).bmtfAddress.detectorSide := std_logic_vector(to_unsigned(detSide3, 1));
      read(L, wheel3);
      track(2).bmtfAddress.wheelNo := to_unsigned(wheel3, 2);
      read(L, station13);
      track(2).bmtfAddress.addressStation0 := to_unsigned(station13, 2);
      read(L, station23);
      track(2).bmtfAddress.stationAddresses(0) := to_unsigned(station23, 4);
      read(L, station33);
      track(2).bmtfAddress.stationAddresses(1) := to_unsigned(station33, 4);
      read(L, station43);
      track(2).bmtfAddress.stationAddresses(2) := to_unsigned(station43, 4);
    end if;
    read(L, empty3);
    track(2).empty := to_stdulogic(empty3);

  end ReadTrack;

  procedure ReadInputFrame (
    variable L       : inout line;
    variable oOutput : out   ldata) is
    variable word  : std_logic_vector(31 downto 0);
    variable valid : bit;
    variable dummy : string(1 to 8);
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
      elsif L.all(2 to 4) = "TRK" then
        ReadTrack(L, event.expectedTracks(wedgeNo));
        wedgeNo    := wedgeNo+1;
      elsif L.all(1 to 4) = "BMTF" or L.all(1 to 4) = "OMTF" or L.all(1 to 4) = "EMTF" then
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
    variable dummyIdxBits  : TIndexBits;
    variable muNo          : integer := 0;
    variable muFinNo       : integer := 0;
    variable muIntBNo      : integer := 0;
    variable muIntONo      : integer := 0;
    variable muIntENo      : integer := 0;
    variable frameNo       : integer := 0;
  begin  -- ReadOutEvent
    event.iEvent := iEvent;

    while (muFinNo < 8) or (muIntBNo < 8) or (muIntONo < 8) or (muIntENo < 8) or (frameNo < 6) loop
      readline(F, L);

      if L.all'length = 0 then
        next;
      elsif(L.all(1 to 1) = "#") then
        next;
      elsif L.all(1 to 3) = "EVT" then
        -- TODO: Parse this maybe?
        next;
      elsif L.all(1 to 3) = "OUT" then
        ReadInputMuon(L, L.all(1 to 3), event.muons(muFinNo), dummySortRank, dummyEmpty, event.iso(muFinNo), event.idxBits(muFinNo));
        muFinNo := muFinNo+1;
        muNo    := muNo+1;
      elsif L.all(1 to 4) = "BIMD" then
        ReadInputMuon(L, event.intMuons_bmtf(muIntBNo), event.intSortRanks_bmtf(muIntBNo), dummyEmpty);
        muIntBNo := muIntBNo+1;
        muNo     := muNo+1;
      elsif L.all(1 to 4) = "OIMD" then
        ReadInputMuon(L, event.intMuons_omtf(muIntONo), event.intSortRanks_omtf(muIntONo), dummyEmpty);
        muIntONo := muIntONo+1;
        muNo     := muNo+1;
      elsif L.all(1 to 4) = "EIMD" then
        ReadInputMuon(L, event.intMuons_emtf(muIntENo), event.intSortRanks_emtf(muIntENo), dummyEmpty);
        muIntENo := muIntENo+1;
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
    file F                 :     text;
    variable iEvent        : in  integer;
    variable event         : out TGMTMuEvent) is
    variable L, L1         : line;
    variable muNo          : integer := 0;
    variable muBmtfNo      : integer := 0;
    variable muOmtfNo      : integer := 0;
    variable muEmtfNo      : integer := 0;
    variable wedgeNo       : integer := 0;
    variable wedgeBmtfNo   : integer := 0;
    variable wedgeOmtfNo   : integer := 0;
    variable wedgeEmtfNo   : integer := 0;
    variable muons         : TGMTMu_vector(107 downto 0);
    variable sortRanks     : TSortRank10_vector(107 downto 0);
    variable emptyBits     : std_logic_vector(107 downto 0);
    variable idxBits       : TIndexBits_vector(107 downto 0);
    variable finId         : string(1 to 3) := "OUT";
    variable bimId         : string(1 to 3) := "BIM";
    variable oimId         : string(1 to 3) := "OIM";
    variable fimId         : string(1 to 3) := "FIM";
    variable dummySrtRnk   : TSortRank10;
    variable dummyEmptyBit : std_logic;
    variable dummyIsoBits  : TIsoBits;
    variable dummyIdxBits  : TIndexBits;
    variable finMuNo       : integer := 0;
    variable intMuBNo      : integer := 0;
    variable intMuONo      : integer := 0;
    variable intMuENo      : integer := 0;
  begin  -- ReadMuEvent

    event.iEvent := iEvent;

    while (muNo < 108) or (wedgeNo < 36) or (finMuNo < 8) or (intMuBNo < 8) or (intMuONo < 8) or (intMuENo < 8) loop
      readline(F, L);

      if L.all'length = 0 then
        next;
      elsif(L.all(1 to 1) = "#") then
        next;
      elsif L.all(1 to 3) = "EVT" then
                                        -- TODO: Parse this maybe?
        next;
      elsif L.all(1 to 4) = "BMTF" then
        ReadInputMuon(L, event.muons_bmtf(muBmtfNo), event.sortRanks_bmtf(muBmtfNo), event.empty_bmtf(muBmtfNo));
        event.idxBits_bmtf(muBmtfNo) := to_unsigned(muNo, 7);
        muBmtfNo                     := muBmtfNo+1;
        muNo                         := muNo+1;
      elsif L.all(1 to 4) = "OMTF" then
        ReadInputMuon(L, event.muons_omtf(muOmtfNo), event.sortRanks_omtf(muOmtfNo), event.empty_omtf(muOmtfNo));
        event.idxBits_omtf(muOmtfNo) := to_unsigned(muNo, 7);
        muOmtfNo                     := muOmtfNo+1;
        muNo                         := muNo+1;
      elsif L.all(1 to 4) = "EMTF" then
        ReadInputMuon(L, event.muons_emtf(muEmtfNo), event.sortRanks_emtf(muEmtfNo), event.empty_emtf(muEmtfNo));
        event.idxBits_emtf(muEmtfNo) := to_unsigned(muNo, 7);
        muEmtfNo                     := muEmtfNo+1;
        muNo                         := muNo+1;
      elsif L.all(1 to 4) = "BTRK" then
        ReadTrack(L, event.tracks_bmtf(wedgeBmtfNo));
        wedgeBmtfNo := wedgeBmtfNo+1;
        wedgeNo     := wedgeNo+1;
      elsif L.all(1 to 4) = "OTRK" then
        ReadTrack(L, event.tracks_omtf(wedgeOmtfNo));
        wedgeOmtfNo := wedgeOmtfNo+1;
        wedgeNo     := wedgeNo+1;
      elsif L.all(1 to 4) = "ETRK" then
        ReadTrack(L, event.tracks_emtf(wedgeEmtfNo));
        wedgeEmtfNo := wedgeEmtfNo+1;
        wedgeNo     := wedgeNo+1;
      elsif L.all(1 to 3) = "OUT" then
        ReadInputMuon(L, finId, event.expectedMuons(finMuNo), dummySrtRnk, dummyEmptyBit, event.expectedIsoBits(finMuNo), dummyIdxBits);
        finMuNo := finMuNo+1;
      elsif L.all(1 to 4) = "BIMD" then
        ReadInputMuon(L, event.expectedIntMuB(intMuBNo), event.expectedSrtRnksB(intMuBNo), dummyEmptyBit);
        intMuBNo := intMuBNo+1;
      elsif L.all(1 to 4) = "OIMD" then
        ReadInputMuon(L, event.expectedIntMuO(intMuONo), event.expectedSrtRnksO(intMuONo), dummyEmptyBit);
        intMuONo := intMuONo+1;
      elsif L.all(1 to 4) = "EIMD" then
        ReadInputMuon(L, event.expectedIntMuE(intMuENo), event.expectedSrtRnksE(intMuENo), dummyEmptyBit);
        intMuENo := intMuENo+1;
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
    variable in_id : string(1 to 4) := "INMU";
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
    variable fin_id          : string(1 to 4)                 := "OUTM";
    variable bmtf_id         : string(1 to 4)                 := "INBM";
    variable omtf_id         : string(1 to 4)                 := "INOM";
    variable emtf_id         : string(1 to 4)                 := "INEM";
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
      DumpMuons(event.intMuons_bmtf, event.intSortRanks_bmtf, FO, bmtf_id);
      DumpMuons(event.intMuons_omtf, event.intSortRanks_omtf, FO, omtf_id);
      DumpMuons(event.intMuons_emtf, event.intSortRanks_emtf, FO, emtf_id);
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
    variable bmtf_id    : string(1 to 4) := "BMTF";
    variable omtf_id    : string(1 to 4) := "OMTF";
    variable emtf_id    : string(1 to 4) := "EMTF";
    variable bmtfTrk_id : string(1 to 4) := "BTRK";
    variable omtfTrk_id : string(1 to 4) := "OTRK";
    variable emtfTrk_id : string(1 to 4) := "ETRK";
  begin  -- DumpMuEvent
    if event.iEvent /= -1 then
      write(L1, string'("++++++++++++++++++++ Dump of event "));
      write(L1, event.iEvent);
      write(L1, string'(": ++++++++++++++++++++"));
      writeline(FO, L1);
      DumpEventMuons(event, FO);

      DumpTracks(event.tracks_bmtf, FO, bmtfTrk_id);
      DumpTracks(event.tracks_omtf, FO, omtfTrk_id);
      DumpTracks(event.tracks_emtf, FO, emtfTrk_id);
    end if;
  end DumpMuEvent;

  procedure DumpEventMuons (
    variable event  : in TGMTMuEvent;
    variable FO     : in text) is
    variable L1     : line;
    variable bmtf_id : string(1 to 4) := "BMTF";
    variable omtf_id : string(1 to 4) := "OMTF";
    variable emtf_id : string(1 to 4) := "EMTF";
  begin -- DumpEventMuons
      if event.iEvent /= -1 then
        write(L1, string'("++++++++++++++++++++ Dump of input muons: "));
        writeline(FO, L1);
        DumpMuons(event.muons_bmtf, event.sortRanks_bmtf, FO, bmtf_id);
        DumpMuons(event.muons_omtf, event.sortRanks_omtf, FO, omtf_id);
        DumpMuons(event.muons_emtf, event.sortRanks_emtf, FO, emtf_id);
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
    variable id        : in string(1 to 4)) is
    variable L1 : line;
  begin  -- DumpMuon
    if iMu.pt = (8 downto 0 => '0') and iMu.phi = (9 downto 0 => '0') and iMu.eta = (8 downto 0 => '0') and iMu.sign = '0' and iMu.sign_valid = '0' and iMu.qual = (3 downto 0 => '0') then
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
    write(L1, to_bit(iMu.sign));
    write(L1, string'(" "));
    write(L1, to_bit(iMu.sign_valid));
    write(L1, string'(" "));
    write(L1, to_integer(iMu.qual));
    -- If we're looking at an input muon the empty bit is of interest.
    if id = string'("INMU") then
        write(L1, string'(" "));
        write(L1, to_bit(iEmpty));
    end if;
    -- For final muons no sort rank information is available and is thus
    -- faked by the testbench. We therefore won't display it.
    if id /= string'("OUTM") then
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
    variable id        : in string(1 to 4)) is
    variable L1 : line;
    variable dummyEmpty : std_logic := '0';
  begin  -- DumpMuon
    DumpMuon(noMu, iMu, iSortRank, dummyEmpty, FO, id);
  end DumpMuon;

  procedure DumpMuons (
    variable iMuons     : in TGMTMu_vector;
    variable iSortRanks : in TSortRank10_vector;
    variable FO         : in text;
    variable id         : in string(1 to 4)) is
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
    variable id         : in string(1 to 4)) is
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
    variable id         : in  string(1 to 4);
    variable FO         : in  text;
    variable error      : out integer) is
    variable LO    : line;
    variable idEmu : string(1 to 4) := "EMUL";
  begin  -- CheckMuon
    error := 0;
    if iMu.phi /= iEmuMu.phi or iMu.eta /= iEmuMu.eta or iMu.pt /= iEmuMu.pt or iMu.sign /= iEmuMu.sign or iMu.sign_valid /= iEmuMu.sign_valid or iMu.qual(3 downto 2) /= iEmuMu.qual(3 downto 2) then
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
    variable id          : in  string(1 to 4);
    variable FO          : in  text;
    variable errors      : out integer) is
    variable LO          : line;
    variable vErrors     : integer := 0;
    variable tmpError    : integer;
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
    variable iMus        : in  TGMTMu_vector;
    variable iEmuMus     : in  TGMTMu_vector;
    variable id          : in  string(1 to 4);
    variable FO          : in  text;
    variable errors      : out integer) is
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
    variable id          : in  string(1 to 4);
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
    variable vErrors         : integer := 0;
  begin
    if iValid_mu /= iValid_energies then
      vErrors := vErrors+1;
      write(L1, string'("!!!!!! Valid bits inconsistent:"));
      writeline(FO, L1);
      DumpValidBits(iValid_mu, iValid_energies, FO);
    end if;

    errors := vErrors;
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
    variable idInMus  : string(1 to 4) := "INMU";
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
    variable idFin    : string(1 to 4) := "FINM";
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
    variable iIntMusE  : in  TGMTMu_vector(7 downto 0);
    variable iSrtRnksB : in  TSortRank10_vector(7 downto 0);
    variable iSrtRnksO : in  TSortRank10_vector(7 downto 0);
    variable iSrtRnksE : in  TSortRank10_vector(7 downto 0);
    variable iEvent    : in  TGMTMuEvent;
    variable FO        : in  text;
    variable error     : out integer) is
    variable LO       : line;
    variable vError   : integer        := 0;
    variable tmpError : integer        := 0;
    variable idFin    : string(1 to 4) := "FINM";
    variable idIntB   : string(1 to 4) := "IMBM";
    variable idIntO   : string(1 to 4) := "IMOM";
    variable idIntE   : string(1 to 4) := "IMEM";
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
      CheckMuons(iIntMusE, iEvent.expectedIntMuE, iSrtRnksE, iEvent.expectedSrtRnksE, idIntE, FO, tmpError);
      vError   := vError + tmpError;

      tmpError := 0;
      CheckSortRanks(iSrtRnksB, iEvent.expectedSrtRnksB, idIntB, FO, tmpError);
      vError   := vError + tmpError;
      tmpError := 0;
      CheckSortRanks(iSrtRnksO, iEvent.expectedSrtRnksO, idIntO, FO, tmpError);
      vError   := vError + tmpError;
      tmpError := 0;
      CheckSortRanks(iSrtRnksE, iEvent.expectedSrtRnksE, idIntE, FO, tmpError);
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
