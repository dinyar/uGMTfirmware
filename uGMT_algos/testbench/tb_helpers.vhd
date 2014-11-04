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
    variable L : line;
  begin  -- ReadMuEvent

    for fwd_mu in 17 downto 0 loop
      ReadInputMuon(L, event.muons_fwd(fwd_mu), event.sortRanks_fwd(fwd_mu), event.emptyBits_fwd(fwd_mu));
      event.idxBits_fwd(fwd_mu) := fwd_mu;
    end loop;  -- fwd_mu
    for ovl_mu in 17 downto 0 loop
      ReadInputMuon(L, event.muons_ovl(ovl_mu), event.sortRanks_ovl(ovl_mu), event.emptyBits_ovl(ovl_mu));
      event.idxBits_ovl(ovl_mu) := 18+ovl_mu;
    end loop;  -- ovl_mu
    for brl_mu in 35 downto 0 loop
      ReadInputMuon(L, event.muons_brl(brl_mu), event.sortRanks_brl(brl_mu), event.emptyBits_brl(brl_mu));
      event.idxBits_brl(brl_mu) := 36+brl_mu;
    end loop;  -- brl_mu
    for ovl_mu in 17 downto 0 loop
      ReadInputMuon(L, event.muons_ovl(ovl_mu), event.sortRanks_ovl(ovl_mu), event.emptyBits_ovl(ovl_mu));
      event.idxBits_ovl(ovl_mu) := 72+ovl_mu;
    end loop;  -- ovl_mu
    for fwd_mu in 17 downto 0 loop
      ReadInputMuon(L, event.muons_fwd(fwd_mu), event.sortRanks_fwd(fwd_mu), event.emptyBits_fwd(fwd_mu));
      event.idxBits_fwd(fwd_mu) := 90+fwd_mu;
    end loop;  -- fwd_mu

  end ReadMuEvent;
  
end tb_helpers;
