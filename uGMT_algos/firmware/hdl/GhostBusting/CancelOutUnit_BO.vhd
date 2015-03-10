library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

use work.mp7_data_types.all;
use work.ipbus.all;

use work.GMTTypes.all;

entity CancelOutUnit_BO is
  port (
    clk_ipb     : in  std_logic;
    rst         : in  std_logic;
    ipb_in      : in  ipb_wbus;
    ipb_out     : out ipb_rbus;
    iWedges_Ovl : in  TGMTMuTracks_vector (0 to 5);
    iWedges_B   : in  TGMTMuTracks_vector (0 to 11);
    oCancel_Ovl : out std_logic_vector (0 to 17);
    oCancel_B   : out std_logic_vector (0 to 35);
    clk         : in  std_logic
    );
end CancelOutUnit_BO;

architecture Behavioral of CancelOutUnit_BO is
  signal sel_wedge : std_logic_vector(4 downto 0);
  signal ipbw      : ipb_wbus_array(4*iWedges_Ovl'length -1 downto 0);
  signal ipbr      : ipb_rbus_array(4*iWedges_Ovl'length -1 downto 0);


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
  -- ipbus address decode
  -----------------------------------------------------------------------------
  -- Use bits before beginning of addresses that are required for later
  -- addressing (i.e. addresses inside LUTs and possible substructure)
  -- Need to address 6x4 wedges -> 5 bits needed.
  -- 6 bits used in internal addressing of wedges -> will use 10th to 6th bit
  sel_wedge <= std_logic_vector(unsigned(ipb_in.ipb_addr(10 downto 6)));

  fabric : entity work.ipbus_fabric_sel
    generic map(
      NSLV      => 24,
      SEL_WIDTH => 5)
    port map(
      ipb_in          => ipb_in,
      ipb_out         => ipb_out,
      sel             => sel_wedge,
      ipb_to_slaves   => ipbw,
      ipb_from_slaves => ipbr
      );


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
      -- TODO: Move contents of this loop into it's own module?
    x0 : entity work.WedgeCheckerUnit
      port map (
        clk_ipb => clk_ipb,
        rst     => rst,
        ipb_in  => ipbw(4*i),
        ipb_out => ipbr(4*i),
        wedge1  => iWedges_Ovl(i),
        wedge2  => iWedges_B((2*i-1) mod iWedges_B'length),
        ghosts1 => sCancel1(i)(0),
        ghosts2 => sCancel2((2*i-1) mod iWedges_B'length)(0),
        clk     => clk);
    x1 : entity work.WedgeCheckerUnit
      port map (
        clk_ipb => clk_ipb,
        rst     => rst,
        ipb_in  => ipbw(4*i+1),
        ipb_out => ipbr(4*i+1),
        wedge1  => iWedges_Ovl(i),
        wedge2  => iWedges_B(2*i),
        ghosts1 => sCancel1(i)(1),
        ghosts2 => sCancel2(2*i)(1),
        clk     => clk);
    x2 : entity work.WedgeCheckerUnit
      port map (
        clk_ipb => clk_ipb,
        rst     => rst,
        ipb_in  => ipbw(4*i+2),
        ipb_out => ipbr(4*i+2),
        wedge1  => iWedges_Ovl(i),
        wedge2  => iWedges_B(2*i+1),
        ghosts1 => sCancel1(i)(2),
        ghosts2 => sCancel2(2*i+1)(1),
        clk     => clk);
    x3 : entity work.WedgeCheckerUnit
      port map (
        clk_ipb => clk_ipb,
        rst     => rst,
        ipb_in  => ipbw(4*i+3),
        ipb_out => ipbr(4*i+3),
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
