library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.mp7_data_types.all;

use work.GMTTypes.all;
use work.ugmt_constants.all;

entity serializer_stage is
  port (clk240               : in  std_logic;
        clk40                : in  std_logic;
        rst                  : in  std_logic;
        iValid               : in  std_logic;
        iMuons               : in  TGMTMu_vector (NUM_OUT_CHANS*NUM_MUONS_OUT-1 downto 0);
        iIso                 : in  TIsoBits_vector(NUM_OUT_CHANS*NUM_MUONS_OUT-1 downto 0);
        iMuIdxBits           : in  TIndexBits_vector (7 downto 0);
        iIntermediateMuonsB  : in  TGMTMu_vector(7 downto 0);
        iIntermediateMuonsO  : in  TGMTMu_vector(7 downto 0);
        iIntermediateMuonsE  : in  TGMTMu_vector(7 downto 0);
        q                    : out ldata (((OUTPUT_MULTIPLIER*NUM_OUT_CHANS)+NUM_INTERM_MU_OUT_CHANS)-1 downto 0));
end serializer_stage;

architecture Behavioral of serializer_stage is
  type TTransceiverBufferOut is array (2*2*NUM_MUONS_LINK-1 downto 0) of ldata((NUM_OUT_CHANS+NUM_INTERM_MU_OUT_CHANS)-1 downto 0);
  signal sOutBuf : TTransceiverBufferOut;

  -- Offsetting the beginning of sending to align with 40 MHz clock and make
  -- sending a bit faster.
  signal sSel    : integer range 0 to 5;

  signal sIntermediateMuons : TGMTMu_vector(23 downto 0);
  signal sFakeIdxBits       : TIndexBits := "0000000";
  signal sFakeIso           : TIsoBits   := "00";
begin

  sIntermediateMuons <= iIntermediateMuonsE(7 downto 4) & iIntermediateMuonsO(7 downto 4) & iIntermediateMuonsB & iIntermediateMuonsO(3 downto 0) & iIntermediateMuonsE(3 downto 0);

  serialize_muons : for i in NUM_MUONS_LINK-1 downto 0 generate
    split_muons : for j in NUM_OUT_CHANS-1 downto 0 generate
      muon_check : if i < NUM_MUONS_OUT generate
        -- First two clocks are always filled with '0'.
        sOutBuf(2*MU_ASSIGNMENT(i))(j).data    <= pack_mu_to_flat(iMuons(i+2*j), iMuIdxBits(i+2*j), iIso(i+2*j))(31 downto 0);
        sOutBuf(2*MU_ASSIGNMENT(i))(j).valid   <= iValid;
        sOutBuf(2*MU_ASSIGNMENT(i)+1)(j).data  <= pack_mu_to_flat(iMuons(i+2*j), iMuIdxBits(i+2*j), iIso(i+2*j))(63 downto 32);
        sOutBuf(2*MU_ASSIGNMENT(i)+1)(j).valid <= iValid;
      end generate muon_check;
      empty_check : if i = NUM_MUONS_OUT generate
        sOutBuf(2*MU_ASSIGNMENT(i))(j).data    <= (31 downto 0 => '0');
        sOutBuf(2*MU_ASSIGNMENT(i))(j).valid   <= iValid;
        sOutBuf(2*MU_ASSIGNMENT(i)+1)(j).data  <= (31 downto 0 => '0');
        sOutBuf(2*MU_ASSIGNMENT(i)+1)(j).valid <= iValid;
      end generate empty_check;
    end generate split_muons;
  end generate serialize_muons;

  serialize_intermediate_muons : for i in NUM_MUONS_LINK-1 downto 0 generate
    split_muons : for j in NUM_INTERM_MU_OUT_CHANS-1 downto 0 generate
      -- Intermediate muons don't have isolation applied and no idx bit available, so forcing those to all '0'.
      sOutBuf(2*i)(j+NUM_OUT_CHANS).data    <= pack_mu_to_flat(sIntermediateMuons(i+3*j), sFakeIdxBits, sFakeIso)(31 downto 0);
      sOutBuf(2*i)(j+NUM_OUT_CHANS).valid   <= iValid;
      sOutBuf(2*i+1)(j+NUM_OUT_CHANS).data  <= pack_mu_to_flat(sIntermediateMuons(i+3*j), sFakeIdxBits, sFakeIso)(63 downto 32);
      sOutBuf(2*i+1)(j+NUM_OUT_CHANS).valid <= iValid;
    end generate split_muons;
  end generate serialize_intermediate_muons;

  shift_intermediates_rising : process (clk40)
  begin  -- process shift_intermediates_rising
    if clk40'event and clk40 = '1' then  -- rising clock edge
      sOutBuf(sOutBuf'high downto BUFFER_INTERMEDIATES_POS_LOW) <= sOutBuf(BUFFER_INTERMEDIATES_POS_LOW-1 downto 0);
    end if;
  end process shift_intermediates_rising;

  serialization : process (clk240)
  begin  -- process serialization
    if clk240'event and clk240 = '1' then  -- rising clock edge
      for m in 0 to OUTPUT_MULTIPLIER-1 loop
        for i in 0 to NUM_OUT_CHANS-1 loop
          q((m*NUM_OUT_CHANS)+i).strobe <= '1';
          q((m*NUM_OUT_CHANS)+i).valid <= sOutBuf(BUFFER_INTERMEDIATES_POS_LOW+sSel)(i).valid;
          q((m*NUM_OUT_CHANS)+i).data <= sOutBuf(sSel)(i).data;
        end loop;  -- i
      end loop;  -- m
      for i in 0 to NUM_INTERM_MU_OUT_CHANS - 1 loop
        q(i+(OUTPUT_MULTIPLIER*NUM_OUT_CHANS)).strobe <= '1';
        q(i+(OUTPUT_MULTIPLIER*NUM_OUT_CHANS)).data <= sOutBuf(BUFFER_INTERMEDIATES_POS_LOW+sSel)(i+NUM_OUT_CHANS).data;
        q(i+(OUTPUT_MULTIPLIER*NUM_OUT_CHANS)).valid <= sOutBuf(BUFFER_INTERMEDIATES_POS_LOW+sSel)(i+NUM_OUT_CHANS).valid;
      end loop;  -- i

      if rst = '1' then
        sSel <= 0;
      elsif sSel < 5 then
        sSel <= sSel+1;
      else
        sSel <= 0;
      end if;
    end if;
  end process serialization;

end Behavioral;
