library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use work.ipbus_reg_types.all;

package ugmt_constants is

  -- Start and end positions for buffers for outputs.
  constant BUFFER_OUT_MU_POS_HIGH        : natural := 5;
  constant BUFFER_OUT_MU_POS_LOW         : natural := 0;
  constant BUFFER_INTERMEDIATES_POS_HIGH : natural := 11;
  constant BUFFER_INTERMEDIATES_POS_LOW  : natural := 6;


  constant NUM_MU_CHANS                : integer := 36;  -- Number of channels for input muons.
  constant NUM_CALO_CHANS              : integer := 28;  -- Number of channels for energy sums.
  constant NUM_IN_CHANS                : integer := NUM_MU_CHANS+NUM_CALO_CHANS;  -- Number of input channels
  constant NUM_OUT_CHANS               : integer := 4;  -- Number of channels to GT.
  constant NUM_INTERM_MU_OUT_CHANS     : integer := 8;  -- Number of channels
                                        -- used for intermediate
                                        -- muons.
  constant NUM_INTERM_SRT_OUT_CHANS    : integer := 2;  -- Number of channels
                                                        -- used for interm.
                                                        -- sort ranks.
  constant NUM_INTERM_ENERGY_OUT_CHANS : integer := 1;  -- Number of channels
                                                        -- used for interm.
                                                        -- energies.
  constant NUM_EXTRAP_COORDS_OUT_CHANS : integer := 12;  -- Number of channels
                                                         -- used for extrap.
                                                         -- coords.

  constant NUM_FRAMES_LINK : integer := 6;  -- Number of frames in a bunch crossing.
  constant NUM_MUONS_LINK  : integer := 3;  -- Number of muons possible per link.
  constant NUM_MUONS_IN    : integer := 3;  -- Number of muons per input link
  constant NUM_MUONS_OUT   : integer := 2;  -- Number of muons per output link

  constant EMTF_NEG_HIGH : integer := 35;
  constant EMTF_NEG_LOW  : integer := 30;
  constant OMTF_NEG_HIGH : integer := 29;
  constant OMTF_NEG_LOW  : integer := 24;
  constant BMTF_HIGH     : integer := 23;  -- Begin of barrel region.
  constant BMTF_LOW      : integer := 12;  -- End of barrel region.
  constant OMTF_POS_HIGH : integer := 11;  -- Begin of positive overlap region.
  constant OMTF_POS_LOW  : integer := 6;   -- End of pos. overlap region.
  constant EMTF_POS_HIGH : integer := 5;
  constant EMTF_POS_LOW  : integer := 0;

  constant IMD_HIGH : natural := 11;
  constant IMD_LOW  : natural := 4;
  constant OUT_HIGH : natural := 3;
  constant OUT_LOW  : natural := 0;

  -----------------------------------------------------------------------------
  -- Quad assignments
  -- IMPORTANT: THESE HAVE TO BE SYNCHRONIZED WITH AREA CONSTRAINTS IN .ucf
  -- file!
  -- Use the script ucf_serdes_constraints_generator.py for this. (Available in
  -- github repo for now.)
  -----------------------------------------------------------------------------
  type QuadAssignment_vector is array (integer range <>) of natural;

  -- Muons
  constant MU_QUAD_ASSIGNMENT : QuadAssignment_vector(8 downto 0) := (17, 16, 15, 14, 13, 12, 11, 10, 9);

  -- Calo
  constant ENERGY_QUAD_ASSIGNMENT : QuadAssignment_vector(6 downto 0) := (8, 7, 6, 5, 4, 3, 2);

  -----------------------------------------------------------------------------
  -- Output word assignment
  -----------------------------------------------------------------------------
  -- Vector to map final muons to positions in output buffer. (Position
  -- indicates the muon (2->empty, 1->second muon, 0->first muon); the entry at the position
  -- indicates the position in the buffer.)
  constant MU_ASSIGNMENT : QuadAssignment_vector(2 downto 0) := (0, 2, 1);

  -----------------------------------------------------------------------------
  -- Bit boundaries for input and output muons.
  -----------------------------------------------------------------------------
  constant WORD_SIZE : natural := 32;

  --
  -- in
  --

  constant PT_IN_LOW  : natural := 0;
  constant PT_IN_HIGH : natural := 8;

  constant QUAL_IN_LOW  : natural := 9;
  constant QUAL_IN_HIGH : natural := 12;

  constant ETA_IN_LOW  : natural := 13;
  constant ETA_IN_HIGH : natural := 21;

  constant PHI_IN_LOW  : natural := 23;
  constant PHI_IN_HIGH : natural := 30;

  -- This crosses the word boundary in the incoming frames. As the MSB is a
  -- control bit we "lose" one bit here, so the bit numbering for the 31 MSBs
  -- is of by one. (i.e. our muon has 62 bits, not 64)
  constant SIGN_IN      : natural := 31;
  constant VALIDSIGN_IN : natural := 32;

  constant BMTF_ADDRESS_STATION_1_IN_LOW  : natural := 35;
  constant BMTF_ADDRESS_STATION_1_IN_HIGH : natural := 36;
  constant BMTF_ADDRESS_STATION_2_IN_LOW  : natural := 37;
  constant BMTF_ADDRESS_STATION_2_IN_HIGH : natural := 40;
  constant BMTF_ADDRESS_STATION_3_IN_LOW  : natural := 41;
  constant BMTF_ADDRESS_STATION_3_IN_HIGH : natural := 44;
  constant BMTF_ADDRESS_STATION_4_IN_LOW  : natural := 45;
  constant BMTF_ADDRESS_STATION_4_IN_HIGH : natural := 48;

  constant BMTF_WHEEL_NO_IN_LOW  : natural := 51;
  constant BMTF_WHEEL_NO_IN_HIGH : natural := 52;

  constant BMTF_DETECTOR_SIDE_LOW  : natural := 53;
  constant BMTF_DETECTOR_SIDE_HIGH : natural := 53;

  --
  -- out
  --
  constant VALIDSIGN_OUT : natural := 35;
  constant SIGN_OUT      : natural := 34;

  constant ISO_OUT_HIGH : natural := 33;
  constant ISO_OUT_LOW  : natural := 32;

  constant ETA_OUT_HIGH : natural := 31;
  constant ETA_OUT_LOW  : natural := 23;

  constant QUAL_OUT_HIGH : natural := 22;
  constant QUAL_OUT_LOW  : natural := 19;

  constant PT_OUT_HIGH : natural := 18;
  constant PT_OUT_LOW  : natural := 10;

  constant PHI_OUT_HIGH : natural := 9;
  constant PHI_OUT_LOW  : natural := 0;

  --
  -- isolation bits within the iso word
  --
  constant ABS_ISO_BIT : natural := 0;
  constant REL_ISO_BIT : natural := 1;

  -----------------------------------------------------------------------------
  -- Constants for LUTs
  -----------------------------------------------------------------------------

  constant CANCEL_OUT_DATA_FILE_BO_POS  : string := string'("BOPosMatchQual.mif");
  constant CANCEL_OUT_DATA_FILE_BO_NEG  : string := string'("BONegMatchQual.mif");
  constant CANCEL_OUT_DATA_FILE_EO_POS  : string := string'("EOPosMatchQual.mif");
  constant CANCEL_OUT_DATA_FILE_EO_NEG  : string := string'("EONegMatchQual.mif");
  constant CANCEL_OUT_DATA_FILE_BMTF     : string := string'("BmtfSingleMatchQual.mif");
  constant CANCEL_OUT_DATA_FILE_OMTF_POS : string := string'("OmtfPosSingleMatchQual.mif");
  constant CANCEL_OUT_DATA_FILE_OMTF_NEG : string := string'("OmtfNegSingleMatchQual.mif");
  constant CANCEL_OUT_DATA_FILE_EMTF_POS : string := string'("EmtfPosSingleMatchQual.mif");
  constant CANCEL_OUT_DATA_FILE_EMTF_NEG : string := string'("EmtfNegSingleMatchQual.mif");

  constant ABSOLUTE_ISO_CHECK_DATA_FILE : string := string'("AbsIsoCheckMem.mif");
  constant RELATIVE_ISO_CHECK_DATA_FILE : string := string'("RelIsoCheckMem.mif");

  constant CALO_ETA_IDX_BITS_DATA_FILE : string := string'("IdxSelMemEta.mif");
  constant CALO_PHI_IDX_BITS_DATA_FILE : string := string'("IdxSelMemPhi.mif");

  constant SORT_RANK_DATA_FILE : string := string'("SortRank.mif");

  type ContentFileAssignment_vector is array (0 to 3) of string(1 to 21);
  -- Barrel
  constant ETA_BMTF_EXTRAP_CONT_ASSIGN     : ContentFileAssignment_vector := (string'("BEtaExtrapolation.mif"), string'("BEtaExtrapolation.mif"), string'("BEtaExtrapolation.mif"), string'("BEtaExtrapolation.mif"));
  constant PHI_BMTF_EXTRAP_CONT_ASSIGN     : ContentFileAssignment_vector := (string'("BPhiExtrapolation.mif"), string'("BPhiExtrapolation.mif"), string'("BPhiExtrapolation.mif"), string'("BPhiExtrapolation.mif"));
  -- OMTF
  constant ETA_OMTF_EXTRAP_CONT_ASSIGN     : ContentFileAssignment_vector := (string'("OEtaExtrapolation.mif"), string'("OEtaExtrapolation.mif"), string'("OEtaExtrapolation.mif"), string'("OEtaExtrapolation.mif"));
  constant PHI_OMTF_EXTRAP_CONT_ASSIGN     : ContentFileAssignment_vector := (string'("OPhiExtrapolation.mif"), string'("OPhiExtrapolation.mif"), string'("OPhiExtrapolation.mif"), string'("OPhiExtrapolation.mif"));
  -- OMTF/EMTF shared
  constant ETA_OMTF_EMTF_EXTRAP_CONT_ASSIGN : ContentFileAssignment_vector := (string'("OEtaExtrapolation.mif"), string'("OEtaExtrapolation.mif"), string'("EEtaExtrapolation.mif"), string'("EEtaExtrapolation.mif"));
  constant PHI_OMTF_EMTF_EXTRAP_CONT_ASSIGN : ContentFileAssignment_vector := (string'("OPhiExtrapolation.mif"), string'("OPhiExtrapolation.mif"), string'("EPhiExtrapolation.mif"), string'("EPhiExtrapolation.mif"));
  constant ETA_EMTF_OMTF_EXTRAP_CONT_ASSIGN : ContentFileAssignment_vector := (string'("EEtaExtrapolation.mif"), string'("EEtaExtrapolation.mif"), string'("OEtaExtrapolation.mif"), string'("OEtaExtrapolation.mif"));
  constant PHI_EMTF_OMTF_EXTRAP_CONT_ASSIGN : ContentFileAssignment_vector := (string'("EPhiExtrapolation.mif"), string'("EPhiExtrapolation.mif"), string'("OPhiExtrapolation.mif"), string'("OPhiExtrapolation.mif"));
  -- Endcap
  constant ETA_EMTF_EXTRAP_CONT_ASSIGN     : ContentFileAssignment_vector := (string'("EEtaExtrapolation.mif"), string'("EEtaExtrapolation.mif"), string'("EEtaExtrapolation.mif"), string'("EEtaExtrapolation.mif"));
  constant PHI_EMTF_EXTRAP_CONT_ASSIGN     : ContentFileAssignment_vector := (string'("EPhiExtrapolation.mif"), string'("EPhiExtrapolation.mif"), string'("EPhiExtrapolation.mif"), string'("EPhiExtrapolation.mif"));

  type ContentFileQuadAssignment_vector is array (natural range <>) of ContentFileAssignment_vector;
  constant ETA_EXTRAP_CONT_ASSIGN : ContentFileQuadAssignment_vector(0 to 8) := (ETA_EMTF_EXTRAP_CONT_ASSIGN, ETA_EMTF_OMTF_EXTRAP_CONT_ASSIGN, ETA_OMTF_EXTRAP_CONT_ASSIGN, ETA_BMTF_EXTRAP_CONT_ASSIGN, ETA_BMTF_EXTRAP_CONT_ASSIGN, ETA_BMTF_EXTRAP_CONT_ASSIGN, ETA_OMTF_EXTRAP_CONT_ASSIGN, ETA_OMTF_EMTF_EXTRAP_CONT_ASSIGN, ETA_EMTF_EXTRAP_CONT_ASSIGN);
  constant PHI_EXTRAP_CONT_ASSIGN : ContentFileQuadAssignment_vector(0 to 8) := (PHI_EMTF_EXTRAP_CONT_ASSIGN, PHI_EMTF_OMTF_EXTRAP_CONT_ASSIGN, PHI_OMTF_EXTRAP_CONT_ASSIGN, PHI_BMTF_EXTRAP_CONT_ASSIGN, PHI_BMTF_EXTRAP_CONT_ASSIGN, PHI_BMTF_EXTRAP_CONT_ASSIGN, PHI_OMTF_EXTRAP_CONT_ASSIGN, PHI_OMTF_EMTF_EXTRAP_CONT_ASSIGN, PHI_EMTF_EXTRAP_CONT_ASSIGN);

  constant ETA_IDX_MEM_ADDR_WIDTH : natural := 9;
  constant ETA_IDX_MEM_WORD_SIZE : natural := 5;
  constant PHI_IDX_MEM_ADDR_WIDTH : natural := 10;
  constant PHI_IDX_MEM_WORD_SIZE : natural := 6;

  constant EXTRAPOLATION_ADDR_WIDTH : natural := 12;
  constant ETA_EXTRAPOLATION_WORD_SIZE : natural := 4;
  constant PHI_EXTRAPOLATION_WORD_SIZE : natural := 3;

  constant REL_ISO_ADDR_WIDTH : natural := 14;
  constant REL_ISO_WORD_SIZE : natural := 1;
  constant ABS_ISO_ADDR_WIDTH : natural := 5;
  constant ABS_ISO_WORD_SIZE : natural := 1;

  constant COU_MEM_ADDR_WIDTH : natural := 7;
  constant COU_MEM_WORD_SIZE : natural := 1;

  constant SORT_RANK_MEM_ADDR_WIDTH : natural := 13;
  constant SORT_RANK_MEM_WORD_SIZE : natural := 10;

  -----------------------------------------------------------------------------
  -- Phi offset initialization vector
  -----------------------------------------------------------------------------

  type PhiOffsetRegisterValueAssignment_vector is array (0 to 8) of ipb_reg_v(0 to 3);
  constant INIT_PHI_OFFSET_ASSIGN : PhiOffsetRegisterValueAssignment_vector := ((X"00000018", X"00000078", X"000000D8", X"00000138"),
                                                                                (X"00000198", X"000001F8", X"00000018", X"00000078"),
                                                                                (X"000000D8", X"00000138", X"00000198", X"000001F8"),
                                                                                (X"00000228", X"00000018", X"00000048", X"00000078"),
                                                                                (X"000000A8", X"000000D8", X"00000108", X"00000138"),
                                                                                (X"00000168", X"00000198", X"000001C8", X"000001F8"),
                                                                                (X"00000018", X"00000078", X"000000D8", X"00000138"),
                                                                                (X"00000198", X"000001F8", X"00000018", X"00000078"),
                                                                                (X"000000D8", X"00000138", X"00000198", X"000001F8")
                                                                               );

  constant LOCAL_PHI_OFFSET_BMTF      : signed(8 downto 0) := to_signed(48, 9);
  constant LOCAL_PHI_OFFSET_OMTF_EMTF : signed(8 downto 0) := to_signed(96, 9);

  -----------------------------------------------------------------------------
  -- Cancel-out selector
  -----------------------------------------------------------------------------

  constant CANCEL_OUT_TYPE_BMTF : string := string'("BMTF_ADDRESSES");
  constant CANCEL_OUT_TYPE_OMTF : string := string'("COORDINATE");
  constant CANCEL_OUT_TYPE_EMTF : string := string'("COORDINATE");
  constant CANCEL_OUT_TYPE_BO   : string := string'("COORDINATE");
  constant CANCEL_OUT_TYPE_EO   : string := string'("COORDINATE");

  -----------------------------------------------------------------------------
  -- Cancel-out unit mapping to chip regions
  -----------------------------------------------------------------------------

  constant COU_EMTF_NEG : natural := 0;
  constant COU_EO_NEG   : natural := 1;
  constant COU_OMTF_NEG : natural := 2;
  constant COU_BO_NEG   : natural := 3;
  constant COU_BMTF     : natural := 4;
  constant COU_BO_POS   : natural := 5;
  constant COU_OMTF_POS : natural := 6;
  constant COU_EO_POS   : natural := 7;
  constant COU_EMTF_POS : natural := 8;

  -----------------------------------------------------------------------------
  -- Constants for stage 1 sorter
  -----------------------------------------------------------------------------

  constant MU_EMTF_POS_BEGIN : natural := 0;
  constant MU_OMTF_POS_BEGIN : natural := 4;
  constant MU_BMTF_BEGIN     : natural := 8;
  constant MU_OMTF_NEG_BEGIN : natural := 16;
  constant MU_EMTF_NEG_BEGIN : natural := 20;
  constant SORTING_END       : natural := 24;

  -----------------------------------------------------------------------------
  -- Misc. constants
  -----------------------------------------------------------------------------
  constant MAX_PHI_VAL          : natural := 576;
  constant EXTRAPOLATION_PT_CUT : natural := 63; -- 31.5 GeV is lowest pT value to be still extrapolated.
  constant LS_LENGTH_IN_ORBITS  : natural := 2**18;

end ugmt_constants;

package body ugmt_constants is

end ugmt_constants;
