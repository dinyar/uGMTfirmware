library IEEE;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;
library Types;
use Types.GMTTypes.all;

entity GMT is
  port (mu_sel           : in unsigned(0 to 2);
        calo_toggle      : in std_logic_vector(0 downto 0);
        mu_toggle        : in std_logic_vector (0 downto 0);
        wedge_toggle     : in std_logic_vector (0 downto 0);
        sort_rank_toggle : in std_logic_vector (0 downto 0);
        idx_bit_toggle   : in std_logic_vector (0 downto 0);
        empty_toggle     : in std_logic_vector (0 downto 0);
        spy_toggle       : in std_logic_vector(0 downto 0);

        oMuon : out TGMTMu;

        clk   : in std_logic;
        sinit : in std_logic
        );
end GMT;

architecture Behavioral of GMT is

  -----------------------------------------------------------------------------
  -- components
  -----------------------------------------------------------------------------

  -- Supplies half the calo data
  component half_calo_sim_mem
    port (
      clka  : in  std_logic;
      wea   : in  std_logic_vector(0 downto 0);
      addra : in  std_logic_vector(0 downto 0);
      dina  : in  std_logic_vector(3455 downto 0);
      douta : out std_logic_vector(3455 downto 0)
      );
  end component;

  -- Supplies TGMTMu_vec data
  component mu_sim_mem
    port (
      clka  : in  std_logic;
      wea   : in  std_logic_vector(0 downto 0);
      addra : in  std_logic_vector(0 downto 0);
      dina  : in  std_logic_vector(3995 downto 0);
      douta : out std_logic_vector(3995 downto 0);
      clkb  : in  std_logic;
      enb   : in  std_logic;
      web   : in  std_logic_vector(0 downto 0);
      addrb : in  std_logic_vector(0 downto 0);
      dinb  : in  std_logic_vector(3995 downto 0);
      doutb : out std_logic_vector(3995 downto 0)
      );
  end component;

  -- Supplies TMuonAddress_Wedge_vector data
  component wedge_sim_mem
    port (
      clka  : in  std_logic;
      wea   : in  std_logic_vector(0 downto 0);
      addra : in  std_logic_vector(0 downto 0);
      dina  : in  std_logic_vector(4319 downto 0);
      douta : out std_logic_vector(4319 downto 0);
      clkb  : in  std_logic;
      enb   : in  std_logic;
      web   : in  std_logic_vector(0 downto 0);
      addrb : in  std_logic_vector(0 downto 0);
      dinb  : in  std_logic_vector(4319 downto 0);
      doutb : out std_logic_vector(4319 downto 0)
      );
  end component;

  -- Supplies sort ranks
  component sort_rank_sim_mem
    port (
      clka  : in  std_logic;
      wea   : in  std_logic_vector(0 downto 0);
      addra : in  std_logic_vector(0 downto 0);
      dina  : in  std_logic_vector(1079 downto 0);
      douta : out std_logic_vector(1079 downto 0);
      clkb  : in  std_logic;
      enb   : in  std_logic;
      web   : in  std_logic_vector(0 downto 0);
      addrb : in  std_logic_vector(0 downto 0);
      dinb  : in  std_logic_vector(1079 downto 0);
      doutb : out std_logic_vector(1079 downto 0)
      );
  end component;

  -- Supplies index bits
  component idx_sim_mem
    port (
      clka  : in  std_logic;
      wea   : in  std_logic_vector(0 downto 0);
      addra : in  std_logic_vector(0 downto 0);
      dina  : in  std_logic_vector(755 downto 0);
      douta : out std_logic_vector(755 downto 0);
      clkb  : in  std_logic;
      enb   : in  std_logic;
      web   : in  std_logic_vector(0 downto 0);
      addrb : in  std_logic_vector(0 downto 0);
      dinb  : in  std_logic_vector(755 downto 0);
      doutb : out std_logic_vector(755 downto 0)
      );
  end component;

  -- Supplies empty bits
  component empty_sim_mem
    port (
      clka  : in  std_logic;
      wea   : in  std_logic_vector(0 downto 0);
      addra : in  std_logic_vector(0 downto 0);
      dina  : in  std_logic_vector(107 downto 0);
      douta : out std_logic_vector(107 downto 0);
      clkb  : in  std_logic;
      enb   : in  std_logic;
      web   : in  std_logic_vector(0 downto 0);
      addrb : in  std_logic_vector(0 downto 0);
      dinb  : in  std_logic_vector(107 downto 0);
      doutb : out std_logic_vector(107 downto 0)
      );
  end component;

  -- Spy memory for final muons
  component spy_mem
    port (
      clka  : in  std_logic;
      wea   : in  std_logic_vector(0 downto 0);
      addra : in  std_logic_vector(0 downto 0);
      dina  : in  std_logic_vector(295 downto 0);
      douta : out std_logic_vector(295 downto 0);
      clkb  : in  std_logic;
      enb   : in  std_logic;
      web   : in  std_logic_vector(0 downto 0);
      addrb : in  std_logic_vector(0 downto 0);
      dinb  : in  std_logic_vector(295 downto 0);
      doutb : out std_logic_vector(295 downto 0)
      );
  end component;

  component IsoAssignmentUnit is
    port (
      iEnergies  : in  TCaloRegionEtaSlice_vector;
      iMuonsB    : in  TGMTMu_vector (0 to 35);
      iMuonsO    : in  TGMTMu_vector (0 to 35);
      iMuonsF    : in  TGMTMu_vector (0 to 35);
      iMuIdxBits : in  TIndexBits_vector (7 downto 0);
      oIsoBits   : out std_logic_vector (7 downto 0);
      clk        : in  std_logic;
      sinit      : in  std_logic);
  end component;

  component SortAndCancelUnit
    generic (
      rpc_merging : boolean);
    port (
      iMuonsB : in TGMTMu_vector(0 to 35);
      iMuonsO : in TGMTMu_vector(0 to 35);
      iMuonsF : in TGMTMu_vector(0 to 35);

      -- For RPC merging.
      iMuonsRPCb     : in TGMTMuRPC_vector(3 downto 0);
      iMuonsRPCf     : in TGMTMuRPC_vector(3 downto 0);
      iSortRanksRPCb : in TSortRank10_vector(3 downto 0);
      iSortRanksRPCf : in TSortRank10_vector(3 downto 0);
      iEmptyRPCb     : in std_logic_vector(3 downto 0);
      iEmptyRPCf     : in std_logic_vector(3 downto 0);
      iIdxBitsRPCb   : in TIndexBits_vector(3 downto 0);
      iIdxBitsRPCf   : in TIndexBits_vector(3 downto 0);

      iTracksB : in TGMTMuTracks_vector(0 to 11);
      iTracksO : in TGMTMuTracks_vector(0 to 11);
      iTracksF : in TGMTMuTracks_vector(0 to 11);

      -- I'm assuming I can assign rank and check for empty during rcv stage.
      iSortRanksB : in TSortRank10_vector(0 to 35);
      iSortRanksO : in TSortRank10_vector(0 to 35);
      iSortRanksF : in TSortRank10_vector(0 to 35);

      iEmptyB : in std_logic_vector(0 to 35);
      iEmptyO : in std_logic_vector(0 to 35);
      iEmptyF : in std_logic_vector(0 to 35);

      iIso : in std_logic_vector(7 downto 0);

      iIdxBitsB : in TIndexBits_vector(0 to 35);
      iIdxBitsO : in TIndexBits_vector(0 to 35);
      iIdxBitsF : in TIndexBits_vector(0 to 35);

      oIdxBits : out TIndexBits_vector(7 downto 0);
      oMuons   : out TGMTMu_vector(7 downto 0);

      -- Clock and control
      clk   : in std_logic;
      sinit : in std_logic
      );
  end component;

  -----------------------------------------------------------------------------
  -- signals
  -----------------------------------------------------------------------------
  signal calo_toggle_reg      : std_logic_vector(0 downto 0);
  signal mu_toggle_reg        : std_logic_vector (0 downto 0);
  signal wedge_toggle_reg     : std_logic_vector (0 downto 0);
  signal sort_rank_toggle_reg : std_logic_vector (0 downto 0);
  signal idx_bit_toggle_reg   : std_logic_vector (0 downto 0);
  signal empty_toggle_reg     : std_logic_vector (0 downto 0);
  signal spy_toggle_reg       : std_logic_vector(0 downto 0);

  signal sGMTCaloInfo_flat : std_logic_vector(0 to 6911);
  signal sEnergyDeposits   : TCaloRegionEtaSlice_vector(31 downto 0);

  signal sGMTMu_flat : std_logic_vector(0 to 3995);
  signal sMuonsInB   : TGMTMuIn_vector(0 to 35);
  signal sMuonsInO   : TGMTMuIn_vector(0 to 35);
  signal sMuonsInF   : TGMTMuIn_vector(0 to 35);
  signal sMuonsB     : TGMTMu_vector(0 to 35);
  signal sMuonsO     : TGMTMu_vector(0 to 35);
  signal sMuonsF     : TGMTMu_vector(0 to 35);

  signal sWedgeAddresses_flat : std_logic_vector(0 to 4319);
  signal sTracksB             : TGMTMuTracks_vector(0 to 11);
  signal sTracksO             : TGMTMuTracks_vector(0 to 11);
  signal sTracksF             : TGMTMuTracks_vector(0 to 11);

  signal sSortRanks_flat : std_logic_vector(0 to 1079);
  signal sSortRanksB     : TSortRank10_vector(0 to 35);
  signal sSortRanksO     : TSortRank10_vector(0 to 35);
  signal sSortRanksF     : TSortRank10_vector(0 to 35);

  signal sIdxBits_flat : std_logic_vector(0 to 755);
  signal sIdxBitsB     : TIndexBits_vector(0 to 35);
  signal sIdxBitsO     : TIndexBits_vector(0 to 35);
  signal sIdxBitsF     : TIndexBits_vector(0 to 35);

  signal sEmpty_flat : std_logic_vector(0 to 107);
  signal sEmptyB     : std_logic_vector(0 to 35);
  signal sEmptyO     : std_logic_vector(0 to 35);
  signal sEmptyF     : std_logic_vector(0 to 35);

  signal sIsoBits : std_logic_vector(7 downto 0);

  signal sMuIdxBits : TIndexBits_vector(7 downto 0);

  signal sMuons_spy    : std_logic_vector(0 to 295);
  signal sMuons_sorted : TGMTMu_vector(7 downto 0);

  -- For RPC merging.
  signal sMuonsRPCb : TGMTMuRPC_vector(3 downto 0);
  signal sMuonsRPCf : TGMTMuRPC_vector(3 downto 0);
  signal sSortRanksRPCb : TSortRank10_vector(3 downto 0);
  signal sSortRanksRPCf : TSortRank10_vector(3 downto 0);
  signal sEmptyRPCb : std_logic_vector(3 downto 0);
  signal sEmptyRPCf : std_logic_vector(3 downto 0);
  signal sIdxBitsRPCb : TIndexBits_vector(3 downto 0);
  signal sIdxBitsRPCf : TIndexBits_vector(3 downto 0);

  -----------------------------------------------------------------------------
  -- functions/procedures
  -----------------------------------------------------------------------------

  function convert_vec_to_wedge (
    signal iGMTMu_vec : TGMTMuIn_vector(0 to 35))
    return TGMTMuTracks_vector is
    variable oWedges : TGMTMuTracks_vector(0 to 11);
  begin
    for i in oWedges'range loop
      -- put 3 muons into wedge vector.
      for j in oWedges(i)'range loop
        oWedges(i)(j).eta := signed(iGMTMu_vec(3*i+j).eta);
        oWedges(i)(j).phi := unsigned(iGMTMu_vec(3*i+j).phi);
        --oWedges(i)(j).address := iGMTMu_vec(3*i+j).address;

        oWedges(i)(j).qual := unsigned(iGMTMu_vec(3*i+j).qual);
      end loop;  -- j
    end loop;  -- oWedges'Range
    return oWedges;
  end;


  function convert_address_vec_from_flat (
    signal iTrackAddress_flat : std_logic_vector(0 to 39))
    return TMuonAddress is
    variable oAddress : TMuonAddress;
  begin  -- convert_address_vec_from_flat
    for i in oAddress'range loop
      oAddress(i) := iTrackAddress_flat(10*i to 10*i+9);
    end loop;  -- i
    return oAddress;
  end convert_address_vec_from_flat;

  function unpack_mu_from_flat (
    signal iGMTMu_flat   :    std_logic_vector(0 to 36);
    signal iTrackAddress : in std_logic_vector(0 to 39))
    return TGMTMuIn is
    variable oMuon : TGMTMuIn;
  begin
    oMuon.sysign  := iGMTMu_flat(0 to 1);
    oMuon.address := convert_address_vec_from_flat(iTrackAddress);
    oMuon.eta     := iGMTMu_flat(2 to 10);
    oMuon.qual    := iGMTMu_flat(11 to 14);
    oMuon.pt      := iGMTMu_flat(15 to 23);
    oMuon.phi     := iGMTMu_flat(24 to 33);
    return oMuon;
  end;

  procedure muon_flat_to_vec (
    signal iGMTMu_flat          : in  std_logic_vector;  --(0 to 1331);
    signal iTrackAddresses_flat : in  std_logic_vector;  -- 1439
    signal oMuons               : out TGMTMuIn_vector    -- (0 to 35)
    ) is
  begin
    for i in oMuons'range loop
      oMuons(i) <= unpack_mu_from_flat(iGMTMu_flat(iGMTMu_flat'low+37*i to iGMTMu_flat'low+37*i+36),
                                       iTrackAddresses_flat(iTrackAddresses_flat'low+40*i to iTrackAddresses_flat'low+40*i+39));
    end loop;  -- i
  end procedure muon_flat_to_vec;

  procedure mu_from_flat (
    signal iGMTMu_flat          : in  std_logic_vector(0 to 3995);
    signal iTrackAddresses_flat : in  std_logic_vector(0 to 4319);
    signal oMuonB               : out TGMTMuIn_vector(0 to 35);
    signal oMuonO               : out TGMTMuIn_vector(0 to 35);
    signal oMuonF               : out TGMTMuIn_vector(0 to 35)
    ) is
  begin
    muon_flat_to_vec(iGMTMu_flat(0 to 1331),
                     iTrackAddresses_flat(0 to 1439),
                     oMuonB);
    muon_flat_to_vec(iGMTMu_flat(1332 to 2663),
                     iTrackAddresses_flat(1440 to 2879),
                     oMuonO);
    muon_flat_to_vec(iGMTMu_flat(2664 to 3995),
                     iTrackAddresses_flat(2880 to 4319),
                     oMuonF);
  end procedure mu_from_flat;

  function gmt_mu_from_in_mu (
    signal iMuonIn : TGMTMuIn)
    return TGMTMu is
    variable oMuon : TGMTMu;
  begin  -- gmt_mu_from_in_mu
    oMuon.sysign := iMuonIn.sysign;
    oMuon.isol   := '0';
    oMuon.eta    := signed(iMuonIn.eta);
    oMuon.qual   := unsigned(iMuonIn.qual);
    oMuon.pt     := unsigned(iMuonIn.pt);
    oMuon.phi    := unsigned(iMuonIn.phi);
    return oMuon;
  end gmt_mu_from_in_mu;

  function gmt_mus_from_in_mus (
    signal iMuonsIn : TGMTMuIn_vector)
    return TGMTMu_vector is
    variable oMuons : TGMTMu_vector(iMuonsIn'range);
  begin  -- gmt_mus_from_in_mus
    for i in iMuonsIn'range loop
      oMuons(i) := gmt_mu_from_in_mu(iMuonsIn(i));
    end loop;  -- i
    return oMuons;
  end gmt_mus_from_in_mus;

  procedure sort_rank_flat_to_vec (
    signal iSortRanks_flat : in  std_logic_vector(0 to 1079);
    signal oSortRanksB     : out TSortRank10_vector(0 to 35);
    signal oSortRanksO     : out TSortRank10_vector(0 to 35);
    signal oSortRanksF     : out TSortRank10_vector(0 to 35)
    ) is
  begin
    g1 : for i in oSortRanksB'range loop
      oSortRanksB(i) <= iSortRanks_flat(10*i to (10*i)+9);
      oSortRanksO(i) <= iSortRanks_flat((oSortRanksB'high*10)+10*i to (oSortRanksB'high*10)+(10*i)+9);
      oSortRanksF(i) <= iSortRanks_flat((2*oSortRanksB'high*10)+10*i to (2*oSortRanksB'high*10)+(10*i)+9);
    end loop;
  end procedure sort_rank_flat_to_vec;

  -----------------------------------------------------------------------------
  --Index bits should count from 0 to 107 for all input muons. Barrel begins --
  --at 0, overlap at 36, and forward at 72.                                  --
  -----------------------------------------------------------------------------
  procedure idx_bits_flat_to_vec (
    signal iIdxBits_flat : in  std_logic_vector(0 to 755);
    signal oIdxBitsB     : out TIndexBits_vector(0 to 35);
    signal oIdxBitsO     : out TIndexBits_vector(0 to 35);
    signal oIdxBitsF     : out TIndexBits_vector(0 to 35)
    ) is
  begin
    g1 : for i in oIdxBitsB'range loop
      oIdxBitsB(i) <= unsigned(iIdxBits_flat(7*i to (7*i)+6));
      oIdxBitsO(i) <= unsigned(iIdxBits_flat((oIdxBitsB'high*7)+7*i to (oIdxBitsB'high*7)+(7*i)+6));
      oIdxBitsF(i) <= unsigned(iIdxBits_flat((2*oIdxBitsB'high*7)+7*i to (2*oIdxBitsB'high*7)+(7*i)+6));
    end loop;
  end procedure idx_bits_flat_to_vec;

  procedure empty_flat_to_vec (
    signal iEmpty_flat : in  std_logic_vector(0 to 107);
    signal oEmptyB     : out std_logic_vector(0 to 35);
    signal oEmptyO     : out std_logic_vector(0 to 35);
    signal oEmptyF     : out std_logic_vector(0 to 35)
    ) is
  begin
    oEmptyB <= iEmpty_flat(0 to 35);
    oEmptyO <= iEmpty_flat(36 to 71);
    oEmptyF <= iEmpty_flat(72 to 107);
  end procedure empty_flat_to_vec;

begin

  -----------------------------------------------------------------------------
  -- register toggles
  -----------------------------------------------------------------------------
  first_register : process (clk)
  begin  -- process first_register
    if clk'event and clk = '1' then     -- rising clock edge
      calo_toggle_reg      <= calo_toggle;
      mu_toggle_reg        <= mu_toggle;
      wedge_toggle_reg     <= wedge_toggle;
      sort_rank_toggle_reg <= sort_rank_toggle;
      idx_bit_toggle_reg   <= idx_bit_toggle;
      empty_toggle_reg     <= empty_toggle;
    end if;
  end process first_register;

  -----------------------------------------------------------------------------
  -- sim memories
  -----------------------------------------------------------------------------
  calo_info1 : half_calo_sim_mem
    port map (
      clka  => clk,
      wea   => "0",
      addra => calo_toggle_reg,
      dina  => (others => '0'),
      douta => sGMTCaloInfo_flat(0 to 3455));
  calo_info2 : half_calo_sim_mem
    port map (
      clka  => clk,
      wea   => "0",
      addra => calo_toggle_reg,
      dina  => (others => '0'),
      douta => sGMTCaloInfo_flat(3456 to 6911));

  mu_info : mu_sim_mem
    port map (
      clka  => clk,
      wea   => "0",
      addra => mu_toggle_reg,
      dina  => (others => '0'),
      douta => sGMTMu_flat,
      clkb  => clk,
      enb   => '0',
      web   => "0",
      addrb => (others => '0'),
      dinb  => (others => '0'),
      doutb => open);

  wedge_info : wedge_sim_mem
    port map (
      clka  => clk,
      wea   => "0",
      addra => wedge_toggle_reg,
      dina  => (others => '0'),
      douta => sWedgeAddresses_flat,
      clkb  => clk,
      enb   => '0',
      web   => "0",
      addrb => (others => '0'),
      dinb  => (others => '0'),
      doutb => open);

  sort_rank_info : sort_rank_sim_mem
    port map (
      clka  => clk,
      wea   => "0",
      addra => sort_rank_toggle_reg,
      dina  => (others => '0'),
      douta => sSortRanks_flat,
      clkb  => clk,
      enb   => '0',
      web   => "0",
      addrb => (others => '0'),
      dinb  => (others => '0'),
      doutb => open);

  idx_bits : idx_sim_mem
    port map (
      clka  => clk,
      wea   => "0",
      addra => idx_bit_toggle_reg,
      dina  => (others => '0'),
      douta => sIdxBits_flat,
      clkb  => clk,
      enb   => '0',
      web   => "0",
      addrb => (others => '0'),
      dinb  => (others => '0'),
      doutb => open);

  empty_bits : empty_sim_mem
    port map (
      clka  => clk,
      wea   => "0",
      addra => empty_toggle_reg,
      dina  => (others => '0'),
      douta => sEmpty_flat,
      clkb  => clk,
      enb   => '0',
      web   => "0",
      addrb => (others => '0'),
      dinb  => (others => '0'),
      doutb => open);

  -----------------------------------------------------------------------------
  -- deserializers
  -----------------------------------------------------------------------------
  sEnergyDeposits <= CaloEtaSlice_vec_from_flat(sGMTCaloInfo_flat);
  mu_from_flat(sGMTMu_flat, sWedgeAddresses_flat, sMuonsInB, sMuonsInO, sMuonsInF);
  sMuonsB         <= gmt_mus_from_in_mus(sMuonsInB);
  sMuonsO         <= gmt_mus_from_in_mus(sMuonsInO);
  sMuonsF         <= gmt_mus_from_in_mus(sMuonsInF);
  sTracksB        <= convert_vec_to_wedge(sMuonsInB);
  sTracksO        <= convert_vec_to_wedge(sMuonsInO);
  sTracksF        <= convert_vec_to_wedge(sMuonsInF);
  sort_rank_flat_to_vec(sSortRanks_flat, sSortRanksB, sSortRanksO, sSortRanksF);
  idx_bits_flat_to_vec(sIdxBits_flat, sIdxBitsB, sIdxBitsO, sIdxBitsF);
  empty_flat_to_vec(sEmpty_flat, sEmptyB, sEmptyO, sEmptyF);

  -----------------------------------------------------------------------------
  -- calo stuff
  -----------------------------------------------------------------------------
  assign_iso : IsoAssignmentUnit
    port map (
      iEnergies  => sEnergyDeposits,
      iMuonsB    => sMuonsB,
      iMuonsO    => sMuonsO,
      iMuonsF    => sMuonsF,
      iMuIdxBits => sMuIdxBits,
      oIsoBits   => sIsoBits,
      clk        => clk,
      sinit      => sinit);
  -----------------------------------------------------------------------------
  -- sorters & COUs
  -----------------------------------------------------------------------------

  sort_and_cancel : SortAndCancelUnit
    generic map (
      rpc_merging => false)
    port map (
      iMuonsB     => sMuonsB,
      iMuonsO     => sMuonsO,
      iMuonsF     => sMuonsF,
      -- For RPC merging.
      iMuonsRPCb => sMuonsRPCb,
      iMuonsRPCf => sMuonsRPCf,
      iSortRanksRPCb => sSortRanksRPCb,
      iSortRanksRPCf => sSortRanksRPCf,
      iEmptyRPCb => sEmptyRPCb,
      iEmptyRPCf => sEmptyRPCf,
      iIdxBitsRPCb => sIdxBitsRPCb,
      iIdxBitsRPCf => sIdxBitsRPCf,
      
      iTracksB    => sTracksB,
      iTracksO    => sTracksO,
      iTracksF    => sTracksF,
      iSortRanksB => sSortRanksB,
      iSortRanksO => sSortRanksO,
      iSortRanksF => sSortRanksF,
      iEmptyB     => sEmptyB,
      iEmptyO     => sEmptyO,
      iEmptyF     => sEmptyF,
      iIso        => sIsoBits,
      iIdxBitsB   => sIdxBitsB,
      iIdxBitsO   => sIdxBitsO,
      iIdxBitsF   => sIdxBitsF,
      oIdxBits    => sMuIdxBits,
      oMuons      => sMuons_sorted,
      clk         => clk,
      sinit       => sinit);


  -----------------------------------------------------------------------------
  -- final flip-flop
  -----------------------------------------------------------------------------
  -- purpose: Final flip-flop
  -- type   : sequential
  -- inputs : clk, sMuons_sorted
  -- outputs: oMuons
  p1 : process (clk)
  begin  -- process p1
    if clk'event and clk = '1' then     -- rising clock edge
      oMuon <= sMuons_sorted(to_integer(mu_sel));
    end if;
  end process p1;

  --spy_lut : spy_mem
  --  port map (
  --    clka  => clk,
  --    wea   => "0",
  --    addra => spy_toggle_reg,
  --    dina  => sMuons_sorted,
  --    douta => sMuons_spy,
  --    clkb  => clk,
  --    enb   => '0',
  --    web   => "0",
  --    addrb => (others => '0'),
  --    dinb  => (others => '0'),
  --    doutb => open);

  --muon_flat_to_vec(sMuons_spy, oMuons);

end Behavioral;
