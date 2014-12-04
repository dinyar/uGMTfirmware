library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

use work.mp7_data_types.all;
use work.ipbus.all;
use work.ipbus_reg_types.all;
use work.ipbus_ctrlreg_v.all;

use work.GMTTypes.all;
use work.ugmt_constants.all;

entity deserialize_mu_quad is
  generic (
    NCHAN     : positive := 4;
    VALID_BIT : std_logic
    );
  port (
    bunch_ctr  : in  std_logic_vector(11 downto 0);
    orb_ctr    : in  std_logic_vector(23 downto 0);
    clk_ipb    : in  std_logic;
    rst        : in  std_logic;
    ipb_in     : in  ipb_wbus;
    ipb_out    : out ipb_rbus;
    clk240     : in  std_logic;
    clk40      : in  std_logic;
    d          : in  ldata(NCHAN-1 downto 0);
    oMuons     : out TGMTMu_vector(NCHAN*NUM_MUONS_IN-1 downto 0);
    oTracks    : out TGMTMuTracks_vector(NCHAN-1 downto 0);
    oEmpty     : out std_logic_vector(NCHAN*NUM_MUONS_IN-1 downto 0);
    oSortRanks : out TSortRank10_vector(NCHAN*NUM_MUONS_IN-1 downto 0);
    oValid     : out std_logic
    );
end deserialize_mu_quad;

architecture Behavioral of deserialize_mu_quad is
  signal sel_lut_group : std_logic_vector(1 downto 0);

  signal ipbw : ipb_wbus_array(NCHAN - 1 downto 0);
  signal ipbr : ipb_rbus_array(NCHAN - 1 downto 0);

  signal in_buf : TQuadTransceiverBufferIn;

  type   TSortRankInput is array (natural range <>) of std_logic_vector(12 downto 0);
  signal sSrtRnkIn : TSortRankInput(NCHAN-1 downto 0);

  signal sMuons_link : TFlatMuons(NCHAN-1 downto 0);  -- All input muons.
  signal sMuons_flat : TFlatMuon_vector(NCHAN*NUM_MUONS_IN-1 downto 0);  -- All input muons unrolled.
  signal sMuonsIn    : TGMTMuIn_vector(NCHAN*NUM_MUONS_IN-1 downto 0);

  signal sValid_link : TValid_link(NCHAN-1 downto 0);

  signal sEmpty_link : TEmpty_link(NCHAN-1 downto 0);

  -- Stores sort ranks for each 32 bit word that arrives from TFs. Every second
  -- such rank is garbage and will be disregarded in second step.
  type   TSortRankBuffer is array (2*2*NUM_MUONS_LINK-1 downto 0) of TSortRank10_vector(NCHAN-1 downto 0);
  signal sSortRank_buffer : TSortRankBuffer;
  signal sSortRank_link   : TSortRank_link(NCHAN-1 downto 0);
  signal ipbusWe_vector   : std_logic_vector(sSortRank_buffer(0)'range);

  type   TControlBits_vector is array (NCHAN-1 downto 0) of std_logic_vector(5 downto 0);
  type   TErrorCounter_vector is array (NCHAN-1 downto 0) of integer range 0 to 65535;
  signal bunchCounterErrors          : TErrorCounter_vector;
  signal bcZeroErrors                : TErrorCounter_vector;
  signal syncCounterErrors           : TErrorCounter_vector;
  signal bunchCounterErrors_register : ipb_reg_v(NCHAN-1 downto 0);
  signal bcZeroErrors_register       : ipb_reg_v(NCHAN-1 downto 0);
  signal syncCounterErrors_register  : ipb_reg_v(NCHAN-1 downto 0);
begin

  -----------------------------------------------------------------------------
  -- ipbus address decode
  -----------------------------------------------------------------------------
  -- Use bits before start of addresses that truly point to addresses
  -- inside LUTs to address the LUTs themselves.
  -- Need to address 4 LUTs, three additional register banks -> 2 bits needed.
  -- SortRank LUT has 12 bit addresses for IPbus -> will use 14th to 12th bits.
  sel_lut_group <= std_logic_vector(unsigned(ipb_in.ipb_addr(14 downto 12)));

  fabric : entity work.ipbus_fabric_sel
    generic map(
      NSLV      => NCHAN+3,
      SEL_WIDTH => 3)
    port map(
      ipb_in          => ipb_in,
      ipb_out         => ipb_out,
      sel             => sel_lut_group,
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
    ipbusWe_vector(i) <= ipbw(i).ipb_write and ipbw(i).ipb_strobe;
    sort_rank_assignment : entity work.sort_rank_lut
      port map (
        clka   => clk_ipb,
        wea(0) => ipbusWe_vector(i),
        addra  => ipbw(i).ipb_addr(12 downto 0),
        dina   => ipbw(i).ipb_wdata(9 downto 0),
        douta  => ipbr(i).ipb_rdata(9 downto 0),
        clkb   => clk240,
        enb    => '1',
        addrb  => sSrtRnkIn(i),
        dinb   => (others => '0'),
        doutb  => sSortRank_buffer(sSortRank_buffer'high)(i),
        web    => "0"
        );

  end generate assign_ranks;

  fill_sort_rank_buf : process (clk240)
  begin  -- process fill_sort_rank_buf
    if clk240'event and clk240 = '1' then  -- rising clock edge
      sSortRank_buffer(sSortRank_buffer'high-1 downto 0) <= sSortRank_buffer(sSortRank_buffer'high downto 1);
    end if;
  end process fill_sort_rank_buf;


  gmt_in_reg : process (clk40)
    variable vControlBits_raw : TControlBits_vector;

    variable vSyncCounterErrors   : TErrorCounter_vector := (0, 0, 0, 0);
    variable vBunchCounterErrors  : TErrorCounter_vector := (0, 0, 0, 0);
    variable vBcZeroCounterErrors : TErrorCounter_vector := (0, 0, 0, 0);
  begin  -- process gmt_in_reg
    if clk40'event and clk40 = '1' then  -- rising clock edge
      for iChan in NCHAN-1 downto 0 loop
        for iFrame in 2*NUM_MUONS_LINK-1 downto 0 loop
          -- Store valid bit.
          sValid_link(iChan)(iFrame) <= in_buf(iFrame+BUFFER_IN_MU_POS_LOW)(iChan).valid;

          -- Store control bits that are encoded into the MSB of each input word.
          vControlBits_raw(iChan)(iFrame) := in_buf(iFrame+BUFFER_IN_MU_POS_LOW)(iChan).data(31);

          if (iFrame mod 2) = 0 then
            -- Get first half of muon.
            if in_buf(iFrame+BUFFER_IN_MU_POS_LOW)(iChan).valid = VALID_BIT then
              -- We're only using the lower 30 bits as the MSB is used for
              -- status codes.
              sMuons_link(iChan)(iFrame/2)(30 downto 0) <= in_buf(iFrame+BUFFER_IN_MU_POS_LOW)(iChan).data(30 downto 0);
            else
              sMuons_link(iChan)(iFrame/2)(30 downto 0) <= (others => '0');
            end if;

            -- Determine empty bit.
            if in_buf(iFrame+BUFFER_IN_MU_POS_LOW)(iChan).data(PT_IN_HIGH downto PT_IN_LOW) = (PT_IN_HIGH downto PT_IN_LOW => '0') then
              sEmpty_link(iChan)(iFrame/2) <= '1';
            else
              sEmpty_link(iChan)(iFrame/2) <= '0';
            end if;

          else
            -- Get second half of muon.
            if in_buf(iFrame+BUFFER_IN_MU_POS_LOW)(iChan).valid = VALID_BIT then
              -- We're only using the lower 30 bits as the MSB is used for
              -- status codes.
              sMuons_link(iChan)(iFrame/2)(61 downto 31) <= in_buf(iFrame+BUFFER_IN_MU_POS_LOW)(iChan).data(30 downto 0);
            else
              sMuons_link(iChan)(iFrame/2)(61 downto 31) <= (others => '0');
            end if;

            -- Use every second result from SortRankLUT. (The other results
            -- were calculated with the 'wrong part' of the TF muon.)
            -- Using this iFrame even though pT and quality are contained in
            -- earlier frame as the rank calculation requires an additional
            -- clk240, so the "correct" sort rank is late by one.
            sSortRank_link(iChan)(iFrame/2) <= sSortRank_buffer(iFrame+BUFFER_IN_MU_POS_LOW)(iChan);
          end if;
        end loop;  -- iFrame

        -- Check control bits and increment error counters.        
        vBunchCounterErrors  := bunchCounterErrors;
        vBcZeroCounterErrors := bcZeroErrors;
        vSyncCounterErrors   := syncCounterErrors;

        if vControlBits_raw(iChan)(iFrame)(B2 downto B0) /= bunch_ctr(2 downto 0) then
          if vBunchCounterErrors < 65535 then
            vBunchCounterErrors := vBunchCounterErrors+1;
          else
            vBunchCounterErrors := 1;
          end if;
        end if;

        if vControlBits_raw(iChan)(SE_FRM).data(31) = '1' then
          if vSyncCounterErrors < 65535 then
            vSyncCounterErrors := vSyncCounterErrors+1;
          else
            vSyncCounterErrors := 1;
          end if;
        end if;

        -- TODO: Resets and BC0 counter.
      end loop;  -- iChan

      bunchCounterErrors <= vBunchCounterErrors;
      bcZeroErrors       <= vBcZeroCounterErrors;
      syncCounterErrors  <= vSyncCounterErrors;
      
    end if;
  end process gmt_in_reg;

  convert_error_counters : for i in NCHAN-1 downto 0 generate
    bunchCounterErrors_register(i) <= std_logic_vector(to_unsigned(bunchCounterErrors(i), 32));
    bcZeroErrors_register(i)       <= std_logic_vector(to_unsigned(bcZeroErrors(i), 32));
    syncCounterErrors_register(i)  <= std_logic_vector(to_unsigned(syncCounterErrors(i), 32));
  end generate convert_error_counters;

  bunchCounterErr : entity work.ipbus_ctrlreg_v
    generic map (
      N_REG => 4)
    port map (
      clk       => clk_ipb,
      reset     => rst,
      ipbus_in  => ipb_wbus(4),
      ipbus_out => ipb_rbus(4),
      d         => bunchCounterErrors_register;
      q         => open;                -- Can I plug in another bunchCounter
                                        -- signal and loop it back to implement
                                        -- the reset in this way?
      stb       => open
      );    
  bcZeroCounterErr : entity work.ipbus_ctrlreg_v
    generic map (
      N_REG => 4)
    port map (
      clk       => clk_ipb,
      reset     => rst,
      ipbus_in  => ipb_wbus(5),
      ipbus_out => ipb_rbus(5),
      d         => bcZeroErrors_register;
      q         => open;                -- Can I plug in another bcZeroCounter
                                        -- signal and loop it back to implement
                                        -- the reset in this way?
      stb       => open
      );    
  syncCounterErr : entity work.ipbus_ctrlreg_v
    generic map (
      N_REG => 4)
    port map (
      clk       => clk_ipb,
      reset     => rst,
      ipbus_in  => ipb_wbus(6),
      ipbus_out => ipb_rbus(6),
      d         => syncCounterErrors_register;
      q         => open;                -- Can I plug in another syncCounter
                                        -- signal and loop it back to implement
                                        -- the reset in this way?
      stb       => open
      );    

  sMuons_flat <= unroll_link_muons(sMuons_link(NCHAN-1 downto 0));
  unpack_muons : for i in sMuonsIn'range generate
    sMuonsIn(i) <= unpack_mu_from_flat(sMuons_flat(i));
  end generate unpack_muons;
  convert_muons : for i in sMuonsIn'range generate
    oMuons(i) <= gmt_mu_from_in_mu(sMuonsIn(i));
  end generate convert_muons;
  oTracks    <= track_addresses_from_in_mus(sMuonsIn);
  oEmpty     <= unpack_empty_bits(sEmpty_link(NCHAN-1 downto 0));
  oSortRanks <= unpack_sort_rank(sSortRank_link(NCHAN-1 downto 0));

  oValid <= check_valid_bits(sValid_link(NCHAN-1 downto 0));
end Behavioral;

