library IEEE;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;
use work.GMTTypes.all;

entity PairFindingUnit is

  port (
    iMQMatrix : in  TMQMatrix;
    oPairs    : out TPairVector(3 downto 0);  -- Holds the indices of the TF
                                              -- muons that should be merged
                                              -- with the Nth RPC muon.
                                              -- Muons from BMTF/fwd: 35 -> 0
                                              -- Muons from ovl: 71 -> 36
    clk       : in  std_logic;
    sinit     : in  std_logic);

end PairFindingUnit;

architecture behavioral of PairFindingUnit is

  component FindMaxMatchQualities
    port (
      iMQMatrix     : in  TMQMatrix;
      iDisableCol   : in  std_logic_vector(3 downto 0);
      iDisableRow   : in  std_logic_vector(71 downto 0);
      oColumnMaxima : out TRowColIndex_vector(3 downto 0);
      oRowMaxima    : out TRowColIndex_vector(71 downto 0));
  end component;

  component MatchPairs
    port (
      iColumnMaxima : in  TRowColIndex_vector(3 downto 0);
      iRowMaxima    : in  TRowColIndex_vector(71 downto 0);
      iMQMatrix     : in  TMQMatrix;
      iPairs        : in  TPairVector(3 downto 0);
      iDisableCol   : in  std_logic_vector(3 downto 0);
      iDisableRow   : in  std_logic_vector(71 downto 0);
      oPairs        : out TPairVector(3 downto 0);
      oDisableCol   : out std_logic_vector(3 downto 0);
      oDisableRow   : out std_logic_vector(71 downto 0));
  end component;

  signal sMQMatrix           : TMQMatrix;
  signal iPairs              : TPairVector(oPairs'range);
  signal sPairs              : TPairVector(oPairs'range);
  signal sColumnMaxima       : TRowColIndex_vector(3 downto 0);
                                        -- Vector that will contain the indices
                                        -- of the max values for each column.
  signal sColumnMaximaSecond : TRowColIndex_vector(3 downto 0);
  signal sRowMaxima          : TRowColIndex_vector(71 downto 0);
                                        -- Vector that will contain the indices
                                        -- of the max values for each row.
  signal sRowMaximaSecond    : TRowColIndex_vector(71 downto 0);
  signal sDisableCol         : std_logic_vector(3 downto 0);
  signal sDisableRow         : std_logic_vector(71 downto 0);

begin  -- behavioral

  -- Initialize pair vector to invalid state (i.e. 'no matching')
  init_pair_vec : for i in sPairs'range generate
    iPairs(i) <= (others => '1');
  end generate init_pair_vec;

  sMQMatrix <= iMQMatrix;

  find_maxima_1 : FindMaxMatchQualities
    port map (
      iMQMatrix     => iMQMatrix,
      iDisableCol   => (others => '0'),
      iDisableRow   => (others => '0'),
      oColumnMaxima => sColumnMaxima,
      oRowMaxima    => sRowMaxima);

  -- Now check whether the max in a given row and col are the same.
  -- loop over larger set (rows) and use the index stored to find the entry in
  -- the column vector. If that entry points back at the current entry of the
  -- row vector the entry is the max of both the column and the row and we set
  -- the appropriate entry in the pair matrix to true.
  find_pairs_1 : MatchPairs
    port map (
      iColumnMaxima => sColumnMaxima,
      iRowMaxima    => sRowMaxima,
      iMQMatrix     => iMQMatrix,
      iPairs        => iPairs,
      -- TODO: Use empty/disable signals here?
      iDisableCol   => (others => '0'),
      iDisableRow   => (others => '0'),
      oPairs        => sPairs,
      oDisableCol   => sDisableCol,
      oDisableRow   => sDisableRow);

  -- Now repeat pair finding algo.
  find_maxima_2 : FindMaxMatchQualities
    port map (
      iMQMatrix     => sMQMatrix,
      iDisableCol   => sDisableCol,
      iDisableRow   => sDisableRow,
      oColumnMaxima => sColumnMaximaSecond,
      oRowMaxima    => sRowMaximaSecond);

  -- Repeat matching.
  find_pairs_2 : MatchPairs
    port map (
      iColumnMaxima => sColumnMaximaSecond,
      iRowMaxima    => sRowMaximaSecond,
      iMQMatrix     => iMQMatrix,
      iPairs        => sPairs,
      iDisableCol   => sDisableCol,
      iDisableRow   => sDisableRow,
      oPairs        => oPairs,
      oDisableCol   => open,
      oDisableRow   => open);

end behavioral;
