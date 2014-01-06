library IEEE;
use IEEE.STD_LOGIC_1164.all;

package ugmt_constants is

  constant NUM_MU_CHANS   : integer := 36;  -- Number of channels for input muons.
  constant NUM_CALO_CHANS : integer := 28;  -- Number of channels for energy sums.
  constant NUM_IN_CHANS   : integer := NUM_MU_CHANS+NUM_CALO_CHANS;  -- Number of input channels
  constant NUM_OUT_CHANS  : integer := 4;   -- Number of channels to GT.

  constant NUM_MUONS_LINK : integer := 3;  -- Number of muons possible per link.
  constant NUM_MUONS_IN   : integer := 3;  -- Number of muons per input link
  constant NUM_MUONS_OUT  : integer := 2;  -- Number of muons per output link

  constant BARREL_HIGH  : integer := NUM_MU_CHANS-1;  -- Begin of barrel region.
  constant BARREL_LOW   : integer := 2*(NUM_MU_CHANS-1)/3+1;  -- End of barrel region.
  constant OVL_POS_HIGH : integer := BARREL_LOW-1;  -- Begin of positiv ovl region.
  constant OVL_POS_LOW  : integer := (NUM_MU_CHANS-1)/2+1;  -- End of pos. ovl region.
  constant OVL_NEG_HIGH : integer := OVL_POS_LOW-1;
  constant OVL_NEG_LOW  : integer := (NUM_MU_CHANS-1)/3+1;
  constant FWD_POS_HIGH : integer := OVL_NEG_LOW-1;
  constant FWD_POS_LOW  : integer := (NUM_MU_CHANS-1)/6+1;
  constant FWD_NEG_HIGH : integer := FWD_POS_LOW-1;
  constant FWD_NEG_LOW  : integer := 0;

  -----------------------------------------------------------------------------
  -- Bit boundaries for input and output muons.
  -----------------------------------------------------------------------------
  constant WORD_SIZE : natural := 32;
  
  --
  -- in
  --

  constant SYSIGN_IN_HIGH : natural := 63;
  constant SYSIGN_IN_LOW  : natural := 62;

  constant ETA_IN_HIGH : natural := 61;
  constant ETA_IN_LOW  : natural := 53;

  constant QUAL_IN_HIGH : natural := 52;
  constant QUAL_IN_LOW  : natural := 49;

  constant PT_IN_HIGH : natural := 48;
  constant PT_IN_LOW  : natural := 40;

  constant PHI_IN_HIGH : natural := 39;
  constant PHI_IN_LOW  : natural := 30;

  constant ADDRESS_IN_HIGH : natural := 29;
  constant ADDRESS_IN_LOW  : natural := 0;

  --
  -- out
  --
  constant SYSIGN_OUT_HIGH : natural := 63;
  constant SYSIGN_OUT_LOW  : natural := 62;

  constant ETA_OUT_HIGH : natural := 61;
  constant ETA_OUT_LOW  : natural := 53;

  constant QUAL_OUT_HIGH : natural := 52;
  constant QUAL_OUT_LOW  : natural := 49;

  constant PT_OUT_HIGH : natural := 48;
  constant PT_OUT_LOW  : natural := 40;

  constant PHI_OUT_HIGH : natural := 39;
  constant PHI_OUT_LOW  : natural := 30;

  constant ISO_OUT_HIGH : natural := 29;
  constant ISO_OUT_LOW  : natural := 28;
  
end ugmt_constants;

package body ugmt_constants is


end ugmt_constants;
