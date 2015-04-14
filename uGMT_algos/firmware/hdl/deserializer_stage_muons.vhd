library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

use work.mp7_data_types.all;
use work.ipbus.all;
use work.ipbus_decode_deserialization.all;

use work.GMTTypes.all;
use work.ugmt_constants.all;

entity deserializer_stage_muons is
  generic (
    NCHAN     : positive;
    VALID_BIT : std_logic
    );
  port (
    clk_ipb    : in  std_logic;
    rst        : in  std_logic;
    ipb_in     : in  ipb_wbus;
    ipb_out    : out ipb_rbus;
    clk240     : in  std_logic;
    clk40      : in  std_logic;
    d          : in  ldata (NCHAN-1 downto 0);
    oMuons     : out TGMTMu_vector(NUM_MU_CHANS*NUM_MUONS_IN-1 downto 0);
    oTracks    : out TGMTMuTracks_vector(NUM_MU_CHANS-1 downto 0);
    oEmpty     : out std_logic_vector(NUM_MU_CHANS*NUM_MUONS_IN-1 downto 0);
    oSortRanks : out TSortRank10_vector(NUM_MU_CHANS*NUM_MUONS_IN-1 downto 0);
    oValid     : out std_logic
    );
end deserializer_stage_muons;

architecture Behavioral of deserializer_stage_muons is

  signal sel_lut_group : std_logic_vector(3 downto 0);

  signal ipbw : ipb_wbus_array(N_SLAVES-1 downto 0);
  signal ipbr : ipb_rbus_array(N_SLAVES-1 downto 0);

  signal sValid : std_logic_vector(MU_QUAD_ASSIGNMENT'range);
begin

    -- IPbus address decode
    fabric : entity work.ipbus_fabric_sel
      generic map(
        NSLV      => N_SLAVES,
        SEL_WIDTH => IPBUS_SEL_WIDTH
        )
      port map(
        ipb_in          => ipb_in,
        ipb_out         => ipb_out,
        sel             => ipbus_sel_deserialization(ipb_in.ipb_addr),
        ipb_to_slaves   => ipbw,
        ipb_from_slaves => ipbr
        );

  deserialize_loop : for i in MU_QUAD_ASSIGNMENT'range generate
    deserialize : entity work.deserialize_mu_quad
      generic map (
        VALID_BIT => VALID_BIT)
      port map (
        clk_ipb    => clk_ipb,
        rst        => rst,
        ipb_in     => ipbw(i),
        ipb_out    => ipbr(i),
        clk240     => clk240,
        clk40      => clk40,
        d          => d(MU_QUAD_ASSIGNMENT(i)*4+3 downto MU_QUAD_ASSIGNMENT(i)*4),
        oMuons     => oMuons(i*4*NUM_MUONS_IN+(4*NUM_MUONS_IN-1) downto i*4*NUM_MUONS_IN),
        oTracks    => oTracks(i*4+3 downto i*4),
        oEmpty     => oEmpty(i*4*NUM_MUONS_IN+(4*NUM_MUONS_IN-1) downto i*4*NUM_MUONS_IN),
        oSortRanks => oSortRanks(i*4*NUM_MUONS_IN+(4*NUM_MUONS_IN-1) downto i*4*NUM_MUONS_IN),
        oValid     => sValid(i)
       -- TODO: Need output for calo idx bits (and optionally for coords at
       -- vertex) here.
        );
  end generate deserialize_loop;


  oValid <=  combine_or(sValid);

end Behavioral;
