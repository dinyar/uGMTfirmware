-------------------------------------------------------------------------------
-- Receives track addresses of all muons found in the passed wedges, then
-- compares each wedge with its right neighbour. In this way every wedge is
-- compared to both neighbours because the operation is symmetric.
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
library types;
use Types.GMTTypes.all;

entity CancelOutUnit_Single is
  generic (
    num_wedges : natural := 12;         -- number of wedges to be checked
    num_tracks : natural := 3);         -- number of tracks per wedge
  port (iWedges : in  TGMTMuTracks_vector (0 to num_wedges-1);
        oCancel : out std_logic_vector (0 to num_tracks*num_wedges-1);
        clk     : in  std_logic);
end CancelOutUnit_Single;

architecture Behavioral of CancelOutUnit_Single is
  component WedgeCheckerUnit
    port (
      wedge1  : in  TGMTMuTracks3;
      wedge2  : in  TGMTMuTracks3;
      ghosts1 : out std_logic_vector(0 to num_tracks-1);
      ghosts2 : out std_logic_vector(0 to num_tracks-1);
      clk     : in  std_logic);
  end component;
  signal sCancel1 : std_logic_vector(oCancel'range);
  signal sCancel2 : std_logic_vector(oCancel'range);
begin
  -- Only compare muons with those from neighbouring wedges.
  g1 : for i in iWedges'range generate
    x1 : WedgeCheckerUnit
      port map (
        wedge1  => iWedges(i),
        wedge2  => iWedges((i+1) mod iWedges'length),
        ghosts1 => sCancel1(num_tracks*i to num_tracks*(i+1)-1),
        ghosts2 => sCancel2(num_tracks*i to num_tracks*(i+1)-1),
        clk     => clk);
  end generate g1;
  
  oCancel <= sCancel1 or sCancel2;
  
end Behavioral;
