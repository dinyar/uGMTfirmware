library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.NUMERIC_STD.all;

library work;
use work.GMTTypes.all;

library work;
use work.SorterUnit.all;

entity SortStage0_countWins is
  port (
    iGEMatrix : in  TGEMatrix36;
    iCancel_A : in  std_logic_vector(35 downto 0);  -- arrive 1/2 bx later
    iCancel_B : in  std_logic_vector(35 downto 0);  -- arrive 1/2 bx later
    iCancel_C : in  std_logic_vector(35 downto 0);  -- arrive 1/2 bx later
    oSelBits  : out TSelBits_1_of_36_vec(0 to 7));
end SortStage0_countWins;

architecture Behavioral of SortStage0_countWins is
  signal sDisable : std_logic_vector(35 downto 0);

begin
  sDisable <= iEmpty or iCancel_A or iCancel_B or iCancel_C;

  count_wins36(iGEMatrix, sDisable, oSelBits);
end Behavioral;
