library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench is
end testbench;

architecture behavior of testbench is

  constant half_period_240 : time      := 25000ps/12;
  constant half_period_40  : time      := 25000ps/2;
  signal   clk240          : std_logic := '0';
  signal   clk40           : std_logic := '0';

  signal iMuonsB             : TGMTMu_vector(35 downto 0);
  signal iMuonsO             : TGMTMu_vector(35 downto 0);
  signal iMuonsF             : TGMTMu_vector(35 downto 0);
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
      clk240              => clk240,
      clk40               => clk40,
      );

  -- Clocks
  clk240 <= not clk240 after half_period_240;
  clk40  <= not clk40  after half_period_40;

  --  Test Bench Statements
  tb : process
  begin

    -- Reset all variables
    for i in input'range loop
      input(i).data  <= (others => '0');
      input(i).valid <= (others => '0');
    end loop;  -- i

    wait for 250 ns;  -- wait until global set/reset completes    

    -- Add user defined stimulus here
    wait for 25 ns;

    wait;                               -- will wait forever
  end process tb;
  --  End Test Bench

end;
