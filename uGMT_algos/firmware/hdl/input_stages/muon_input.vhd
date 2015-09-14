library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

use work.mp7_data_types.all;
use work.ipbus.all;
use work.ipbus_decode_muon_input.all;

use work.mp7_ttc_decl.all;
use work.mp7_brd_decl.all;

use work.GMTTypes.all;
use work.ugmt_constants.all;

entity muon_input is
  generic (
    NCHAN     : positive
    );
  port (
    clk_ipb      : in  std_logic;
    rst          : in  std_logic_vector(N_REGION - 1 downto 0);
    ipb_in       : in  ipb_wbus;
    ipb_out      : out ipb_rbus;
    ctrs         : in  ttc_stuff_array(N_REGION - 1 downto 0);
    mu_ctr_rst   : in std_logic_vector(N_REGION - 1 downto 0);
    clk240       : in  std_logic;
    clk40        : in  std_logic;
    d            : in  ldata (NCHAN-1 downto 0);
    oMuons       : out TGMTMu_vector(NUM_MU_CHANS*NUM_MUONS_IN-1 downto 0);
    oTracks      : out TGMTMuTracks_vector(NUM_MU_CHANS-1 downto 0);
    oEmpty       : out std_logic_vector(NUM_MU_CHANS*NUM_MUONS_IN-1 downto 0);
    oSortRanks   : out TSortRank10_vector(NUM_MU_CHANS*NUM_MUONS_IN-1 downto 0);
    oValid       : out std_logic;
    oCaloIdxBits : out TCaloIndexBit_vector(NUM_MU_CHANS*NUM_MUONS_IN-1 downto 0) -- Out one bx after muons
    );
end muon_input;

architecture Behavioral of muon_input is

  signal ipbw : ipb_wbus_array(N_SLAVES-1 downto 0);
  signal ipbr : ipb_rbus_array(N_SLAVES-1 downto 0);

  signal sGlobalPhi : TGlobalPhi_frame(NCHAN-1 downto 0);

  signal q : ldata (NCHAN-1 downto 0);

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
        sel             => ipbus_sel_muon_input(ipb_in.ipb_addr),
        ipb_to_slaves   => ipbw,
        ipb_from_slaves => ipbr
        );

  deserialize_loop : for i in MU_QUAD_ASSIGNMENT'range generate
    deserialize : entity work.deserialize_mu_quad
      generic map (
        INIT_PHI_OFFSET => INIT_PHI_OFFSET_ASSIGN(i)
        )
      port map (
        clk_ipb            => clk_ipb,
        rst                => rst(MU_QUAD_ASSIGNMENT(i)),
        ipb_in             => ipbw(N_SLV_MU_QUAD_0+i),
        ipb_out            => ipbr(N_SLV_MU_QUAD_0+i),
        bctr               => ctrs(MU_QUAD_ASSIGNMENT(i)).bctr,
        muon_counter_reset => mu_ctr_rst(i),
        clk240             => clk240,
        clk40              => clk40,
        d                  => d(MU_QUAD_ASSIGNMENT(i)*4+3 downto MU_QUAD_ASSIGNMENT(i)*4),
        oMuons             => oMuons(i*4*NUM_MUONS_IN+(4*NUM_MUONS_IN-1) downto i*4*NUM_MUONS_IN),
        oTracks            => oTracks(i*4+3 downto i*4),
        oEmpty             => oEmpty(i*4*NUM_MUONS_IN+(4*NUM_MUONS_IN-1) downto i*4*NUM_MUONS_IN),
        oSortRanks         => oSortRanks(i*4*NUM_MUONS_IN+(4*NUM_MUONS_IN-1) downto i*4*NUM_MUONS_IN),
        oValid             => sValid(i),
        q                  => q(MU_QUAD_ASSIGNMENT(i)*4+3 downto MU_QUAD_ASSIGNMENT(i)*4),
        oGlobalPhi         => sGlobalPhi(MU_QUAD_ASSIGNMENT(i)*4+3 downto MU_QUAD_ASSIGNMENT(i)*4)
        );

    extrapolate : entity work.gen_idx_bits
      generic map (
        ETA_EXTRAPOLATION_DATA_FILE  => ETA_EXTRAP_CONT_ASSIGN(i),
        PHI_EXTRAPOLATION_DATA_FILE  => PHI_EXTRAP_CONT_ASSIGN(i)
      )
      port map (
        clk_ipb       => clk_ipb,
        rst           => rst(i),
        ipb_in        => ipbw(N_SLV_GEN_CALO_IDX_BITS_QUAD_0+i),
        ipb_out       => ipbr(N_SLV_GEN_CALO_IDX_BITS_QUAD_0+i),
        clk240        => clk240,
        clk40         => clk40,
        d             => q(MU_QUAD_ASSIGNMENT(i)*4+3 downto MU_QUAD_ASSIGNMENT(i)*4),
        iGlobalPhi    => sGlobalPhi(MU_QUAD_ASSIGNMENT(i)*4+3 downto MU_QUAD_ASSIGNMENT(i)*4),
        oCaloIdxBits  => oCaloIdxBits(i*4*NUM_MUONS_IN+(4*NUM_MUONS_IN-1) downto i*4*NUM_MUONS_IN)
        );
  end generate deserialize_loop;

  oValid <=  combine_or(sValid);

end Behavioral;
