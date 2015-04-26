library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.mp7_data_types.all;
use work.ipbus.all;
--use work.ipbus_decode_mp7_xxx.all;

use work.GMTTypes.all;
use work.ugmt_constants.all;

entity deserialize_energy_quad is
  generic (
    NCHAN     : positive := 4;
    VALID_BIT : std_logic
    );
  port (
    clk240    : in  std_logic;
    clk40     : in  std_logic;
    d         : in  ldata(3 downto 0);
    oEnergies : out TCaloRegionEtaSlice_vector(NCHAN-1 downto 0);
    oValid    : out std_logic
    );
end deserialize_energy_quad;

architecture Behavioral of deserialize_energy_quad is
  signal in_buf    : TQuadTransceiverBufferIn;
  type TQuadDataBuffer is array (natural range <>) of std_logic_vector(179 downto 0);
  signal sLinkData : TQuadDataBuffer(NCHAN-1 downto 0);

  signal sEnergies   : TCaloRegionEtaSlice_vector(NCHAN-1 downto 0);
  signal sValid_link : TValid_link(NCHAN-1 downto 0);
begin  -- Behavioral


  fill_buffer : process (clk240)
  begin  -- process fill_buffer
    if clk240'event and clk240 = '1' then  -- rising clock edge
      in_buf(in_buf'high) <= d(NCHAN-1 downto 0);
      in_buf(in_buf'high-1 downto 0) <= in_buf(in_buf'high downto 1);
    end if;
  end process fill_buffer;

  unroll_links : for chan in NCHAN-1 downto 0 generate
    unroll_bx : for bx in 5 downto 0 generate
      sLinkData(chan)(30*(bx)+29 downto 30*(bx)) <= in_buf(bx)(chan).data(29 downto 0);
    end generate unroll_bx;
  end generate unroll_links;

  gmt_in_reg : process (clk40)
  begin  -- process gmt_in_reg
    if clk40'event and clk40 = '1' then  -- rising clock edge
      for chan in d'range loop
        for bx in 5 downto 0 loop
          -- Store valid bit.
          sValid_link(chan)(bx) <= in_buf(bx)(chan).valid;
          if in_buf(bx)(chan).valid = VALID_BIT then
            sEnergies(chan) <= calo_etaslice_from_flat(sLinkData(chan));
          else
            sEnergies(chan) <= (others => (others => '0'));
          end if;
        end loop;  -- bx
      end loop;  -- chan
    end if;
  end process gmt_in_reg;
  oEnergies <= sEnergies;
  oValid    <= check_valid_bits(sValid_link(NCHAN-1 downto 0));

end Behavioral;
