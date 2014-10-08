-------------------------------------------------------------------------------
-- Receives track addresses of all muons found in the passed wedges, then
-- compares each wedge with its right neighbour. In this way every wedge is
-- compared to both neighbours because the operation is symmetric.
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

use work.mp7_data_types.all;
use work.ipbus.all;

use work.GMTTypes.all;

entity CancelOutUnit_Single is
  generic (
    num_wedges : natural := 12;         -- number of wedges to be checked
    num_tracks : natural := 3           -- number of tracks per wedge
    );
  port (
    clk_ipb : in  std_logic;
    rst     : in  std_logic;
    ipb_in  : in  ipb_wbus;
    ipb_out : out ipb_rbus;
    iWedges : in  TGMTMuTracks_vector (0 to num_wedges-1);
    oCancel : out std_logic_vector (0 to num_tracks*num_wedges-1);
    clk     : in  std_logic
    );
end CancelOutUnit_Single;

architecture Behavioral of CancelOutUnit_Single is
  signal sel_wedge : std_logic_vector(3 downto 0);
  signal ipbw      : ipb_wbus_array(num_wedges-1 downto 0);
  signal ipbr      : ipb_rbus_array(num_wedges-1 downto 0);

  signal sCancel1 : std_logic_vector(oCancel'range);
  signal sCancel2 : std_logic_vector(oCancel'range);
begin
  -----------------------------------------------------------------------------
  -- ipbus address decode
  -----------------------------------------------------------------------------
  -- Use bits before beginning of addresses that are required for later
  -- addressing (i.e. addresses inside LUTs and possible substructure)
  -- Need to address 12 or 6 wedges -> 3 or 4 bits needed
  -- 6 bits used in internal addressing of wedges -> will use 9th to 6th bit or
  -- 8 to 6th.
  -- TODO: Maybe make this more elegant?
  all_wedges : if num_wedges > 9 generate
    sel_wedge <= std_logic_vector(unsigned(ipb_in.ipb_addr(9 downto 6)));

    fabric : entity work.ipbus_fabric_sel
      generic map(
        NSLV      => num_wedges,
        SEL_WIDTH => 4)
      port map(
        ipb_in          => ipb_in,
        ipb_out         => ipb_out,
        sel             => sel_wedge,
        ipb_to_slaves   => ipbw,
        ipb_from_slaves => ipbr
        );
  end generate all_wedges;

  half_wedges : if num_wedges <= 9 generate
    sel_wedge(2 downto 0) <= std_logic_vector(unsigned(ipb_in.ipb_addr(8 downto 6)));

    fabric : entity work.ipbus_fabric_sel
      generic map(
        NSLV      => num_wedges,
        SEL_WIDTH => 3)
      port map(
        ipb_in          => ipb_in,
        ipb_out         => ipb_out,
        sel             => sel_wedge(2 downto 0),
        ipb_to_slaves   => ipbw,
        ipb_from_slaves => ipbr
        );    
  end generate half_wedges;


  -- Only compare muons with those from neighbouring wedges.
  g1 : for i in iWedges'range generate
    x1 : entity work.WedgeCheckerUnit
      port map (
        clk_ipb => clk_ipb,
        rst     => rst,
        ipb_in  => ipbw(i),
        ipb_out => ipbr(i),
        wedge1  => iWedges(i),
        wedge2  => iWedges((i+1) mod iWedges'length),
        ghosts1 => sCancel1(num_tracks*i to num_tracks*(i+1)-1),
        ghosts2 => sCancel2(num_tracks*i to num_tracks*(i+1)-1),
        clk     => clk);
  end generate g1;

  oCancel <= sCancel1 or sCancel2;
  
end Behavioral;
