library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.mp7_data_types.all;
use work.ipbus.all;
use work.ipbus_decode_energy_deserialization.all;

use work.mp7_ttc_decl.all;
use work.mp7_brd_decl.all;

use work.GMTTypes.all;
use work.ugmt_constants.all;

entity deserializer_stage_energies is
  generic (
    NCHAN     : positive;
    VALID_BIT : std_logic
    );
  port (
    clk_ipb   : in  std_logic;
    rst       : in  std_logic;
    ipb_in    : in  ipb_wbus;
    ipb_out   : out ipb_rbus;
    ctrs      : in  ttc_stuff_array(N_REGION - 1 downto 0);
    clk240    : in  std_logic;
    clk40     : in  std_logic;
    d         : in  ldata(NCHAN-1 downto 0);
    oEnergies : out TCaloRegionEtaSlice_vector(NUM_CALO_CHANS-1 downto 0);
    oValid    : out std_logic
    );
end deserializer_stage_energies;

architecture Behavioral of deserializer_stage_energies is

  signal ipbw : ipb_wbus_array(N_SLAVES-1 downto 0);
  signal ipbr : ipb_rbus_array(N_SLAVES-1 downto 0);

  signal sValid : std_logic_vector(ENERGY_QUAD_ASSIGNMENT'range);

begin  -- Behavioral
  -- IPbus address decode
  fabric : entity work.ipbus_fabric_sel
    generic map(
      NSLV      => N_SLAVES,
      SEL_WIDTH => IPBUS_SEL_WIDTH
      )
    port map(
      ipb_in          => ipb_in,
      ipb_out         => ipb_out,
      sel             => ipbus_sel_energy_deserialization(ipb_in.ipb_addr),
      ipb_to_slaves   => ipbw,
      ipb_from_slaves => ipbr
    );

  deserialize_loop : for i in ENERGY_QUAD_ASSIGNMENT'range generate
    deserialize : entity work.deserialize_energy_quad
      generic map (
        VALID_BIT => VALID_BIT)
      port map (
        clk_ipb   => clk_ipb,
        rst       => rst,
        ipb_in    => ipbw(i),
        ipb_out   => ipbr(i),
        bctr      => ctrs(ENERGY_QUAD_ASSIGNMENT(i)).bctr,
        clk240    => clk240,
        clk40     => clk40,
        d         => d(ENERGY_QUAD_ASSIGNMENT(i)*4+3 downto ENERGY_QUAD_ASSIGNMENT(i)*4),
        oEnergies => oEnergies(i*4+3 downto i*4),
        oValid    => sValid(i)
        );
  end generate deserialize_loop;


  oValid <= combine_or(sValid);

end Behavioral;
