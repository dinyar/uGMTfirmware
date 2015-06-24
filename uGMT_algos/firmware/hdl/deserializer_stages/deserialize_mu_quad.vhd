library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

use work.mp7_data_types.all;
use work.ipbus.all;
use work.ipbus_reg_types.all;
use work.ipbus_decode_mu_quad_deserialization.all;

use work.mp7_ttc_decl.all;
use work.mp7_brd_decl.all;

use work.GMTTypes.all;
use work.ugmt_constants.all;

entity deserialize_mu_quad is
  generic (
    NCHAN     : positive := 4;
    VALID_BIT : std_logic
    );
  port (
    clk_ipb    : in  std_logic;
    rst        : in  std_logic;
    ipb_in     : in  ipb_wbus;
    ipb_out    : out ipb_rbus;
    bctr       : in  bctr_t;
    clk240     : in  std_logic;
    clk40      : in  std_logic;
    d          : in  ldata(NCHAN-1 downto 0);
    oMuons     : out TGMTMu_vector(NCHAN*NUM_MUONS_IN-1 downto 0);
    oTracks    : out TGMTMuTracks_vector(NCHAN-1 downto 0);
    oEmpty     : out std_logic_vector(NCHAN*NUM_MUONS_IN-1 downto 0);
    oSortRanks : out TSortRank10_vector(NCHAN*NUM_MUONS_IN-1 downto 0);
    oValid     : out std_logic;
    q          : out ldata(NCHAN-1 downto 0);
    oGlobalPhi : out TGlobalPhi_frame(NCHAN-1 downto 0)
    );
end deserialize_mu_quad;

architecture Behavioral of deserialize_mu_quad is

  signal ipbw : ipb_wbus_array(N_SLAVES - 1 downto 0);
  signal ipbr : ipb_rbus_array(N_SLAVES - 1 downto 0);

  constant PHI_COMP_LATENCY : natural := 1;

  signal sPhiOffsetRegOutput : ipb_reg_v(3 downto 0);
  type   TOffsetVec is array (natural range <>) of unsigned(9 downto 0);
  signal sPhiOffset          : TOffsetVec(3 downto 0);

  signal sIntermediatePhi     : TIntermediatePhi_vector(NCHAN-1 downto 0);
  signal sIntermediatePhi_reg : TIntermediatePhi_vector(NCHAN-1 downto 0);

  signal in_buf : TQuadTransceiverBufferIn;

  type   TSortRankInput is array (natural range <>) of std_logic_vector(12 downto 0);
  signal sSrtRnkIn : TSortRankInput(NCHAN-1 downto 0);

  signal sMuons_event : TFlatMuons(NCHAN-1 downto 0);  -- All input muons.
  signal sMuons_flat  : TFlatMuon_vector(NCHAN*NUM_MUONS_IN-1 downto 0);  -- All input muons unrolled.
  signal sMuonsIn     : TGMTMuIn_vector(NCHAN*NUM_MUONS_IN-1 downto 0);

  type   TGlobalPhiBuffer is array (2*NUM_MUONS_LINK-1 downto 0) of TGlobalPhi_frame(NCHAN-1 downto 0);
  signal sGlobalPhi_buffer : TGlobalPhiBuffer;
  signal sGlobalPhi_frame  : TGlobalPhi_frame(NCHAN-1 downto 0);
  signal sGlobalPhi_event  : TGlobalPhi_event;  -- All input phi values.
  signal sGlobalPhi_flat   : TGlobalPhi_vector(NCHAN*NUM_MUONS_IN-1 downto 0);  -- All input phi values unrolled.

  signal sValid_link : TValid_link(NCHAN-1 downto 0);

  signal sEmpty_link : TEmpty_link(NCHAN-1 downto 0);

  signal sBCerror    : std_logic_vector(NCHAN-1 downto 0);
  signal sBnchCntErr : std_logic_vector(NCHAN-1 downto 0);

  -- Stores sort ranks for each 32 bit word that arrives from TFs. Every second
  -- such rank is garbage and will be disregarded in second step.
  type   TSortRankBuffer is array (2*NUM_MUONS_LINK-1 downto 0) of TSortRank10_vector(NCHAN-1 downto 0);
  signal sSortRank_buffer : TSortRankBuffer;
  signal sSortRank_link   : TSortRank_link(NCHAN-1 downto 0);

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
      sel             => ipbus_sel_mu_quad_deserialization(ipb_in.ipb_addr),
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

  assign_ranks : for i in sSortRank_buffer(0)'range generate
    sSrtRnkIn(i) <= d(i).data(QUAL_IN_HIGH downto QUAL_IN_LOW) &
                    d(i).data(PT_IN_HIGH downto PT_IN_LOW);
    sort_rank_assignment : entity work.ipbus_dpram
      generic map (
        DATA_FILE  => "SortRank.mif",
        ADDR_WIDTH => SORT_RANK_MEM_ADDR_WIDTH,
        WORD_WIDTH => SORT_RANK_MEM_WORD_SIZE
        )
      port map (
        clk     => clk_ipb,
        rst     => rst,
        ipb_in  => ipbw(i),
        ipb_out => ipbr(i),
        rclk    => clk240,
        q       => sSortRank_buffer(sSortRank_buffer'high)(i),
        addr    => sSrtRnkIn(i)
        );
  end generate assign_ranks;

  calculate_global_phi : for i in sGlobalPhi_frame'range generate
    sIntermediatePhi(i) <= add_offset_to_local_phi(
      d(i).data(PHI_IN_HIGH downto PHI_IN_LOW),
      sPhiOffset(i)
      );
  end generate calculate_global_phi;

  apply_global_phi_wraparound : process (sIntermediatePhi_reg)
  begin  -- process apply_global_phi_wraparound
    for i in sIntermediatePhi_reg'range loop
      sGlobalPhi_frame(i).phi <= apply_global_phi_wraparound(sIntermediatePhi_reg(i));
    end loop;
  end process apply_global_phi_wraparound;

  -- We're filling with an offset as we registered the data once before (sIntermediatePhi_reg).
  sGlobalPhi_buffer(sGlobalPhi_buffer'high-PHI_COMP_LATENCY) <= sGlobalPhi_frame;

  shift_buffers : process (clk240)
  begin  -- process shift_buffers
    if clk240'event and clk240 = '1' then  -- rising clock edge
      sSortRank_buffer(sSortRank_buffer'high-1 downto 0)   <= sSortRank_buffer(sSortRank_buffer'high downto 1);
      sIntermediatePhi_reg                                 <= sIntermediatePhi;
      sGlobalPhi_buffer(sGlobalPhi_buffer'high-1 downto 0) <= sGlobalPhi_buffer(sGlobalPhi_buffer'high downto 1);
    end if;
  end process shift_buffers;

  gmt_in_reg : process (clk40)
  begin  -- process gmt_in_reg
    if clk40'event and clk40 = '1' then  -- rising clock edge
      for iChan in NCHAN-1 downto 0 loop
        for iFrame in 2*NUM_MUONS_LINK-1 downto 0 loop
          -- Store valid bit.
          sValid_link(iChan)(iFrame) <= in_buf(iFrame)(iChan).valid;
          if (iFrame mod 2) = 0 then
            -- Get first half of muon.
            if in_buf(iFrame)(iChan).valid = VALID_BIT then
              -- We're only using the lower 30 bits as the MSB is used for
              -- status codes.
              sMuons_event(iChan)(iFrame/2)(30 downto 0) <= in_buf(iFrame)(iChan).data(30 downto 0);
            else
              sMuons_event(iChan)(iFrame/2)(30 downto 0) <= (others => '0');
            end if;

            -- Determine empty bit.
            if in_buf(iFrame)(iChan).data(PT_IN_HIGH downto PT_IN_LOW) = (PT_IN_HIGH downto PT_IN_LOW => '0') then
              sEmpty_link(iChan)(iFrame/2) <= '1';
            else
              sEmpty_link(iChan)(iFrame/2) <= '0';
            end if;

          else
            -- Get second half of muon.
            if in_buf(iFrame)(iChan).valid = VALID_BIT then
              -- We're only using the lower 30 bits as the MSB is used for
              -- status codes.
              sMuons_event(iChan)(iFrame/2)(61 downto 31) <= in_buf(iFrame)(iChan).data(30 downto 0);
            else
              sMuons_event(iChan)(iFrame/2)(61 downto 31) <= (others => '0');
            end if;

            -- Use every second result from SortRankLUT. (The other results
            -- were calculated with the 'wrong part' of the TF muon.)
            -- Using this iFrame even though pT and quality are contained in
            -- earlier frame as the rank calculation requires an additional
            -- clk240, so the "correct" sort rank is late by one.
            sSortRank_link(iChan)(iFrame/2) <= sSortRank_buffer(iFrame)(iChan);

            -- Store global phi value. As the calculation of global phi is
            -- delayed by one 240 MHz tick we're using the second result using
            -- the same argument as for the sort rank above.
            sGlobalPhi_event(iChan)(iFrame/2) <= sGlobalPhi_buffer(iFrame)(iChan);
          end if;
        end loop;  -- iFrame

        -- Check for errors
        if bctr = (11 downto 0 => '0') then
          if in_buf(0)(iChan).data(31) = '1' then
            sBCerror(iChan) <= '0';
          else
            sBCerror(iChan) <= '1';
          end if;
        else
          sBCerror(iChan) <= '0';
        end if;
        if in_buf(2)(iChan).data(31) = bctr(0) and in_buf(3)(iChan).data(31) = bctr(1) and in_buf(4)(iChan).data(31) = bctr(2) then
          sBnchCntErr(iChan) <= '0';
        else
          sBnchCntErr(iChan) <= '1';
        end if;

      end loop;  -- iChan
    end if;
  end process gmt_in_reg;

  gen_ipb_registers : for i in NCHAN-1 downto 0 generate
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
    phi_offset_reg : entity work.ipbus_reg_v
      generic map(
        N_REG => 1
        )
      port map(
        clk       => clk_ipb,
        reset     => rst,
        ipbus_in  => ipbw(N_SLV_PHI_OFFSET_0+i),
        ipbus_out => ipbr(N_SLV_PHI_OFFSET_0+i),
        q         => sPhiOffsetRegOutput(i downto i)
        );
  end generate gen_ipb_registers;

  assign_offsets : for i in sPhiOffset'range generate
    sPhiOffset(i) <= unsigned(sPhiOffsetRegOutput(i)(9 downto 0));
  end generate assign_offsets;

  sMuons_flat     <= unroll_link_muons(sMuons_event(NCHAN-1 downto 0));
  sGlobalPhi_flat <= unroll_global_phi(sGlobalPhi_event(NCHAN-1 downto 0));
  unpack_muons : for i in sMuonsIn'range generate
    sMuonsIn(i) <= unpack_mu_from_flat(sMuons_flat(i), sGlobalPhi_flat(i));
  end generate unpack_muons;
  convert_muons : for i in sMuonsIn'range generate
    oMuons(i) <= gmt_mu_from_in_mu(sMuonsIn(i));
  end generate convert_muons;
  oTracks    <= track_addresses_from_in_mus(sMuons_flat);
  oEmpty     <= unpack_empty_bits(sEmpty_link(NCHAN-1 downto 0));
  oSortRanks <= unpack_sort_rank(sSortRank_link(NCHAN-1 downto 0));

  oValid <= check_valid_bits(sValid_link(NCHAN-1 downto 0));

  q          <= in_buf(0);
  oGlobalPhi <= sGlobalPhi_buffer(0);

end Behavioral;
