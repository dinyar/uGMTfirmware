library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.mp7_data_types.all;
use work.ipbus.all;

use work.GMTTypes.all;
use work.ugmt_constants.all;

entity deserializer_stage_energies is
  generic (
    NCHAN     : positive;
    VALID_BIT : std_logic
    );
  port (
    bunch_ctr : in  std_logic_vector(11 downto 0);
    orb_ctr   : in  std_logic_vector(23 downto 0);
    clk240    : in  std_logic;
    clk40     : in  std_logic;
    d         : in  ldata(NCHAN-1 downto 0);
    oEnergies : out TCaloRegionEtaSlice_vector(NUM_CALO_CHANS-1 downto 0);
    oValid    : out std_logic
    );
end deserializer_stage_energies;

architecture Behavioral of deserializer_stage_energies is

  signal sValid : std_logic_vector(ENERGY_QUAD_ASSIGNMENT'range);
  
begin  -- Behavioral

  deserialize_loop : for i in ENERGY_QUAD_ASSIGNMENT'range generate
    deserialize : entity work.deserialize_energy_quad
      generic map (
        VALID_BIT => VALID_BIT)
      port map (
        bunch_ctr => bunch_ctr,
        orb_ctr   => orb_ctr,
        clk240    => clk240,
        clk40     => clk40,
        d         => d(ENERGY_QUAD_ASSIGNMENT(i)*4+3 downto ENERGY_QUAD_ASSIGNMENT(i)*4),
        oEnergies => oEnergies(i*4+3 downto i*4),
        oValid    => sValid(i)
        );
  end generate deserialize_loop;


  oValid <= combine_or(sValid);
  
end Behavioral;
