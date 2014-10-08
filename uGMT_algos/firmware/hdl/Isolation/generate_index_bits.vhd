library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

use work.mp7_data_types.all;
use work.ipbus.all;
use work.ipbus_decode_index_bits.all;

use work.GMTTypes.all;

entity generate_index_bits is
  port (
    iCoordsB      : in  TSpatialCoordinate_vector(35 downto 0);
    iCoordsO      : in  TSpatialCoordinate_vector(35 downto 0);
    iCoordsF      : in  TSpatialCoordinate_vector(35 downto 0);
    oCaloIdxBitsB : out TCaloIndexBit_vector(35 downto 0);
    oCaloIdxBitsO : out TCaloIndexBit_vector(35 downto 0);
    oCaloIdxBitsF : out TCaloIndexBit_vector(35 downto 0);
    clk           : in  std_logic;
    clk_ipb       : in  std_logic;
    rst           : in  std_logic;
    ipb_in        : in  ipb_wbus;
    ipb_out       : out ipb_rbus
    );
end generate_index_bits;

architecture Behavioral of generate_index_bits is
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
      sel             => ipbus_sel_index_bits(ipb_in.ipb_addr),
      ipb_to_slaves   => ipbw,
      ipb_from_slaves => ipbr
      );


  brl_index_bits : entity work.index_bits_generator
    port map (
      clk_ipb      => clk_ipb,
      rst          => rst,
      ipb_in       => ipbw(N_SLV_IDX_BITS_BRL),
      ipb_out      => ipbr(N_SLV_IDX_BITS_BRL),
      clk          => clk,
      iCoords      => iCoordsB,
      oCaloIdxBits => oCaloIdxBitsB
      );
  ovl_index_bits : entity work.index_bits_generator
    port map (
      clk_ipb      => clk_ipb,
      rst          => rst,
      ipb_in       => ipbw(N_SLV_IDX_BITS_OVL),
      ipb_out      => ipbr(N_SLV_IDX_BITS_OVL),
      clk          => clk,
      iCoords      => iCoordsO,
      oCaloIdxBits => oCaloIdxBitsO
      );
  fwd_index_bits : entity work.index_bits_generator
    port map (
      clk_ipb      => clk_ipb,
      rst          => rst,
      ipb_in       => ipbw(N_SLV_IDX_BITS_FWD),
      ipb_out      => ipbr(N_SLV_IDX_BITS_FWD),
      clk          => clk,
      iCoords      => iCoordsF,
      oCaloIdxBits => oCaloIdxBitsF
      );

end Behavioral;

