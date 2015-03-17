library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

use work.mp7_data_types.all;
use work.ipbus.all;
use work.ipbus_decode_cancel_out_fo.all;

use work.GMTTypes.all;

entity CancelOutUnit_FO is
  port (
    clk_ipb     : in  std_logic;
    rst         : in  std_logic;
    ipb_in      : in  ipb_wbus;
    ipb_out     : out ipb_rbus;
    iWedges_Ovl : in  TGMTMuTracks_vector (5 downto 0);
    iWedges_F   : in  TGMTMuTracks_vector (5 downto 0);
    oCancel_Ovl : out std_logic_vector (17 downto 0);
    oCancel_F   : out std_logic_vector (17 downto 0);
    clk         : in  std_logic
    );
end CancelOutUnit_FO;

architecture Behavioral of CancelOutUnit_FO is
  signal ipbw      : ipb_wbus_array(N_SLAVES-1 downto 0);
  signal ipbr      : ipb_rbus_array(N_SLAVES-1 downto 0);

  -- Need:
  -- vector of 3 to hold cancel bits for one muon (to all neighbouring wedges)
  -- vector of 3 to hold above vector (all cancels for one wedge)
  -- vector of 12 to hold above wedge (all cancels for one subsystem)
  type   cancel_vec is array (integer range <>) of TCancelWedge(2 downto 0);
  signal sCancel1 : cancel_vec(5 downto 0);
  signal sCancel2 : cancel_vec(5 downto 0);

begin
    -- IPbus address decode
    fabric : entity work.ipbus_fabric_sel
      generic map(
        NSLV      => N_SLAVES,
        SEL_WIDTH => IPBUS_SEL_WIDTH
        )
      port map(
        ipb_in          => ipb_in,
        ipb_out         => ipb_out,
        sel             => ipbus_sel_cancel_out_fo(ipb_in.ipb_addr),
        ipb_to_slaves   => ipbw,
        ipb_from_slaves => ipbr
        );


  -- Compare muons from same wedge (and neighbouring ones) with each
  -- other).
  g1 : for i in iWedges_Ovl'range generate
      x0 : entity work.CancelOutUnit_FO_WedgeComp
        port map (
          clk_ipb => clk_ipb,
          rst     => rst,
          ipb_in  => ipbw(i),
          ipb_out => ipbr(i),
          iWedge_Ovl  => iWedges_Ovl(i),
          iWedge_Fwd1 => iWedges_F((i-1) mod iWedges_F'length),
          iWedge_Fwd2 => iWedges_F(i),
          iWedge_Fwd3 => iWedges_F((i+1) mod iWedges_F'length),
          oCancel_Ovl => sCancel1(i),
          oCancel_Fwd1 => sCancel2((i-1) mod iWedges_F'length)(2),
          oCancel_Fwd2 => sCancel2(i)(0),
          oCancel_Fwd3 => sCancel2((i+1) mod iWedges_F'length)(1),
          clk => clk
          );
  end generate g1;

  -- Now OR all i'th cancels.
  g3 : for i in iWedges_Ovl'range generate
    oCancel_Ovl((i+1)*3-1 downto i*3) <= sCancel1(i)(0) or sCancel1(i)(1) or sCancel1(i)(2);
    oCancel_F((i+1)*3-1 downto i*3)   <= sCancel2(i)(0) or sCancel2(i)(1) or sCancel2(i)(2);
  end generate g3;
end Behavioral;
