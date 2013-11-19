library IEEE;
use IEEE.STD_LOGIC_1164.all;
library Types;
use Types.GMTTypes.all;

entity CancelOutUnit_BO is
  port (iWedges_Ovl : in  TGMTMuTracks_vector (0 to 5);
        iWedges_B   : in  TGMTMuTracks_vector (0 to 11);
        oCancel_Ovl : out std_logic_vector (0 to 17);
        oCancel_B   : out std_logic_vector (0 to 35);
        clk         : in  std_logic);
end CancelOutUnit_BO;

architecture Behavioral of CancelOutUnit_BO is
  component WedgeCheckerUnit
    port (
      wedge1  : in  TGMTMuTracks3;
      wedge2  : in  TGMTMuTracks3;
      ghosts1 : out std_logic_vector(0 to 2);
      ghosts2 : out std_logic_vector(0 to 2);
      clk     : in  std_logic);
  end component;

  -- Need:
  -- vector of 3 to hold cancel bits for three muons
  -- vector of 4 to hold above vector for each wedge that is compared
  -- against.
  -- vector of 12 to hold above wedge (all cancels for one subsystem)
  type   cancel_wedge is array (0 to 3) of std_logic_vector(0 to 2);
  type   cancel_vec is array (integer range <>) of cancel_wedge;
  signal sCancel1 : cancel_vec(0 to 11);
  signal sCancel2 : cancel_vec(0 to 11);
begin
  -----------------------------------------------------------------------------
  -- Basic layout of ovl wedges vs. barrel wedges:
  --
  -- ___ _____________________...
  -- |  ||____________________...
  -- |__||____________________...
  -- |  ||____________________...
  -- |__||____________________...
  -- |  ||____________________...
  --
  -- => Cancel out between one ovl wedge and 2+2 barrel wedges (due to
  -- crossings in phi as well as in eta.
  --
  -- First comparing ovl wedge with "above" brl wedge, then with first adjacent
  -- brl wedge, second adjacent brl wedge and finally with brl wedge below.
  -----------------------------------------------------------------------------
  g1 : for i in 0 to 5 generate
    x0 : WedgeCheckerUnit
      port map (
        wedge1  => iWedges_Ovl(i),
        wedge2  => iWedges_B((2*i-1) mod iWedges_B'length),
        ghosts1 => sCancel1(i)(0),
        ghosts2 => sCancel2((2*i-1) mod iWedges_B'length)(0),
        clk     => clk);
    x1 : WedgeCheckerUnit
      port map (
        wedge1  => iWedges_Ovl(i),
        wedge2  => iWedges_B(2*i),
        ghosts1 => sCancel1(i)(1),
        ghosts2 => sCancel2(2*i)(1),
        clk     => clk);
    x2 : WedgeCheckerUnit
      port map (
        wedge1  => iWedges_Ovl(i),
        wedge2  => iWedges_B(2*i+1),
        ghosts1 => sCancel1(i)(2),
        ghosts2 => sCancel2(2*i+1)(1),
        clk     => clk);
    x3 : WedgeCheckerUnit
      port map (
        wedge1  => iWedges_Ovl(i),
        wedge2  => iWedges_B((2*i+2) mod iWedges_B'length),
        ghosts1 => sCancel1(i)(3),
        ghosts2 => sCancel2((2*i+2) mod iWedges_B'length)(0),
        clk     => clk);
  end generate g1;

  -- Now OR all i'th cancels.
  g2 : for i in iWedges_Ovl'range generate
    oCancel_Ovl(i*3 to (i+1)*3-1) <= sCancel1(i)(0) or sCancel1(i)(1) or sCancel1(i)(2) or sCancel1(i)(3);
  end generate g2;
  g3 : for i in iWedges_B'range generate
    oCancel_B(i*3 to (i+1)*3-1) <= sCancel2(i)(0) or sCancel2(i)(1);
  end generate g3;
end Behavioral;
