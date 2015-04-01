library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

use work.mp7_data_types.all;
use work.ipbus.all;
use work.ipbus_decode_sort_rank_mems.all;

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

  signal ipbw : ipb_wbus_array(N_SLAVES - 1 downto 0);
  signal ipbr : ipb_rbus_array(N_SLAVES - 1 downto 0);

  signal in_buf : TQuadTransceiverBufferIn;

  type TSortRankInput is array (natural range <>) of std_logic_vector(12 downto 0);
  signal sSrtRnkIn : TSortRankInput(NCHAN-1 downto 0);

  signal sMuons_link : TFlatMuons(NCHAN-1 downto 0);  -- All input muons.
  signal sMuons_flat : TFlatMuon_vector(NCHAN*NUM_MUONS_IN-1 downto 0);  -- All input muons unrolled.
  signal sMuonsIn    : TGMTMuIn_vector(NCHAN*NUM_MUONS_IN-1 downto 0);

  signal sValid_link : TValid_link(NCHAN-1 downto 0);

  signal sEmpty_link : TEmpty_link(NCHAN-1 downto 0);

  -- Stores sort ranks for each 32 bit word that arrives from TFs. Every second
  -- such rank is garbage and will be disregarded in second step.
  type TSortRankBuffer is array (2*2*NUM_MUONS_LINK-1 downto 0) of TSortRank10_vector(NCHAN-1 downto 0);
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
        sel             => ipbus_sel_sort_rank_mems(ipb_in.ipb_addr),
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
            clk => clk_ipb,
            rst => rst,
            ipb_in => ipbw(i),
            ipb_out => ipbr(i),
            rclk => clk240,
            q => sSortRank_buffer(sSortRank_buffer'high)(i),
            addr => sSrtRnkIn(i)
        );

  end generate assign_ranks;

  fill_sort_rank_buf : process (clk240)
  begin  -- process fill_sort_rank_buf
    if clk240'event and clk240 = '1' then  -- rising clock edge
      sSortRank_buffer(sSortRank_buffer'high-1 downto 0) <= sSortRank_buffer(sSortRank_buffer'high downto 1);
    end if;
  end process fill_sort_rank_buf;


  gmt_in_reg : process (clk40)
  begin  -- process gmt_in_reg
    if clk40'event and clk40 = '1' then  -- rising clock edge
      for iChan in NCHAN-1 downto 0 loop
        for iFrame in 2*NUM_MUONS_LINK-1 downto 0 loop
          -- Store valid bit.
          sValid_link(iChan)(iFrame) <= in_buf(iFrame+BUFFER_IN_MU_POS_LOW)(iChan).valid;
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
      end loop;  -- iChan
    end if;
  end process gmt_in_reg;

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

  oValid      <= check_valid_bits(sValid_link(NCHAN-1 downto 0));
end Behavioral;
