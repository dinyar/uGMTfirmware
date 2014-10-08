library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

use work.mp7_data_types.all;
use work.ipbus.all;
use work.ipbus_decode_idx_bit_mems.all;

use work.GMTTypes.all;

entity index_bits_generator is
  port (
    clk_ipb      : in  std_logic;
    rst          : in  std_logic;
    ipb_in       : in  ipb_wbus;
    ipb_out      : out ipb_rbus;
    clk          : in  std_logic;
    iCoords      : in  TSpatialCoordinate_vector(35 downto 0);
    oCaloIdxBits : out TCaloIndexBit_vector(35 downto 0)
    );
end index_bits_generator;

architecture Behavioral of index_bits_generator is
  signal ipbw : ipb_wbus_array(N_SLAVES - 1 downto 0);
  signal ipbr : ipb_rbus_array(N_SLAVES - 1 downto 0);

  signal sCaloEtaCoords  : TEtaCoordinate_vector(iCoords'range);
  signal sCaloPhiCoords  : TPhiCoordinate_vector(iCoords'range);
  signal sCaloEtaIdxBits : TEtaCaloIdxBit_vector(iCoords'range);
  signal sCaloPhiIdxBits : TPhiCaloIdxBit_vector(iCoords'range);

begin

  -- ipbus address decode
  fabric : entity work.ipbus_fabric_sel
    generic map(
      NSLV      => N_SLAVES,
      SEL_WIDTH => IPBUS_SEL_WIDTH
      )
    port map(
      ipb_in          => ipb_in,
      ipb_out         => ipb_out,
      sel             => ipbus_sel_idx_bit_mems(ipb_in.ipb_addr),
      ipb_to_slaves   => ipbw,
      ipb_from_slaves => ipbr
      );

  split_coordinates : for i in iCoords'range generate
    sCaloEtaCoords(i) <= iCoords(i).eta;
    sCaloPhiCoords(i) <= iCoords(i).phi;
  end generate split_coordinates;

  eta_idx_bits : entity work.eta_index_bits_memories
    port map (
      clk_ipb      => clk_ipb,
      rst          => rst,
      ipb_in       => ipbw(N_SLV_ETA_IDX_BITS),
      ipb_out      => ipbr(N_SLV_ETA_IDX_BITS),
      clk          => clk,
      oCaloIdxBits => sCaloEtaIdxBits,
      iCoords      => sCaloEtaCoords
      );
  phi_idx_bits : entity work.phi_index_bits_memories
    port map (
      clk_ipb      => clk_ipb,
      rst          => rst,
      ipb_in       => ipbw(N_SLV_PHI_IDX_BITS),
      ipb_out      => ipbr(N_SLV_PHI_IDX_BITS),
      clk          => clk,
      oCaloIdxBits => sCaloPhiIdxBits,
      iCoords      => sCaloPhiCoords
      );

  merge_idx_bits : for i in oCaloIdxBits'range generate
    oCaloIdxBits(i).eta <= sCaloEtaIdxBits(i);
    oCaloIdxBits(i).phi <= sCaloPhiIdxBits(i);
  end generate merge_idx_bits;
end Behavioral;

