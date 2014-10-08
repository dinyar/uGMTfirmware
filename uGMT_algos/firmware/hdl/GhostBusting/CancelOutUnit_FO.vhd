library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

use work.mp7_data_types.all;
use work.ipbus.all;

use work.GMTTypes.all;

entity CancelOutUnit_FO is
  port (
    clk_ipb     : in  std_logic;
    rst         : in  std_logic;
    ipb_in      : in  ipb_wbus;
    ipb_out     : out ipb_rbus;
    iWedges_Ovl : in  TGMTMuTracks_vector (0 to 5);
    iWedges_F   : in  TGMTMuTracks_vector (0 to 5);
    oCancel_Ovl : out std_logic_vector (0 to 17);
    oCancel_F   : out std_logic_vector (0 to 17);
    clk         : in  std_logic
    );
end CancelOutUnit_FO;

architecture Behavioral of CancelOutUnit_FO is
  signal sel_wedge : std_logic_vector(4 downto 0);
  signal ipbw      : ipb_wbus_array(3*iWedges_Ovl'length -1 downto 0);
  signal ipbr      : ipb_rbus_array(3*iWedges_Ovl'length -1 downto 0);

  -- Need:
  -- vector of 3 to hold cancel bits for one muon (to all neighbouring wedges)
  -- vector of 3 to hold above vector (all cancels for one wedge)
  -- vector of 12 to hold above wedge (all cancels for one subsystem)
  type   cancel_wedge is array (0 to 2) of std_logic_vector(0 to 2);
  type   cancel_vec is array (integer range <>) of cancel_wedge;
  signal sCancel1 : cancel_vec(0 to 11);
  signal sCancel2 : cancel_vec(0 to 11);

begin
  -----------------------------------------------------------------------------
  -- ipbus address decode
  -----------------------------------------------------------------------------
  -- Use bits before beginning of addresses that are required for later
  -- addressing (i.e. addresses inside LUTs and possible substructure)
  -- Need to address 6x3 wedges -> 5 bits needed.
  -- 6 bits used in internal addressing of wedges -> will use 10th to 6th bit
  sel_wedge <= std_logic_vector(unsigned(ipb_in.ipb_addr(10 downto 6)));

  fabric : entity work.ipbus_fabric_sel
    generic map(
      NSLV      => 18,
      SEL_WIDTH => 5)
    port map(
      ipb_in          => ipb_in,
      ipb_out         => ipb_out,
      sel             => sel_wedge,
      ipb_to_slaves   => ipbw,
      ipb_from_slaves => ipbr
      );


  -- Compare muons from same wedge (and neighbouring ones) with each
  -- other).
  g1 : for i in iWedges_Ovl'range generate
    x0 : entity work.WedgeCheckerUnit
      port map (
        clk_ipb => clk_ipb,
        rst     => rst,
        ipb_in  => ipbw(3*i),
        ipb_out => ipbr(3*i),
        wedge1  => iWedges_Ovl(i),
        wedge2  => iWedges_F((i-1) mod iWedges_F'length),
        ghosts1 => sCancel1(i)(0),
        ghosts2 => sCancel2((i-1) mod iWedges_F'length)(2),
        clk     => clk);
    x1 : entity work.WedgeCheckerUnit
      port map (
        clk_ipb => clk_ipb,
        rst     => rst,
        ipb_in  => ipbw(3*i+1),
        ipb_out => ipbr(3*i+1),
        wedge1  => iWedges_Ovl(i),
        wedge2  => iWedges_F(i),
        ghosts1 => sCancel1(i)(1),
        ghosts2 => sCancel2(i)(0),
        clk     => clk);
    x2 : entity work.WedgeCheckerUnit
      port map (
        clk_ipb => clk_ipb,
        rst     => rst,
        ipb_in  => ipbw(3*i+2),
        ipb_out => ipbr(3*i+2),
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
