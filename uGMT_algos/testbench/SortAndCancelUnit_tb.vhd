library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.GMTTypes.all;
use work.tb_helpers.all;
use STD.TEXTIO.all;

entity testbench is
end testbench;

architecture behavior of testbench is

  constant div240          : integer   := 12;
  constant div40           : integer   := 2;
  constant half_period_240 : time      := 25000 ps / div240;
  constant half_period_40  : time      := 25000 ps / div40;
  signal   clk240          : std_logic := '0';
  signal   clk40           : std_logic := '0';
  signal   rst             : std_logic := '0';

  signal iMuonsB             : TGMTMu_vector(35 downto 0);
  signal iMuonsO             : TGMTMu_vector(35 downto 0);
  signal iMuonsF             : TGMTMu_vector(35 downto 0);
  signal iMuonsRPCb          : TGMTMuRPC_vector(3 downto 0);
  signal iMuonsRPCf          : TGMTMuRPC_vector(3 downto 0);
  signal iTracksB            : TGMTMuTracks_vector(11 downto 0);
  signal iTracksO            : TGMTMuTracks_vector(11 downto 0);
  signal iTracksF            : TGMTMuTracks_vector(11 downto 0);
  signal iSortRanksB         : TSortRank10_vector(35 downto 0);
  signal iSortRanksO         : TSortRank10_vector(35 downto 0);
  signal iSortRanksF         : TSortRank10_vector(35 downto 0);
  signal iEmptyB             : std_logic_vector(35 downto 0);
  signal iEmptyO             : std_logic_vector(35 downto 0);
  signal iEmptyF             : std_logic_vector(35 downto 0);
  signal iIdxBitsB           : TIndexBits_vector(35 downto 0);
  signal iIdxBitsO           : TIndexBits_vector(35 downto 0);
  signal iIdxBitsF           : TIndexBits_vector(35 downto 0);
  signal oIntermediateMuonsB : TGMTMu_vector(7 downto 0);
  signal oIntermediateMuonsO : TGMTMu_vector(7 downto 0);
  signal oIntermediateMuonsF : TGMTMu_vector(7 downto 0);
  signal oSortRanksB         : TSortRank10_vector(7 downto 0);
  signal oSortRanksO         : TSortRank10_vector(7 downto 0);
  signal oSortRanksF         : TSortRank10_vector(7 downto 0);
  signal oIdxBits            : TIndexBits_vector(7 downto 0);
  signal oMuPt               : TMuonPT_vector(7 downto 0);
  signal oMuons              : TGMTMu_vector(7 downto 0);
begin

  -- Component Instantiation
  uut : entity work.SortAndCancelUnit
    port map(
      iMuonsB             => iMuonsB,
      iMuonsO             => iMuonsO,
      iMuonsF             => iMuonsF,
      iMuonsRPCb          => iMuonsRPCb,
      iMuonsRPCf          => iMuonsRPCf,
      iSortRanksRPCb      => (others => "0000000000"),
      iSortRanksRPCf      => (others => "0000000000"),
      iEmptyRPCb          => (others => '0'),
      iEmptyRPCf          => (others => '0'),
      iIdxBitsRPCb        => (others => "0000000"),
      iIdxBitsRPCf        => (others => "0000000"),
      iTracksB            => iTracksB,
      iTracksO            => iTracksO,
      iTracksF            => iTracksF,
      iSortRanksB         => iSortRanksB,
      iSortRanksO         => iSortRanksO,
      iSortRanksF         => iSortRanksF,
      iEmptyB             => iEmptyB,
      iEmptyO             => iEmptyO,
      iEmptyF             => iEmptyF,
      iIdxBitsB           => iIdxBitsB,
      iIdxBitsO           => iIdxBitsO,
      iIdxBitsF           => iIdxBitsF,
      oIntermediateMuonsB => oIntermediateMuonsB,
      oIntermediateMuonsO => oIntermediateMuonsO,
      oIntermediateMuonsF => oIntermediateMuonsF,
      oSortRanksB         => oSortRanksB,
      oSortRanksO         => oSortRanksO,
      oSortRanksF         => oSortRanksF,
      oIdxBits            => oIdxBits,
      oMuPt               => oMuPt,
      oMuons              => oMuons,
      clk                 => clk40,
      clk_ipb             => clk240,
      sinit               => rst,
      ipb_in.ipb_addr     => (others => '0'),
      ipb_in.ipb_wdata    => (others => '0'),
      ipb_in.ipb_strobe   => '0',
      ipb_in.ipb_write    => '0',
      ipb_out             => open
      );

  -- Clocks
  clk240 <= not clk240 after half_period_240;
  clk40  <= not clk40  after half_period_40;

  --  Test Bench Statements
  tb : process
    file F                               : text open read_mode is "ugmt_testfile.dat";
    variable L, LO                       : line;
    variable event                       : TGMTMuEvent;
    variable vMuons, vIntB, vIntO, vIntF : TGMTMu_vector(oMuons'range);
    variable fin_id                      : string(1 to 3) := string'("FIN");
    variable int_id                      : string(1 to 3) := string'("INT");
  begin

    -- Reset all variables
    for i in iMuonsB'range loop
      -- TODO: Reset muons, empty, srtrnks
    end loop;  -- i
    for i in iTracksB'range loop
      for j in iTracksB(0)'range loop
        -- TODO: Reset tracks        
      end loop;  -- j
    end loop;  -- i

    wait for 250 ns;  -- wait until global set/reset completes    
    write (LO, string'("******************* start of tests  ********************** "));
    writeline (OUTPUT, LO);
    -- Add user defined stimulus here
    while not endfile(F) loop
      write (LO, string'("++++++++++++++++++++ reading event ++++++++++++++++++++"));
      writeline (OUTPUT, LO);
      ReadMuEvent(F, event);
      DumpMuEvent(event);

      iMuonsB     <= event.muons_brl;
      iMuonsO     <= event.muons_ovl;
      iMuonsF     <= event.muons_fwd;
      iTracksB    <= event.tracks_brl;
      iTracksO    <= event.tracks_ovl;
      iTracksF    <= event.tracks_fwd;
      iSortRanksB <= event.sortRanks_brl;
      iSortRanksO <= event.sortRanks_ovl;
      iSortRanksF <= event.sortRanks_fwd;
      iEmptyB     <= event.empty_brl;
      iEmptyO     <= event.empty_ovl;
      iEmptyF     <= event.empty_fwd;
      iIdxBitsB   <= event.idxBits_brl;
      iIdxBitsO   <= event.idxBits_ovl;
      iIdxBitsF   <= event.idxBits_fwd;

      vIntB := oIntermediateMuonsB;
      vIntO := oIntermediateMuonsO;
      vIntF := oIntermediateMuonsF;
      DumpMuons(vIntB, int_id);
      DumpMuons(vIntO, int_id);
      DumpMuons(vIntF, int_id);
      vMuons := oMuons;
      DumpMuons(vMuons, fin_id);
      wait for 25 ns;
    end loop;

    for i in 0 to 9 loop
      vIntB := oIntermediateMuonsB;
      vIntO := oIntermediateMuonsO;
      vIntF := oIntermediateMuonsF;
      DumpMuons(vIntB, int_id);
      DumpMuons(vIntO, int_id);
      DumpMuons(vIntF, int_id);
      vMuons := oMuons;
      DumpMuons(vMuons, fin_id);
      wait for 25 ns;
    end loop;  -- i

    wait;                               -- will wait forever
  end process tb;
  --  End Test Bench

end;
