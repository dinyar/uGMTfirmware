library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

use work.mp7_data_types.all;
use work.ipbus.all;
use work.ipbus_decode_cancel_out_bo_wedge.all;

use work.GMTTypes.all;

entity CancelOutUnit_BO_WedgeComp is
  generic (
    COORDINATE_BASED : boolean := true -- whether coordinate-based cancel-out should be done.
    DATA_FILE        : string;
    LOCAL_PHI_OFFSET : signed(8 downto 0)
    );
  port (
    clk_ipb     : in  std_logic;
    rst         : in  std_logic;
    ipb_in      : in  ipb_wbus;
    ipb_out     : out ipb_rbus;
    iWedge_Ovl : in  TGMTMuTracks;
    iWedge_B1   : in  TGMTMuTracks;
    iWedge_B2   : in  TGMTMuTracks;
    iWedge_B3   : in  TGMTMuTracks;
    iWedge_B4   : in  TGMTMuTracks;
    oCancel_Ovl : out TCancelWedge(3 downto 0);
    oCancel_B1  : out std_logic_vector(2 downto 0);
    oCancel_B2  : out std_logic_vector(2 downto 0);
    oCancel_B3  : out std_logic_vector(2 downto 0);
    oCancel_B4  : out std_logic_vector(2 downto 0);
    clk         : in  std_logic
    );
end CancelOutUnit_BO_WedgeComp;

architecture Behavioral of CancelOutUnit_BO_WedgeComp is
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
        sel             => ipbus_sel_cancel_out_bo_wedge(ipb_in.ipb_addr),
        ipb_to_slaves   => ipbw,
        ipb_from_slaves => ipbr
        );

    x0 : entity work.WedgeCheckerUnit
    generic map (
      COORDINATE_BASED => COORDINATE_BASED,
      DATA_FILE        => DATA_FILE,
      LOCAL_PHI_OFFSET => -LOCAL_PHI_OFFSET
      )
      port map (
        clk_ipb => clk_ipb,
        rst     => rst,
        ipb_in  => ipbw(N_SLV_CANCEL_OUT_MEMS_0),
        ipb_out => ipbr(N_SLV_CANCEL_OUT_MEMS_0),
        wedge1  => iWedge_Ovl,
        wedge2  => iWedge_B1,
        ghosts1 => oCancel_Ovl(0),
        ghosts2 => oCancel_B1,
        clk     => clk);
    x1 : entity work.WedgeCheckerUnit
    generic map (
      COORDINATE_BASED => COORDINATE_BASED,
      DATA_FILE        => DATA_FILE,
      LOCAL_PHI_OFFSET => to_signed(0, 9)
      )
      port map (
        clk_ipb => clk_ipb,
        rst     => rst,
        ipb_in  => ipbw(N_SLV_CANCEL_OUT_MEMS_1),
        ipb_out => ipbr(N_SLV_CANCEL_OUT_MEMS_1),
        wedge1  => iWedge_Ovl,
        wedge2  => iWedge_B2,
        ghosts1 => oCancel_Ovl(1),
        ghosts2 => oCancel_B2,
        clk     => clk);
    x2 : entity work.WedgeCheckerUnit
    generic map (
      COORDINATE_BASED => COORDINATE_BASED,
      DATA_FILE        => DATA_FILE,
      LOCAL_PHI_OFFSET => LOCAL_PHI_OFFSET
      )
      port map (
        clk_ipb => clk_ipb,
        rst     => rst,
        ipb_in  => ipbw(N_SLV_CANCEL_OUT_MEMS_2),
        ipb_out => ipbr(N_SLV_CANCEL_OUT_MEMS_2),
        wedge1  => iWedge_Ovl,
        wedge2  => iWedge_B3,
        ghosts1 => oCancel_Ovl(2),
        ghosts2 => oCancel_B3,
        clk     => clk);
    x3 : entity work.WedgeCheckerUnit
    generic map (
      COORDINATE_BASED => COORDINATE_BASED,
      DATA_FILE        => DATA_FILE,
      LOCAL_PHI_OFFSET => resize(2*LOCAL_PHI_OFFSET, 9)
      )
      port map (
        clk_ipb => clk_ipb,
        rst     => rst,
        ipb_in  => ipbw(N_SLV_CANCEL_OUT_MEMS_3),
        ipb_out => ipbr(N_SLV_CANCEL_OUT_MEMS_3),
        wedge1  => iWedge_Ovl,
        wedge2  => iWedge_B4,
        ghosts1 => oCancel_Ovl(3),
        ghosts2 => oCancel_B4,
        clk     => clk);

end Behavioral;
