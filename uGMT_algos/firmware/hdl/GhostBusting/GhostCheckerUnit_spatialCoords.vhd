library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

use work.mp7_data_types.all;
use work.ipbus.all;
use work.ipbus_dpram_dist;

use work.GMTTypes.all;
use work.ugmt_constants.all;

entity GhostCheckerUnit_spatialCoords is
  generic (
    USE_ETA_FINE_1   : boolean := false;
    USE_ETA_FINE_2   : boolean := false;
    DATA_FILE        : string;
    LOCAL_PHI_OFFSET : signed(8 downto 0);
    COU_INPUT_SIZE   : natural
    );
  port (
    clk_ipb  : in  std_logic;
    rst      : in  std_logic;
    ipb_in   : in  ipb_wbus;
    ipb_out  : out ipb_rbus;
    etaFine1 : in  std_logic := '1'; -- Per default we assume best eta.
    eta1     : in  signed(8 downto 0);
    phi1     : in  signed(7 downto 0);
    qual1    : in  unsigned(3 downto 0);
    etaFine2 : in  std_logic := '1'; -- Per default we assume best eta.
    eta2     : in  signed(8 downto 0);
    phi2     : in  signed(7 downto 0);
    qual2    : in  unsigned(3 downto 0);
    ghost1   : out std_logic;
    ghost2   : out std_logic;
    clk      : in  std_logic
    );
end GhostCheckerUnit_spatialCoords;

architecture Behavioral of GhostCheckerUnit_spatialCoords is
  signal ipbusWe     : std_logic;

  signal notClk : std_logic;

  signal deltaEta     : signed(9 downto 0);
  signal deltaPhi     : signed(8 downto 0);
  signal deltaEta_reg : signed(9 downto 0);
  signal deltaPhi_reg : signed(8 downto 0);
  signal deltaEtaRed  : unsigned(3 downto 0);
  signal deltaPhiRed  : unsigned(2 downto 0);
  signal lutInput     : std_logic_vector(COU_INPUT_SIZE-1 downto 0);
  signal match        : std_logic_vector(0 downto 0);
begin
  ipbusWe <= ipb_in.ipb_write and ipb_in.ipb_strobe;

  notClk <= not clk;

  deltaEta    <= abs(resize(eta1, 10) - resize(eta2, 10));
  deltaPhi    <= abs(resize(phi1, 9) - (LOCAL_PHI_OFFSET + resize(phi2, 9)));

  deltaEtaRed <= resize(unsigned(deltaEta), 4);
  deltaPhiRed <= resize(unsigned(deltaPhi), 3);

  construct_lut_input : process (deltaEtaRed, deltaPhiRed, etaFine1, etaFine2)
  begin  -- construct_lut_input
    if USE_ETA_FINE_1 = true and USE_ETA_FINE_2 = true then
      lutInput <= etaFine1 & etaFine2 & std_logic_vector(deltaEtaRed) & std_logic_vector(deltaPhiRed);
    elsif USE_ETA_FINE_1 = true then
      lutInput <= etaFine1 & std_logic_vector(deltaEtaRed) & std_logic_vector(deltaPhiRed);
    elsif USE_ETA_FINE_2 = true then
      lutInput <= etaFine2 & std_logic_vector(deltaEtaRed) & std_logic_vector(deltaPhiRed);
    else
      lutInput <= std_logic_vector(deltaEtaRed) & std_logic_vector(deltaPhiRed);
    end if;
  end process construct_lut_input;

  match_qual_calc : entity work.ipbus_dpram_dist
      generic map (
        DATA_FILE  => DATA_FILE,
        ADDR_WIDTH => COU_INPUT_SIZE,
        WORD_WIDTH => COU_MEM_WORD_SIZE
        )
      port map (
        clk     => clk_ipb,
        ipb_in  => ipb_in,
        ipb_out => ipb_out,
        rclk    => notClk,
        q       => match,
        addr    => lutInput
        );

  reg_deltas : process (clk)
  begin  -- reg_deltas
    if clk'event and clk = '0' then  -- falling clock edge
      deltaPhi_reg <= deltaPhi;
      deltaEta_reg <= deltaEta;
    end if;
  end process reg_deltas;


  check_ghosts : process (match, qual1, qual2, deltaPhi_reg, deltaEta_reg)
  begin  -- process check_ghosts
    -- If the muons are 'far enough' apart we don't check the LUT output.
    if (deltaPhi(7 downto 3) /= (4 downto 0 => '0')) or (deltaEta(8 downto 4) /= (4 downto 0 => '0')) then
      ghost1 <= '0';
      ghost2 <= '0';
    elsif match = "1" then
      if qual1 > qual2 then
        ghost1 <= '0';
        ghost2 <= '1';
      else
        ghost1 <= '1';
        ghost2 <= '0';
      end if;
    else
      ghost1 <= '0';
      ghost2 <= '0';
    end if;
  end process check_ghosts;
end Behavioral;
