library IEEE;
use IEEE.STD_LOGIC_1164.all;

use IEEE.NUMERIC_STD.all;

library types;
use Types.GMTTypes.all;

entity WedgeCheckerUnit is
  port (wedge1  : in  TGMTMuTracks3;
        wedge2  : in  TGMTMuTracks3;
        ghosts1 : out std_logic_vector (0 to 2);
        ghosts2 : out std_logic_vector (0 to 2);
        clk     : in  std_logic); 

end WedgeCheckerUnit;

architecture Behavioral of WedgeCheckerUnit is
  component GhostCheckerUnit
    port (
      mu1    : in  TMuonAddress;
      qual1  : in  unsigned(0 to 3);
      mu2    : in  TMuonAddress;
      qual2  : in  unsigned(0 to 3);
      ghost1 : out std_logic;
      ghost2 : out std_logic);
  end component;

  component GhostCheckerUnit_spatialCoords
    port (
      eta1   : in  signed(0 to 8);
      phi1   : in  unsigned(0 to 9);
      qual1  : in  unsigned(0 to 3);
      eta2   : in  signed(0 to 8);
      phi2   : in  unsigned(0 to 9);
      qual2  : in  unsigned(0 to 3);
      ghost1 : out std_logic;
      ghost2 : out std_logic;
      clk    : in  std_logic);
  end component;

  subtype muon_cancel is std_logic_vector(wedge2'range);
  type    muon_cancel_vec is array (integer range <>) of muon_cancel;
  signal  sCancel1 : muon_cancel_vec(wedge1'range);
  signal  sCancel2 : muon_cancel_vec(wedge2'range);
begin
  -- Compare the two wedges' muons with each other.
  g1 : for i in wedge1'range generate
    g2 : for j in wedge2'range generate
      --x : GhostCheckerUnit
      --  port map (
      --    mu1   => wedge1(i).address,
      --    qual1 => wedge1(i).qual,
      --    mu2   => wedge2(j).address,
      --    qual2 => wedge2(i).qual,
      --    ghost1 => sCancel1(j)(i),      -- TODO: Is this correct?
      --    ghost2 => sCancel2(j)(i));     -- TODO: Is this correct?
      x : GhostCheckerUnit_spatialCoords
        port map (
          eta1   => wedge1(i).eta,
          phi1   => wedge1(i).phi,
          qual1  => wedge1(i).qual,
          eta2   => wedge2(j).eta,
          phi2   => wedge2(j).phi,
          qual2  => wedge2(i).qual,
          ghost1 => sCancel1(j)(i),
          ghost2 => sCancel2(j)(i),
          clk    => clk);
    end generate g2;
  end generate g1;

  g3 : for i in ghosts1'range generate
    ghosts1(i) <= sCancel1(i)(0) or sCancel1(i)(1) or sCancel1(i)(2);
    ghosts2(i) <= sCancel2(i)(0) or sCancel2(i)(1) or sCancel2(i)(2);
  end generate g3;
end Behavioral;

