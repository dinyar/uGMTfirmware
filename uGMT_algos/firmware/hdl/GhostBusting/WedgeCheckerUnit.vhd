library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

use work.mp7_data_types.all;
use work.ipbus.all;
use work.ipbus_decode_cancel_out_mems.all;

use work.GMTTypes.all;
use work.ugmt_constants.all;

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

  type TEtaFineMatrix is array (wedge1'range) of std_logic_vector(wedge2'range);
  signal etaFine : TEtaFineMatrix;

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
      gen_bmtf_addr_based : if CANCEL_OUT_TYPE = string'("BMTF_ADDRESSES") generate
        x : entity work.GhostCheckerUnit_BMTF
         port map (
           mu1     => wedge1(i).bmtfAddress,
           qual1   => wedge1(i).qual,
           mu2     => wedge2(j).bmtfAddress,
           qual2   => wedge2(j).qual,
           ghost1  => sIntermediateCancel1(i)(j),
           ghost2  => sIntermediateCancel2(j)(i),
           clk     => clk
           );
      end generate gen_bmtf_addr_based;

      -- TODO: MISSING!
      gen_omtf_addr_based : if CANCEL_OUT_TYPE = string'("OMTF_ADDRESSES") generate
        sIntermediateCancel1(j)(i) <= '0';
        sIntermediateCancel2(j)(i) <= '0';
      end generate gen_omtf_addr_based;

      -- TODO: MISSING!
      gen_emtf_addr_based : if CANCEL_OUT_TYPE = string'("EMTF_ADDRESSES") generate
        sIntermediateCancel1(j)(i) <= '0';
        sIntermediateCancel2(j)(i) <= '0';
      end generate gen_emtf_addr_based;

      gen_coord_based : if CANCEL_OUT_TYPE = string'("COORDINATE") generate
        x : entity work.GhostCheckerUnit_spatialCoords
        generic map (
          DATA_FILE        => DATA_FILE,
          LOCAL_PHI_OFFSET => LOCAL_PHI_OFFSET,
          COU_INPUT_SIZE   => COU_MEM_ADDR_WIDTH
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
          qual2   => wedge2(j).qual,
          ghost1  => sIntermediateCancel1(i)(j),
          ghost2  => sIntermediateCancel2(j)(i),
          clk     => clk
          );
      end generate gen_coord_based;

      -- Need to be able to tell if a muon can have eta fine bit set.
      gen_coord_w_eta_fine : if CANCEL_OUT_TYPE = string'("COORDINATE_ETA_FINE") generate
        etaFine(i)(j) <= wedge1(i).etaFine and wedge2(j).etaFine;
        x : entity work.GhostCheckerUnit_spatialCoords
        generic map (
          USE_ETA_FINE     => true,
          DATA_FILE        => DATA_FILE,
          LOCAL_PHI_OFFSET => LOCAL_PHI_OFFSET,
          COU_INPUT_SIZE   => COU_ETA_FINE_MEM_ADDR_WIDTH
          )
        port map (
          clk_ipb  => clk_ipb,
          rst      => rst,
          ipb_in   => ipbw(3*i +j),
          ipb_out  => ipbr(3*i +j),
          etaFine  => etaFine(i)(j),
          eta1     => wedge1(i).eta,
          phi1     => wedge1(i).phi,
          qual1    => wedge1(i).qual,
          eta2     => wedge2(j).eta,
          phi2     => wedge2(j).phi,
          qual2    => wedge2(j).qual,
          ghost1   => sIntermediateCancel1(i)(j),
          ghost2   => sIntermediateCancel2(j)(i),
          clk      => clk
          );
      end generate gen_coord_w_eta_fine;
      -- If the other muon is empty we won't cancel even if it's requested.
      sCancel1(i)(j) <= sIntermediateCancel1(i)(j) and (not wedge2_reg(j).empty);
      sCancel2(j)(i) <= sIntermediateCancel2(j)(i) and (not wedge1_reg(i).empty);
    end generate g2;
  end generate g1;

  reg_wedges : process (clk)
  begin  -- reg_wedges
    if clk'event and clk = '0' then  -- falling clock edge
      wedge1_reg <= wedge1;
      wedge2_reg <= wedge2;
    end if;
  end process reg_wedges;

  -- The empty bit will be regarded as cancel bit from here.
  g3 : for i in ghosts1'range generate
    ghosts1(i) <= wedge1_reg(i).empty or sCancel1(i)(0) or sCancel1(i)(1) or sCancel1(i)(2);
    ghosts2(i) <= wedge2_reg(i).empty or sCancel2(i)(0) or sCancel2(i)(1) or sCancel2(i)(2);
  end generate g3;
end Behavioral;
