-- Sorter 18 -> 8

library ieee;
use ieee.std_logic_1164.all;
use ieee.NUMERIC_STD.all;

use work.GMTTypes.all;

use work.SorterUnit.all;

entity HalfSortStage0 is
  port (
    iSortRanks : in  TSortRank10_vector(17 downto 0);
    iEmpty     : in  std_logic_vector(17 downto 0);   -- arrive 1/2 bx later?
    iCancel_A  : in  std_logic_vector(17 downto 0);   -- arrive 1/2 bx later
    iCancel_B  : in  std_logic_vector(17 downto 0);   -- arrive 1/2 bx later
    iCancel_C  : in  std_logic_vector(17 downto 0);   -- arrive 1/2 bx later
    iMuons     : in  TGMTMu_vector(17 downto 0);      -- arrive 1/2 bx later?
    iIdxBits   : in  TIndexBits_vector(17 downto 0);  -- arrive 1/2 bx later?
    oMuons     : out TGMTMu_vector(3 downto 0);
    oIdxBits   : out TIndexBits_vector(3 downto 0);
    oSortRanks : out TSortRank10_vector(3 downto 0);
    oEmpty     : out std_logic_vector(3 downto 0);

    -- Clock and control
    clk   : in std_logic;
    sinit : in std_logic);
end;

architecture behavioral of HalfSortStage0 is
  attribute syn_useioff               : boolean;
  attribute syn_useioff of behavioral : architecture is true;

  component comp10_ge
    port (
      A      : in  std_logic_vector(9 downto 0);
      B      : in  std_logic_vector(9 downto 0);
      A_GE_B : out std_logic);
  end component;

  signal GEMatrix : TGEMatrix18;
  signal sDisable : std_logic_vector(17 downto 0);

  signal sSelBits : TSelBits_1_of_18_vec (0 to 3);
begin  -- architecture behavioral
  -----------------------------------------------------------------------------
  -- calculate GE Matrix
  -----------------------------------------------------------------------------
  -- Remark: Diagonal elements of GEMatrix are never used and also not
  -- generated.
  g1 : for i in 0 to 16 generate
    g2 : for j in i+1 to 17 generate
      x : comp10_ge
        port map (
          A      => iSortRanks(i),
          B      => iSortRanks(j),
          A_GE_B => GEMatrix(i, j));

      -- in case of equal ranks the lower index muon wins
      GEMatrix(j, i) <= not GEMatrix(i, j);
    end generate;
  end generate;

  -- If we receive a cancel signal from one of the two CU units or the entry is
  -- empty we will disable the corresponding muon.
  sDisable <= iEmpty or iCancel_A or iCancel_B or iCancel_C;

  -----------------------------------------------------------------------------
  -- sort and four 8 to 1 Muxes
  -----------------------------------------------------------------------------
  count_wins18(GEMatrix, sDisable, sSelBits);

  mux : process (sSelBits, iMuons, iSortRanks, iEmpty, iIdxBits) is
  begin
    for iplace in 0 to 3 loop
      case sSelBits(iplace) is
        when "100000000000000000" => oMuons(iplace) <= iMuons(0);
        when "010000000000000000" => oMuons(iplace) <= iMuons(1);
        when "001000000000000000" => oMuons(iplace) <= iMuons(2);
        when "000100000000000000" => oMuons(iplace) <= iMuons(3);
        when "000010000000000000" => oMuons(iplace) <= iMuons(4);
        when "000001000000000000" => oMuons(iplace) <= iMuons(5);
        when "000000100000000000" => oMuons(iplace) <= iMuons(6);
        when "000000010000000000" => oMuons(iplace) <= iMuons(7);
        when "000000001000000000" => oMuons(iplace) <= iMuons(8);
        when "000000000100000000" => oMuons(iplace) <= iMuons(9);
        when "000000000010000000" => oMuons(iplace) <= iMuons(10);
        when "000000000001000000" => oMuons(iplace) <= iMuons(11);
        when "000000000000100000" => oMuons(iplace) <= iMuons(12);
        when "000000000000010000" => oMuons(iplace) <= iMuons(13);
        when "000000000000001000" => oMuons(iplace) <= iMuons(14);
        when "000000000000000100" => oMuons(iplace) <= iMuons(15);
        when "000000000000000010" => oMuons(iplace) <= iMuons(16);
        when "000000000000000001" => oMuons(iplace) <= iMuons(17);
        when others               => oMuons(iplace) <= ('0', '0', "000000000", "0000", "000000000", "0000000000");
      end case;
      case sSelBits(iplace) is
        when "100000000000000000" => oSortRanks(iplace) <= iSortRanks(0);
        when "010000000000000000" => oSortRanks(iplace) <= iSortRanks(1);
        when "001000000000000000" => oSortRanks(iplace) <= iSortRanks(2);
        when "000100000000000000" => oSortRanks(iplace) <= iSortRanks(3);
        when "000010000000000000" => oSortRanks(iplace) <= iSortRanks(4);
        when "000001000000000000" => oSortRanks(iplace) <= iSortRanks(5);
        when "000000100000000000" => oSortRanks(iplace) <= iSortRanks(6);
        when "000000010000000000" => oSortRanks(iplace) <= iSortRanks(7);
        when "000000001000000000" => oSortRanks(iplace) <= iSortRanks(8);
        when "000000000100000000" => oSortRanks(iplace) <= iSortRanks(9);
        when "000000000010000000" => oSortRanks(iplace) <= iSortRanks(10);
        when "000000000001000000" => oSortRanks(iplace) <= iSortRanks(11);
        when "000000000000100000" => oSortRanks(iplace) <= iSortRanks(12);
        when "000000000000010000" => oSortRanks(iplace) <= iSortRanks(13);
        when "000000000000001000" => oSortRanks(iplace) <= iSortRanks(14);
        when "000000000000000100" => oSortRanks(iplace) <= iSortRanks(15);
        when "000000000000000010" => oSortRanks(iplace) <= iSortRanks(16);
        when "000000000000000001" => oSortRanks(iplace) <= iSortRanks(17);
        when others               => oSortRanks(iplace) <= (others => '0');
      end case;
      case sSelBits(iplace) is
        when "100000000000000000" => oEmpty(iplace) <= iEmpty(0);
        when "010000000000000000" => oEmpty(iplace) <= iEmpty(1);
        when "001000000000000000" => oEmpty(iplace) <= iEmpty(2);
        when "000100000000000000" => oEmpty(iplace) <= iEmpty(3);
        when "000010000000000000" => oEmpty(iplace) <= iEmpty(4);
        when "000001000000000000" => oEmpty(iplace) <= iEmpty(5);
        when "000000100000000000" => oEmpty(iplace) <= iEmpty(6);
        when "000000010000000000" => oEmpty(iplace) <= iEmpty(7);
        when "000000001000000000" => oEmpty(iplace) <= iEmpty(8);
        when "000000000100000000" => oEmpty(iplace) <= iEmpty(9);
        when "000000000010000000" => oEmpty(iplace) <= iEmpty(10);
        when "000000000001000000" => oEmpty(iplace) <= iEmpty(11);
        when "000000000000100000" => oEmpty(iplace) <= iEmpty(12);
        when "000000000000010000" => oEmpty(iplace) <= iEmpty(13);
        when "000000000000001000" => oEmpty(iplace) <= iEmpty(14);
        when "000000000000000100" => oEmpty(iplace) <= iEmpty(15);
        when "000000000000000010" => oEmpty(iplace) <= iEmpty(16);
        when "000000000000000001" => oEmpty(iplace) <= iEmpty(17);
        when others               => oEmpty(iplace) <= '1';
      end case;
      case sSelBits(iplace) is
        when "100000000000000000" => oIdxBits(iplace) <= iIdxBits(0);
        when "010000000000000000" => oIdxBits(iplace) <= iIdxBits(1);
        when "001000000000000000" => oIdxBits(iplace) <= iIdxBits(2);
        when "000100000000000000" => oIdxBits(iplace) <= iIdxBits(3);
        when "000010000000000000" => oIdxBits(iplace) <= iIdxBits(4);
        when "000001000000000000" => oIdxBits(iplace) <= iIdxBits(5);
        when "000000100000000000" => oIdxBits(iplace) <= iIdxBits(6);
        when "000000010000000000" => oIdxBits(iplace) <= iIdxBits(7);
        when "000000001000000000" => oIdxBits(iplace) <= iIdxBits(8);
        when "000000000100000000" => oIdxBits(iplace) <= iIdxBits(9);
        when "000000000010000000" => oIdxBits(iplace) <= iIdxBits(10);
        when "000000000001000000" => oIdxBits(iplace) <= iIdxBits(11);
        when "000000000000100000" => oIdxBits(iplace) <= iIdxBits(12);
        when "000000000000010000" => oIdxBits(iplace) <= iIdxBits(13);
        when "000000000000001000" => oIdxBits(iplace) <= iIdxBits(14);
        when "000000000000000100" => oIdxBits(iplace) <= iIdxBits(15);
        when "000000000000000010" => oIdxBits(iplace) <= iIdxBits(16);
        when "000000000000000001" => oIdxBits(iplace) <= iIdxBits(17);
        when others               => oIdxBits(iplace) <= (others => '0');
      end case;
    end loop;  -- iplace
  end process mux;

end architecture behavioral;
