library IEEE;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;
library Types;
use Types.GMTTypes.all;

entity MatchPairs is
  
  port (
    iColumnMaxima : in  TRowColIndex_vector(3 downto 0);
    iRowMaxima    : in  TRowColIndex_vector(71 downto 0);
    iMQMatrix     : in  TMQMatrix;
    iPairs        : in  TPairVector(3 downto 0);
    -- TODO: Remove the disable inputs here.
    iDisableCol   : in  std_logic_vector(3 downto 0);
    iDisableRow   : in  std_logic_vector(71 downto 0);
    oPairs        : out TPairVector(3 downto 0);
    oDisableCol   : out std_logic_vector(3 downto 0);
    oDisableRow   : out std_logic_vector(71 downto 0));

end MatchPairs;

architecture behavioral of MatchPairs is

begin  -- behavioral

  find_pairs : process (iColumnMaxima, iRowMaxima, iMQMatrix, iPairs)
  begin  -- process find_pairs
    oDisableCol <= (others => '0');
    oDisableRow <= (others => '0');
    
    for i in oPairs'range loop
      for j in iRowMaxima'range loop
        -- First condition makes sure we're actually looking at an entry for
        -- the RPC muon we're just now matching.
        -- Second condition checks whether the maximum in the column is also the
        -- maximum in the row. In that case those muons are matched.
        -- Last condition needed to make sure that match quality is not zero.
        -- If the first TF and first RPC muon have a match quality of 0 for each
        -- pairing they would otherwise be matched.
        if to_integer(iRowMaxima(j)) = i and
          iColumnMaxima(to_integer(iRowMaxima(j))) =
          to_unsigned(j, iColumnMaxima(0)'length) and
          iMQMatrix(to_integer(iRowMaxima(j)), j) /= 0
        then

          -- Add matched TF muon to pair vector.
          oPairs(i) <= to_unsigned(j, oPairs(0)'length);

          -- Disable matched muons.
          oDisableCol(to_integer(iRowMaxima(j))) <= '1';
          oDisableRow(j)                         <= '1';
        else
          -- If no match was found we use the one we already had.
          oPairs(i) <= iPairs(i);
        end if;
      end loop;  -- j
    end loop;  -- i
  end process find_pairs;

end behavioral;
