-- Address decode logic for ipbus fabric
-- 
-- This file has been AUTOGENERATED from the address table - do not hand edit
-- 
-- We assume the synthesis tool is clever enough to recognise exclusive conditions
-- in the if statement.
-- 
-- Dave Newbold, February 2011

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

package ipbus_decode_extrapolation_phi is

  constant IPBUS_SEL_WIDTH: positive := 5; -- Should be enough for now?
  subtype ipbus_sel_t is std_logic_vector(IPBUS_SEL_WIDTH - 1 downto 0);
  function ipbus_sel_extrapolation_phi(addr : in std_logic_vector(31 downto 0)) return ipbus_sel_t;

-- START automatically  generated VHDL the Sat Apr 18 14:46:27 2015 
  constant N_SLV_PHI_EXTRAPOLATION_MEM_0: integer := 0;
  constant N_SLV_PHI_EXTRAPOLATION_MEM_1: integer := 1;
  constant N_SLV_PHI_EXTRAPOLATION_MEM_2: integer := 2;
  constant N_SLV_PHI_EXTRAPOLATION_MEM_3: integer := 3;
  constant N_SLV_PHI_EXTRAPOLATION_MEM_4: integer := 4;
  constant N_SLV_PHI_EXTRAPOLATION_MEM_5: integer := 5;
  constant N_SLV_PHI_EXTRAPOLATION_MEM_6: integer := 6;
  constant N_SLV_PHI_EXTRAPOLATION_MEM_7: integer := 7;
  constant N_SLV_PHI_EXTRAPOLATION_MEM_8: integer := 8;
  constant N_SLV_PHI_EXTRAPOLATION_MEM_9: integer := 9;
  constant N_SLV_PHI_EXTRAPOLATION_MEM_10: integer := 10;
  constant N_SLV_PHI_EXTRAPOLATION_MEM_11: integer := 11;
  constant N_SLV_PHI_EXTRAPOLATION_MEM_12: integer := 12;
  constant N_SLV_PHI_EXTRAPOLATION_MEM_13: integer := 13;
  constant N_SLV_PHI_EXTRAPOLATION_MEM_14: integer := 14;
  constant N_SLV_PHI_EXTRAPOLATION_MEM_15: integer := 15;
  constant N_SLV_PHI_EXTRAPOLATION_MEM_16: integer := 16;
  constant N_SLV_PHI_EXTRAPOLATION_MEM_17: integer := 17;
  constant N_SLV_PHI_EXTRAPOLATION_MEM_18: integer := 18;
  constant N_SLV_PHI_EXTRAPOLATION_MEM_19: integer := 19;
  constant N_SLV_PHI_EXTRAPOLATION_MEM_20: integer := 20;
  constant N_SLV_PHI_EXTRAPOLATION_MEM_21: integer := 21;
  constant N_SLV_PHI_EXTRAPOLATION_MEM_22: integer := 22;
  constant N_SLV_PHI_EXTRAPOLATION_MEM_23: integer := 23;
  constant N_SLV_PHI_EXTRAPOLATION_MEM_24: integer := 24;
  constant N_SLV_PHI_EXTRAPOLATION_MEM_25: integer := 25;
  constant N_SLV_PHI_EXTRAPOLATION_MEM_26: integer := 26;
  constant N_SLV_PHI_EXTRAPOLATION_MEM_27: integer := 27;
  constant N_SLV_PHI_EXTRAPOLATION_MEM_28: integer := 28;
  constant N_SLV_PHI_EXTRAPOLATION_MEM_29: integer := 29;
  constant N_SLV_PHI_EXTRAPOLATION_MEM_30: integer := 30;
  constant N_SLV_PHI_EXTRAPOLATION_MEM_31: integer := 31;
  constant N_SLV_PHI_EXTRAPOLATION_MEM_32: integer := 32;
  constant N_SLV_PHI_EXTRAPOLATION_MEM_33: integer := 33;
  constant N_SLV_PHI_EXTRAPOLATION_MEM_34: integer := 34;
  constant N_SLV_PHI_EXTRAPOLATION_MEM_35: integer := 35;
  constant N_SLAVES: integer := 36;
-- END automatically generated VHDL

    
end ipbus_decode_extrapolation_phi;

package body ipbus_decode_extrapolation_phi is

  function ipbus_sel_extrapolation_phi(addr : in std_logic_vector(31 downto 0)) return ipbus_sel_t is
    variable sel: ipbus_sel_t;
  begin

-- START automatically  generated VHDL the Sat Apr 18 14:46:27 2015 
    if    std_match(addr, "------------000000--------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_PHI_EXTRAPOLATION_MEM_0, IPBUS_SEL_WIDTH)); -- phi_extrapolation_mem_0 / base 0x00000000 / mask 0x000fc000
    elsif std_match(addr, "------------000001--------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_PHI_EXTRAPOLATION_MEM_1, IPBUS_SEL_WIDTH)); -- phi_extrapolation_mem_1 / base 0x00004000 / mask 0x000fc000
    elsif std_match(addr, "------------000010--------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_PHI_EXTRAPOLATION_MEM_2, IPBUS_SEL_WIDTH)); -- phi_extrapolation_mem_2 / base 0x00008000 / mask 0x000fc000
    elsif std_match(addr, "------------000011--------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_PHI_EXTRAPOLATION_MEM_3, IPBUS_SEL_WIDTH)); -- phi_extrapolation_mem_3 / base 0x0000c000 / mask 0x000fc000
    elsif std_match(addr, "------------000100--------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_PHI_EXTRAPOLATION_MEM_4, IPBUS_SEL_WIDTH)); -- phi_extrapolation_mem_4 / base 0x00010000 / mask 0x000fc000
    elsif std_match(addr, "------------000101--------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_PHI_EXTRAPOLATION_MEM_5, IPBUS_SEL_WIDTH)); -- phi_extrapolation_mem_5 / base 0x00014000 / mask 0x000fc000
    elsif std_match(addr, "------------000110--------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_PHI_EXTRAPOLATION_MEM_6, IPBUS_SEL_WIDTH)); -- phi_extrapolation_mem_6 / base 0x00018000 / mask 0x000fc000
    elsif std_match(addr, "------------000111--------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_PHI_EXTRAPOLATION_MEM_7, IPBUS_SEL_WIDTH)); -- phi_extrapolation_mem_7 / base 0x0001c000 / mask 0x000fc000
    elsif std_match(addr, "------------001000--------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_PHI_EXTRAPOLATION_MEM_8, IPBUS_SEL_WIDTH)); -- phi_extrapolation_mem_8 / base 0x00020000 / mask 0x000fc000
    elsif std_match(addr, "------------001001--------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_PHI_EXTRAPOLATION_MEM_9, IPBUS_SEL_WIDTH)); -- phi_extrapolation_mem_9 / base 0x00024000 / mask 0x000fc000
    elsif std_match(addr, "------------001010--------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_PHI_EXTRAPOLATION_MEM_10, IPBUS_SEL_WIDTH)); -- phi_extrapolation_mem_10 / base 0x00028000 / mask 0x000fc000
    elsif std_match(addr, "------------001011--------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_PHI_EXTRAPOLATION_MEM_11, IPBUS_SEL_WIDTH)); -- phi_extrapolation_mem_11 / base 0x0002c000 / mask 0x000fc000
    elsif std_match(addr, "------------001100--------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_PHI_EXTRAPOLATION_MEM_12, IPBUS_SEL_WIDTH)); -- phi_extrapolation_mem_12 / base 0x00030000 / mask 0x000fc000
    elsif std_match(addr, "------------001101--------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_PHI_EXTRAPOLATION_MEM_13, IPBUS_SEL_WIDTH)); -- phi_extrapolation_mem_13 / base 0x00034000 / mask 0x000fc000
    elsif std_match(addr, "------------001110--------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_PHI_EXTRAPOLATION_MEM_14, IPBUS_SEL_WIDTH)); -- phi_extrapolation_mem_14 / base 0x00038000 / mask 0x000fc000
    elsif std_match(addr, "------------001111--------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_PHI_EXTRAPOLATION_MEM_15, IPBUS_SEL_WIDTH)); -- phi_extrapolation_mem_15 / base 0x0003c000 / mask 0x000fc000
    elsif std_match(addr, "------------010000--------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_PHI_EXTRAPOLATION_MEM_16, IPBUS_SEL_WIDTH)); -- phi_extrapolation_mem_16 / base 0x00040000 / mask 0x000fc000
    elsif std_match(addr, "------------010001--------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_PHI_EXTRAPOLATION_MEM_17, IPBUS_SEL_WIDTH)); -- phi_extrapolation_mem_17 / base 0x00044000 / mask 0x000fc000
    elsif std_match(addr, "------------010010--------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_PHI_EXTRAPOLATION_MEM_18, IPBUS_SEL_WIDTH)); -- phi_extrapolation_mem_18 / base 0x00048000 / mask 0x000fc000
    elsif std_match(addr, "------------010011--------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_PHI_EXTRAPOLATION_MEM_19, IPBUS_SEL_WIDTH)); -- phi_extrapolation_mem_19 / base 0x0004c000 / mask 0x000fc000
    elsif std_match(addr, "------------010100--------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_PHI_EXTRAPOLATION_MEM_20, IPBUS_SEL_WIDTH)); -- phi_extrapolation_mem_20 / base 0x00050000 / mask 0x000fc000
    elsif std_match(addr, "------------010101--------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_PHI_EXTRAPOLATION_MEM_21, IPBUS_SEL_WIDTH)); -- phi_extrapolation_mem_21 / base 0x00054000 / mask 0x000fc000
    elsif std_match(addr, "------------010110--------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_PHI_EXTRAPOLATION_MEM_22, IPBUS_SEL_WIDTH)); -- phi_extrapolation_mem_22 / base 0x00058000 / mask 0x000fc000
    elsif std_match(addr, "------------010111--------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_PHI_EXTRAPOLATION_MEM_23, IPBUS_SEL_WIDTH)); -- phi_extrapolation_mem_23 / base 0x0005c000 / mask 0x000fc000
    elsif std_match(addr, "------------011000--------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_PHI_EXTRAPOLATION_MEM_24, IPBUS_SEL_WIDTH)); -- phi_extrapolation_mem_24 / base 0x00060000 / mask 0x000fc000
    elsif std_match(addr, "------------011001--------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_PHI_EXTRAPOLATION_MEM_25, IPBUS_SEL_WIDTH)); -- phi_extrapolation_mem_25 / base 0x00064000 / mask 0x000fc000
    elsif std_match(addr, "------------011010--------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_PHI_EXTRAPOLATION_MEM_26, IPBUS_SEL_WIDTH)); -- phi_extrapolation_mem_26 / base 0x00068000 / mask 0x000fc000
    elsif std_match(addr, "------------011011--------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_PHI_EXTRAPOLATION_MEM_27, IPBUS_SEL_WIDTH)); -- phi_extrapolation_mem_27 / base 0x0006c000 / mask 0x000fc000
    elsif std_match(addr, "------------011100--------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_PHI_EXTRAPOLATION_MEM_28, IPBUS_SEL_WIDTH)); -- phi_extrapolation_mem_28 / base 0x00070000 / mask 0x000fc000
    elsif std_match(addr, "------------011101--------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_PHI_EXTRAPOLATION_MEM_29, IPBUS_SEL_WIDTH)); -- phi_extrapolation_mem_29 / base 0x00074000 / mask 0x000fc000
    elsif std_match(addr, "------------011110--------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_PHI_EXTRAPOLATION_MEM_30, IPBUS_SEL_WIDTH)); -- phi_extrapolation_mem_30 / base 0x00078000 / mask 0x000fc000
    elsif std_match(addr, "------------011111--------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_PHI_EXTRAPOLATION_MEM_31, IPBUS_SEL_WIDTH)); -- phi_extrapolation_mem_31 / base 0x0007c000 / mask 0x000fc000
    elsif std_match(addr, "------------100000--------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_PHI_EXTRAPOLATION_MEM_32, IPBUS_SEL_WIDTH)); -- phi_extrapolation_mem_32 / base 0x00080000 / mask 0x000fc000
    elsif std_match(addr, "------------100001--------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_PHI_EXTRAPOLATION_MEM_33, IPBUS_SEL_WIDTH)); -- phi_extrapolation_mem_33 / base 0x00084000 / mask 0x000fc000
    elsif std_match(addr, "------------100010--------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_PHI_EXTRAPOLATION_MEM_34, IPBUS_SEL_WIDTH)); -- phi_extrapolation_mem_34 / base 0x00088000 / mask 0x000fc000
    elsif std_match(addr, "------------100011--------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_PHI_EXTRAPOLATION_MEM_35, IPBUS_SEL_WIDTH)); -- phi_extrapolation_mem_35 / base 0x0008c000 / mask 0x000fc000
-- END automatically generated VHDL

    else
        sel := ipbus_sel_t(to_unsigned(N_SLAVES, IPBUS_SEL_WIDTH));
    end if;

    return sel;

  end function ipbus_sel_extrapolation_phi;

end ipbus_decode_extrapolation_phi;

