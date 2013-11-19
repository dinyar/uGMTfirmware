library IEEE;
use IEEE.STD_LOGIC_1164.all;

use IEEE.NUMERIC_STD.ALL;

library types;
use types.GMTTypes.all;

entity generate_index_bits is
  port (iCoordsB      : in  TSpatialCoordinate_vector(0 to 35);
        iCoordsO      : in  TSpatialCoordinate_vector(0 to 35);
        iCoordsF      : in  TSpatialCoordinate_vector(0 to 35);
        oCaloIdxBitsB : out TCaloSelBit_vector(35 downto 0);
        oCaloIdxBitsO : out TCaloSelBit_vector(35 downto 0);
        oCaloIdxBitsF : out TCaloSelBit_vector(35 downto 0);
        clk           : in  std_logic;
        sinit         : in  std_logic);
end generate_index_bits;

architecture Behavioral of generate_index_bits is
  component eta_sel_mem
    port (
      clka  : in  std_logic;
      wea   : in  std_logic_vector(0 downto 0);
      addra : in  std_logic_vector(8 downto 0);
      dina  : in  std_logic_vector(4 downto 0);
      douta : out std_logic_vector(4 downto 0);
      clkb  : in  std_logic;
      web   : in  std_logic_vector(0 downto 0);
      addrb : in  std_logic_vector(8 downto 0);
      dinb  : in  std_logic_vector(4 downto 0);
      doutb : out std_logic_vector(4 downto 0)
      );
  end component;
  component phi_sel_mem
    port (
      clka  : in  std_logic;
      wea   : in  std_logic_vector(0 downto 0);
      addra : in  std_logic_vector(9 downto 0);
      dina  : in  std_logic_vector(5 downto 0);
      douta : out std_logic_vector(5 downto 0);
      clkb  : in  std_logic;
      web   : in  std_logic_vector(0 downto 0);
      addrb : in  std_logic_vector(9 downto 0);
      dinb  : in  std_logic_vector(5 downto 0);
      doutb : out std_logic_vector(5 downto 0)
      );
  end component;
begin
  -----------------------------------------------------------------------------
  -- Generate index bits for barrel muons
  -----------------------------------------------------------------------------
  convert_coords_to_sel_barrel : for i in iCoordsB'range generate
    barrel_eta_sel_mem : eta_sel_mem
      port map (
        clka            => clk,
        wea             => "0",
        addra           => std_logic_vector(iCoordsB(i).eta),
        dina            => "00000",
        unsigned(douta) => oCaloIdxBitsB(i).eta,
        clkb            => clk,
        web             => "0",
        addrb           => "000000000",
        dinb            => "00000",
        doutb           => open
        );
    barrel_phi_sel_mem : phi_sel_mem
      port map (
        clka            => clk,
        wea             => "0",
        addra           => std_logic_vector(iCoordsB(i).phi),
        dina            => "000000",
        unsigned(douta) => oCaloIdxBitsB(i).phi,
        clkb            => clk,
        web             => "0",
        addrb           => "0000000000",
        dinb            => "000000",
        doutb           => open
        );
  end generate convert_coords_to_sel_barrel;

    -----------------------------------------------------------------------------
  -- Generate index bits for overlap muons
  -----------------------------------------------------------------------------
  convert_coords_to_sel_overlap : for i in iCoordsO'range generate
    overlap_eta_sel_mem : eta_sel_mem
      port map (
        clka            => clk,
        wea             => "0",
        addra           => std_logic_vector(iCoordsO(i).eta),
        dina            => "00000",
        unsigned(douta) => oCaloIdxBitsO(i).eta,
        clkb            => clk,
        web             => "0",
        addrb           => "000000000",
        dinb            => "00000",
        doutb           => open
        );
    overlap_phi_sel_mem : phi_sel_mem
      port map (
        clka            => clk,
        wea             => "0",
        addra           => std_logic_vector(iCoordsO(i).phi),
        dina            => "000000",
        unsigned(douta) => oCaloIdxBitsO(i).phi,
        clkb            => clk,
        web             => "0",
        addrb           => "0000000000",
        dinb            => "000000",
        doutb           => open
        );
  end generate convert_coords_to_sel_overlap;

 -----------------------------------------------------------------------------
  -- Generate index bits for forward muons
  -----------------------------------------------------------------------------
  convert_coords_to_sel_forward : for i in iCoordsF'range generate
    forward_eta_sel_mem : eta_sel_mem
      port map (
        clka            => clk,
        wea             => "0",
        addra           => std_logic_vector(iCoordsF(i).eta),
        dina            => "00000",
        unsigned(douta) => oCaloIdxBitsF(i).eta,
        clkb            => clk,
        web             => "0",
        addrb           => "000000000",
        dinb            => "00000",
        doutb           => open
        );
    forward_phi_sel_mem : phi_sel_mem
      port map (
        clka            => clk,
        wea             => "0",
        addra           => std_logic_vector(iCoordsF(i).phi),
        dina            => "000000",
        unsigned(douta) => oCaloIdxBitsF(i).phi,
        clkb            => clk,
        web             => "0",
        addrb           => "0000000000",
        dinb            => "000000",
        doutb           => open
        );
  end generate convert_coords_to_sel_forward;
end Behavioral;

