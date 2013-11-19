library IEEE;
use IEEE.STD_LOGIC_1164.all;
library Types;
use Types.GMTTypes.all;

entity CancelOutUnit_FO is
  port (iWedges_Ovl : in  TGMTMuTracks_vector (0 to 5);
        iWedges_F   : in  TGMTMuTracks_vector (0 to 5);
        oCancel_Ovl : out std_logic_vector (0 to 17);
        oCancel_F   : out std_logic_vector (0 to 17);
        clk         : in  std_logic);
end CancelOutUnit_FO;

architecture Behavioral of CancelOutUnit_FO is
  component WedgeCheckerUnit
    port (
      wedge1  : in  TGMTMuTracks3;
      wedge2  : in  TGMTMuTracks3;
      ghosts1 : out std_logic_vector(0 to 2);
      ghosts2 : out std_logic_vector(0 to 2);
      clk     : in  std_logic);
  end component;

  -- Need:
  -- vector of 3 to hold cancel bits for one muon (to all neighbouring wedges)
  -- vector of 3 to hold above vector (all cancels for one wedge)
  -- vector of 12 to hold above wedge (all cancels for one subsystem)
  type   cancel_wedge is array (0 to 2) of std_logic_vector(0 to 2);
  type   cancel_vec is array (integer range <>) of cancel_wedge;
  signal sCancel1 : cancel_vec(0 to 11);
  signal sCancel2 : cancel_vec(0 to 11);

begin
  
  -- Compare muons from same wedge (and neighbouring ones) with each
  -- other).
  g1 : for i in iWedges_Ovl'range generate
      x0 : WedgeCheckerUnit
        port map (
          wedge1  => iWedges_Ovl(i),
          wedge2  => iWedges_F((i-1) mod iWedges_F'length),
          ghosts1 => sCancel1(i)(0),
          ghosts2 => sCancel2((i-1) mod iWedges_F'length)(2),
          clk     => clk);
      x1 : WedgeCheckerUnit
        port map (
          wedge1  => iWedges_Ovl(i),
          wedge2  => iWedges_F(i),
          ghosts1 => sCancel1(i)(1),
          ghosts2 => sCancel2(i)(0),
          clk     => clk);
      x2 : WedgeCheckerUnit
        port map (
          wedge1  => iWedges_Ovl(i),
          wedge2  => iWedges_F((i+1) mod iWedges_F'length),
          ghosts1 => sCancel1(i)(2),
          ghosts2 => sCancel2((i+1) mod iWedges_F'length)(1),
          clk     => clk);
  end generate g1;

  -- Now OR all i'th cancels.
  g3 : for i in iWedges_Ovl'range generate
    oCancel_Ovl(i*3 to (i+1)*3-1) <= sCancel1(i)(0) or sCancel1(i)(1) or sCancel1(i)(2);
    oCancel_F(i*3 to (i+1)*3-1)   <= sCancel2(i)(0) or sCancel2(i)(1) or sCancel2(i)(2);
  end generate g3;
end Behavioral;
