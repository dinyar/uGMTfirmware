library ieee;
use IEEE.NUMERIC_STD.all;
use ieee.std_logic_1164.all;
use STD.TEXTIO.all;

package GMTTypes is

  -- Cancel-out information at station level
  type TMuonAddress is array (0 to 3) of std_logic_vector(0 to 9);
--  type TMuonAddress_vector is array (integer range <>) of TMuonAddress;

  -----------------------------------------------------------------------------
  -- GMT muon at the input to the GMT.
  -----------------------------------------------------------------------------
  type TGMTMuIn is record
    sysign  : std_logic_vector(1 downto 0);  -- charge bit (1= plus)
    address : TMuonAddress;                  -- 4x10 bit for track addresses
    eta     : std_logic_vector(8 downto 0);  -- 9 bit eta
    qual    : std_logic_vector(3 downto 0);  -- 4 bit quality
    pt      : std_logic_vector(8 downto 0);  -- 9 bit pt
    phi     : std_logic_vector(9 downto 0);  -- 10 bit phi
  end record;

  type    TGMTMuIn_vector is array (integer range <>) of TGMTMuIn;
  subtype TGMTMuIn_wedge is TGMTMuIn_vector (0 to 2);
  type    TGMTMuIn_wedges is array (integer range <>) of TGMTMuIn_wedge;

  -------------------------------------------------------------------------------
  -- GMT muon at the output of the GMT and inside the logic components
  -------------------------------------------------------------------------------
  type TGMTMu is record
    sysign : std_logic_vector(1 downto 0);  -- charge bit (1= plus)
    isol   : std_logic;
    eta    : signed(8 downto 0);            -- 9 bit eta
    qual   : unsigned(3 downto 0);          -- 4 bit quality
    pt     : unsigned(8 downto 0);          -- 9 bit pt
    phi    : unsigned(9 downto 0);          -- 10 bit phi
  end record;

  type TGMTMu_vector is array (integer range <>) of TGMTMu;

  -----------------------------------------------------------------------------
  -- GMT muon as above, but from RPC system
  -----------------------------------------------------------------------------
  type TGMTMuRPC is record
    sysign    : std_logic_vector(1 downto 0);  -- charge bit(1= plus)
    -- Values as in the legacy system.
    eta_comp  : signed(5 downto 0);            -- 6 bit eta
    qual_comp : unsigned(2 downto 0);          -- 3 bit quality
    pt_comp   : unsigned(4 downto 0);          -- 5 bit pT
    phi_comp  : unsigned(7 downto 0);          -- 8 bit phi
    -- Values converted to new (linear) scale.
    eta       : signed(8 downto 0);            -- 9 bit eta
    qual      : unsigned(3 downto 0);          -- 4 bit quality
    pt        : unsigned(9 downto 0);          -- 10 bit pt
    phi       : unsigned(9 downto 0);          -- 10 bit phi
  end record;

  type TGMTMuRPC_vector is array (integer range <>) of TGMTMuRPC;

  -----------------------------------------------------------------------------
  -- Information used for ghostbusting (track addresses and/or spatial
  -- coordinates.
  -----------------------------------------------------------------------------
  type TGMTMuTrackInfo is record
    eta : signed(8 downto 0);
    phi : unsigned(9 downto 0);
    --address : TMuonAddress;

    qual : unsigned(3 downto 0);
  end record;

  -- Collection of muon tracks
  type    TGMTMuTracks is array (integer range <>) of TGMTMuTrackInfo;
  subtype TGMTMuTracks3 is TGMTMuTracks (0 to 2);
  type    TGMTMuTracks_vector is array (integer range <>) of TGMTMuTracks3;

  -----------------------------------------------------------------------------
  -- Energy info from calo is stored in rings of 18 segments in phi
  -----------------------------------------------------------------------------
  subtype TCaloRegionEnergy is unsigned (0 to 4);  -- Energy value for a 2x2
                                                   -- region.
  -- Eta ring of energies.
  type    TCaloRegionEtaSlice is array (integer range <>) of TCaloRegionEnergy;
  -- All eta rings of detector. Two additional rings on each side for
  -- calculation of area energies.
  type    TCaloRegionEtaSlice_vector is array (integer range <>) of TCaloRegionEtaSlice(35 downto 0);
  function CaloEtaSlice_vec_from_flat (signal flat : std_logic_vector) return TCaloRegionEtaSlice_vector;

  subtype TCaloStripEnergy is unsigned(0 to 7);  -- Energy value for strip in
                                                 -- phi
  type    TCaloStripEtaSlice is array (0 to 35) of TCaloStripEnergy;
  type    TCaloStripEtaSlice_vector is array (0 to 27) of TCaloStripEtaSlice;

  subtype TCaloAreaEnergy is unsigned (0 to 9);  -- Energy for a 5x5 regions
                                                 -- area around a 2x2 region
  type    TCaloArea_vector is array (integer range <>) of TCaloAreaEnergy;

  -----------------------------------------------------------------------------
  -- Extrapolated coordinates at vertex
  -----------------------------------------------------------------------------
  type TSpatialCoordinate is record
    eta : signed(0 to 8);
    phi : unsigned(0 to 9);
  end record;
  type TSpatialCoordinate_vector is array (integer range <>) of TSpatialCoordinate;

  -----------------------------------------------------------------------------
  -- Select bits for calorimeter regions
  -----------------------------------------------------------------------------
  type TCaloSelBit is record
    eta : unsigned(0 to 4);
    phi : unsigned(0 to 5);
  end record;
  type TCaloSelBit_vector is array (integer range <>) of TCaloSelBit;

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
  subtype TSelBits_1_of_32 is std_logic_vector(0 to 31);  -- Select bits for
                                                          -- second sorter unit
                                                          -- when using RPCs
  type    TSelBits_1_of_32_vec is array (integer range <>) of TSelBits_1_of_32;
  subtype TSelBits_1_of_24 is std_logic_vector(0 to 23);  -- Select bits for
                                                          -- second sorter unit
  type    TSelBits_1_of_24_vec is array (integer range <>) of TSelBits_1_of_24;
  subtype TSelBits_1_of_18 is std_logic_vector(0 to 17);  -- Select bits for
                                                          -- half sorter unit.
  type    TSelBits_1_of_18_vec is array (integer range <>) of TSelBits_1_of_18;
  subtype TSelBits_1_of_16 is std_logic_vector(0 to 15);  -- Select bits for
                                                          -- matching unit.
  type    TSelBits_1_of_16_vec is array (integer range <>) of TSelBits_1_of_16;

  subtype TPairIndex is unsigned(7 downto 0);
  -- Vector which holds indices of TF muons to be merged with Nth RPC muon.
  type    TPairVector is array (integer range <>) of TPairIndex;

  -- Match Quality Matrix:
  subtype TMatchQual is unsigned(3 downto 0);
  type    TMQMatrix is array (integer range 0 to 3, integer range 0 to 71) of TMatchQual;
  type    TMQMatrix_vec is array (integer range<>) of TMQMatrix;

  subtype TCancelBits is std_logic_vector(0 to 7);
  type    TCancelBits_vec is array (integer range <>) of TCancelBits;

  -- Stuff for muon merging.
  type TRowColIndex_vector is array (integer range <>) of unsigned(6 downto 0);

end;


package body GMTTypes is

  -------------------------------------------------------------------------------
  -- Energy info from calo
  -------------------------------------------------------------------------------

  --
  -- unpack
  --
  function CaloEtaSlice_vec_from_flat (
    signal flat : std_logic_vector)     -- input from calorimeter trigger
    return TCaloRegionEtaSlice_vector is
    variable vec : TCaloRegionEtaSlice_vector(31 downto 0);
  begin
    for i in vec'range loop
      for j in vec(i)'range loop
        vec(i)(j) := unsigned(flat((i*215)+(j*5) to (i*215)+(j*5)+4));
      end loop;  -- j
    end loop;  -- i
    return vec;
  end function CaloEtaSlice_vec_from_flat;

end GMTTypes;
