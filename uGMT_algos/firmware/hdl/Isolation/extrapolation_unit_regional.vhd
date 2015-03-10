library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

use work.mp7_data_types.all;
use work.ipbus.all;
use work.ipbus_decode_extrapolation_regional.all;

use work.GMTTypes.all;

entity extrapolation_unit_regional is
  port (
    iMuons              : in  TGMTMu_vector(35 downto 0);
    oExtrapolatedCoords : out TSpatialCoordinate_vector(35 downto 0);
    clk                 : in  std_logic;
    clk_ipb             : in  std_logic;
    rst                 : in  std_logic;
    ipb_in              : in  ipb_wbus;
    ipb_out             : out ipb_rbus
    );
end extrapolation_unit_regional;

architecture Behavioral of extrapolation_unit_regional is
  -- IPbus
  signal ipbw : ipb_wbus_array(N_SLAVES - 1 downto 0);
  signal ipbr : ipb_rbus_array(N_SLAVES - 1 downto 0);

  signal sEtaExtrapolationAddress : TEtaExtrapolationAddress(iMuons'range);
  signal sPhiExtrapolationAddress : TPhiExtrapolationAddress(iMuons'range);

  type   TEtaAbs is array (integer range <>) of unsigned(8 downto 0);
  signal sEtaAbs : TEtaAbs(iMuons'range);

  signal sDeltaEta : TDelta_vector(iMuons'range);
  signal sDeltaPhi : TDelta_vector(iMuons'range);

  signal sExtrapolatedCoords : TSpatialCoordinate_vector(oExtrapolatedCoords'range);

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
      sel             => ipbus_sel_extrapolation_regional(ipb_in.ipb_addr),
      ipb_to_slaves   => ipbw,
      ipb_from_slaves => ipbr
      );

  calc_extrap_addresses : for i in iMuons'range generate
    sEtaAbs(i) <= unsigned(abs(signed(iMuons(i).eta)));

    sEtaExtrapolationAddress(i) <= std_logic_vector(iMuons(i).sysign(0 downto 0)) &
                                   std_logic_vector(sEtaAbs(i)(8 downto 2)) &
                                   std_logic_vector(iMuons(i).pt(4 downto 0));
    sPhiExtrapolationAddress(i) <= std_logic_vector(iMuons(i).sysign(0 downto 0)) &
                                   std_logic_vector(sEtaAbs(i)(8 downto 1)) &
                                   std_logic_vector(iMuons(i).pt(4 downto 0));
  end generate calc_extrap_addresses;

  extrapolation_eta : entity work.extrapolate_eta
    port map (
      clk_ipb                  => clk_ipb,
      rst                      => rst,
      ipb_in                   => ipbw(N_SLV_ETA_EXTRAPOLATION),
      ipb_out                  => ipbr(N_SLV_ETA_EXTRAPOLATION),
      clk                      => clk,
      iEtaExtrapolationAddress => sEtaExtrapolationAddress,
      oDeltaEta                => sDeltaEta
      );
  extrapolation_phi : entity work.extrapolate_phi
    port map (
      clk_ipb                  => clk_ipb,
      rst                      => rst,
      ipb_in                   => ipbw(N_SLV_PHI_EXTRAPOLATION),
      ipb_out                  => ipbr(N_SLV_PHI_EXTRAPOLATION),
      clk                      => clk,
      iPhiExtrapolationAddress => sPhiExtrapolationAddress,
      oDeltaPhi                => sDeltaPhi
      );

  -- TODO: Fix this!
  -- purpose: Assign corrected coordinates to muons.
  -- outputs: sExtrapolatedCoords
  assign_coords : process (iMuons, sDeltaEta, sDeltaPhi)
  begin  -- process assign_coords
    for i in iMuons'range loop
      if unsigned(iMuons(i).pt) > 31 then
        -- If muon is high-pT we won't extrapolate.
        sExtrapolatedCoords(i).eta <= signed(iMuons(i).eta);
        sExtrapolatedCoords(i).phi <= unsigned(iMuons(i).phi);
      elsif (abs signed(iMuons(i).eta)) > 127 then
        -- If muon is low-pT and has high eta we etrapolate both coordinates.
        sExtrapolatedCoords(i).eta <= signed(iMuons(i).eta) + sDeltaEta(i);
        sExtrapolatedCoords(i).phi <= unsigned(signed(iMuons(i).phi) + sDeltaPhi(i));
      else
        -- If muon is low-pT but low is in the barrel we only extrapolate phi.
        sExtrapolatedCoords(i).eta <= signed(iMuons(i).eta);
        sExtrapolatedCoords(i).phi <= unsigned(signed(iMuons(i).phi) + sDeltaPhi(i));
      end if;
    end loop;  -- i
  end process assign_coords;

  oExtrapolatedCoords <= sExtrapolatedCoords;

end Behavioral;
