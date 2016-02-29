library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

use work.mp7_data_types.all;
use work.ipbus.all;
use work.ipbus_decode_cancel_out_eo.all;

use work.GMTTypes.all;

entity CancelOutUnit_EO is
  generic (
    MUON_SELECTION_ALGO : string; -- how to select the winning muon
    CANCEL_OUT_TYPE     : string := string'("COORDINATE"); -- which type of cancel-out should be used.
    DATA_FILE           : string;
    LOCAL_PHI_OFFSET    : signed(8 downto 0)
    );
  port (
    clk_ipb   : in  std_logic;
    rst       : in  std_logic;
    ipb_in    : in  ipb_wbus;
    ipb_out   : out ipb_rbus;
    iWedges_O : in  TGMTMuTracks_vector (5 downto 0);
    iWedges_E : in  TGMTMuTracks_vector (5 downto 0);
    oCancel_O : out std_logic_vector (17 downto 0);
    oCancel_E : out std_logic_vector (17 downto 0);
    clk       : in  std_logic
    );
end CancelOutUnit_EO;

architecture Behavioral of CancelOutUnit_EO is
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
        sel             => ipbus_sel_cancel_out_eo(ipb_in.ipb_addr),
        ipb_to_slaves   => ipbw,
        ipb_from_slaves => ipbr
        );


  -- Compare muons from same wedge (and neighbouring ones) with each
  -- other).
  g1 : for i in iWedges_O'range generate
      x0 : entity work.CancelOutUnit_EO_WedgeComp
      generic map (
        MUON_SELECTION_ALGO => MUON_SELECTION_ALGO,
        CANCEL_OUT_TYPE     => CANCEL_OUT_TYPE,
        DATA_FILE           => DATA_FILE,
        LOCAL_PHI_OFFSET    => LOCAL_PHI_OFFSET
        )
        port map (
          clk_ipb       => clk_ipb,
          rst           => rst,
          ipb_in        => ipbw(i),
          ipb_out       => ipbr(i),
          iWedge_O      => iWedges_O(i),
          iWedge_EMTF1  => iWedges_E((i-1) mod iWedges_E'length),
          iWedge_EMTF2  => iWedges_E(i),
          iWedge_EMTF3  => iWedges_E((i+1) mod iWedges_E'length),
          oCancel_O     => sCancel1(i),
          oCancel_EMTF1 => sCancel2((i-1) mod iWedges_E'length)(2),
          oCancel_EMTF2 => sCancel2(i)(0),
          oCancel_EMTF3 => sCancel2((i+1) mod iWedges_E'length)(1),
          clk           => clk
          );
  end generate g1;

  -- Now OR all i'th cancels.
  g3 : for i in iWedges_O'range generate
    oCancel_O((i+1)*3-1 downto i*3)   <= sCancel1(i)(0) or sCancel1(i)(1) or sCancel1(i)(2);
    oCancel_E((i+1)*3-1 downto i*3)   <= sCancel2(i)(0) or sCancel2(i)(1) or sCancel2(i)(2);
  end generate g3;
end Behavioral;
