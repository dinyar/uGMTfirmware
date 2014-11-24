-- Sorter 36 -> 8

library ieee;
use ieee.std_logic_1164.all;
use ieee.NUMERIC_STD.all;

use work.GMTTypes.all;

use work.SorterUnit.all;

entity SortStage0 is
  generic (
    sorter_lat_start : integer := 6);                 -- start latency
  port (iSortRanks : in  TSortRank10_vector(35 downto 0);
        iEmpty     : in  std_logic_vector(35 downto 0);   -- arrive 1/2 bx later?
        iCancel_A  : in  std_logic_vector(35 downto 0);   -- arrive 1/2 bx later
        iCancel_B  : in  std_logic_vector(35 downto 0);   -- arrive 1/2 bx later
        iCancel_C  : in  std_logic_vector(35 downto 0);   -- arrive 1/2 bx later
        iMuons     : in  TGMTMu_vector(35 downto 0);      -- arrive 1/2 bx later?
        iIdxBits   : in  TIndexBits_vector(35 downto 0);  -- arrive 1/2 bx later?
        oMuons     : out TGMTMu_vector(7 downto 0);
        oIdxBits   : out TIndexBits_vector(7 downto 0);
        oSortRanks : out TSortRank10_vector(7 downto 0);
        oEmpty     : out std_logic_vector(7 downto 0);

        -- Clock and control
        clk   : in std_logic;
        sinit : in std_logic);
end;

architecture behavioral of SortStage0 is

  component comp10_ge
    port (
      A      : in  std_logic_vector(9 downto 0);
      B      : in  std_logic_vector(9 downto 0);
      A_GE_B : out std_logic);
  end component;

  signal sMuons_reg   : TGMTMu_vector(35 downto 0);
  signal sMuons_store : TGMTMu_vector(35 downto 0);

  signal GEMatrix, GEMatrix_reg : TGEMatrix36;

  signal sIdxBits       : TIndexBits_vector(35 downto 0);
  signal sIdxBits_reg   : TIndexBits_vector(35 downto 0);
  signal sIdxBits_store : TIndexBits_vector(35 downto 0);

  signal sSortRanks       : TSortRank10_vector(35 downto 0);
  signal sSortRanks_reg   : TSortRank10_vector(35 downto 0);
  signal sSortRanks_store : TSortRank10_vector(35 downto 0);

  signal sEmpty_store : std_logic_vector(35 downto 0);
  signal sEmpty_reg   : std_logic_vector(35 downto 0);

  signal sSelBits     : TSelBits_1_of_36_vec (0 to 7);
  signal sSelBits_reg : TSelBits_1_of_36_vec (0 to 7);

begin  -- architecture behavioral
  sIdxBits   <= iIdxBits;
  sSortRanks <= iSortRanks;

  -----------------------------------------------------------------------------
  -- calculate GE Matrix
  -----------------------------------------------------------------------------
  -- Remark: Diagonal elements of GEMatrix are never used and also not
  -- generated. 
  g1 : for i in 0 to 34 generate
    g2 : for j in i+1 to 35 generate
      x : comp10_ge
        port map (
          A      => sSortRanks(i),
          B      => sSortRanks(j),
          A_GE_B => GEMatrix(i, j));

      -- in case of equal ranks the lower index muon wins
      GEMatrix(j, i) <= not GEMatrix(i, j);
    end generate;
  end generate;

  -----------------------------------------------------------------------------
  -- register the result and the empty inputs
  -----------------------------------------------------------------------------
  -- TODO: Is this flip-flop correct?
  reg_ge : process (clk) is
  begin  -- process reg_ge
    if clk'event and clk = '1' then
      GEMatrix_reg     <= GEMatrix;
      sIdxBits_store   <= sIdxBits;
      sSortRanks_store <= sSortRanks;
      sMuons_store     <= iMuons;
      sEmpty_store     <= iEmpty;
    end if;
  end process reg_ge;

  -----------------------------------------------------------------------------
  -- sort and four 8 to 1 Muxes
  -----------------------------------------------------------------------------
  countWins : entity work.SortStage0_countWins
    port map (
      iGEMatrix => GEMatrix_reg,
      iEmpty    => sEmpty_store,
      iCancel_A => iCancel_A,
      iCancel_B => iCancel_B,
      iCancel_C => iCancel_C,
      oSelBits  => sSelBits);

  reg_count_wins : process (clk)
  begin  -- process reg_count_wins
    if clk'event and clk = '1' then     -- rising clock edge
      sSelBits_reg   <= sSelBits;
      sMuons_reg     <= sMuons_store;
      sSortRanks_reg <= sSortRanks_store;
      sEmpty_reg     <= sEmpty_store;
      sIdxBits_reg   <= sIdxBits_store;
    end if;
  end process reg_count_wins;

  mux : entity work.SortStage0_Mux
    port map (
      iSelBits   => sSelBits_reg,
      iMuons     => sMuons_reg,
      iSortRanks => sSortRanks_reg,
      iEmpty     => sEmpty_reg,
      iIdxBits   => sIdxBits_reg,
      oMuons     => oMuons,
      oSortRanks => oSortRanks,
      oEmpty     => oEmpty,
      oIdxBits   => oIdxBits
      );

end architecture behavioral;
