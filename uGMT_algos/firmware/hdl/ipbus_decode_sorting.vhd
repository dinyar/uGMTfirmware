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

package ipbus_decode_sorting is

  constant IPBUS_SEL_WIDTH: positive := 5; -- Should be enough for now?
  subtype ipbus_sel_t is std_logic_vector(IPBUS_SEL_WIDTH - 1 downto 0);
  function ipbus_sel_sorting(addr : in std_logic_vector(31 downto 0)) return ipbus_sel_t;

-- START automatically  generated VHDL the Thu Mar  3 03:05:20 2016 
  constant N_SLV_COU_BO_POS: integer := 0;
  constant N_SLV_COU_BO_NEG: integer := 1;
  constant N_SLV_COU_EO_POS: integer := 2;
  constant N_SLV_COU_EO_NEG: integer := 3;
  constant N_SLV_COU_OMTF_POS: integer := 4;
  constant N_SLV_COU_OMTF_NEG: integer := 5;
  constant N_SLV_COU_EMTF_POS: integer := 6;
  constant N_SLV_COU_EMTF_NEG: integer := 7;
  constant N_SLV_MUON_COUNTER_BMTF: integer := 8;
  constant N_SLV_MUON_COUNTER_OMTFP: integer := 9;
  constant N_SLV_MUON_COUNTER_OMTFN: integer := 10;
  constant N_SLV_MUON_COUNTER_EMTFP: integer := 11;
  constant N_SLV_MUON_COUNTER_EMTFN: integer := 12;
  constant N_SLAVES: integer := 13;
-- END automatically generated VHDL

    
end ipbus_decode_sorting;

package body ipbus_decode_sorting is

  function ipbus_sel_sorting(addr : in std_logic_vector(31 downto 0)) return ipbus_sel_t is
    variable sel: ipbus_sel_t;
  begin

-- START automatically  generated VHDL the Thu Mar  3 03:05:20 2016 
    if    std_match(addr, "------------0000----------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_COU_BO_POS, IPBUS_SEL_WIDTH)); -- cou_bo_pos / base 0x00000000 / mask 0x000f0000
    elsif std_match(addr, "------------0001----------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_COU_BO_NEG, IPBUS_SEL_WIDTH)); -- cou_bo_neg / base 0x00010000 / mask 0x000f0000
    elsif std_match(addr, "------------0010----------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_COU_EO_POS, IPBUS_SEL_WIDTH)); -- cou_eo_pos / base 0x00020000 / mask 0x000f0000
    elsif std_match(addr, "------------0011----------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_COU_EO_NEG, IPBUS_SEL_WIDTH)); -- cou_eo_neg / base 0x00030000 / mask 0x000f0000
    elsif std_match(addr, "------------0100----------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_COU_OMTF_POS, IPBUS_SEL_WIDTH)); -- cou_omtf_pos / base 0x00040000 / mask 0x000f0000
    elsif std_match(addr, "------------0101----------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_COU_OMTF_NEG, IPBUS_SEL_WIDTH)); -- cou_omtf_neg / base 0x00050000 / mask 0x000f0000
    elsif std_match(addr, "------------0110----------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_COU_EMTF_POS, IPBUS_SEL_WIDTH)); -- cou_emtf_pos / base 0x00060000 / mask 0x000f0000
    elsif std_match(addr, "------------0111----------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_COU_EMTF_NEG, IPBUS_SEL_WIDTH)); -- cou_emtf_neg / base 0x00070000 / mask 0x000f0000
    elsif std_match(addr, "------------1000-------------000") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_MUON_COUNTER_BMTF, IPBUS_SEL_WIDTH)); -- muon_counter_BMTF / base 0x00080000 / mask 0x000f0007
    elsif std_match(addr, "------------1000-------------001") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_MUON_COUNTER_OMTFP, IPBUS_SEL_WIDTH)); -- muon_counter_OMTFp / base 0x00080001 / mask 0x000f0007
    elsif std_match(addr, "------------1000-------------010") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_MUON_COUNTER_OMTFN, IPBUS_SEL_WIDTH)); -- muon_counter_OMTFn / base 0x00080002 / mask 0x000f0007
    elsif std_match(addr, "------------1000-------------011") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_MUON_COUNTER_EMTFP, IPBUS_SEL_WIDTH)); -- muon_counter_EMTFp / base 0x00080003 / mask 0x000f0007
    elsif std_match(addr, "------------1000-------------100") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_MUON_COUNTER_EMTFN, IPBUS_SEL_WIDTH)); -- muon_counter_EMTFn / base 0x00080004 / mask 0x000f0007
-- END automatically generated VHDL

    else
        sel := ipbus_sel_t(to_unsigned(N_SLAVES, IPBUS_SEL_WIDTH));
    end if;

    return sel;

  end function ipbus_sel_sorting;

end ipbus_decode_sorting;

