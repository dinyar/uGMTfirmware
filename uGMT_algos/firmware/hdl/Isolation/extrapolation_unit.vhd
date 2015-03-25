library IEEE;
use IEEE.STD_LOGIC_1164.all;

use work.mp7_data_types.all;
use work.ipbus.all;
use work.ipbus_decode_extrapolation.all;

use work.GMTTypes.all;

entity extrapolation_unit is
  port (
    iMuonsB              : in  TGMTMu_vector(35 downto 0);
    iMuonsO              : in  TGMTMu_vector(35 downto 0);
    iMuonsF              : in  TGMTMu_vector(35 downto 0);
    oExtrapolatedCoordsB : out TSpatialCoordinate_vector(35 downto 0);
    oExtrapolatedCoordsO : out TSpatialCoordinate_vector(35 downto 0);
    oExtrapolatedCoordsF : out TSpatialCoordinate_vector(35 downto 0);
    clk                  : in  std_logic;
    clk_ipb              : in  std_logic;
    rst                  : in  std_logic;
    ipb_in               : in  ipb_wbus;
    ipb_out              : out ipb_rbus);
end extrapolation_unit;

architecture Behavioral of extrapolation_unit is
  signal ipbw : ipb_wbus_array(N_SLAVES - 1 downto 0);
  signal ipbr : ipb_rbus_array(N_SLAVES - 1 downto 0);
begin

  -- IPbus address top-level decode
  fabric : entity work.ipbus_fabric_sel
    generic map(
      NSLV      => N_SLAVES,
      SEL_WIDTH => IPBUS_SEL_WIDTH
      )
    port map(
      ipb_in          => ipb_in,
      ipb_out         => ipb_out,
      sel             => ipbus_sel_extrapolation(ipb_in.ipb_addr),
      ipb_to_slaves   => ipbw,
      ipb_from_slaves => ipbr
      );

  extrapolate_barrel : entity work.extrapolation_unit_regional
  generic map (
    ETA_DATA_FILE  => "BEtaExtrapolation.dat",
    PHI_DATA_FILE  => "BPhiExtrapolation.dat"
  )
    port map (
      iMuons              => iMuonsB,
      oExtrapolatedCoords => oExtrapolatedCoordsB,
      clk                 => clk,
      clk_ipb             => clk_ipb,
      rst                 => rst,
      ipb_in              => ipbw(N_SLV_EXTRAPOLATE_BRL),
      ipb_out             => ipbr(N_SLV_EXTRAPOLATE_BRL)
      );
  extrapolate_overlap : entity work.extrapolation_unit_regional
  generic map (
    ETA_DATA_FILE  => "OEtaExtrapolation.dat",
    PHI_DATA_FILE  => "OPhiExtrapolation.dat"
  )
    port map (
      iMuons              => iMuonsO,
      oExtrapolatedCoords => oExtrapolatedCoordsO,
      clk                 => clk,
      clk_ipb             => clk_ipb,
      rst                 => rst,
      ipb_in              => ipbw(N_SLV_EXTRAPOLATE_OVL),
      ipb_out             => ipbr(N_SLV_EXTRAPOLATE_OVL)
      );
  extrapolate_forward : entity work.extrapolation_unit_regional
  generic map (
    ETA_DATA_FILE  => "FEtaExtrapolation.dat",
    PHI_DATA_FILE  => "FPhiExtrapolation.dat"
  )
    port map (
      iMuons              => iMuonsF,
      oExtrapolatedCoords => oExtrapolatedCoordsF,
      clk                 => clk,
      clk_ipb             => clk_ipb,
      rst                 => rst,
      ipb_in              => ipbw(N_SLV_EXTRAPOLATE_FWD),
      ipb_out             => ipbr(N_SLV_EXTRAPOLATE_FWD)
      );

end Behavioral;
