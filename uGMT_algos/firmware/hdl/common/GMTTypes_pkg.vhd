library ieee;
use IEEE.NUMERIC_STD.all;
use ieee.std_logic_1164.all;
use STD.TEXTIO.all;

use work.mp7_data_types.all;
use work.ugmt_constants.all;

package GMTTypes is

  type TLutBuf is array (natural range <>) of std_logic_vector(31 downto 0);
  -----------------------------------------------------------------------------
  -- GMT muon at the input to the GMT.
  -----------------------------------------------------------------------------

  type TGMTMuIn is record
    sign       : std_logic;                     -- charge bit (1= plus)
    sign_valid : std_logic;                     -- charge bit valid indicator
    eta        : std_logic_vector(8 downto 0);  -- 9 bit eta
    fine_eta   : std_logic;                     -- BMTF eta was measured fine/coarse
    qual       : std_logic_vector(3 downto 0);  -- 4 bit quality
    pt         : std_logic_vector(8 downto 0);  -- 9 bit pt
    phi        : std_logic_vector(9 downto 0);  -- 10 bit phi
    halo       : std_logic;                     -- EMTF muon travelled parallel to beamline
  end record;

  type    TGMTMuIn_vector is array (integer range <>) of TGMTMuIn;
  subtype TGMTMuIn_wedge is TGMTMuIn_vector (0 to 2);
  type    TGMTMuIn_wedges is array (integer range <>) of TGMTMuIn_wedge;

  -----------------------------------------------------------------------------
  -- GMT muon at the output of the GMT and inside the logic components
  -----------------------------------------------------------------------------
  type TGMTMu is record
    sign       : std_logic;                     -- charge bit (1= plus)
    sign_valid : std_logic;                     -- charge bit valid indicator
    eta        : signed(8 downto 0);            -- 9 bit eta
    fine_eta   : std_logic;                     -- BMTF eta was measured fine/coarse
    qual       : unsigned(3 downto 0);          -- 4 bit quality
    pt         : unsigned(8 downto 0);          -- 9 bit pt
    phi        : unsigned(9 downto 0);          -- 10 bit phi
    halo       : std_logic;                     -- EMTF muon travelled parallel to beamline
  end record;

  type TGMTMu_vector is array (integer range <>) of TGMTMu;

  -----------------------------------------------------------------------------
  -- Information used for ghostbusting (track addresses and/or spatial
  -- coordinates.
  -----------------------------------------------------------------------------

  type TBMTFSectorAddresses is array (2 downto 0) of unsigned(3 downto 0);

  type TBMTFTrackAddress is record
    detectorSide : std_logic_vector(0 downto 0); -- Side of detector
    wheelNo      : unsigned(1 downto 0);  -- 0, 1, or 2

    addressStation0  : unsigned(1 downto 0); -- 1 or 2. 3 for empty
    stationAddresses : TBMTFSectorAddresses; -- 8 to D; 0 to 5. F for empty
  end record;

  type TEMTFChamberIDs is array (4 downto 1) of unsigned(2 downto 0);
  subtype TEMTFChamberSegments is std_logic_vector(4 downto 1);

  type TEMTFTrackAddress is record
    chamberIDs      : TEMTFChamberIDs; -- Chamber ID. 1-6 for ME1; 1-4 for all else. 0 means no segment from this station
    chamberSegments : TEMTFChamberSegments; -- ID of segment from given chamber. Can be 0 or 1.
  end record;

  type TGMTMuTrackInfo is record
    etaFine     : std_logic; -- eta fine bit. 1 = fine eta measurement
    eta         : signed(8 downto 0);
    phi         : signed(7 downto 0);
    bmtfAddress : TBMTFTrackAddress;
    emtfAddress : TEMTFTrackAddress;

    qual  : unsigned(3 downto 0);
    empty : std_logic;
  end record;

  -- Collection of muon tracks
  type    TGMTMuTracks is array (integer range <>) of TGMTMuTrackInfo;
  subtype TGMTMuTracks3 is TGMTMuTracks (2 downto 0);
  type    TGMTMuTracks_vector is array (integer range <>) of TGMTMuTracks3;

  -----------------------------------------------------------------------------
  -- Energy info from calo is stored in rings of 18 segments in phi
  -----------------------------------------------------------------------------
  subtype TCaloRegionEnergy is unsigned (4 downto 0);  -- Energy value for a 2x2
                                                       -- region.
  -- Eta ring of energies.
  type    TCaloRegionEtaSlice is array (integer range <>) of TCaloRegionEnergy;
  -- All eta rings of detector. Two additional rings on each side for
  -- calculation of area energies.
  type    TCaloRegionEtaSlice_vector is array (integer range <>) of TCaloRegionEtaSlice(35 downto 0);

  subtype TCaloStripEnergy is unsigned(7 downto 0);  -- Energy value for strip in
                                                     -- phi
  type    TCaloStripEtaSlice is array (35 downto 0) of TCaloStripEnergy;
  type    TCaloStripEtaSlice_vector is array (27 downto 0) of TCaloStripEtaSlice;

  subtype TCaloAreaEnergy is unsigned (4 downto 0);  -- Energy for a 5x5 regions
                                        -- area around a 2x2 region
  type    TCaloArea_vector is array (integer range <>) of TCaloAreaEnergy;

  -----------------------------------------------------------------------------
  -- Select bits for calorimeter regions
  -----------------------------------------------------------------------------
  type TEtaCaloIdxBit_vector is array (integer range <>) of unsigned(4 downto 0);
  type TPhiCaloIdxBit_vector is array (integer range <>) of unsigned(5 downto 0);

  type TCaloIndexBit is record
    eta : unsigned(4 downto 0);
    phi : unsigned(5 downto 0);
  end record;
  type TCaloIndexBit_vector is array (integer range <>) of TCaloIndexBit;

  type TCaloSelBit is record
    eta : unsigned(0 to 4);
    phi : unsigned(0 to 5);
  end record;
  type TCaloSelBit_vector is array (integer range <>) of TCaloSelBit;

  -----------------------------------------------------------------------------
  -- Vectors describing muon state
  -----------------------------------------------------------------------------

  -- Sort Rank
  subtype TSortRank10 is std_logic_vector (9 downto 0);
  type    TSortRank10_vector is array (integer range <>) of TSortRank10;

  -- Index bits
  subtype TIndexBits is unsigned(0 to 6);  -- Can point at one of 108 muons.
  type    TIndexBits_vector is array (integer range <>) of TIndexBits;

  -- Select bits
  subtype TSelBits_1_of_36 is std_logic_vector(0 to 35);  -- Select bits for
                                                          -- first sorter unit
  type    TSelBits_1_of_36_vec is array (integer range <>) of TSelBits_1_of_36;
  subtype TSelBits_1_of_24 is std_logic_vector(0 to 23);  -- Select bits for
                                                          -- second sorter unit
  type    TSelBits_1_of_24_vec is array (integer range <>) of TSelBits_1_of_24;
  subtype TSelBits_1_of_18 is std_logic_vector(0 to 17);  -- Select bits for
                                                          -- half sorter unit.
  type    TSelBits_1_of_18_vec is array (integer range <>) of TSelBits_1_of_18;

  subtype TCancelBits is std_logic_vector(7 downto 0);
  type    TCancelBits_vec is array (integer range <>) of TCancelBits;

  -- Vector for muons pTs.
  type TMuonPT_vector is array (integer range <>) of unsigned(8 downto 0);

  -- Iso bits
  subtype TIsoBits is std_logic_vector(1 downto 0);
  type    TIsoBits_vector is array (integer range <>) of TIsoBits;

  -----------------------------------------------------------------------------
  -- Addresses used for extrapolation memories
  -----------------------------------------------------------------------------
  type TExtrapolationAddress is array (integer range <>) of std_logic_vector(EXTRAPOLATION_ADDR_WIDTH -1 downto 0);

  -----------------------------------------------------------------------------
  -- Type containing difference between spatial coordinates
  -----------------------------------------------------------------------------
  type TDeltaEta_vector is array (integer range <>) of signed(ETA_EXTRAPOLATION_WORD_SIZE-1 downto 0);
  type TDeltaPhi_vector is array (integer range <>) of unsigned(PHI_EXTRAPOLATION_WORD_SIZE-1 downto 0);

  type TIntermediateEta_vector is array (natural range <>) of signed(8 downto 0);
  type TIntermediatePhi_vector is array (natural range <>) of signed(10 downto 0);

  -----------------------------------------------------------------------------
  -- Extrapolated coordinates at vertex
  -----------------------------------------------------------------------------

  -- Vector for extrapolated coordinatates
  type TPhi_vector is array (integer range <>) of unsigned(9 downto 0);
  type TEta_vector is array (integer range <>) of signed(8 downto 0);

  type TExtrapolatedPhi_link is array (natural range <>) of TPhi_vector(NUM_MUONS_IN-1 downto 0);
  type TExtrapolatedEta_link is array (natural range <>) of TEta_vector(NUM_MUONS_IN-1 downto 0);

  type TSpatialCoordinate is record
    eta : signed(8 downto 0);
    phi : unsigned(9 downto 0);
  end record;
  type TSpatialCoordinate_vector is array (integer range <>) of TSpatialCoordinate;

  -----------------------------------------------------------------------------
  -- Vectors to store cancel bits
  -----------------------------------------------------------------------------
  type TCancelWedge is array (integer range <>) of std_logic_vector(2 downto 0);

  -----------------------------------------------------------------------------
  -- Types for Transceivers
  -----------------------------------------------------------------------------
  type TQuadTransceiverBufferIn is array (2*NUM_MUONS_IN-1 downto 0) of ldata(3 downto 0);

  -- Contains only the data words received from the links
  type TDataBuffer is array (natural range <>) of std_logic_vector(31 downto 0);

  -----------------------------------------------------------------------------
  -- Types for link format.
  -----------------------------------------------------------------------------
  subtype TFlatMuon is std_logic_vector(63 downto 0);
  -- Contains muons from one link.
  type    TFlatMuon_link is array (NUM_MUONS_IN-1 downto 0) of TFlatMuon;
  -- Contains muons from all links.
  type    TFlatMuons is array (natural range <>) of TFlatMuon_link;
  -- Contains flat muons inside a simple vector
  type    TFlatMuon_vector is array (natural range <>) of TFlatMuon;

  -- global phi values from one frame for all links in a quad
  type TGlobalPhi_frame is array (natural range <>) of unsigned(9 downto 0);
  type TGlobalPhiFrameBuffer is array (2*NUM_MUONS_IN-1 downto 0) of TGlobalPhi_frame(3 downto 0);
  -- Contains phi values from one link.
  type TGlobalPhi_link is array (NUM_MUONS_IN-1 downto 0) of unsigned(9 downto 0);
  -- Contains global phi values from a full event (4 links, 6 frames)
  type TGlobalPhi_event is array (3 downto 0) of TGlobalPhi_link;
  -- Contains the global phi values in a simple vector
  type TGlobalPhi_vector is array (natural range <>) of unsigned(9 downto 0);

  -- Empty bits for muons from one link for one BX.
  type TEmpty_link is array (natural range <>) of std_logic_vector(NUM_MUONS_IN-1 downto 0);

  type TIndexBits_link is array (natural range <>) of TIndexBits_vector(NUM_MUONS_IN-1 downto 0);

  type TSortRank_link is array (natural range <>) of TSortRank10_vector(NUM_MUONS_IN-1 downto 0);

  type TCaloIndexBits_link is array (natural range <>) of TCaloIndexBit_vector(NUM_MUONS_IN-1 downto 0);

  -- Valid bits for words from one link for one BX.
  type TValid_link is array (natural range <>) of std_logic_vector(2*NUM_MUONS_IN-1 downto 0);

  function unroll_link_muons (signal iMuons_link      : TFlatMuons) return TFlatMuon_vector;
  function unroll_global_phi (signal iGlobalPhi_event : TGlobalPhi_event) return TGlobalPhi_vector;
  function gmt_mu_from_in_mu (signal iMuonIn          : TGMTMuIn) return TGMTMu;
  function calo_etaslice_from_flat (constant flat     : std_logic_vector) return TCaloRegionEtaSlice;
  function combine_or (or_vec                         : std_logic_vector) return std_logic;
  function check_valid_bits (signal iValid_link       : TValid_link) return std_logic;
  function unpack_idx_bits(signal iIdxBits            : TIndexBits_link) return TIndexBits_vector;
  function unpack_sort_rank(signal iSortRanks         : TSortRank_link) return TSortRank10_vector;
  function unpack_calo_idx_bits(signal iCaloIdxBits   : TCaloIndexBits_link) return TCaloIndexBit_vector;
  function apply_global_phi_wraparound(iPhi           : signed(10 downto 0)) return unsigned;

  function track_address_from_bmtf_mus(signal iMuon_flat : TFlatMuon;
                                       signal iEmpty     : std_logic) return TGMTMuTrackInfo;
  function track_address_from_omtf_mus(signal iMuon_flat : TFlatMuon;
                                       signal iEmpty     : std_logic) return TGMTMuTrackInfo;
  function track_address_from_emtf_mus(signal iMuon_flat : TFlatMuon;
                                       signal iEmpty     : std_logic) return TGMTMuTrackInfo;

  function add_offset_to_local_phi(signal iLocalPhi : std_logic_vector(7 downto 0);
                       signal iOffset   : unsigned(9 downto 0)) return signed;

  function unpack_bmtf_mu_from_flat(signal iMuon_flat : TFlatMuon;
                                    signal iPhi       : unsigned(9 downto 0)) return TGMTMuIn;
  function unpack_omtf_mu_from_flat(signal iMuon_flat : TFlatMuon;
                                    signal iPhi       : unsigned(9 downto 0)) return TGMTMuIn;
  function unpack_emtf_mu_from_flat(signal iMuon_flat : TFlatMuon;
                                    signal iPhi       : unsigned(9 downto 0)) return TGMTMuIn;

  function unpack_extrapolated_phi (signal iPhi : TExtrapolatedPhi_link) return TPhi_vector;
  function unpack_extrapolated_eta (signal iEta : TExtrapolatedEta_link) return TEta_vector;

  function pack_mu_to_flat(signal iMuon      : TGMTMu;
                           signal iPhi       : unsigned(9 downto 0);
                           signal iEta       : signed(8 downto 0);
                           signal iMuIdxBits : TIndexBits;
                           signal iIso       : TIsoBits) return TFlatMuon;
end;


package body GMTTypes is

  -----------------------------------------------------------------------------
  -- Energy info from calo
  -----------------------------------------------------------------------------

  --
  -- unpack
  --

  function calo_etaslice_from_flat (
    constant flat : std_logic_vector)   -- input from calorimeter trigger
    return TCaloRegionEtaSlice is
    variable oEnergies : TCaloRegionEtaSlice(35 downto 0);
  begin
    for i in oEnergies'range loop
      oEnergies(i) := unsigned(flat(i*5+4 downto i*5));
    end loop;  -- i
    return oEnergies;
  end function calo_etaslice_from_flat;

  -----------------------------------------------------------------------------
  -- Cancel-out information for each wedge.
  -----------------------------------------------------------------------------
  function track_address_from_in_mus (
    signal   iMuon_flat   : TFlatMuon;
    signal   iEmpty       : std_logic;
    iBmtfAddress          : TBMTFTrackAddress;
    iEmtfAddress          : TEMTFTrackAddress;
    signal   iEtaFine     : std_logic)
    return   TGMTMuTrackInfo is
    variable oTrack : TGMTMuTrackInfo;
  begin
      oTrack.etaFine := iEtaFine;
      oTrack.eta     := signed(iMuon_flat(ETA_IN_HIGH downto ETA_IN_LOW));
      oTrack.phi     := signed(iMuon_flat(PHI_IN_HIGH downto PHI_IN_LOW));

      oTrack.bmtfAddress := iBmtfAddress;
      oTrack.emtfAddress := iEmtfAddress;

      oTrack.qual  := unsigned(iMuon_flat(QUAL_IN_HIGH downto QUAL_IN_LOW));
      oTrack.empty := iEmpty;
    return oTrack;
  end;

  function track_address_from_bmtf_mus (
    signal iMuon_flat : TFlatMuon;
    signal iEmpty     : std_logic)
    return TGMTMuTrackInfo is
    variable vBmtfAddress : TBMTFTrackAddress;
    variable vEmtfAddress : TEMTFTrackAddress;
    variable oTrack       : TGMTMuTrackInfo;
  begin
    vBmtfAddress.addressStation0 := unsigned(iMuon_flat(BMTF_ADDRESS_STATION_1_IN_HIGH downto BMTF_ADDRESS_STATION_1_IN_LOW));

    vBmtfAddress.stationAddresses(0) := unsigned(iMuon_flat(BMTF_ADDRESS_STATION_2_IN_HIGH downto BMTF_ADDRESS_STATION_2_IN_LOW));
    vBmtfAddress.stationAddresses(1) := unsigned(iMuon_flat(BMTF_ADDRESS_STATION_3_IN_HIGH downto BMTF_ADDRESS_STATION_3_IN_LOW));
    vBmtfAddress.stationAddresses(2) := unsigned(iMuon_flat(BMTF_ADDRESS_STATION_4_IN_HIGH downto BMTF_ADDRESS_STATION_4_IN_LOW));

    vBmtfAddress.detectorSide := iMuon_flat(BMTF_DETECTOR_SIDE_HIGH downto BMTF_DETECTOR_SIDE_LOW);
    vBmtfAddress.wheelNo      := unsigned(iMuon_flat(BMTF_WHEEL_NO_IN_HIGH downto BMTF_WHEEL_NO_IN_LOW));

    vEmtfAddress.chamberIDs      := (others => (others => '0'));
    vEmtfAddress.chamberSegments := (others => '0');

    oTrack := track_address_from_in_mus(iMuon_flat, iEmpty, vBmtfAddress, vEmtfAddress, iMuon_flat(HALO_FINE_IN));

    return oTrack;
  end;

  function track_address_from_omtf_mus (
    signal iMuon_flat : TFlatMuon;
    signal iEmpty     : std_logic)
    return TGMTMuTrackInfo is
    variable vBmtfAddress : TBMTFTrackAddress;
    variable vEmtfAddress : TEMTFTrackAddress;
    variable oTrack       : TGMTMuTrackInfo;
  begin
    vBmtfAddress.addressStation0 := (others => '0');

    vBmtfAddress.stationAddresses(0) := (others => '0');
    vBmtfAddress.stationAddresses(1) := (others => '0');
    vBmtfAddress.stationAddresses(2) := (others => '0');

    vBmtfAddress.detectorSide := (others => '0');
    vBmtfAddress.wheelNo      := (others => '0');

    vEmtfAddress.chamberIDs      := (others => (others => '0'));
    vEmtfAddress.chamberSegments := (others => '0');

    oTrack := track_address_from_in_mus(iMuon_flat, iEmpty, vBmtfAddress, vEmtfAddress, iMuon_flat(HALO_FINE_IN));

    return oTrack;
  end;

  function track_address_from_emtf_mus (
    signal iMuon_flat : TFlatMuon;
    signal iEmpty     : std_logic)
    return TGMTMuTrackInfo is
    variable vBmtfAddress : TBMTFTrackAddress;
    variable vEmtfAddress : TEMTFTrackAddress;
    variable oTrack       : TGMTMuTrackInfo;
  begin
    vBmtfAddress.addressStation0 := (others => '0');

    vBmtfAddress.stationAddresses(0) := (others => '0');
    vBmtfAddress.stationAddresses(1) := (others => '0');
    vBmtfAddress.stationAddresses(2) := (others => '0');

    vBmtfAddress.detectorSide := (others => '0');
    vBmtfAddress.wheelNo      := (others => '0');

    vEmtfAddress.chamberIDs(1)      := unsigned(iMuon_flat(EMTF_ME1_CHAMBER_ID_IN_HIGH downto EMTF_ME1_CHAMBER_ID_IN_LOW));
    vEmtfAddress.chamberIDs(2)      := unsigned(iMuon_flat(EMTF_ME2_CHAMBER_ID_IN_HIGH downto EMTF_ME2_CHAMBER_ID_IN_LOW));
    vEmtfAddress.chamberIDs(3)      := unsigned(iMuon_flat(EMTF_ME3_CHAMBER_ID_IN_HIGH downto EMTF_ME3_CHAMBER_ID_IN_LOW));
    vEmtfAddress.chamberIDs(4)      := unsigned(iMuon_flat(EMTF_ME4_CHAMBER_ID_IN_HIGH downto EMTF_ME4_CHAMBER_ID_IN_LOW));
    vEmtfAddress.chamberSegments(1) := iMuon_flat(EMTF_ME1_SEGMENT_ID_IN);
    vEmtfAddress.chamberSegments(2) := iMuon_flat(EMTF_ME2_SEGMENT_ID_IN);
    vEmtfAddress.chamberSegments(3) := iMuon_flat(EMTF_ME3_SEGMENT_ID_IN);
    vEmtfAddress.chamberSegments(4) := iMuon_flat(EMTF_ME4_SEGMENT_ID_IN);

    oTrack := track_address_from_in_mus(iMuon_flat, iEmpty, vBmtfAddress, vEmtfAddress, iMuon_flat(HALO_FINE_IN));

    return oTrack;
  end;


  -----------------------------------------------------------------------------
  -- Unpack input muons.
  -----------------------------------------------------------------------------

  function unroll_link_muons (
    signal iMuons_link : TFlatMuons)
    return TFlatMuon_vector is
    variable oMuons_flat : TFlatMuon_vector(iMuons_link'length*iMuons_link(0)'length-1 downto 0);
  begin
    for i in iMuons_link'range loop
      for j in iMuons_link(i)'range loop
        oMuons_flat(i*iMuons_link(i)'length+j) := iMuons_link(i+iMuons_link'low)(j+iMuons_link(i)'low);
      end loop;  -- j
    end loop;  -- i

    return oMuons_flat;
  end;

  function unroll_global_phi (
    signal iGlobalPhi_event : TGlobalPhi_event)
    return TGlobalPhi_vector is
    variable oGlobalPhi_flat : TGlobalPhi_vector(iGlobalPhi_event'length*iGlobalPhi_event(0)'length-1 downto 0);
  begin
    for i in iGlobalPhi_event'range loop
      for j in iGlobalPhi_event(i)'range loop
        oGlobalPhi_flat(i*iGlobalPhi_event(i)'length+j) := iGlobalPhi_event(i+iGlobalPhi_event'low)(j+iGlobalPhi_event(i)'low);
      end loop;  -- j
    end loop;  -- j

    return oGlobalPhi_flat;
  end;

  function unpack_mu_from_flat (
    signal iMuon_flat : TFlatMuon;
    signal iPhi       : unsigned(9 downto 0);
    constant etaFine    : std_logic;
    constant haloMuon   : std_logic)
    return TGMTMuIn is
    variable oMuon : TGMTMuIn;
  begin
    oMuon.sign        := iMuon_flat(SIGN_IN);
    oMuon.sign_valid  := iMuon_flat(VALIDSIGN_IN);
    oMuon.eta         := iMuon_flat(ETA_IN_HIGH downto ETA_IN_LOW);
    oMuon.fine_eta    := etaFine;
    oMuon.qual        := iMuon_flat(QUAL_IN_HIGH downto QUAL_IN_LOW);
    oMuon.pt          := iMuon_flat(PT_IN_HIGH downto PT_IN_LOW);
    oMuon.phi         := std_logic_vector(iPhi);
    oMuon.halo        := haloMuon;
    return oMuon;
  end;

  function unpack_bmtf_mu_from_flat (
    signal iMuon_flat : TFlatMuon;
    signal iPhi       : unsigned(9 downto 0))
    return TGMTMuIn is
    constant dummyHalo : std_logic := '0';
    variable oMuon     : TGMTMuIn;
  begin
    return unpack_mu_from_flat(iMuon_flat, iPhi, iMuon_flat(HALO_FINE_IN), dummyHalo);
  end;


  function unpack_omtf_mu_from_flat (
    signal iMuon_flat : TFlatMuon;
    signal iPhi       : unsigned(9 downto 0))
    return TGMTMuIn is
    constant dummyFine : std_logic := '1';
    constant dummyHalo : std_logic := '0';
    variable oMuon     : TGMTMuIn;
  begin
    return unpack_mu_from_flat(iMuon_flat, iPhi, dummyFine, dummyHalo);
  end;

  function unpack_emtf_mu_from_flat (
    signal iMuon_flat : TFlatMuon;
    signal iPhi       : unsigned(9 downto 0))
    return TGMTMuIn is
    constant dummyFine : std_logic := '1';
    variable oMuon : TGMTMuIn;
  begin
    return unpack_mu_from_flat(iMuon_flat, iPhi, dummyFine, iMuon_flat(HALO_FINE_IN));
  end;

  -----------------------------------------------------------------------------
  -- Pack output muons.
  -----------------------------------------------------------------------------

  function pack_mu_to_flat (
    signal iMuon      : TGMTMu;
    signal iPhi       : unsigned(9 downto 0);
    signal iEta       : signed(8 downto 0);
    signal iMuIdxBits : TIndexBits;
    signal iIso       : TIsoBits)
    return TFlatMuon is
    variable oMuon_flat : TFlatMuon;
  begin  -- pack_mu_to_flat
    oMuon_flat(oMuon_flat'high downto PHI_EXTRAPOLATED_HIGH+1)    := (others => '0');
    oMuon_flat(PHI_EXTRAPOLATED_HIGH downto PHI_EXTRAPOLATED_LOW) := std_logic_vector(iPhi);
    oMuon_flat(ETA_EXTRAPOLATED_HIGH downto ETA_EXTRAPOLATED_LOW) := std_logic_vector(iEta);
    oMuon_flat(IDX_OUT_HIGH downto IDX_OUT_LOW)                   := std_logic_vector(iMuIdxBits);
    oMuon_flat(SIGN_OUT)                                          := iMuon.sign;
    oMuon_flat(VALIDSIGN_OUT)                                     := iMuon.sign_valid;
    oMuon_flat(ISO_OUT_HIGH downto ISO_OUT_LOW)                   := iIso;
    oMuon_flat(ETA_OUT_HIGH downto ETA_OUT_LOW)                   := std_logic_vector(iMuon.eta);
    if iMuon.halo = '0' then
      oMuon_flat(QUAL_OUT_HIGH downto QUAL_OUT_LOW)               := std_logic_vector(iMuon.qual(3 downto 2)) & "00";
    else
      oMuon_flat(QUAL_OUT_HIGH downto QUAL_OUT_LOW)               := "1111";
    end if;
    oMuon_flat(PT_OUT_HIGH downto PT_OUT_LOW)                     := std_logic_vector(iMuon.pt);
    oMuon_flat(PHI_OUT_HIGH downto PHI_OUT_LOW)                   := std_logic_vector(iMuon.phi);
    return oMuon_flat;
  end pack_mu_to_flat;

  -----------------------------------------------------------------------------
  -- Convert input muons to GMT muons.
  -----------------------------------------------------------------------------
  function gmt_mu_from_in_mu (
    signal iMuonIn : TGMTMuIn)
    return TGMTMu is
    variable oMuon : TGMTMu;
  begin  -- gmt_mu_from_in_mu
    oMuon.sign       := iMuonIn.sign;
    oMuon.sign_valid := iMuonIn.sign_valid;
    oMuon.eta        := signed(iMuonIn.eta);
    oMuon.fine_eta   := iMuonIn.fine_eta;
    oMuon.qual       := unsigned(iMuonIn.qual);
    oMuon.pt         := unsigned(iMuonIn.pt);
    oMuon.phi        := unsigned(iMuonIn.phi);
    oMuon.halo       := iMuonIn.halo;
    return oMuon;
  end gmt_mu_from_in_mu;

  function add_offset_to_local_phi (
    signal iLocalPhi : std_logic_vector(7 downto 0);
    signal iOffset   : unsigned(9 downto 0))
    return signed is
    variable vPhiOffsetSigned : signed(10 downto 0);
    variable oPhi             : signed(10 downto 0);
  begin  -- add_offset_to_local_phi
    vPhiOffsetSigned := signed(resize(iOffset, 11));
    oPhi             := vPhiOffsetSigned + signed(iLocalPhi);

    return oPhi;
  end add_offset_to_local_phi;

  function apply_global_phi_wraparound (
    iPhi : signed(10 downto 0))
    return unsigned is
    variable oPhi : unsigned(9 downto 0);
  begin  -- apply_global_phi_wraparound
    if (iPhi >= 0) and (iPhi < MAX_PHI_VAL) then
      oPhi := resize(unsigned(iPhi), 10);
    elsif (iPhi < 0) then
      oPhi := resize(unsigned(MAX_PHI_VAL+iPhi), 10);
    elsif (iPhi >= MAX_PHI_VAL) then
      oPhi := resize(unsigned(iPhi-MAX_PHI_VAL), 10);
    else
      oPhi := to_unsigned(1023, 10);
    end if;

    return oPhi;
  end apply_global_phi_wraparound;

  -----------------------------------------------------------------------------
  -- Unpack valid bits
  -----------------------------------------------------------------------------
  function combine_or (
    or_vec : std_logic_vector)
    return std_logic is
    variable tmpVar : std_logic := '0';
  begin  -- combine_or
    for i in or_vec'range loop
      tmpVar := tmpVar or or_vec(i);
    end loop;  -- i

    return tmpVar;
  end combine_or;

  function check_valid_bits (
    signal iValid_link : TValid_link)
    return std_logic is
    variable or_vec : std_logic_vector(2*NUM_MUONS_IN-1 downto 0);
    variable oValid : std_logic := '0';
  begin  -- check_valid_bits
    for i in iValid_link'range loop
      or_vec := iValid_link(i);
      oValid := oValid or combine_or(or_vec);
    end loop;  -- i

    return oValid;
  end check_valid_bits;

-----------------------------------------------------------------------------
-- Unpack index bits.
-----------------------------------------------------------------------------
  function unpack_idx_bits (
    signal iIdxBits : TIndexBits_link)
    return TIndexBits_vector is
    variable oIdxBits : TIndexBits_vector(iIdxBits'length*NUM_MUONS_LINK-1 downto 0);
  begin  -- unpack_idx_bits
    for i in iIdxBits'range loop
      for j in iIdxBits(i)'range loop
        oIdxBits(i*iIdxBits(i)'length+j) := iIdxBits(i)(j);
      end loop;  -- j
    end loop;  -- i

    return oIdxBits;
  end unpack_idx_bits;

-----------------------------------------------------------------------------
-- Unpack sort ranks.
-----------------------------------------------------------------------------

  function unpack_sort_rank (
    signal iSortRanks : TSortRank_link)
    return TSortRank10_vector is
    variable oSortRanks : TSortRank10_vector(iSortRanks'length*NUM_MUONS_LINK-1 downto 0);
  begin  -- unpack_sort_rank
    for i in iSortRanks'range loop
      for j in iSortRanks(i)'range loop
        oSortRanks(i*iSortRanks(i)'length+j) := iSortRanks(i)(j);
      end loop;  -- j
    end loop;  -- i
    return oSortRanks;
  end unpack_sort_rank;

  function unpack_calo_idx_bits (
    signal iCaloIdxBits : TCaloIndexBits_link)
    return TCaloIndexBit_vector is
    variable oCaloIdxBits : TCaloIndexBit_vector(iCaloIdxBits'length*NUM_MUONS_LINK-1 downto 0);
  begin  -- unpack_calo_idx_bits
    for i in iCaloIdxBits'range loop
      for j in iCaloIdxBits(i)'range loop
        oCaloIdxBits(i*iCaloIdxBits(i)'length+j) := iCaloIdxBits(i)(j);
      end loop;  -- j
    end loop;  -- i
    return oCaloIdxBits;
  end unpack_calo_idx_bits;

  function unpack_extrapolated_phi (
    signal iPhi : TExtrapolatedPhi_link)
    return TPhi_vector is
    variable oPhi : TPhi_vector(iPhi'length*NUM_MUONS_LINK-1 downto 0);
  begin  -- unpack_extrapolated_phi
    for i in iPhi'range loop
      for j in iPhi(i)'range loop
        oPhi(i*iPhi(i)'length+j) := iPhi(i)(j);
      end loop;  -- j
    end loop;  -- i
    return oPhi;
  end unpack_extrapolated_phi;

  function unpack_extrapolated_eta (
    signal iEta : TExtrapolatedEta_link)
    return TEta_vector is
    variable oEta : TEta_vector(iEta'length*NUM_MUONS_LINK-1 downto 0);
  begin  -- unpack_extrapolated_eta
    for i in iEta'range loop
      for j in iEta(i)'range loop
        oEta(i*iEta(i)'length+j) := iEta(i)(j);
      end loop;  -- j
    end loop;  -- i
    return oEta;
  end unpack_extrapolated_eta;


end GMTTypes;
