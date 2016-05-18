library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.mp7_data_types.all;

use work.GMTTypes.all;
use work.ugmt_constants.all;

entity serializer_stage is
  port (clk240               : in  std_logic;
        clk40                : in  std_logic;
        rst                  : in  std_logic;
        iValidMuons          : in  std_logic;
        iValidEnergies       : in  std_logic;
        iMuons               : in  TGMTMu_vector(OUTPUT_QUAD_ASSIGNMENT'length*NUM_OUT_CHANS*NUM_MUONS_OUT-1 downto 0);
        iIso                 : in  TIsoBits_vector(NUM_OUT_CHANS*NUM_MUONS_OUT-1 downto 0);
        iMuIdxBits           : in  TIndexBits_vector(OUTPUT_QUAD_ASSIGNMENT'length*NUM_OUT_CHANS*NUM_MUONS_OUT-1 downto 0);
        iIntermediateMuonsB  : in  TGMTMu_vector(7 downto 0);
        iIntermediateMuonsO  : in  TGMTMu_vector(7 downto 0);
        iIntermediateMuonsE  : in  TGMTMu_vector(7 downto 0);
        q                    : out ldata (((OUTPUT_QUAD_ASSIGNMENT'length*NUM_OUT_CHANS)+NUM_INTERM_MU_OUT_CHANS)-1 downto 0));
end serializer_stage;

architecture Behavioral of serializer_stage is
  signal sValid : std_logic;

  signal sIntermediateMuons : TGMTMu_vector(23 downto 0);
  signal sFakeIdxBits       : TIndexBits_vector(11 downto 0) := (others => "0000000");
  signal sFakeIso           : TIsoBits_vector(11 downto 0)   := (others => "00");
begin

  sIntermediateMuons <= iIntermediateMuonsE(7 downto 4) & iIntermediateMuonsO(7 downto 4) & iIntermediateMuonsB & iIntermediateMuonsO(3 downto 0) & iIntermediateMuonsE(3 downto 0);

  sValid <= iValidMuons; -- or iValidEnergies;

  generate_serializers : for i in OUTPUT_QUAD_ASSIGNMENT'range generate
    serializer_quad : entity work.serialize_outputs_quad
      generic map (
        N_MU_OUT => 8
      )
      port map (
        clk240     => clk240,
        clk40      => clk40,
        rst        => rst,
        iValid     => sValid,
        iMuons     => iMuons(8*i+7 downto 8*i),
        iIso       => iIso,
        iMuIdxBits => iMuIdxBits(8*i+7 downto 8*i),
        q          => q(4*OUTPUT_QUAD_ASSIGNMENT(i)+3 downto 4*OUTPUT_QUAD_ASSIGNMENT(i))
        );
  end generate generate_serializers;

  generate_int_serializers : for i in INTERMEDIATE_QUAD_ASSIGNMENT'range generate
    serializer_quad : entity work.serialize_outputs_quad
      generic map (
        N_MU_OUT => 12
      )
      port map (
        clk240     => clk240,
        clk40      => clk40,
        rst        => rst,
        iValid     => sValid,
        iMuons     => sIntermediateMuons(12*i+11 downto 12*i),
        iIso       => sFakeIso,
        iMuIdxBits => sFakeIdxBits,
        q          => q(4*INTERMEDIATE_QUAD_ASSIGNMENT(i)+3 downto 4*INTERMEDIATE_QUAD_ASSIGNMENT(i))
        );
  end generate generate_int_serializers;

end Behavioral;
