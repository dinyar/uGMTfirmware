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
use work.ipbus_decode_cancel_out_barrel.all;
use work.ipbus_decode_cancel_out_half_sorters.all;

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
    iWedges : in  TGMTMuTracks_vector (num_wedges-1 downto 0);
    oCancel : out std_logic_vector (num_tracks*num_wedges-1 downto 0);
    clk     : in  std_logic
    );
end CancelOutUnit_Single;

architecture Behavioral of CancelOutUnit_Single is
  signal ipbw      : ipb_wbus_array(num_wedges-1 downto 0);
  signal ipbr      : ipb_rbus_array(num_wedges-1 downto 0);

  signal sCancel1 : std_logic_vector(oCancel'range);
  signal sCancel2 : std_logic_vector(oCancel'range);
begin
  -- IPbus address decode
  all_wedges : if num_wedges = 12 generate
      fabric : entity work.ipbus_fabric_sel
        generic map(
          NSLV      => work.ipbus_decode_cancel_out_barrel.N_SLAVES,
          SEL_WIDTH => work.ipbus_decode_cancel_out_barrel.IPBUS_SEL_WIDTH
          )
        port map(
          ipb_in          => ipb_in,
          ipb_out         => ipb_out,
          sel             => ipbus_sel_cancel_out_barrel(ipb_in.ipb_addr),
          ipb_to_slaves   => ipbw,
          ipb_from_slaves => ipbr
          );
  end generate all_wedges;

  half_wedges : if num_wedges /= 12 generate
      fabric : entity work.ipbus_fabric_sel
        generic map(
          NSLV      => work.ipbus_decode_cancel_out_half_sorters.N_SLAVES,
          SEL_WIDTH => work.ipbus_decode_cancel_out_half_sorters.IPBUS_SEL_WIDTH
          )
        port map(
          ipb_in          => ipb_in,
          ipb_out         => ipb_out,
          sel             => ipbus_sel_cancel_out_half_sorters(ipb_in.ipb_addr),
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
        ghosts1 => sCancel1(num_tracks*(i+1)-1 downto num_tracks*i),
        ghosts2 => sCancel2(num_tracks*(i+1)-1 downto num_tracks*i),
        clk     => clk);
  end generate g1;

  oCancel <= sCancel1 or sCancel2;

end Behavioral;
