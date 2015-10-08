-- Sorting 24 -> 8

library ieee;
use ieee.std_logic_1164.all;
use ieee.NUMERIC_STD.all;
use work.GMTTypes.all;
use work.ugmt_constants.all;
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
    oMuons   : out TGMTMu_vector(7 downto 0)
    );
end entity SortStage1;

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

begin  -- architecture behavioral

  sSortRanks <= iSortRanksF(7 downto 4) & iSortRanksO(7 downto 4) & iSortRanksB & iSortRanksO(3 downto 0) & iSortRanksF(3 downto 0);
  sMuons     <= iMuonsF(7 downto 4) & iMuonsO(7 downto 4) & iMuonsB & iMuonsO(3 downto 0) & iMuonsF(3 downto 0);
  sIdxBits   <= iIdxBitsF(7 downto 4) & iIdxBitsO(7 downto 4) & iIdxBitsB & iIdxBitsO(3 downto 0) & iIdxBitsF(3 downto 0);

  sEmpty <= iEmptyF(7 downto 4) & iEmptyO(7 downto 4) & iEmptyB & iEmptyO(3 downto 0) & iEmptyF(3 downto 0);

  -----------------------------------------------------------------------------
  -- calculate GE Matrix :
  -----------------------------------------------------------------------------
  -- Remark: Diagonal elements of GEMatrix are never used and also not
  -- generated.
  -- Remark: Don't have to compute results for TF internal comparisons as these
  -- are known already.
  gen_ge_matrix : process (sSortRanks, GEMatrix)
  begin  -- process gen_ge_matrix
    for i in 0 to 22 loop
      for j in i+1 to 23 loop
        if (i < MU_OMTF_POS_BEGIN) and (j < MU_OMTF_POS_BEGIN) then -- Staying inside EMTF+
          GEMatrix(i, j) <= '1';
        elsif (i >= MU_OMTF_POS_BEGIN) and (j >= MU_OMTF_POS_BEGIN) and
              (i < MU_BMTF_BEGIN) and (j < MU_BMTF_BEGIN) then -- Staying inside OMTF+
          GEMatrix(i, j) <= '1';
        elsif (i >= MU_BMTF_BEGIN) and (j >= MU_BMTF_BEGIN) and
              (i < MU_OMTF_NEG_BEGIN) and (j < MU_OMTF_NEG_BEGIN) then -- Staying inside BMTF
          GEMatrix(i, j) <= '1';
        elsif (i >= MU_OMTF_NEG_BEGIN) and (j >= MU_OMTF_NEG_BEGIN) and
              (i < MU_EMTF_NEG_BEGIN) and (j < MU_EMTF_NEG_BEGIN) then -- Staying inside OMTF-
          GEMatrix(i, j) <= '1';
        elsif (i >= MU_EMTF_NEG_BEGIN) and (j >= MU_EMTF_NEG_BEGIN) and
              (i < SORTING_END) and (j < SORTING_END) then -- Staying inside EMTF-
          GEMatrix(i, j) <= '1';
        else
          if (sSortRanks(i) >= sSortRanks(j)) then
             GEMatrix(i, j) <= '1';
          else
             GEMatrix(i, j) <= '0';
          end if;
        end if;
      -- in case of equal ranks the lower index muon wins
      GEMatrix(j, i) <= not GEMatrix(i, j);
      end loop;
    end loop;
  end process gen_ge_matrix;

  -----------------------------------------------------------------------------
  -- sort and eight 24 to 1 Muxes
  -----------------------------------------------------------------------------
  count_wins24(GEMatrix, sEmpty, sSelBits);

  mux : process (sSelBits, sMuons, sIdxBits)
  begin  -- process mux
    for iplace in 0 to 7 loop
      case sSelBits(iplace) is
        when "100000000000000000000000" => oMuons(iplace) <= sMuons(0);
        when "010000000000000000000000" => oMuons(iplace) <= sMuons(1);
        when "001000000000000000000000" => oMuons(iplace) <= sMuons(2);
        when "000100000000000000000000" => oMuons(iplace) <= sMuons(3);
        when "000010000000000000000000" => oMuons(iplace) <= sMuons(4);
        when "000001000000000000000000" => oMuons(iplace) <= sMuons(5);
        when "000000100000000000000000" => oMuons(iplace) <= sMuons(6);
        when "000000010000000000000000" => oMuons(iplace) <= sMuons(7);
        when "000000001000000000000000" => oMuons(iplace) <= sMuons(8);
        when "000000000100000000000000" => oMuons(iplace) <= sMuons(9);
        when "000000000010000000000000" => oMuons(iplace) <= sMuons(10);
        when "000000000001000000000000" => oMuons(iplace) <= sMuons(11);
        when "000000000000100000000000" => oMuons(iplace) <= sMuons(12);
        when "000000000000010000000000" => oMuons(iplace) <= sMuons(13);
        when "000000000000001000000000" => oMuons(iplace) <= sMuons(14);
        when "000000000000000100000000" => oMuons(iplace) <= sMuons(15);
        when "000000000000000010000000" => oMuons(iplace) <= sMuons(16);
        when "000000000000000001000000" => oMuons(iplace) <= sMuons(17);
        when "000000000000000000100000" => oMuons(iplace) <= sMuons(18);
        when "000000000000000000010000" => oMuons(iplace) <= sMuons(19);
        when "000000000000000000001000" => oMuons(iplace) <= sMuons(20);
        when "000000000000000000000100" => oMuons(iplace) <= sMuons(21);
        when "000000000000000000000010" => oMuons(iplace) <= sMuons(22);
        when "000000000000000000000001" => oMuons(iplace) <= sMuons(23);
        when others                     => oMuons(iplace) <= ('0', '0', "000000000", "0000", "000000000", "0000000000");
      end case;

      case sSelBits(iplace) is
        when "100000000000000000000000" => oIdxBits(iplace) <= sIdxBits(0);
        when "010000000000000000000000" => oIdxBits(iplace) <= sIdxBits(1);
        when "001000000000000000000000" => oIdxBits(iplace) <= sIdxBits(2);
        when "000100000000000000000000" => oIdxBits(iplace) <= sIdxBits(3);
        when "000010000000000000000000" => oIdxBits(iplace) <= sIdxBits(4);
        when "000001000000000000000000" => oIdxBits(iplace) <= sIdxBits(5);
        when "000000100000000000000000" => oIdxBits(iplace) <= sIdxBits(6);
        when "000000010000000000000000" => oIdxBits(iplace) <= sIdxBits(7);
        when "000000001000000000000000" => oIdxBits(iplace) <= sIdxBits(8);
        when "000000000100000000000000" => oIdxBits(iplace) <= sIdxBits(9);
        when "000000000010000000000000" => oIdxBits(iplace) <= sIdxBits(10);
        when "000000000001000000000000" => oIdxBits(iplace) <= sIdxBits(11);
        when "000000000000100000000000" => oIdxBits(iplace) <= sIdxBits(12);
        when "000000000000010000000000" => oIdxBits(iplace) <= sIdxBits(13);
        when "000000000000001000000000" => oIdxBits(iplace) <= sIdxBits(14);
        when "000000000000000100000000" => oIdxBits(iplace) <= sIdxBits(15);
        when "000000000000000010000000" => oIdxBits(iplace) <= sIdxBits(16);
        when "000000000000000001000000" => oIdxBits(iplace) <= sIdxBits(17);
        when "000000000000000000100000" => oIdxBits(iplace) <= sIdxBits(18);
        when "000000000000000000010000" => oIdxBits(iplace) <= sIdxBits(19);
        when "000000000000000000001000" => oIdxBits(iplace) <= sIdxBits(20);
        when "000000000000000000000100" => oIdxBits(iplace) <= sIdxBits(21);
        when "000000000000000000000010" => oIdxBits(iplace) <= sIdxBits(22);
        when "000000000000000000000001" => oIdxBits(iplace) <= sIdxBits(23);
        when others                     => oIdxBits(iplace) <= (others => '0');
      end case;
    end loop;  -- iplace
  end process mux;

end architecture behavioral;
