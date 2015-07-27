library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.NUMERIC_STD.all;

library work;
use work.GMTTypes.all;

entity SortStage0_Mux is
  port (
    iSelBits   : in  TSelBits_1_of_36_vec(0 to 7);
    iMuons     : in  TGMTMu_vector(35 downto 0);
    iSortRanks : in  TSortRank10_vector(35 downto 0);
    iEmpty     : in  std_logic_vector(35 downto 0);
    iIdxBits   : in  TIndexBits_vector(35 downto 0);
    oMuons     : out TGMTMu_vector(7 downto 0);
    oSortRanks : out TSortRank10_vector(7 downto 0);
    oEmpty     : out std_logic_vector(7 downto 0);
    oIdxBits   : out TIndexBits_vector(7 downto 0)
    );
end SortStage0_Mux;

architecture Behavioral of SortStage0_Mux is

begin
  mux : process (iSelBits, iMuons, iSortRanks, iEmpty, iIdxBits) is
  begin
    for iplace in 0 to 7 loop
      case iSelBits(iplace) is
        when "100000000000000000000000000000000000" => oMuons(iplace) <= iMuons(0);
        when "010000000000000000000000000000000000" => oMuons(iplace) <= iMuons(1);
        when "001000000000000000000000000000000000" => oMuons(iplace) <= iMuons(2);
        when "000100000000000000000000000000000000" => oMuons(iplace) <= iMuons(3);
        when "000010000000000000000000000000000000" => oMuons(iplace) <= iMuons(4);
        when "000001000000000000000000000000000000" => oMuons(iplace) <= iMuons(5);
        when "000000100000000000000000000000000000" => oMuons(iplace) <= iMuons(6);
        when "000000010000000000000000000000000000" => oMuons(iplace) <= iMuons(7);
        when "000000001000000000000000000000000000" => oMuons(iplace) <= iMuons(8);
        when "000000000100000000000000000000000000" => oMuons(iplace) <= iMuons(9);
        when "000000000010000000000000000000000000" => oMuons(iplace) <= iMuons(10);
        when "000000000001000000000000000000000000" => oMuons(iplace) <= iMuons(11);
        when "000000000000100000000000000000000000" => oMuons(iplace) <= iMuons(12);
        when "000000000000010000000000000000000000" => oMuons(iplace) <= iMuons(13);
        when "000000000000001000000000000000000000" => oMuons(iplace) <= iMuons(14);
        when "000000000000000100000000000000000000" => oMuons(iplace) <= iMuons(15);
        when "000000000000000010000000000000000000" => oMuons(iplace) <= iMuons(16);
        when "000000000000000001000000000000000000" => oMuons(iplace) <= iMuons(17);
        when "000000000000000000100000000000000000" => oMuons(iplace) <= iMuons(18);
        when "000000000000000000010000000000000000" => oMuons(iplace) <= iMuons(19);
        when "000000000000000000001000000000000000" => oMuons(iplace) <= iMuons(20);
        when "000000000000000000000100000000000000" => oMuons(iplace) <= iMuons(21);
        when "000000000000000000000010000000000000" => oMuons(iplace) <= iMuons(22);
        when "000000000000000000000001000000000000" => oMuons(iplace) <= iMuons(23);
        when "000000000000000000000000100000000000" => oMuons(iplace) <= iMuons(24);
        when "000000000000000000000000010000000000" => oMuons(iplace) <= iMuons(25);
        when "000000000000000000000000001000000000" => oMuons(iplace) <= iMuons(26);
        when "000000000000000000000000000100000000" => oMuons(iplace) <= iMuons(27);
        when "000000000000000000000000000010000000" => oMuons(iplace) <= iMuons(28);
        when "000000000000000000000000000001000000" => oMuons(iplace) <= iMuons(29);
        when "000000000000000000000000000000100000" => oMuons(iplace) <= iMuons(30);
        when "000000000000000000000000000000010000" => oMuons(iplace) <= iMuons(31);
        when "000000000000000000000000000000001000" => oMuons(iplace) <= iMuons(32);
        when "000000000000000000000000000000000100" => oMuons(iplace) <= iMuons(33);
        when "000000000000000000000000000000000010" => oMuons(iplace) <= iMuons(34);
        when "000000000000000000000000000000000001" => oMuons(iplace) <= iMuons(35);
        when others                                 => oMuons(iplace) <= ('0', '0', "000000000", "0000", "000000000", "0000000000");
      end case;
      case iSelBits(iplace) is
        when "100000000000000000000000000000000000" => oSortRanks(iplace) <= iSortRanks(0);
        when "010000000000000000000000000000000000" => oSortRanks(iplace) <= iSortRanks(1);
        when "001000000000000000000000000000000000" => oSortRanks(iplace) <= iSortRanks(2);
        when "000100000000000000000000000000000000" => oSortRanks(iplace) <= iSortRanks(3);
        when "000010000000000000000000000000000000" => oSortRanks(iplace) <= iSortRanks(4);
        when "000001000000000000000000000000000000" => oSortRanks(iplace) <= iSortRanks(5);
        when "000000100000000000000000000000000000" => oSortRanks(iplace) <= iSortRanks(6);
        when "000000010000000000000000000000000000" => oSortRanks(iplace) <= iSortRanks(7);
        when "000000001000000000000000000000000000" => oSortRanks(iplace) <= iSortRanks(8);
        when "000000000100000000000000000000000000" => oSortRanks(iplace) <= iSortRanks(9);
        when "000000000010000000000000000000000000" => oSortRanks(iplace) <= iSortRanks(10);
        when "000000000001000000000000000000000000" => oSortRanks(iplace) <= iSortRanks(11);
        when "000000000000100000000000000000000000" => oSortRanks(iplace) <= iSortRanks(12);
        when "000000000000010000000000000000000000" => oSortRanks(iplace) <= iSortRanks(13);
        when "000000000000001000000000000000000000" => oSortRanks(iplace) <= iSortRanks(14);
        when "000000000000000100000000000000000000" => oSortRanks(iplace) <= iSortRanks(15);
        when "000000000000000010000000000000000000" => oSortRanks(iplace) <= iSortRanks(16);
        when "000000000000000001000000000000000000" => oSortRanks(iplace) <= iSortRanks(17);
        when "000000000000000000100000000000000000" => oSortRanks(iplace) <= iSortRanks(18);
        when "000000000000000000010000000000000000" => oSortRanks(iplace) <= iSortRanks(19);
        when "000000000000000000001000000000000000" => oSortRanks(iplace) <= iSortRanks(20);
        when "000000000000000000000100000000000000" => oSortRanks(iplace) <= iSortRanks(21);
        when "000000000000000000000010000000000000" => oSortRanks(iplace) <= iSortRanks(22);
        when "000000000000000000000001000000000000" => oSortRanks(iplace) <= iSortRanks(23);
        when "000000000000000000000000100000000000" => oSortRanks(iplace) <= iSortRanks(24);
        when "000000000000000000000000010000000000" => oSortRanks(iplace) <= iSortRanks(25);
        when "000000000000000000000000001000000000" => oSortRanks(iplace) <= iSortRanks(26);
        when "000000000000000000000000000100000000" => oSortRanks(iplace) <= iSortRanks(27);
        when "000000000000000000000000000010000000" => oSortRanks(iplace) <= iSortRanks(28);
        when "000000000000000000000000000001000000" => oSortRanks(iplace) <= iSortRanks(29);
        when "000000000000000000000000000000100000" => oSortRanks(iplace) <= iSortRanks(30);
        when "000000000000000000000000000000010000" => oSortRanks(iplace) <= iSortRanks(31);
        when "000000000000000000000000000000001000" => oSortRanks(iplace) <= iSortRanks(32);
        when "000000000000000000000000000000000100" => oSortRanks(iplace) <= iSortRanks(33);
        when "000000000000000000000000000000000010" => oSortRanks(iplace) <= iSortRanks(34);
        when "000000000000000000000000000000000001" => oSortRanks(iplace) <= iSortRanks(35);
        when others                                 => oSortRanks(iplace) <= (others => '0');
      end case;
      case iSelBits(iplace) is
        when "100000000000000000000000000000000000" => oEmpty(iplace) <= iEmpty(0);
        when "010000000000000000000000000000000000" => oEmpty(iplace) <= iEmpty(1);
        when "001000000000000000000000000000000000" => oEmpty(iplace) <= iEmpty(2);
        when "000100000000000000000000000000000000" => oEmpty(iplace) <= iEmpty(3);
        when "000010000000000000000000000000000000" => oEmpty(iplace) <= iEmpty(4);
        when "000001000000000000000000000000000000" => oEmpty(iplace) <= iEmpty(5);
        when "000000100000000000000000000000000000" => oEmpty(iplace) <= iEmpty(6);
        when "000000010000000000000000000000000000" => oEmpty(iplace) <= iEmpty(7);
        when "000000001000000000000000000000000000" => oEmpty(iplace) <= iEmpty(8);
        when "000000000100000000000000000000000000" => oEmpty(iplace) <= iEmpty(9);
        when "000000000010000000000000000000000000" => oEmpty(iplace) <= iEmpty(10);
        when "000000000001000000000000000000000000" => oEmpty(iplace) <= iEmpty(11);
        when "000000000000100000000000000000000000" => oEmpty(iplace) <= iEmpty(12);
        when "000000000000010000000000000000000000" => oEmpty(iplace) <= iEmpty(13);
        when "000000000000001000000000000000000000" => oEmpty(iplace) <= iEmpty(14);
        when "000000000000000100000000000000000000" => oEmpty(iplace) <= iEmpty(15);
        when "000000000000000010000000000000000000" => oEmpty(iplace) <= iEmpty(16);
        when "000000000000000001000000000000000000" => oEmpty(iplace) <= iEmpty(17);
        when "000000000000000000100000000000000000" => oEmpty(iplace) <= iEmpty(18);
        when "000000000000000000010000000000000000" => oEmpty(iplace) <= iEmpty(19);
        when "000000000000000000001000000000000000" => oEmpty(iplace) <= iEmpty(20);
        when "000000000000000000000100000000000000" => oEmpty(iplace) <= iEmpty(21);
        when "000000000000000000000010000000000000" => oEmpty(iplace) <= iEmpty(22);
        when "000000000000000000000001000000000000" => oEmpty(iplace) <= iEmpty(23);
        when "000000000000000000000000100000000000" => oEmpty(iplace) <= iEmpty(24);
        when "000000000000000000000000010000000000" => oEmpty(iplace) <= iEmpty(25);
        when "000000000000000000000000001000000000" => oEmpty(iplace) <= iEmpty(26);
        when "000000000000000000000000000100000000" => oEmpty(iplace) <= iEmpty(27);
        when "000000000000000000000000000010000000" => oEmpty(iplace) <= iEmpty(28);
        when "000000000000000000000000000001000000" => oEmpty(iplace) <= iEmpty(29);
        when "000000000000000000000000000000100000" => oEmpty(iplace) <= iEmpty(30);
        when "000000000000000000000000000000010000" => oEmpty(iplace) <= iEmpty(31);
        when "000000000000000000000000000000001000" => oEmpty(iplace) <= iEmpty(32);
        when "000000000000000000000000000000000100" => oEmpty(iplace) <= iEmpty(33);
        when "000000000000000000000000000000000010" => oEmpty(iplace) <= iEmpty(34);
        when "000000000000000000000000000000000001" => oEmpty(iplace) <= iEmpty(35);
        when others                                 => oEmpty(iplace) <= '1';
      end case;
      case iSelBits(iplace) is
        when "100000000000000000000000000000000000" => oIdxBits(iplace) <= iIdxBits(0);
        when "010000000000000000000000000000000000" => oIdxBits(iplace) <= iIdxBits(1);
        when "001000000000000000000000000000000000" => oIdxBits(iplace) <= iIdxBits(2);
        when "000100000000000000000000000000000000" => oIdxBits(iplace) <= iIdxBits(3);
        when "000010000000000000000000000000000000" => oIdxBits(iplace) <= iIdxBits(4);
        when "000001000000000000000000000000000000" => oIdxBits(iplace) <= iIdxBits(5);
        when "000000100000000000000000000000000000" => oIdxBits(iplace) <= iIdxBits(6);
        when "000000010000000000000000000000000000" => oIdxBits(iplace) <= iIdxBits(7);
        when "000000001000000000000000000000000000" => oIdxBits(iplace) <= iIdxBits(8);
        when "000000000100000000000000000000000000" => oIdxBits(iplace) <= iIdxBits(9);
        when "000000000010000000000000000000000000" => oIdxBits(iplace) <= iIdxBits(10);
        when "000000000001000000000000000000000000" => oIdxBits(iplace) <= iIdxBits(11);
        when "000000000000100000000000000000000000" => oIdxBits(iplace) <= iIdxBits(12);
        when "000000000000010000000000000000000000" => oIdxBits(iplace) <= iIdxBits(13);
        when "000000000000001000000000000000000000" => oIdxBits(iplace) <= iIdxBits(14);
        when "000000000000000100000000000000000000" => oIdxBits(iplace) <= iIdxBits(15);
        when "000000000000000010000000000000000000" => oIdxBits(iplace) <= iIdxBits(16);
        when "000000000000000001000000000000000000" => oIdxBits(iplace) <= iIdxBits(17);
        when "000000000000000000100000000000000000" => oIdxBits(iplace) <= iIdxBits(18);
        when "000000000000000000010000000000000000" => oIdxBits(iplace) <= iIdxBits(19);
        when "000000000000000000001000000000000000" => oIdxBits(iplace) <= iIdxBits(20);
        when "000000000000000000000100000000000000" => oIdxBits(iplace) <= iIdxBits(21);
        when "000000000000000000000010000000000000" => oIdxBits(iplace) <= iIdxBits(22);
        when "000000000000000000000001000000000000" => oIdxBits(iplace) <= iIdxBits(23);
        when "000000000000000000000000100000000000" => oIdxBits(iplace) <= iIdxBits(24);
        when "000000000000000000000000010000000000" => oIdxBits(iplace) <= iIdxBits(25);
        when "000000000000000000000000001000000000" => oIdxBits(iplace) <= iIdxBits(26);
        when "000000000000000000000000000100000000" => oIdxBits(iplace) <= iIdxBits(27);
        when "000000000000000000000000000010000000" => oIdxBits(iplace) <= iIdxBits(28);
        when "000000000000000000000000000001000000" => oIdxBits(iplace) <= iIdxBits(29);
        when "000000000000000000000000000000100000" => oIdxBits(iplace) <= iIdxBits(30);
        when "000000000000000000000000000000010000" => oIdxBits(iplace) <= iIdxBits(31);
        when "000000000000000000000000000000001000" => oIdxBits(iplace) <= iIdxBits(32);
        when "000000000000000000000000000000000100" => oIdxBits(iplace) <= iIdxBits(33);
        when "000000000000000000000000000000000010" => oIdxBits(iplace) <= iIdxBits(34);
        when "000000000000000000000000000000000001" => oIdxBits(iplace) <= iIdxBits(35);
        when others                                 => oIdxBits(iplace) <= (others => '0');
      end case;
    end loop;  -- iplace
  end process mux;

end Behavioral;

