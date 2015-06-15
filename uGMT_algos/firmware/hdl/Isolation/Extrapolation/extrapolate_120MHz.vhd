library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

use work.mp7_data_types.all;
use work.ipbus.all;
use work.ipbus_reg_types.all;
use work.ipbus_decode_extrapolate_120MHz.all;

use work.mp7_ttc_decl.all;
use work.mp7_brd_decl.all;

use work.GMTTypes.all;
use work.ugmt_constants.all;

entity extrapolate_120MHz is
  generic (
    NCHAN     : positive := 4;
    );
  port (
    clk_ipb       : in  std_logic;
    rst           : in  std_logic;
    ipb_in        : in  ipb_wbus;
    ipb_out       : out ipb_rbus;
    clk240        : in  std_logic;
    clk40         : in  std_logic;
    d             : in  ldata(NCHAN-1 downto 0);
	oExtrapCoords : out ????
    );
end extrapolate_120MHz;

architecture Behavioral of extrapolate_120MHz is

  signal ipbw : ipb_wbus_array(N_SLAVES - 1 downto 0);
  signal ipbr : ipb_rbus_array(N_SLAVES - 1 downto 0);

  signal in_buf : TQuadTransceiverBufferIn;

  type   TEtaAbs is array (integer range <>) of unsigned(8 downto 0);
  signal sEtaAbs : TEtaAbs(NCHAN-1 downto 0);
  signal sExtrapolationAddress : TExtrapolationAddress(NCHAN-1 downto 0);

  signal sEtaLutOutput : TLutBuf(sExtrapolatedCoords_buffer(0)'range);
  signal sPhiLutOutput : TLutBuf(sExtrapolatedCoords_buffer(0)'range);

  -- Stores extrapolated coordinates for each 32 bit word that arrives from TFs.
  -- Every second such extrapolation is garbage and will be disregarded in a
  -- second step.
  type TCoordinateBuffer is array (2*NUM_MUONS_LINK-1 downto 0) of TSpatialCoordinate_vector(NCHAN-1 downto 0);
  signal sExtrapolatedCoords_buffer : TCoordinateBuffer;
  signal sExtrapolatedCoords_link   : TExtrapolatedCoords_link(NCHAN-1 downto 0);


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
        sel             => ipbus_sel_extrapolate_120MHz(ipb_in.ipb_addr),
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

  coordinate_extrapolation : for i in sExtrapolatedCoords_buffer(0)'range generate

	sEtaAbs(i) <= unsigned(abs(signed(d(i).data(ETA_IN_HIGH downto ETA_IN_LOW))));
	sExtrapolationAddress(i) <= std_logic_vector(sEtaAbs(i)(7 downto 2)) &
    							d(i).data(PT_IN_LOW+5 downto PT_IN_LOW);

	phi_extrapolation : entity work.ipbus_dpram
		generic map (
			DATA_FILE  => DATA_FILE,
			ADDR_WIDTH => PHI_EXTRAPOLATION_ADDR_WIDTH,
			WORD_WIDTH => PHI_EXTRAPOLATION_WORD_SIZE
			)
		port map (
			clk => clk_ipb,
			rst => rst,
			ipb_in => ipbw(???+i),  -- TODO
			ipb_out => ipbr(???+i), -- TODO
			rclk => clk,
			q => sPhiLutOutput(i)(PHI_EXTRAPOLATION_WORD_SIZE-1 downto 0),
			addr => std_logic_vector(iExtrapolationAddress(i))
		);
	-- TODO: Do I need this intermediate signal?
	sDeltaPhi(i) <= unsigned(sPhiLutOutput(i)(PHI_EXTRAPOLATION_WORD_SIZE-1 downto 0));

    eta_extrapolation : entity work.ipbus_dpram
        generic map (
          DATA_FILE  => DATA_FILE,
          ADDR_WIDTH => ETA_EXTRAPOLATION_ADDR_WIDTH,
          WORD_WIDTH => ETA_EXTRAPOLATION_WORD_SIZE
          )
        port map (
            clk => clk_ipb,
            rst => rst,
            ipb_in => ipbw(???+i), -- TODO
            ipb_out => ipbr(???+i), -- TODO
            rclk => clk240,
            q => sEtaLutOutput(i)(ETA_EXTRAPOLATION_WORD_SIZE-1 downto 0),
            addr => iExtrapolationAddress(i)
        );
    sDeltaEta(i) <= signed(sEtaLutOutput(i)(ETA_EXTRAPOLATION_WORD_SIZE-1 downto 0));

  end generate coordinate_extrapolation;

  assign_coords : process (d, in_buf, sDeltaEta, sDeltaPhi)
    variable tmpPhi : unsigned(9 downto 0);
  begin  -- process assign_coords
    for i in NCHAN-1 downto 0 loop
      if unsigned(d(i).data(PT_IN_HIGH downto PT_IN_LOW)) > 63 then
        -- If muon is high-pT we won't extrapolate.
        sExtrapolatedCoords_buffer(sExtrapolatedCoords_buffer'high)(i).eta <= signed(d(i).data(ETA_IN_HIGH downto ETA_IN_LOW));
        sExtrapolatedCoords_buffer(sExtrapolatedCoords_buffer'high)(i).phi <= unsigned(d(i).data(PHI_IN_HIGH downto PHI_IN_LOW));
      else
        -- If muon is low-pT we etrapolate.
        sExtrapolatedCoords_buffer(sExtrapolatedCoords_buffer'high)(i).eta <= signed(d(i).data(ETA_IN_HIGH downto ETA_IN_LOW)) + SHIFT_LEFT("000" & sDeltaEta(i), 3);

        if d(i).data(SYSIGN_IN_LOW) = '1' then
            tmpPhi := unsigned(d(i).data(PHI_IN_HIGH downto PHI_IN_LOW)) + SHIFT_LEFT("000" & sDeltaPhi(i), 3);
        else
            tmpPhi := unsigned(d(i).data(PHI_IN_HIGH downto PHI_IN_LOW)) - SHIFT_LEFT("000" & sDeltaPhi(i), 3);
        end if;
        sExtrapolatedCoords_buffer(sExtrapolatedCoords_buffer'high)(i).phi <= tmpPhi mod 576;
      end if;
    end loop;  -- i
  end process assign_coords;

  -- TODO: This buffer can probably be only 2 deep (actually it may be ok to replace the buffer with the one for idx bits altogether.)
  -- TODO: Buffer for idx bits will have to be more than 6 frames deep (to sync with 40 MHz clock again)
  shift_coord_buffer : process (clk240)
  begin  -- process shift_coord_buffer
    if clk240'event and clk240 = '1' then  -- rising clock edge
	sExtrapolatedCoords_buffer(sExtrapolatedCoords_buffer'high-1 downto 0) <= sExtrapolatedCoords_buffer(sExtrapolatedCoords_buffer'high downto 1);
    end if;
  end process shift_coord_buffer;

  -- TODO: Generate idx bits.
  -- TODO: Everything below this!!!!
  -- TODO: Lots of signals not declared!

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
              sMuons_link(iChan)(iFrame/2)(30 downto 0) <= in_buf(iFrame)(iChan).data(30 downto 0);
            else
              sMuons_link(iChan)(iFrame/2)(30 downto 0) <= (others => '0');
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
              sMuons_link(iChan)(iFrame/2)(61 downto 31) <= in_buf(iFrame)(iChan).data(30 downto 0);
            else
              sMuons_link(iChan)(iFrame/2)(61 downto 31) <= (others => '0');
            end if;
            -- Use every second result from SortRankLUT. (The other results
            -- were calculated with the 'wrong part' of the TF muon.)
            -- Using this iFrame even though pT and quality are contained in
            -- earlier frame as the rank calculation requires an additional
            -- clk240, so the "correct" sort rank is late by one.
            sSortRank_link(iChan)(iFrame/2) <= sSortRank_buffer(iFrame)(iChan);
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
          clk => clk_ipb,
          reset => rst,
          ipbus_in => ipbw(N_SLV_PHI_OFFSET_0+i),
          ipbus_out => ipbr(N_SLV_PHI_OFFSET_0+i),
          q => sPhiOffsetRegOutput(i downto i)
      );
  end generate gen_ipb_registers;

  assign_offsets : for i in sPhiOffset'range generate
      sPhiOffset(i) <= unsigned(sPhiOffsetRegOutput(i)(9 downto 0));
  end generate assign_offsets;

  sMuons_flat <= unroll_link_muons(sMuons_link(NCHAN-1 downto 0));
  unpack_muons : for i in sMuonsIn'range generate
    sMuonsIn(i) <= unpack_mu_from_flat(sMuons_flat(i), sPhiOffset(i/3));
  end generate unpack_muons;
  convert_muons : for i in sMuonsIn'range generate
    oMuons(i) <= gmt_mu_from_in_mu(sMuonsIn(i));
  end generate convert_muons;
  oTracks    <= track_addresses_from_in_mus(sMuons_flat);
  oEmpty     <= unpack_empty_bits(sEmpty_link(NCHAN-1 downto 0));
  oSortRanks <= unpack_sort_rank(sSortRank_link(NCHAN-1 downto 0));

  oValid      <= check_valid_bits(sValid_link(NCHAN-1 downto 0));

  q(NCHAN-1 downto 0) <= in_buf(0);

end Behavioral;
