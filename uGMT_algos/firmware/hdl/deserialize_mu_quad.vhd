library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

use work.mp7_data_types.all;
use work.ipbus.all;

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
    sMuons     : out TGMTMu_vector(NCHAN*NUM_MUONS_IN-1 downto 0);
    sTracks    : out TGMTMuTracks_vector(NCHAN-1 downto 0);
    sEmpty     : out std_logic_vector(NCHAN*NUM_MUONS_IN-1 downto 0);
    sSortRanks : out TSortRank10_vector(NCHAN*NUM_MUONS_IN-1 downto 0)
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

  signal sEmpty_link : TEmpty_link(NCHAN-1 downto 0);

  -- Stores sort ranks for each 32 bit word that arrives from TFs. Every second
  -- such rank is garbage and will be disregarded in second step.
  type   TSortRankBuffer is array (2*2*NUM_MUONS_LINK-1 downto 0) of TSortRank10_vector(NCHAN-1 downto 0);
  signal sSortRank_buffer : TSortRankBuffer;
  signal sSortRank_link   : TSortRank_link(NCHAN-1 downto 0);
  signal ipbusWe_vector   : std_logic_vector(sSortRank_buffer(0)'range);

begin

  -----------------------------------------------------------------------------
  -- ipbus address decode
  -----------------------------------------------------------------------------
  -- Use bits before start of addresses that truly point to addresses
  -- inside LUTs to address the LUTs themselves.
  -- Need to address 4 LUTs -> 2 bits needed.
  -- SortRank LUT has 12 bit addresses for IPbus. -> will use 13th and 12th
  -- bits.
  sel_lut_group <= std_logic_vector(unsigned(ipb_in.ipb_addr(13 downto 12)));

  fabric : entity work.ipbus_fabric_sel
    generic map(
      NSLV      => NCHAN,
      SEL_WIDTH => 2)
    port map(
      ipb_in          => ipb_in,
      ipb_out         => ipb_out,
      sel             => sel_lut_group,
      ipb_to_slaves   => ipbw,
      ipb_from_slaves => ipbr
      );

  in_buf(0) <= d(NCHAN-1 downto 0);

  fill_buffer : process (clk240)
  begin  -- process fill_buffer
    if clk240'event and clk240 = '1' then  -- rising clock edge
      in_buf(in_buf'high downto 1) <= in_buf(in_buf'high-1 downto 0);
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
        doutb  => sSortRank_buffer(0)(i),
        web    => "0"
        );

  end generate assign_ranks;

  fill_sort_rank_buf : process (clk240)
  begin  -- process fill_sort_rank_buf
    if clk240'event and clk240 = '1' then  -- rising clock edge
      sSortRank_buffer(sSortRank_buffer'high downto 1) <= sSortRank_buffer(sSortRank_buffer'high-1 downto 0);
    end if;
  end process fill_sort_rank_buf;


  gmt_in_reg : process (clk40)
  begin  -- process gmt_in_reg
    if clk40'event and clk40 = '1' then  -- rising clock edge
      for i in NCHAN-1 downto 0 loop
        for j in 2*NUM_MUONS_LINK-1 downto 0 loop
          if (j mod 2) = 1 then
            -- Get first half of muon.
            if in_buf(j+BUFFER_IN_MU_POS_LOW)(i).valid = VALID_BIT then
              -- We're only using the lower 30 bits as the MSB is used for
              -- status codes.
              sMuons_link(i)(j/2)(30 downto 0) <= in_buf(j+BUFFER_IN_MU_POS_LOW)(i).data(30 downto 0);
            else
              sMuons_link(i)(j/2)(30 downto 0) <= (others => '0');
            end if;

            -- Determine empty bit.
            if in_buf(j+BUFFER_IN_MU_POS_LOW)(i).data(PT_IN_HIGH downto PT_IN_LOW) = (PT_IN_HIGH downto PT_IN_LOW => '0') then
              sEmpty_link(i)(j/2) <= '1';
            else
              sEmpty_link(i)(j/2) <= '0';
            end if;

          else
            -- Get second half of muon.
            if in_buf(j+BUFFER_IN_MU_POS_LOW)(i).valid = VALID_BIT then
              -- We're only using the lower 30 bits as the MSB is used for
              -- status codes.
              sMuons_link(i)(j/2)(61 downto 31) <= in_buf(j+BUFFER_IN_MU_POS_LOW)(i).data(30 downto 0);
            else
              sMuons_link(i)(j/2)(61 downto 31) <= (others => '0');
            end if;

            -- Use every second result from SortRankLUT. (The other results
            -- were calculated with the 'wrong part' of the TF muon.)
            -- Using j-1 as the rank calculation requires an additional clk240,
            -- so the "correct" sort rank is late by one.
            sSortRank_link(i)(j/2) <= sSortRank_buffer(j+BUFFER_IN_MU_POS_LOW)(i);
          end if;
        end loop;  -- j
      end loop;  -- i
    end if;
  end process gmt_in_reg;

  sMuons_flat <= unroll_link_muons(sMuons_link(NCHAN-1 downto 0));
  unpack_muons : for i in sMuonsIn'range generate
    sMuonsIn(i) <= unpack_mu_from_flat(sMuons_flat(i));
  end generate unpack_muons;
  convert_muons : for i in sMuonsIn'range generate
    sMuons(i) <= gmt_mu_from_in_mu(sMuonsIn(i));
  end generate convert_muons;
  sTracks    <= track_addresses_from_in_mus(sMuonsIn);
  sEmpty     <= unpack_empty_bits(sEmpty_link(NCHAN-1 downto 0));
  sSortRanks <= unpack_sort_rank(sSortRank_link(NCHAN-1 downto 0));
end Behavioral;

