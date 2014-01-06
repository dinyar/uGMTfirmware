library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

library types;
use types.GMTTypes.all;


entity iso_check is
  port (iAreaSums : in  TCaloArea_vector (7 downto 0);
        iPileUp   : in  unsigned (6 downto 0);
        oIsoBits  : out TIsoBits_vector (7 downto 0);
        clk       : in  std_logic;
        sinit     : in  std_logic);
end iso_check;

architecture Behavioral of iso_check is
  component IsolationLUT
    port (
      clka  : in  std_logic;
      ena   : in  std_logic;
      wea   : in  std_logic_vector(0 downto 0);
      addra : in  std_logic_vector(16 downto 0);
      dina  : in  std_logic_vector(0 downto 0);
      douta : out std_logic_vector(0 downto 0);
      clkb  : in  std_logic;
      enb   : in  std_logic;
      web   : in  std_logic_vector(0 downto 0);
      addrb : in  std_logic_vector(16 downto 0);
      dinb  : in  std_logic_vector(0 downto 0);
      doutb : out std_logic_vector(0 downto 0)
      );
  end component;

  subtype IsoInput is std_logic_vector(16 downto 0);
  type    IsoInput_vector is array (iAreaSums'range) of IsoInput;
  signal  sInputVec : IsoInput_vector;
begin
  construct_input_vec : for i in sInputVec'range generate
    sInputVec(i) <= std_logic_vector(iAreaSums(i)) & std_logic_vector(iPileUp);
  end generate construct_input_vec;

  iso_check_loop : for i in oIsoBits'range generate
    iso_check : IsolationLUT
      port map (
        clka     => clk,
        ena      => '1',
        wea      => "0",
        addra    => sInputVec(i),
        dina     => (others => '0'),
        douta(0) => oIsoBits(i)(0),
        clkb     => clk,
        enb      => '0',
        web      => "0",
        addrb    => (others => '0'),
        dinb     => (others => '0'),
        doutb    => open
        );
    -- TODO: Isolation LUT should have 2 bit output.
    oIsoBits(i)(1) <= '0';
  end generate iso_check_loop;

end Behavioral;

