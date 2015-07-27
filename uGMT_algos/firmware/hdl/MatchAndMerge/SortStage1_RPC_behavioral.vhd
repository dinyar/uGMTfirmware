-- Sorting 32 -> 8

library ieee;
use ieee.std_logic_1164.all;
use ieee.NUMERIC_STD.all;
use work.GMTTypes.all;
use work.SorterUnit.all;                -- use procedure in package


entity SortStage1_RPC is
  port (
    iSortRanksB : in TSortRank10_vector(0 to 7);
    iEmptyB     : in std_logic_vector(0 to 7);
    iIdxBitsB   : in TIndexBits_vector(0 to 7);
    iMuonsB     : in TGMTMu_vector(0 to 7);

    iSortRanksO : in TSortRank10_vector(0 to 7);
    iEmptyO     : in std_logic_vector(0 to 7);
    iIdxBitsO   : in TIndexBits_vector(0 to 7);
    iMuonsO     : in TGMTMu_vector(0 to 7);

    iSortRanksF : in TSortRank10_vector(0 to 7);
    iEmptyF     : in std_logic_vector(0 to 7);
    iIdxBitsF   : in TIndexBits_vector(0 to 7);
    iMuonsF     : in TGMTMu_vector(0 to 7);

    -- Need the following for RPC merging:
    iSortRanksMergedB : in TSortRank10_vector(3 downto 0);
    iEmptyMergedB     : in std_logic_vector(3 downto 0);
    iIdxBitsMergedB   : in TIndexBits_vector(3 downto 0);
    iMuonsMergedB     : in TGMTMu_vector(3 downto 0);
    iCancelB          : in std_logic_vector(7 downto 0);
    iCancelO_B        : in std_logic_vector(7 downto 0);
    iSortRanksMergedF : in TSortRank10_vector(3 downto 0);
    iEmptyMergedF     : in std_logic_vector(3 downto 0);
    iIdxBitsMergedF   : in TIndexBits_vector(3 downto 0);
    iMuonsMergedF     : in TGMTMu_vector(3 downto 0);
    iCancelO_A        : in std_logic_vector(7 downto 0);
    iCancelF          : in std_logic_vector(7 downto 0);

    oIdxBits : out TIndexBits_vector(7 downto 0);  -- Sent to IsoAU.
    oMuons   : out TGMTMu_vector(7 downto 0);


    -- Clock and control
    clk   : in std_logic;
    sinit : in std_logic
    );
end entity SortStage1_RPC;

--
architecture behavioral of SortStage1_RPC is
--  attribute syn_useioff : boolean;   -- Synplicity commands not required
--  attribute syn_useioff of behavioral : architecture is true;

  component comp10_ge
    port (
      a      : in  std_logic_vector(9 downto 0);
      b      : in  std_logic_vector(9 downto 0);
      a_ge_b : out std_logic);
  end component;

-- Synplicity black box declaration
-- attribute syn_black_box : boolean;
-- attribute syn_black_box of comp10: component is true;

  signal sSortRanks : TSortRank10_vector(0 to 31);
  signal sDisable   : std_logic_vector(31 downto 0);
  signal sEmpty     : std_logic_vector(31 downto 0);
  signal sCancel    : std_logic_vector(31 downto 0);
  signal sCancelB   : std_logic_vector(7 downto 0);
  signal sCancelO   : std_logic_vector(7 downto 0);
  signal sCancelF   : std_logic_vector(7 downto 0);
  signal sMuons     : TGMTMu_vector(0 to 31);
  signal sIdxBits   : TIndexBits_vector(0 to 31);

  signal GEMatrix : TGEMatrix32;
  signal sSelBits : TSelBits_1_of_32_vec (0 to 7);


  -- purpose: final mux after sort
  procedure mux_muons (
    constant vSelBits : in  TSelBits_1_of_32_vec (0 to 7);
    signal   iMuons   : in  TGMTMu_vector(0 to 31);
    signal   iIdxBits : in  TIndexBits_vector(0 to 31);
    signal   oMuons   : out TGMTMu_vector(0 to 7);
    signal   oIdxBits : out TIndexBits_vector(0 to 7)
    ) is
  begin  -- procedure mux
    for iplace in 0 to 7 loop
      case vSelBits(iplace) is
        when "10000000000000000000000000000000" => oMuons(iplace) <= iMuons(0);
        when "01000000000000000000000000000000" => oMuons(iplace) <= iMuons(1);
        when "00100000000000000000000000000000" => oMuons(iplace) <= iMuons(2);
        when "00010000000000000000000000000000" => oMuons(iplace) <= iMuons(3);
        when "00001000000000000000000000000000" => oMuons(iplace) <= iMuons(4);
        when "00000100000000000000000000000000" => oMuons(iplace) <= iMuons(5);
        when "00000010000000000000000000000000" => oMuons(iplace) <= iMuons(6);
        when "00000001000000000000000000000000" => oMuons(iplace) <= iMuons(7);
        when "00000000100000000000000000000000" => oMuons(iplace) <= iMuons(8);
        when "00000000010000000000000000000000" => oMuons(iplace) <= iMuons(9);
        when "00000000001000000000000000000000" => oMuons(iplace) <= iMuons(10);
        when "00000000000100000000000000000000" => oMuons(iplace) <= iMuons(11);
        when "00000000000010000000000000000000" => oMuons(iplace) <= iMuons(12);
        when "00000000000001000000000000000000" => oMuons(iplace) <= iMuons(13);
        when "00000000000000100000000000000000" => oMuons(iplace) <= iMuons(14);
        when "00000000000000010000000000000000" => oMuons(iplace) <= iMuons(15);
        when "00000000000000001000000000000000" => oMuons(iplace) <= iMuons(16);
        when "00000000000000000100000000000000" => oMuons(iplace) <= iMuons(17);
        when "00000000000000000010000000000000" => oMuons(iplace) <= iMuons(18);
        when "00000000000000000001000000000000" => oMuons(iplace) <= iMuons(19);
        when "00000000000000000000100000000000" => oMuons(iplace) <= iMuons(20);
        when "00000000000000000000010000000000" => oMuons(iplace) <= iMuons(21);
        when "00000000000000000000001000000000" => oMuons(iplace) <= iMuons(22);
        when "00000000000000000000000100000000" => oMuons(iplace) <= iMuons(23);
        when "00000000000000000000000010000000" => oMuons(iplace) <= iMuons(24);
        when "00000000000000000000000001000000" => oMuons(iplace) <= iMuons(25);
        when "00000000000000000000000000100000" => oMuons(iplace) <= iMuons(26);
        when "00000000000000000000000000010000" => oMuons(iplace) <= iMuons(27);
        when "00000000000000000000000000001000" => oMuons(iplace) <= iMuons(28);
        when "00000000000000000000000000000100" => oMuons(iplace) <= iMuons(29);
        when "00000000000000000000000000000010" => oMuons(iplace) <= iMuons(30);
        when "00000000000000000000000000000001" => oMuons(iplace) <= iMuons(31);
        when others                             => oMuons(iplace) <= ('0', '0', "000000000", "0000", "000000000", "0000000000");
      end case;

      case vSelBits(iplace) is
        when "10000000000000000000000000000000" => oIdxBits(iplace) <= iIdxBits(0);
        when "01000000000000000000000000000000" => oIdxBits(iplace) <= iIdxBits(1);
        when "00100000000000000000000000000000" => oIdxBits(iplace) <= iIdxBits(2);
        when "00010000000000000000000000000000" => oIdxBits(iplace) <= iIdxBits(3);
        when "00001000000000000000000000000000" => oIdxBits(iplace) <= iIdxBits(4);
        when "00000100000000000000000000000000" => oIdxBits(iplace) <= iIdxBits(5);
        when "00000010000000000000000000000000" => oIdxBits(iplace) <= iIdxBits(6);
        when "00000001000000000000000000000000" => oIdxBits(iplace) <= iIdxBits(7);
        when "00000000100000000000000000000000" => oIdxBits(iplace) <= iIdxBits(8);
        when "00000000010000000000000000000000" => oIdxBits(iplace) <= iIdxBits(9);
        when "00000000001000000000000000000000" => oIdxBits(iplace) <= iIdxBits(10);
        when "00000000000100000000000000000000" => oIdxBits(iplace) <= iIdxBits(11);
        when "00000000000010000000000000000000" => oIdxBits(iplace) <= iIdxBits(12);
        when "00000000000001000000000000000000" => oIdxBits(iplace) <= iIdxBits(13);
        when "00000000000000100000000000000000" => oIdxBits(iplace) <= iIdxBits(14);
        when "00000000000000010000000000000000" => oIdxBits(iplace) <= iIdxBits(15);
        when "00000000000000001000000000000000" => oIdxBits(iplace) <= iIdxBits(16);
        when "00000000000000000100000000000000" => oIdxBits(iplace) <= iIdxBits(17);
        when "00000000000000000010000000000000" => oIdxBits(iplace) <= iIdxBits(18);
        when "00000000000000000001000000000000" => oIdxBits(iplace) <= iIdxBits(19);
        when "00000000000000000000100000000000" => oIdxBits(iplace) <= iIdxBits(20);
        when "00000000000000000000010000000000" => oIdxBits(iplace) <= iIdxBits(21);
        when "00000000000000000000001000000000" => oIdxBits(iplace) <= iIdxBits(22);
        when "00000000000000000000000100000000" => oIdxBits(iplace) <= iIdxBits(23);
        when "00000000000000000000000010000000" => oIdxBits(iplace) <= iIdxBits(24);
        when "00000000000000000000000001000000" => oIdxBits(iplace) <= iIdxBits(25);
        when "00000000000000000000000000100000" => oIdxBits(iplace) <= iIdxBits(26);
        when "00000000000000000000000000010000" => oIdxBits(iplace) <= iIdxBits(27);
        when "00000000000000000000000000001000" => oIdxBits(iplace) <= iIdxBits(28);
        when "00000000000000000000000000000100" => oIdxBits(iplace) <= iIdxBits(29);
        when "00000000000000000000000000000010" => oIdxBits(iplace) <= iIdxBits(30);
        when "00000000000000000000000000000001" => oIdxBits(iplace) <= iIdxBits(31);
        when others                             => oIdxBits(iplace) <= (others => '0');
      end case;
      
    end loop;  -- iplace
    
  end procedure mux_muons;

begin  -- architecture behavioral
  
  sSortRanks <= iSortRanksB & iSortRanksO & iSortRanksF & iSortRanksMergedB & iSortRanksMergedF;
  sMuons     <= iMuonsB & iMuonsO & iMuonsF & iMuonsMergedB & iMuonsMergedF;
  sIdxBits   <= iIdxBitsB & iIdxBitsO & iIdxBitsF & iIdxBitsMergedB & iIdxBitsMergedF;

  sCancelB <= iCancelB;
  sCancelO <= iCancelO_A or iCancelO_B;
  sCancelF <= iCancelF;
  sCancel  <= sCancelB & sCancelO & sCancelF & "00000000";  -- Don't want to
                                                            -- cancel merged
                                                            -- muons. 
  sEmpty   <= iEmptyB & iEmptyO & iEmptyF & iEmptyMergedB & iEmptyMergedF;
  sDisable <= sCancel or sEmpty;

  -----------------------------------------------------------------------------
  -- calculate GE Matrix : 
  -----------------------------------------------------------------------------  

  -- Remark: Diagonal elements of GEMatrix are never used and also not generated. 
  g1 : for i in 0 to 30 generate
    g2 : for j in i+1 to 31 generate
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
  -- sort and eight 32 to 1 Muxes
  -----------------------------------------------------------------------------  
  count_wins32(GEMatrix, sDisable, sSelBits);
  mux_muons(sSelBits, sMuons, sIdxBits, oMuons, oIdxBits);

end architecture behavioral;
