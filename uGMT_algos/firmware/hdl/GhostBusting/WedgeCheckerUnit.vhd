library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

use work.mp7_data_types.all;
use work.ipbus.all;
use work.ipbus_decode_cancel_out_mems.all;

use work.GMTTypes.all;

entity WedgeCheckerUnit is
  generic (
    CANCEL_OUT_TYPE  : string := string'("COORDINATE"); -- which type of cancel-out should be used.
    DATA_FILE        : string;
    LOCAL_PHI_OFFSET : signed(8 downto 0)
    );
  port (
    clk_ipb : in  std_logic;
    rst     : in  std_logic;
    ipb_in  : in  ipb_wbus;
    ipb_out : out ipb_rbus;
    wedge1  : in  TGMTMuTracks3;
    wedge2  : in  TGMTMuTracks3;
    ghosts1 : out std_logic_vector (2 downto 0);
    ghosts2 : out std_logic_vector (2 downto 0);
    clk     : in  std_logic
    );

end WedgeCheckerUnit;

architecture Behavioral of WedgeCheckerUnit is
  signal ipbw    : ipb_wbus_array(N_SLAVES-1 downto 0);
  signal ipbr    : ipb_rbus_array(N_SLAVES-1 downto 0);

  subtype muon_cancel is std_logic_vector(wedge2'range);
  type    muon_cancel_vec is array (integer range <>) of muon_cancel;
  signal  sCancel1             : muon_cancel_vec(wedge1'range);
  signal  sCancel2             : muon_cancel_vec(wedge2'range);
  signal  sIntermediateCancel1 : muon_cancel_vec(wedge1'range);
  signal  sIntermediateCancel2 : muon_cancel_vec(wedge2'range);

  signal wedge1_reg : TGMTMuTracks3;
  signal wedge2_reg : TGMTMuTracks3;

begin

    -- IPbus address decode
    fabric : entity work.ipbus_fabric_sel
      generic map(
        NSLV      => N_SLAVES,
        SEL_WIDTH => IPBUS_SEL_WIDTH
        )
      port map(
        ipb_in          => ipb_in,
        ipb_out         => ipb_out,
        sel             => ipbus_sel_cancel_out_mems(ipb_in.ipb_addr),
        ipb_to_slaves   => ipbw,
        ipb_from_slaves => ipbr
        );

  -- Compare the two wedges' muons with each other.
  g1 : for i in wedge1'range generate
    g2 : for j in wedge2'range generate
      gen_addr_based : if CANCEL_OUT_TYPE /= string'("COORDINATE") generate
        x : entity work.GhostCheckerUnit
         port map (
           mu1     => (others => '0'),
           qual1   => wedge1(i).qual,
           mu2     => (others => '0'),
           qual2   => wedge2(i).qual,
           ghost1  => sIntermediateCancel1(j)(i),
           ghost2  => sIntermediateCancel2(j)(i)
           );
      end generate gen_addr_based;

      gen_coord_based : if CANCEL_OUT_TYPE = string'("COORDINATE") generate
        x : entity work.GhostCheckerUnit_spatialCoords
        generic map (
          DATA_FILE        => DATA_FILE,
          LOCAL_PHI_OFFSET => LOCAL_PHI_OFFSET
          )
          port map (
            clk_ipb => clk_ipb,
            rst     => rst,
            ipb_in  => ipbw(3*i +j),
            ipb_out => ipbr(3*i +j),
            eta1    => wedge1(i).eta,
            phi1    => wedge1(i).phi,
            qual1   => wedge1(i).qual,
            eta2    => wedge2(j).eta,
            phi2    => wedge2(j).phi,
            qual2   => wedge2(i).qual,
            ghost1  => sIntermediateCancel1(j)(i),
            ghost2  => sIntermediateCancel2(j)(i),
            clk     => clk
            );
      end generate gen_coord_based;
    end generate g2;
  end generate g1;

  -- If one of the muons are empty we won't check for ghosts.
  check_empty : process (sIntermediateCancel2, sIntermediateCancel2, wedge1_reg, wedge2_reg)
  begin  -- process check_empty
    for i in wedge1'range loop
        for j in wedge2'range loop
            if (wedge1_reg(i).empty = '1') or (wedge2_reg(j).empty = '1') then
                sCancel1(j)(i) <= '0';
                sCancel2(j)(i) <= '0';
            else
                sCancel1(j)(i) <= sIntermediateCancel1(j)(i);
                sCancel2(j)(i) <= sIntermediateCancel2(j)(i);
            end if;
        end loop;
    end loop;
  end process check_empty;

  reg_wedges : process (clk)
  begin  -- reg_wedges
    if clk'event and clk = '1' then  -- rising clock edge
      wedge1_reg <= wedge1;
      wedge2_reg <= wedge2;
    end if;
  end process reg_wedges;

  g3 : for i in ghosts1'range generate
    ghosts1(i) <= sCancel1(i)(0) or sCancel1(i)(1) or sCancel1(i)(2);
    ghosts2(i) <= sCancel2(i)(0) or sCancel2(i)(1) or sCancel2(i)(2);
  end generate g3;
end Behavioral;
