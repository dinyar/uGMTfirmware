library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

use work.mp7_data_types.all;
use work.ipbus.all;
use work.ipbus_decode_cancel_out_eo_wedge.all;

use work.GMTTypes.all;

entity CancelOutUnit_EO_WedgeComp is
  generic (
    MUON_SELECTION_ALGO : string; -- how to select the winning muon
    CANCEL_OUT_TYPE     : string := string'("COORDINATE"); -- which type of cancel-out should be used.
    DATA_FILE           : string;
    LOCAL_PHI_OFFSET    : signed(8 downto 0)
    );
  port (
    clk_ipb       : in  std_logic;
    rst           : in  std_logic;
    ipb_in        : in  ipb_wbus;
    ipb_out       : out ipb_rbus;
    iWedge_O      : in  TGMTMuTracks;
    iWedge_EMTF1  : in  TGMTMuTracks;
    iWedge_EMTF2  : in  TGMTMuTracks;
    iWedge_EMTF3  : in  TGMTMuTracks;
    oCancel_O     : out TCancelWedge(2 downto 0);
    oCancel_EMTF1 : out std_logic_vector (2 downto 0);
    oCancel_EMTF2 : out std_logic_vector (2 downto 0);
    oCancel_EMTF3 : out std_logic_vector (2 downto 0);
    clk           : in  std_logic
    );
end CancelOutUnit_EO_WedgeComp;

architecture Behavioral of CancelOutUnit_EO_WedgeComp is
  signal ipbw      : ipb_wbus_array(N_SLAVES-1 downto 0);
  signal ipbr      : ipb_rbus_array(N_SLAVES-1 downto 0);

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
        sel             => ipbus_sel_cancel_out_eo_wedge(ipb_in.ipb_addr),
        ipb_to_slaves   => ipbw,
        ipb_from_slaves => ipbr
        );


  -- Compare muons from this wedge with muons from each neighbour
  x0 : entity work.WedgeCheckerUnit
  generic map (
    MUON_SELECTION_ALGO => MUON_SELECTION_ALGO,
    CANCEL_OUT_TYPE     => CANCEL_OUT_TYPE,
    DATA_FILE           => DATA_FILE,
    LOCAL_PHI_OFFSET    => -LOCAL_PHI_OFFSET
    )
  port map (
    clk_ipb => clk_ipb,
    rst     => rst,
    ipb_in  => ipbw(N_SLV_CANCEL_OUT_MEMS_0),
    ipb_out => ipbr(N_SLV_CANCEL_OUT_MEMS_0),
    wedge1  => iWedge_O,
    wedge2  => iWedge_EMTF1,
    ghosts1 => oCancel_O(0),
    ghosts2 => oCancel_EMTF1,
    clk     => clk);
  x1 : entity work.WedgeCheckerUnit
  generic map (
    MUON_SELECTION_ALGO => MUON_SELECTION_ALGO,
    CANCEL_OUT_TYPE     => CANCEL_OUT_TYPE,
    DATA_FILE           => DATA_FILE,
    LOCAL_PHI_OFFSET    => to_signed(0, 9)
    )
  port map (
    clk_ipb => clk_ipb,
    rst     => rst,
    ipb_in  => ipbw(N_SLV_CANCEL_OUT_MEMS_1),
    ipb_out => ipbr(N_SLV_CANCEL_OUT_MEMS_1),
    wedge1  => iWedge_O,
    wedge2  => iWedge_EMTF2,
    ghosts1 => oCancel_O(1),
    ghosts2 => oCancel_EMTF2,
    clk     => clk);
  x2 : entity work.WedgeCheckerUnit
  generic map (
    MUON_SELECTION_ALGO => MUON_SELECTION_ALGO,
    CANCEL_OUT_TYPE     => CANCEL_OUT_TYPE,
    DATA_FILE           => DATA_FILE,
    LOCAL_PHI_OFFSET    => LOCAL_PHI_OFFSET
  )
  port map (
    clk_ipb => clk_ipb,
    rst     => rst,
    ipb_in  => ipbw(N_SLV_CANCEL_OUT_MEMS_2),
    ipb_out => ipbr(N_SLV_CANCEL_OUT_MEMS_2),
    wedge1  => iWedge_O,
    wedge2  => iWedge_EMTF3,
    ghosts1 => oCancel_O(2),
    ghosts2 => oCancel_EMTF3,
    clk     => clk);

end Behavioral;
