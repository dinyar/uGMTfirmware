library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

use work.mp7_data_types.all;
use work.ipbus.all;

use work.GMTTypes.all;

entity WedgeCheckerUnit is
  port (
    clk_ipb : in  std_logic;
    rst     : in  std_logic;
    ipb_in  : in  ipb_wbus;
    ipb_out : out ipb_rbus;
    wedge1  : in  TGMTMuTracks3;
    wedge2  : in  TGMTMuTracks3;
    ghosts1 : out std_logic_vector (0 to 2);
    ghosts2 : out std_logic_vector (0 to 2);
    clk     : in  std_logic
    ); 

end WedgeCheckerUnit;

architecture Behavioral of WedgeCheckerUnit is
  signal sel_lut : std_logic_vector(3 downto 0);
  signal ipbw    : ipb_wbus_array(wedge1'length*wedge2'length -1 downto 0);
  signal ipbr    : ipb_rbus_array(wedge1'length*wedge2'length -1 downto 0);

  subtype muon_cancel is std_logic_vector(wedge2'range);
  type    muon_cancel_vec is array (integer range <>) of muon_cancel;
  signal  sCancel1 : muon_cancel_vec(wedge1'range);
  signal  sCancel2 : muon_cancel_vec(wedge2'range);
begin

  -----------------------------------------------------------------------------
  -- ipbus address decode
  -----------------------------------------------------------------------------
  -- Use bits before beginning of addresses that are required for later
  -- addressing (i.e. addresses inside LUTs)
  -- Need to address 3x3 LUTs -> 4 bits needed.
  -- 2 bits used for addressing in LUTs themselves -> will use 5th to 2nd bits.
  sel_lut <= std_logic_vector(unsigned(ipb_in.ipb_addr(5 downto 2)));

  fabric : entity work.ipbus_fabric_sel
    generic map(
      NSLV      => 9,
      SEL_WIDTH => 4)
    port map(
      ipb_in          => ipb_in,
      ipb_out         => ipb_out,
      sel             => sel_lut,
      ipb_to_slaves   => ipbw,
      ipb_from_slaves => ipbr
      );  

  -- Compare the two wedges' muons with each other.
  g1 : for i in wedge1'range generate
    g2 : for j in wedge2'range generate
      --x : entity work.GhostCheckerUnit
      --  port map (
      --    clk_ipb => clk_ipb,
      --    rst     => rst,
      --    ipb_in  => ipbw(i),
      --    ipb_out => ipbr(i),
      --    mu1     => wedge1(i).address,
      --    qual1   => wedge1(i).qual,
      --    mu2     => wedge2(j).address,
      --    qual2   => wedge2(i).qual,
      --    ghost1  => sCancel1(j)(i),    -- TODO: Is this correct?
      --    ghost2  => sCancel2(j)(i)     -- TODO: Is this correct?
      --    );
      x : entity work.GhostCheckerUnit_spatialCoords
        port map (
          clk_ipb => clk_ipb,
          rst     => rst,
          ipb_in  => ipbw(3*i +j),
          ipb_out => ipbr(3*i +j),
          eta1    => wedge1(i).eta,
          phi1    => wedge1(i).phi,
          qual1   => wedge1(i).qual,
          eta2    => wedge2(j).eta,
          phi2    => wedge2(j).phi,
          qual2   => wedge2(i).qual,
          ghost1  => sCancel1(j)(i),
          ghost2  => sCancel2(j)(i),
          clk     => clk);
    end generate g2;
  end generate g1;

  g3 : for i in ghosts1'range generate
    ghosts1(i) <= sCancel1(i)(0) or sCancel1(i)(1) or sCancel1(i)(2);
    ghosts2(i) <= sCancel2(i)(0) or sCancel2(i)(1) or sCancel2(i)(2);
  end generate g3;
end Behavioral;

