library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

library Types;
use Types.GMTTypes.all;

entity MatchQualityUnit is
  
  port (
    iMuonsRPC    : in  TGMTMuRPC_vector(3 downto 0);
    iMuonsBrlFwd : in  TGMTMu_vector(35 downto 0);
    iMuonsOvl    : in  TGMTMu_vector(35 downto 0);
    oMQMatrix    : out TMQMatrix;
    clk          : in  std_logic;
    sinit        : in  std_logic);

end MatchQualityUnit;

architecture behavioral of MatchQualityUnit is
  component match_qual_lut
    port (
      clka  : in  std_logic;
      wea   : in  std_logic_vector(0 downto 0);
      addra : in  std_logic_vector(6 downto 0);
      dina  : in  std_logic_vector(3 downto 0);
      douta : out std_logic_vector(3 downto 0);
      clkb  : in  std_logic;
      enb   : in  std_logic;
      web   : in  std_logic_vector(0 downto 0);
      addrb : in  std_logic_vector(6 downto 0);
      dinb  : in  std_logic_vector(3 downto 0);
      doutb : out std_logic_vector(3 downto 0)
      );
  end component;

  signal sMQMatrix : TMQMatrix;
  signal sMuonsTF  : TGMTMu_vector(71 downto 0);

begin  -- behavioral
  sMuonsTF <= iMuonsBrlFwd & iMuonsOvl;

  g1 : for i in iMuonsRPC'range generate
    g2 : for j in sMuonsTF'range generate
      -- TODO: May need to add scale factors?
      match_qual_calc : match_qual_lut
        port map (
          clka            => not clk,
          wea             => "0",
          -- BUG: Need to check if the MSBs that I cut off with last resize are
          -- all '0'. If this is not the case the MQ should be set to 0.
          addra           => std_logic_vector(resize(unsigned(abs(resize(iMuonsRPC(i).eta, 10) -
                                                                  resize(sMuonsTF(j).eta, 10))), 4)) &
          std_logic_vector(resize(unsigned(abs(signed(resize(iMuonsRPC(i).phi, 11)) -
                                               signed(resize(sMuonsTF(j).phi, 11)))), 3)),
          dina            => (others => '0'),
          unsigned(douta) => sMQMatrix(i, j),
          clkb            => not clk,
          enb             => '0',
          web             => "0",
          addrb           => (others => '0'),
          dinb            => (others => '0'),
          doutb           => open
          );
    end generate g2;
  end generate g1;

  oMQMatrix <= sMQMatrix;

end behavioral;
