library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

use work.mp7_data_types.all;
use work.ipbus.all;
use work.ipbus_decode_extrapolation_regional.all;

use work.GMTTypes.all;

entity extrapolation_unit_regional is
  generic (
    ETA_DATA_FILE: string;
    PHI_DATA_FILE: string
    );
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

  signal sDeltaEta : TDeltaEta_vector(iMuons'range);
  signal sDeltaPhi : TDeltaPhi_vector(iMuons'range);

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
      -- TODO: Can we cut more due to the abs? (We're not using the full eta
      --       scale and we're centering the center bin at 0, so we don't have
      --       an asymmetry, therefore the MSB is guaranteed to be unused after
      --       the abs operation.)
    sEtaAbs(i) <= unsigned(abs(iMuons(i).eta));

    -- TODO: Merge the two types of extrapolation addresses?
    sEtaExtrapolationAddress(i) <= std_logic_vector(sEtaAbs(i)(7 downto 2)) &
                                   std_logic_vector(iMuons(i).pt(5 downto 0));
    sPhiExtrapolationAddress(i) <= std_logic_vector(sEtaAbs(i)(7 downto 2)) &
                                   std_logic_vector(iMuons(i).pt(5 downto 0));
  end generate calc_extrap_addresses;

  extrapolation_eta : entity work.extrapolate_eta
    generic map (
      DATA_FILE  => ETA_DATA_FILE
      )
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
    generic map (
      DATA_FILE  => PHI_DATA_FILE
      )
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
      if unsigned(iMuons(i).pt) > 63 then
        -- If muon is high-pT we won't extrapolate.
        sExtrapolatedCoords(i).eta <= iMuons(i).eta;
        sExtrapolatedCoords(i).phi <= iMuons(i).phi;
      else
        -- If muon is low-pT we etrapolate.
        sExtrapolatedCoords(i).eta <= iMuons(i).eta + sDeltaEta(i);

        if iMuons(i).sysign(0) = '1' then
            sExtrapolatedCoords(i).phi <= iMuons(i).phi + sDeltaPhi(i);
        else
            sExtrapolatedCoords(i).phi <= iMuons(i).phi - sDeltaPhi(i);
        end if;
      end if;
    end loop;  -- i
  end process assign_coords;

  oExtrapolatedCoords <= sExtrapolatedCoords;

end Behavioral;
