library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

use work.mp7_data_types.all;
use work.ipbus.all;
use work.ipbus_reg_types.all;
use work.ipbus_decode_gen_calo_idx_bits.all;

use work.mp7_ttc_decl.all;
use work.mp7_brd_decl.all;

use work.GMTTypes.all;
use work.ugmt_constants.all;

entity gen_idx_bits is
  generic (
    NCHAN                        : positive := 4;
    PHI_EXTRAPOLATION_DATA_FILE  : string;
    ETA_EXTRAPOLATION_DATA_FILE  : string
    );
  port (
    clk_ipb      : in  std_logic;
    rst          : in  std_logic;
    ipb_in       : in  ipb_wbus;
    ipb_out      : out ipb_rbus;
    clk240       : in  std_logic;
    clk40        : in  std_logic;
    d            : in  ldata(NCHAN-1 downto 0);
    iGlobalPhi   : in  TGlobalPhi_frame(NCHAN-1 downto 0);
    oCaloIdxBits : out TCaloIndexBit_vector(NCHAN*NUM_MUONS_IN-1 downto 0)
    );
end gen_idx_bits;

architecture Behavioral of gen_idx_bits is

  signal ipbw : ipb_wbus_array(N_SLAVES - 1 downto 0);
  signal ipbr : ipb_rbus_array(N_SLAVES - 1 downto 0);

  signal d_reg          : ldata(NCHAN-1 downto 0);
  signal sGlobalPhi_reg : TGlobalPhi_frame(NCHAN-1 downto 0);

  type   TEtaAbs is array (integer range <>) of unsigned(8 downto 0);
  signal sEtaAbs : TEtaAbs(NCHAN-1 downto 0);
  signal sExtrapolationAddress : TExtrapolationAddress(NCHAN-1 downto 0);

  signal sEtaExtrapolationLutOutput : TLutBuf(sExtrapolationAddress'range);
  signal sPhiExtrapolationLutOutput : TLutBuf(sExtrapolationAddress'range);
  signal sEtaIdxBitsLutOutput : TLutBuf(sExtrapolationAddress'range);
  signal sPhiIdxBitsLutOutput : TLutBuf(sExtrapolationAddress'range);

  signal sDeltaEta : TDeltaEta_vector(sExtrapolationAddress'range);
  signal sDeltaPhi : TDeltaPhi_vector(sExtrapolationAddress'range);

  -- Stores calo index bits for each 32 bit word that arrives from TFs.
  -- Every second such value is garbage and will be disregarded in a
  -- second step.
  signal sExtrapolatedCoords : TSpatialCoordinate_vector(NCHAN-1 downto 0);
--   type TCaloIndexBitsBuffer is array (2*NUM_MUONS_LINK-1 downto 0) of TCaloIndexBit_vector(NCHAN-1 downto 0);
  -- TODO: Would be significantly clearer with two buffers in series.
  -- Buffer is 10 frames deep as it needs to compensate that idx bits are computed in 2 240 MHz ticks.
  type TCaloIndexBitsBuffer is array (9 downto 0) of TCaloIndexBit_vector(NCHAN-1 downto 0);
  signal sCaloIndexBits_buffer : TCaloIndexBitsBuffer;
  signal sCaloIndexBits_link   : TCaloIndexBits_link(NCHAN-1 downto 0);

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
        sel             => ipbus_sel_gen_calo_idx_bits(ipb_in.ipb_addr),
        ipb_to_slaves   => ipbw,
        ipb_from_slaves => ipbr
        );

  fill_buffer : process (clk240)
  begin  -- process fill_buffer
    if clk240'event and clk240 = '1' then  -- rising clock edge
      d_reg       <= d;
      sGlobalPhi_reg <= iGlobalPhi;
    end if;
  end process fill_buffer;

  coordinate_extrapolation : for i in sExtrapolatedCoords'range generate
	sEtaAbs(i) <= unsigned(abs(signed(d(i).data(ETA_IN_HIGH downto ETA_IN_LOW))));
	sExtrapolationAddress(i) <= std_logic_vector(sEtaAbs(i)(7 downto 2)) &
    							d(i).data(PT_IN_LOW+5 downto PT_IN_LOW);
	phi_extrapolation : entity work.ipbus_dpram
		generic map (
			DATA_FILE  => PHI_EXTRAPOLATION_DATA_FILE,
			ADDR_WIDTH => EXTRAPOLATION_ADDR_WIDTH,
			WORD_WIDTH => PHI_EXTRAPOLATION_WORD_SIZE
			)
		port map (
			clk => clk_ipb,
			rst => rst,
			ipb_in => ipbw(N_SLV_PHI_EXTRAPOLATION_MEM_0+i),
			ipb_out => ipbr(N_SLV_PHI_EXTRAPOLATION_MEM_0+i),
			rclk => clk240,
			q => sPhiExtrapolationLutOutput(i)(PHI_EXTRAPOLATION_WORD_SIZE-1 downto 0),
			addr => std_logic_vector(sExtrapolationAddress(i))
		);
	-- TODO: Do I need this intermediate signal?
	sDeltaPhi(i) <= unsigned(sPhiExtrapolationLutOutput(i)(PHI_EXTRAPOLATION_WORD_SIZE-1 downto 0));
    eta_extrapolation : entity work.ipbus_dpram
        generic map (
          DATA_FILE  => ETA_EXTRAPOLATION_DATA_FILE,
          ADDR_WIDTH => EXTRAPOLATION_ADDR_WIDTH,
          WORD_WIDTH => ETA_EXTRAPOLATION_WORD_SIZE
          )
        port map (
            clk => clk_ipb,
            rst => rst,
            ipb_in => ipbw(N_SLV_ETA_EXTRAPOLATION_MEM_0+i),
            ipb_out => ipbr(N_SLV_ETA_EXTRAPOLATION_MEM_0+i),
            rclk => clk240,
            q => sEtaExtrapolationLutOutput(i)(ETA_EXTRAPOLATION_WORD_SIZE-1 downto 0),
            addr => sExtrapolationAddress(i)
        );
    sDeltaEta(i) <= signed(sEtaExtrapolationLutOutput(i)(ETA_EXTRAPOLATION_WORD_SIZE-1 downto 0));
  end generate coordinate_extrapolation;

  -- We use the output of the (clocked) deltaEta/deltaPhi LUTs here.
  -- As they are clocked we have to take care to extract the muon quantities
  -- from the buffered value (i.e. d_reg). The exception is the
  -- sign bit as this is transmitted one frame later.
  assign_coords : process (d, d_reg, sDeltaEta, sDeltaPhi, sGlobalPhi_reg)
    variable tmpPhi : unsigned(9 downto 0);
  begin  -- process assign_coords
    for i in NCHAN-1 downto 0 loop
      if unsigned(d_reg(i).data(PT_IN_HIGH downto PT_IN_LOW)) > 63 then
        -- If muon is high-pT we won't extrapolate.
        sExtrapolatedCoords(i).eta <= signed(d_reg(i).data(ETA_IN_HIGH downto ETA_IN_LOW));
        sExtrapolatedCoords(i).phi <= sGlobalPhi_reg(i);
      else
        -- If muon is low-pT we etrapolate.
        sExtrapolatedCoords(i).eta <= signed(d_reg(i).data(ETA_IN_HIGH downto ETA_IN_LOW)) + SHIFT_LEFT("000" & sDeltaEta(i), 3);

        if d(i).data(SYSIGN_IN_LOW) = '1' then
            tmpPhi := sGlobalPhi_reg(i) + SHIFT_LEFT("000" & sDeltaPhi(i), 3);
        else
            tmpPhi := sGlobalPhi_reg(i) - SHIFT_LEFT("000" & sDeltaPhi(i), 3);
        end if;
        sExtrapolatedCoords(i).phi <= tmpPhi mod 576;
      end if;
    end loop;  -- i
  end process assign_coords;

  lookup_calo_idx_bits : for i in sExtrapolatedCoords'range generate
	eta_idx_bits_mem : entity work.ipbus_dpram_dist
	    generic map (
	      DATA_FILE  => "IdxSelMemEta.mif",
	      ADDR_WIDTH => ETA_IDX_MEM_ADDR_WIDTH,
	      WORD_WIDTH => ETA_IDX_MEM_WORD_SIZE
	      )
	    port map (
	      clk     => clk_ipb,
	      ipb_in  => ipbw(N_SLV_ETA_IDX_BITS_MEM_0+i),
	      ipb_out => ipbr(N_SLV_ETA_IDX_BITS_MEM_0+i),
	      rclk    => clk240,
	      q       => sEtaIdxBitsLutOutput(i)(ETA_IDX_MEM_WORD_SIZE-1 downto 0),
	      addr    => std_logic_vector(sExtrapolatedCoords(i).eta)
	      );
    sCaloIndexBits_buffer(sCaloIndexBits_buffer'high)(i).eta <= unsigned(sEtaIdxBitsLutOutput(i)(ETA_IDX_MEM_WORD_SIZE-1 downto 0));
	phi_idx_bits_mem : entity work.ipbus_dpram_dist
	    generic map (
	      DATA_FILE  => "IdxSelMemPhi.mif",
	      ADDR_WIDTH => PHI_IDX_MEM_ADDR_WIDTH,
	      WORD_WIDTH => PHI_IDX_MEM_WORD_SIZE
	      )
	    port map (
	      clk     => clk_ipb,
	      ipb_in  => ipbw(N_SLV_PHI_IDX_BITS_MEM_0+i),
	      ipb_out => ipbr(N_SLV_PHI_IDX_BITS_MEM_0+i),
	      rclk    => clk240,
	      q       => sPhiIdxBitsLutOutput(i)(PHI_IDX_MEM_WORD_SIZE-1 downto 0),
	      addr    => std_logic_vector(sExtrapolatedCoords(i).phi)
	      );
    sCaloIndexBits_buffer(sCaloIndexBits_buffer'high)(i).phi <= unsigned(sPhiIdxBitsLutOutput(i)(PHI_IDX_MEM_WORD_SIZE-1 downto 0));
  end generate lookup_calo_idx_bits;

  shift_idx_bits_buffer : process (clk240)
  begin  -- process shift_idx_bits_buffer
    if clk240'event and clk240 = '1' then  -- rising clock edge
	sCaloIndexBits_buffer(sCaloIndexBits_buffer'high-1 downto 0) <= sCaloIndexBits_buffer(sCaloIndexBits_buffer'high downto 1);
    end if;
  end process shift_idx_bits_buffer;

  gmt_in_reg : process (clk40)
  begin  -- process gmt_in_reg
    if clk40'event and clk40 = '1' then  -- rising clock edge
      for iChan in NCHAN-1 downto 0 loop
        for iFrame in 2*NUM_MUONS_LINK-1 downto 0 loop
          if (iFrame mod 2) = 0 then
            -- Use every second result from index bit generation. (The other
            -- results were calculated with the 'wrong part' of the TF muon.)
            sCaloIndexBits_link(iChan)(iFrame/2) <= sCaloIndexBits_buffer(iFrame)(iChan);
          else
            -- DO NOTHING
          end if;
        end loop;  -- iFrame
      end loop;  -- iChan
    end if;
  end process gmt_in_reg;

  oCaloIdxBits <= unpack_calo_idx_bits(sCaloIndexBits_link(NCHAN-1 downto 0));

end Behavioral;
