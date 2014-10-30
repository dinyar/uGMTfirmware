-- Sorting 24 -> 8

library ieee;
use ieee.std_logic_1164.all;
use ieee.NUMERIC_STD.all;
use work.GMTTypes.all;
use work.SorterUnit.all;                -- use procedure in package


entity SortStage1 is
  port (
    iSortRanksB : in TSortRank10_vector(7 downto 0);
    iEmptyB     : in std_logic_vector(7 downto 0);
    iIdxBitsB   : in TIndexBits_vector(7 downto 0);
    iMuonsB     : in TGMTMu_vector(7 downto 0);

    iSortRanksO : in TSortRank10_vector(7 downto 0);
    iEmptyO     : in std_logic_vector(7 downto 0);
    iIdxBitsO   : in TIndexBits_vector(7 downto 0);
    iMuonsO     : in TGMTMu_vector(7 downto 0);

    iSortRanksF : in TSortRank10_vector(7 downto 0);
    iEmptyF     : in std_logic_vector(7 downto 0);
    iIdxBitsF   : in TIndexBits_vector(7 downto 0);
    iMuonsF     : in TGMTMu_vector(7 downto 0);

    oIdxBits : out TIndexBits_vector(7 downto 0);  -- Sent to IsoAU.
    oMuons   : out TGMTMu_vector(7 downto 0);


    -- Clock and control
    clk   : in std_logic;
    sinit : in std_logic
    );
end entity SortStage1;

--
architecture behavioral of SortStage1 is

  component comp10_ge
    port (
      a      : in  std_logic_vector(9 downto 0);
      b      : in  std_logic_vector(9 downto 0);
      a_ge_b : out std_logic);
  end component;

  signal sSortRanks : TSortRank10_vector(23 downto 0);
  signal sEmpty     : std_logic_vector(23 downto 0);
  signal sMuons     : TGMTMu_vector(23 downto 0);
  signal sIdxBits   : TIndexBits_vector(23 downto 0);

  signal GEMatrix : TGEMatrix24;
  signal sSelBits : TSelBits_1_of_24_vec (0 to 7);


  -- purpose: final mux after sort
  procedure mux_muons (
    constant vSelBits : in  TSelBits_1_of_24_vec (0 to 7);
    signal   iMuons   : in  TGMTMu_vector(23 downto 0);
    signal   iIdxBits : in  TIndexBits_vector(23 downto 0);
    signal   oMuons   : out TGMTMu_vector(7 downto 0);
    signal   oIdxBits : out TIndexBits_vector(7 downto 0)
    ) is
  begin  -- procedure mux
    for iplace in 0 to 7 loop
      case vSelBits(iplace) is
        when "100000000000000000000000" => oMuons(iplace) <= iMuons(0);
        when "010000000000000000000000" => oMuons(iplace) <= iMuons(1);
        when "001000000000000000000000" => oMuons(iplace) <= iMuons(2);
        when "000100000000000000000000" => oMuons(iplace) <= iMuons(3);
        when "000010000000000000000000" => oMuons(iplace) <= iMuons(4);
        when "000001000000000000000000" => oMuons(iplace) <= iMuons(5);
        when "000000100000000000000000" => oMuons(iplace) <= iMuons(6);
        when "000000010000000000000000" => oMuons(iplace) <= iMuons(7);
        when "000000001000000000000000" => oMuons(iplace) <= iMuons(8);
        when "000000000100000000000000" => oMuons(iplace) <= iMuons(9);
        when "000000000010000000000000" => oMuons(iplace) <= iMuons(10);
        when "000000000001000000000000" => oMuons(iplace) <= iMuons(11);
        when "000000000000100000000000" => oMuons(iplace) <= iMuons(12);
        when "000000000000010000000000" => oMuons(iplace) <= iMuons(13);
        when "000000000000001000000000" => oMuons(iplace) <= iMuons(14);
        when "000000000000000100000000" => oMuons(iplace) <= iMuons(15);
        when "000000000000000010000000" => oMuons(iplace) <= iMuons(16);
        when "000000000000000001000000" => oMuons(iplace) <= iMuons(17);
        when "000000000000000000100000" => oMuons(iplace) <= iMuons(18);
        when "000000000000000000010000" => oMuons(iplace) <= iMuons(19);
        when "000000000000000000001000" => oMuons(iplace) <= iMuons(20);
        when "000000000000000000000100" => oMuons(iplace) <= iMuons(21);
        when "000000000000000000000010" => oMuons(iplace) <= iMuons(22);
        when "000000000000000000000001" => oMuons(iplace) <= iMuons(23);
        when others                     => oMuons(iplace) <= ("00", "000000000", "0000", "000000000", "0000000000");
      end case;

      case vSelBits(iplace) is
        when "100000000000000000000000" => oIdxBits(iplace) <= iIdxBits(0);
        when "010000000000000000000000" => oIdxBits(iplace) <= iIdxBits(1);
        when "001000000000000000000000" => oIdxBits(iplace) <= iIdxBits(2);
        when "000100000000000000000000" => oIdxBits(iplace) <= iIdxBits(3);
        when "000010000000000000000000" => oIdxBits(iplace) <= iIdxBits(4);
        when "000001000000000000000000" => oIdxBits(iplace) <= iIdxBits(5);
        when "000000100000000000000000" => oIdxBits(iplace) <= iIdxBits(6);
        when "000000010000000000000000" => oIdxBits(iplace) <= iIdxBits(7);
        when "000000001000000000000000" => oIdxBits(iplace) <= iIdxBits(8);
        when "000000000100000000000000" => oIdxBits(iplace) <= iIdxBits(9);
        when "000000000010000000000000" => oIdxBits(iplace) <= iIdxBits(10);
        when "000000000001000000000000" => oIdxBits(iplace) <= iIdxBits(11);
        when "000000000000100000000000" => oIdxBits(iplace) <= iIdxBits(12);
        when "000000000000010000000000" => oIdxBits(iplace) <= iIdxBits(13);
        when "000000000000001000000000" => oIdxBits(iplace) <= iIdxBits(14);
        when "000000000000000100000000" => oIdxBits(iplace) <= iIdxBits(15);
        when "000000000000000010000000" => oIdxBits(iplace) <= iIdxBits(16);
        when "000000000000000001000000" => oIdxBits(iplace) <= iIdxBits(17);
        when "000000000000000000100000" => oIdxBits(iplace) <= iIdxBits(18);
        when "000000000000000000010000" => oIdxBits(iplace) <= iIdxBits(19);
        when "000000000000000000001000" => oIdxBits(iplace) <= iIdxBits(20);
        when "000000000000000000000100" => oIdxBits(iplace) <= iIdxBits(21);
        when "000000000000000000000010" => oIdxBits(iplace) <= iIdxBits(22);
        when "000000000000000000000001" => oIdxBits(iplace) <= iIdxBits(23);
        when others                     => oIdxBits(iplace) <= (others => '0');
      end case;
      
    end loop;  -- iplace
    
  end procedure mux_muons;

begin  -- architecture behavioral
  
  sSortRanks <= iSortRanksB & iSortRanksO & iSortRanksF;
  sMuons     <= iMuonsB & iMuonsO & iMuonsF;
  sIdxBits   <= iIdxBitsB & iIdxBitsO & iIdxBitsF;

  sEmpty <= iEmptyB & iEmptyO & iEmptyF;

  -----------------------------------------------------------------------------
  -- calculate GE Matrix : 
  -----------------------------------------------------------------------------  

  -- Remark: Diagonal elements of GEMatrix are never used and also not generated. 
  g1 : for i in 0 to 22 generate
    g2 : for j in i+1 to 23 generate
      x : comp10_ge
        port map (
          a      => sSortRanks(i),
          b      => sSortRanks(j),
          a_ge_b => GEMatrix(i, j));

      -- in case of equal ranks the lower index muon wins
      GEMatrix(j, i) <= not GEMatrix(i, j);
    end generate;
  end generate;
  -----------------------------------------------------------------------------
  -- sort and eight 24 to 1 Muxes
  -----------------------------------------------------------------------------  
  count_wins24(GEMatrix, sEmpty, sSelBits);

  mux_muons(sSelBits, sMuons, sIdxBits, oMuons, oIdxBits);

end architecture behavioral;
