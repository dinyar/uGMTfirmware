library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
use WORK.GMTTypes.all;
use STD.TEXTIO.all;

package body tb_helpers is

  type TGMTMuEvent is record
    muons_brl     : TGMTMu_vector(35 downto 0);
    muons_ovl     : TGMTMu_vector(35 downto 0);
    muons_fwd     : TGMTMu_vector(35 downto 0);
    tracks_brl    : TGMTMuTracks_vector(11 downto 0);
    tracks_ovl    : TGMTMuTracks_vector(11 downto 0);
    tracks_fwd    : TGMTMuTracks_vector(11 downto 0);
    sortRanks_brl : TSortRank10_vector(35 downto 0);
    sortRanks_ovl : TSortRank10_vector(35 downto 0);
    sortRanks_fwd : TSortRank10_vector(35 downto 0);
    empty_brl     : std_logic_vector(35 downto 0);
    empty_ovl     : std_logic_vector(35 downto 0);
    empty_fwd     : std_logic_vector(35 downto 0);
    idxBits_brl   : TIndexBits_vector(35 downto 0);
    idxBits_ovl   : TIndexBits_vector(35 downto 0);
    idxBits_fwd   : TIndexBits_vector(35 downto 0);
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

  procedure ReadMuEvent (
    file F         :     text;
    variable event : out TGMTMuEvent);

  procedure ReadCaloEvent (
    file F         :     text;
    variable event : out TGMTCaloEvent);

  procedure ReadEvent (
    file F         :     text;
    variable event : out TGMTEvent);

end tb_helpers;

package body tb_helpers is

  procedure ReadInputMuon (
    variable L        : in  line;
    variable muon     : out TGMTMu;
    variable sortRank : out TSortRank10;
    variable emptyBit : out std_logic
    ) is
    variable sysign : integer;
    variable eta    : integer;
    variable qual   : integer;
    variable pt     : integer;
    variable phi    : integer;
    variable rank   : integer;
    variable empty  : bit;
    variable dummy  : string(0 to 3);
  begin  -- ReadInputMuon
    read(L, dummy);

    muon.valid  := '1';
    read(L, sysign);
    muon.sysign := std_logic_vector(to_unsigned(sysign, 2));
    read(L, eta);
    muon.eta    := to_signed(eta, 9);
    read(L, qual);
    muon.qual   := to_unsigned(qual, 4);
    read(L, pt);
    muon.pt     := to_unsigned(pt, 9);
    read(L, phi);
    muon.phi    := to_unsigned(phi, 10);
    read(L, rank);
    sortRank    := std_logic_vector(to_unsigned(rank, 10));
    read(L, empty);
    emptyBit    := to_stdulogic(empty);
  end ReadInputMuon;

  procedure ReadTrack (
    variable L     : in  line;
    variable track : out TGMTMuTracks3) is
    variable eta1, eta2, eta3    : integer;
    variable phi1, phi2, phi3    : integer;
    variable qual1, qual2, qual3 : integer;
    variable dummy               : string(0 to 3);
  begin  -- ReadTrack
    read(L, dummy);

    read(L, eta1);
    track(0).eta  := to_signed(eta1);
    read(L, phi1);
    track(0).phi  := to_unsigned(phi1);
    read(L, qual1);
    track(0).qual := to_unsigned(qual1);

    read(L, eta2);
    track(1).eta  := to_signed(eta2);
    read(L, phi2);
    track(1).phi  := to_unsigned(phi2);
    read(L, qual2);
    track(1).qual := to_unsigned(qual2);

    read(L, eta3);
    track(2).eta  := to_signed(eta3);
    read(L, phi3);
    track(2).phi  := to_unsigned(phi3);
    read(L, qual3);
    track(2).qual := to_unsigned(qual3);
    
  end ReadTrack;

  -- TODO: Add procedure for reading calo inputs.

  procedure ReadMuEvent (
    file F         :     text;
    variable event : out TGMTMuEvent) is
    variable L          : line;
    variable muNo       : integer := 0;
    variable muBrlNo    : integer := 0;
    variable muOvlNo    : integer := 0;
    variable muFwdNo    : integer := 0;
    variable wedgeNo    : integer := 0;
    variable wedgeBrlNo : integer := 0;
    variable wedgeOvlNo : integer := 0;
    variable wedgeFwdNo : integer := 0;
    variable muons      : TGMTMu_vector(107 downto 0);
    variable sortRanks  : TSortRank10_vector(107 downto 0);
    variable emptyBits  : std_logic_vector(107 downto 0);
    variable idxBits    : TIndexBits_vector(107 downto 0);
  begin  -- ReadMuEvent

    while (muNo < 108) or (wedgeNo < 36) loop
      readline(F, L);
      if(L.all(1 to 2) = "--") then
        next;
      end if;

      if L.all(1 to 3) = "BRL" then
        ReadInputMuon(L, event.muons_brl(muBrlNo), event.sortRanks_brl(muBrlNo), event.emptyBits_brl(muBrlNo));
        event.idxBits_brl(muBrlNo) := muNo;
        muBrlNo                    := muBrlNo+1;
      end if;
      if L.all(1 to 3) = "OVL" then
        ReadInputMuon(L, event.muons_ovl(muOvlNo), event.sortRanks_ovl(muOvlNo), event.emptyBits_ovl(muOvlNo));
        event.idxBits_ovl(muOvlNo) := muNo;
        muOvlNo                    := muOvlNo+1;
      end if;
      if L.all(1 to 3) = "FWD" then
        ReadInputMuon(L, event.muons_fwd(muFwdNo), event.sortRanks_fwd(muFwdNo), event.emptyBits_fwd(muFwdNo));
        event.idxBits_fwd(muFwdNo) := muNo;
        muFwdNo                    := muFwdNo+1;
      end if;


      if L.all(1 to 4) = "BTRK" then
        ReadTrack(L, event.tracks_brl(wedgeBrlNo));
        wedgeBrlNo := wedgeBrlNo+1;
      end if;
      if L.all(1 to 4) = "OTRK" then
        ReadTrack(L, event.tracks_ovl(wedgeOvlNo));
        wedgeOvlNo := wedgeOvlNo+1;
      end if;
      if L.all(1 to 4) = "FTRK" then
        ReadTrack(L, event.tracks_fwd(wedgeFwdNo));
        wedgeFwdNo := wedgeFwdNo+1;
      end if;

      if L.all(1 to 3) = "BRL" or L.all(1 to 3) = "OVL" or L.all(1 to 3) = "FWD" then
        muNo := muNo+1;
      elsif L.all(2 to 4) = "TRK" then
        wedgeNo := wedgeNo+1;
      end if;

    end loop;
  end ReadMuEvent;

end tb_helpers;
