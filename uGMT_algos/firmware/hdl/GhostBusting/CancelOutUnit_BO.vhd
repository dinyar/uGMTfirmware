library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

use work.mp7_data_types.all;
use work.ipbus.all;
use work.ipbus_decode_cancel_out_bo.all;

use work.GMTTypes.all;

entity CancelOutUnit_BO is
  generic (
    CANCEL_OUT_TYPE  : string := string'("COORDINATE"); -- which type of cancel-out should be used.
    DATA_FILE        : string;
    LOCAL_PHI_OFFSET : signed(8 downto 0)
    );
  port (
    clk_ipb     : in  std_logic;
    rst         : in  std_logic;
    ipb_in      : in  ipb_wbus;
    ipb_out     : out ipb_rbus;
    iWedges_Ovl : in  TGMTMuTracks_vector (5 downto 0);
    iWedges_B   : in  TGMTMuTracks_vector (11 downto 0);
    oCancel_Ovl : out std_logic_vector (17 downto 0);
    oCancel_B   : out std_logic_vector (35 downto 0);
    clk         : in  std_logic
    );
end CancelOutUnit_BO;

architecture Behavioral of CancelOutUnit_BO is
  signal ipbw      : ipb_wbus_array(N_SLAVES-1 downto 0);
  signal ipbr      : ipb_rbus_array(N_SLAVES-1 downto 0);

  -- Need:
  -- vector of 3 to hold cancel bits for three muons
  -- vector of 4 to hold above vector for each wedge that is compared
  -- against.
  -- vector of 6/12 to hold above wedge (all cancels for one subsystem)
  type   cancel_vec is array (integer range <>) of TCancelWedge(3 downto 0);
  signal sCancel1 : cancel_vec(5 downto 0);
  signal sCancel2 : cancel_vec(11 downto 0);
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
        sel             => ipbus_sel_cancel_out_bo(ipb_in.ipb_addr),
        ipb_to_slaves   => ipbw,
        ipb_from_slaves => ipbr
        );


  -----------------------------------------------------------------------------
  -- Basic layout of ovl wedges vs. BMTF wedges:
  --
  -- ___ _____________________...
  -- |  ||____________________...
  -- |__||____________________...
  -- |  ||____________________...
  -- |__||____________________...
  -- |  ||____________________...
  --
  -- => Cancel out between one ovl wedge and 2+2 BMTF wedges (due to
  -- crossings in phi as well as in eta.
  --
  -- First comparing ovl wedge with "above" BMTF wedge, then with first adjacent
  -- BMTF wedge, second adjacent BMTF wedge and finally with BMTF wedge below.
  -----------------------------------------------------------------------------
  g1 : for i in 0 to 5 generate
    x0 : entity work.CancelOutUnit_BO_WedgeComp
    generic map (
      CANCEL_OUT_TYPE  => CANCEL_OUT_TYPE,
      DATA_FILE        => DATA_FILE,
      LOCAL_PHI_OFFSET => LOCAL_PHI_OFFSET
      )
    port map (
      clk_ipb => clk_ipb,
      rst     => rst,
      ipb_in  => ipbw(i),
      ipb_out => ipbr(i),
      iWedge_Ovl  => iWedges_Ovl(i),
      iWedge_B1  => iWedges_B((2*i) mod iWedges_B'length),
      iWedge_B2  => iWedges_B((2*i+1) mod iWedges_B'length),
      iWedge_B3  => iWedges_B((2*i+2) mod iWedges_B'length),
      iWedge_B4  => iWedges_B((2*i+3) mod iWedges_B'length),
      oCancel_Ovl  => sCancel1(i),
      oCancel_B1 => sCancel2((2*i) mod iWedges_B'length)(0),
      oCancel_B2 => sCancel2((2*i+1) mod iWedges_B'length)(1),
      oCancel_B3 => sCancel2((2*i+2) mod iWedges_B'length)(1),
      oCancel_B4 => sCancel2((2*i+3) mod iWedges_B'length)(0),
      clk     => clk
      );
  end generate g1;

  -- Now OR all i'th cancels.
  g2 : for i in iWedges_Ovl'range generate
    oCancel_Ovl((i+1)*3-1 downto i*3) <= sCancel1(i)(0) or sCancel1(i)(1) or sCancel1(i)(2) or sCancel1(i)(3);
  end generate g2;
  g3 : for i in iWedges_B'range generate
    oCancel_B((i+1)*3-1 downto i*3) <= sCancel2(i)(0) or sCancel2(i)(1);
  end generate g3;
end Behavioral;
