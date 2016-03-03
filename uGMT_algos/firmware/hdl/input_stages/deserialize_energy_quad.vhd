library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.mp7_data_types.all;
use work.ipbus.all;
use work.ipbus_decode_energy_quad_deserialization.all;

use work.mp7_ttc_decl.all;
use work.mp7_brd_decl.all;

use work.GMTTypes.all;
use work.ugmt_constants.all;

entity deserialize_energy_quad is
  generic (
    NCHAN     : positive := 4
    );
  port (
    clk_ipb   : in  std_logic;
    rst       : in  std_logic;
    ipb_in    : in  ipb_wbus;
    ipb_out   : out ipb_rbus;
    bctr      : in  bctr_t;
    clk240    : in  std_logic;
    clk40     : in  std_logic;
    d         : in  ldata(3 downto 0);
    iDisable  : in  std_logic_vector(3 downto 0);
    oEnergies : out TCaloRegionEtaSlice_vector(NCHAN-1 downto 0);
    oValid    : out std_logic
    );
end deserialize_energy_quad;

architecture Behavioral of deserialize_energy_quad is

  signal ipbw : ipb_wbus_array(N_SLAVES - 1 downto 0);
  signal ipbr : ipb_rbus_array(N_SLAVES - 1 downto 0);

  signal in_buf     : TQuadTransceiverBufferIn;
  type TQuadDataBuffer is array (natural range <>) of std_logic_vector(179 downto 0);
  signal sLinkData  : TQuadDataBuffer(NCHAN-1 downto 0);
  signal sValid_buf : std_logic_vector(NCHAN-1 downto 0);

  signal sBCerror    : std_logic_vector(NCHAN-1 downto 0);
  signal sBnchCntErr : std_logic_vector(NCHAN-1 downto 0);

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

  check_valid : process (d, iDisable)
    variable vValid_frame : std_logic_vector(NCHAN-1 downto 0);
  begin  -- process check_valid
    for i in d'range loop
      if d(i).valid = '1' and iDisable(i) = '0' then
        in_buf(in_buf'high)(i) <= d(i);
      else
        in_buf(in_buf'high)(i).data  <= (31 downto 0 => '0');
        in_buf(in_buf'high)(i).valid <= '0';
      end if;

      vValid_frame(i) := d(i).valid;
    end loop;  -- i

    sValid_buf(sValid_buf'high) <= combine_or(vValid_frame);
  end process check_valid;

  shift_buffers : process (clk240)
  begin  -- process shift_buffers
    if clk240'event and clk240 = '1' then  -- rising clock edge
      sValid_buf(sValid_buf'high-1 downto 0) <= sValid_buf(sValid_buf'high downto 1);
      in_buf(in_buf'high-1 downto 0)         <= in_buf(in_buf'high downto 1);
    end if;
end process shift_buffers;

  unroll_links : for chan in NCHAN-1 downto 0 generate
    unroll_bx : for bx in 5 downto 0 generate
      sLinkData(chan)(30*(bx)+29 downto 30*(bx)) <= in_buf(bx)(chan).data(29 downto 0);
    end generate unroll_bx;
  end generate unroll_links;

  gmt_in_reg : process (clk40)
  begin  -- process gmt_in_reg
    if clk40'event and clk40 = '1' then  -- rising clock edge
      -- Store valid bit.
      oValid <= combine_or(sValid_buf);
      for chan in d'range loop
        for frame in 5 downto 0 loop
          oEnergies(chan) <= calo_etaslice_from_flat(sLinkData(chan));
        end loop;  -- frame

        -- Check for errors
        if in_buf(0)(chan).valid = '1' then
          if ((bctr /= (11 downto 0 => '0')) and (in_buf(0)(chan).data(31) = '1')) or
             ((bctr = (11 downto 0 => '0')) and (in_buf(0)(chan).data(31) = '0')) then
            sBCerror(chan) <= '1';
          else
            sBCerror(chan) <= '0';
          end if;

          if in_buf(2)(chan).data(31) /= bctr(0) or
             in_buf(3)(chan).data(31) /= bctr(1) or
             in_buf(4)(chan).data(31) /= bctr(2) then
            sBnchCntErr(chan) <= '1';
          else
            sBnchCntErr(chan) <= '0';
          end if;
        else
          -- If valid bit is '0'
          sBCerror(chan)    <= '0';
          sBnchCntErr(chan) <= '0';
        end if;

      end loop;  -- chan
    end if;
  end process gmt_in_reg;

  gen_error_counter : for i in NCHAN-1 downto 0 generate
    bc0_reg : entity work.ipbus_counter
      port map(
          clk          => clk40,
          reset        => rst,
          ipbus_in     => ipbw(N_SLV_BC0_ERRORS_0+i),
          ipbus_out    => ipbr(N_SLV_BC0_ERRORS_0+i),
          incr_counter => sBCerror(i)
      );
    sync_reg : entity work.ipbus_counter
      port map(
        clk          => clk40,
        reset        => rst,
        ipbus_in     => ipbw(N_SLV_BNCH_CNT_ERRORS_0+i),
        ipbus_out    => ipbr(N_SLV_BNCH_CNT_ERRORS_0+i),
        incr_counter => sBnchCntErr(i)
      );
  end generate gen_error_counter;

end Behavioral;
