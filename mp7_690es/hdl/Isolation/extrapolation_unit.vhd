library IEEE;
use IEEE.STD_LOGIC_1164.all;

use IEEE.NUMERIC_STD.all;

library types;
use types.GMTTypes.all;

entity extrapolation_unit is
  port (iMuons              : in  TGMTMu_vector(0 to 35);
        oExtrapolatedCoords : out TSpatialCoordinate_vector(0 to 35);
        clk                 : in  std_logic;
        sinit               : in  std_logic);
end extrapolation_unit;
architecture Behavioral of extrapolation_unit is
  component eta_extrapolation_mem
    port (
      clka  : in  std_logic;
      wea   : in  std_logic_vector(0 downto 0);
      addra : in  std_logic_vector(11 downto 0);
      dina  : in  std_logic_vector(3 downto 0);
      douta : out std_logic_vector(3 downto 0);
      clkb  : in  std_logic;
      web   : in  std_logic_vector(0 downto 0);
      addrb : in  std_logic_vector(11 downto 0);
      dinb  : in  std_logic_vector(3 downto 0);
      doutb : out std_logic_vector(3 downto 0)
      );
  end component;

  component phi_extrapolation_mem
    port (
      clka  : in  std_logic;
      wea   : in  std_logic_vector(0 downto 0);
      addra : in  std_logic_vector(12 downto 0);
      dina  : in  std_logic_vector(3 downto 0);
      douta : out std_logic_vector(3 downto 0);
      clkb  : in  std_logic;
      web   : in  std_logic_vector(0 downto 0);
      addrb : in  std_logic_vector(12 downto 0);
      dinb  : in  std_logic_vector(3 downto 0);
      doutb : out std_logic_vector(3 downto 0)
      );
  end component;

  type   TEtaExtrapolationAddress is array (integer range <>) of std_logic_vector(0 to 11);
  type   TPhiExtrapolationAddress is array (integer range <>) of std_logic_vector(0 to 12);
  signal sEtaExtrapolationAddress : TEtaExtrapolationAddress(iMuons'range);
  signal sPhiExtrapolationAddress : TPhiExtrapolationAddress(iMuons'range);

  type   TEtaAbs is array (integer range <>) of unsigned(0 to 8);
  signal sEtaAbs : TEtaAbs(iMuons'range);

  type   TDelta_vector is array (integer range <>) of signed(0 to 3);
  signal sDeltaEta : TDelta_vector(iMuons'range);
  signal sDeltaPhi : TDelta_vector(iMuons'range);

  signal sExtrapolatedCoords : TSpatialCoordinate_vector(oExtrapolatedCoords'Range);

begin
  etrapolation : for i in iMuons'range generate
    -----------------------------------------------------------------------------
    -- eta extrapolation
    --
    -- 7 bits of eta (only interested in forward regions)
    -- 5 bits of pT -> max pT of 15.5 GeV
    -- (high pT muons will be regarded as straight lines)
    -----------------------------------------------------------------------------
    sEtaAbs(i)                  <= unsigned(abs(signed(iMuons(i).eta)));
    sEtaExtrapolationAddress(i) <= std_logic_vector(sEtaAbs(i)(0 to 6)) &
                                   std_logic_vector(iMuons(i).pt(4 downto 0));
    eta_extrapolation : eta_extrapolation_mem
      port map (
        clka          => clk,
        wea           => "0",
        addra         => sEtaExtrapolationAddress(i),
        dina          => "0000",
        signed(douta) => sDeltaEta(i),
        clkb          => clk,
        web           => "0",
        addrb         => "000000000000",
        dinb          => "0000",
        doutb         => open
        );
    -----------------------------------------------------------------------------
    -- phi extrapolation
    --
    -- 8 bits of eta (only need to know absolute distance from 0)
    -- 5 bits of pT (high pT muons will be regarded as straight lines)
    -----------------------------------------------------------------------------
    sPhiExtrapolationAddress(i) <= std_logic_vector(sEtaAbs(i)(0 to 7)) & std_logic_vector(iMuons(i).pt(4 downto 0));
    phi_extrapolation : phi_extrapolation_mem
      port map (
        clka          => clk,
        wea           => "0",
        addra         => sPhiExtrapolationAddress(i),
        dina          => "0000",
        signed(douta) => sDeltaPhi(i),
        clkb          => clk,
        web           => "0",
        addrb         => "0000000000000",
        dinb          => "0000",
        doutb         => open
        );
  end generate etrapolation;

  -- purpose: Assign corrected coordinates to muons.
  -- type   : combinational
  -- inputs : iMuons, sDeltaEta, sDeltaPhi
  -- outputs: sExtrapolatedCoords
  assign_coords : process (iMuons, sDeltaEta, sDeltaPhi)
  begin  -- process assign_coords
    for i in iMuons'range loop
      if unsigned(iMuons(i).pt) > 31 then
        -- If muon is high-pT we won't extrapolate.
        sExtrapolatedCoords(i).eta <= signed(iMuons(i).eta);
        sExtrapolatedCoords(i).phi <= unsigned(iMuons(i).phi);
      elsif (abs signed(iMuons(i).eta)) > 127 then
        -- If muon is low-pT and has high eta we etrapolate both coordinates.
        sExtrapolatedCoords(i).eta <= signed(iMuons(i).eta) + sDeltaEta(i);
        sExtrapolatedCoords(i).phi <= unsigned(signed(iMuons(i).phi) + sDeltaPhi(i));
      else
        -- If muon is low-pT but low is in the barrel we only extrapolate phi.
        sExtrapolatedCoords(i).eta <= signed(iMuons(i).eta);
        sExtrapolatedCoords(i).phi <= unsigned(signed(iMuons(i).phi) + sDeltaPhi(i));
      end if;
    end loop;  -- i
  end process assign_coords;

  oExtrapolatedCoords <= sExtrapolatedCoords;
  
  -- Register already done through memory??
  ---- purpose: Final register
  ---- type   : sequential
  ---- inputs : clk, sinit, sExtrapolatedCoords
  ---- outputs: oExtrapolatedCoords
  --final_reg : process (clk, sinit)
  --begin  -- process final_reg
  --  if sinit = '0' then                 -- asynchronous reset (active low)
  --    oExtrapolatedCoords <= (others => ("000000000", "0000000000"));
  --  elsif clk'event and clk = '1' then  -- rising clock edge
  --    oExtrapolatedCoords <= sExtrapolatedCoords;
  --  end if;
  --end process final_reg;
end Behavioral;

