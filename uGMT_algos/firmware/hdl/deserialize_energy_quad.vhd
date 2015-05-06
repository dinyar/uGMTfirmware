library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.mp7_data_types.all;
use work.ipbus.all;
use work.ipbus_reg_types.all;
use work.ipbus_decode_energy_quad_deserialization.all;

use work.mp7_ttc_decl.all;
use work.mp7_brd_decl.all;

use work.GMTTypes.all;
use work.ugmt_constants.all;

entity deserialize_energy_quad is
  generic (
    NCHAN     : positive := 4;
    VALID_BIT : std_logic
    );
  port (
    clk_ipb   : in  std_logic;
    rst       : in  std_logic;
    ipb_in    : in  ipb_wbus;
    ipb_out   : out ipb_rbus;
    ctrs      : in  ttc_stuff_t;
    clk240    : in  std_logic;
    clk40     : in  std_logic;
    d         : in  ldata(3 downto 0);
    oEnergies : out TCaloRegionEtaSlice_vector(NCHAN-1 downto 0);
    oValid    : out std_logic
    );
end deserialize_energy_quad;

architecture Behavioral of deserialize_energy_quad is

  signal ipbw : ipb_wbus_array(N_SLAVES - 1 downto 0);
  signal ipbr : ipb_rbus_array(N_SLAVES - 1 downto 0);

  signal in_buf    : TQuadTransceiverBufferIn;
  type TQuadDataBuffer is array (natural range <>) of std_logic_vector(179 downto 0);
  signal sLinkData : TQuadDataBuffer(NCHAN-1 downto 0);

  signal sBCerror   : std_logic_vector(NCHAN-1 downto 0);
  signal sBnchCntErr : std_logic_vector(NCHAN-1 downto 0);

  signal sValid_link : TValid_link(NCHAN-1 downto 0);
begin  -- Behavioral

  -- IPbus address decode
  fabric : entity work.ipbus_fabric_sel
    generic map(
      NSLV      => N_SLAVES,
      SEL_WIDTH => IPBUS_SEL_WIDTH
      )
    port map(
      ipb_in          => ipb_in,
      ipb_out         => ipb_out,
      sel             => ipbus_sel_energy_quad_deserialization(ipb_in.ipb_addr),
      ipb_to_slaves   => ipbw,
      ipb_from_slaves => ipbr
    );

  in_buf(in_buf'high) <= d(NCHAN-1 downto 0);
  fill_buffer : process (clk240)
  begin  -- process fill_buffer
    if clk240'event and clk240 = '1' then  -- rising clock edge
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
            oEnergies(chan) <= calo_etaslice_from_flat(sLinkData(chan));
          else
            oEnergies(chan) <= (others => (others => '0'));
          end if;
        end loop;  -- bx

        -- Check for errors
        if ctrs.bctr = (11 downto 0 => '0') then
            if in_buf(0)(chan).data(31) = '1' then
                sBCerror(chan) <= '0';
            else
                sBCerror(chan) <= '1';
            end if;
        else
            sBCerror(chan) <= '0';
        end if;
        if in_buf(2)(chan).data(31) = ctrs.bctr(0) and in_buf(3)(chan).data(31) = ctrs.bctr(1) and in_buf(4)(chan).data(31) = ctrs.bctr(2) then
            sBnchCntErr(chan) <= '0';
        else
            sBnchCntErr(chan) <= '1';
        end if;
      end loop;  -- chan
    end if;
  end process gmt_in_reg;

  gen_error_counter : for i in NCHAN-1 downto 0 generate
    bc0_reg : entity work.ipbus_counter
      port map(
          clk          => clk_ipb,
          reset        => rst,
          ipbus_in     => ipbw(N_SLV_BC0_ERRORS_0+i),
          ipbus_out    => ipbr(N_SLV_BC0_ERRORS_0+i),
          incr_counter => sBCerror(i)
      );
    sync_reg : entity work.ipbus_counter
      port map(
        clk          => clk_ipb,
        reset        => rst,
        ipbus_in     => ipbw(N_SLV_BNCH_CNT_ERRORS_0+i),
        ipbus_out    => ipbr(N_SLV_BNCH_CNT_ERRORS_0+i),
        incr_counter => sBnchCntErr(i)
      );
  end generate gen_error_counter;

  oValid    <= check_valid_bits(sValid_link(NCHAN-1 downto 0));

end Behavioral;
