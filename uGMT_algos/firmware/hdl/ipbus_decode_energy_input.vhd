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

package ipbus_decode_energy_input is

  constant IPBUS_SEL_WIDTH: positive := 5; -- Should be enough for now?
  subtype ipbus_sel_t is std_logic_vector(IPBUS_SEL_WIDTH - 1 downto 0);
  function ipbus_sel_energy_input(addr : in std_logic_vector(31 downto 0)) return ipbus_sel_t;

-- START automatically  generated VHDL the Mon Sep 14 23:45:35 2015 
  constant N_SLV_ENERGY_QUAD_0: integer := 0;
  constant N_SLV_ENERGY_QUAD_1: integer := 1;
  constant N_SLV_ENERGY_QUAD_2: integer := 2;
  constant N_SLV_ENERGY_QUAD_3: integer := 3;
  constant N_SLV_ENERGY_QUAD_4: integer := 4;
  constant N_SLV_ENERGY_QUAD_5: integer := 5;
  constant N_SLV_ENERGY_QUAD_6: integer := 6;
  constant N_SLAVES: integer := 7;
-- END automatically generated VHDL

    
end ipbus_decode_energy_input;

package body ipbus_decode_energy_input is

  function ipbus_sel_energy_input(addr : in std_logic_vector(31 downto 0)) return ipbus_sel_t is
    variable sel: ipbus_sel_t;
  begin

-- START automatically  generated VHDL the Mon Sep 14 23:45:35 2015 
    if    std_match(addr, "-------------000----------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_ENERGY_QUAD_0, IPBUS_SEL_WIDTH)); -- energy_quad_0 / base 0x00000000 / mask 0x00070000
    elsif std_match(addr, "-------------001----------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_ENERGY_QUAD_1, IPBUS_SEL_WIDTH)); -- energy_quad_1 / base 0x00010000 / mask 0x00070000
    elsif std_match(addr, "-------------010----------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_ENERGY_QUAD_2, IPBUS_SEL_WIDTH)); -- energy_quad_2 / base 0x00020000 / mask 0x00070000
    elsif std_match(addr, "-------------011----------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_ENERGY_QUAD_3, IPBUS_SEL_WIDTH)); -- energy_quad_3 / base 0x00030000 / mask 0x00070000
    elsif std_match(addr, "-------------100----------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_ENERGY_QUAD_4, IPBUS_SEL_WIDTH)); -- energy_quad_4 / base 0x00040000 / mask 0x00070000
    elsif std_match(addr, "-------------101----------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_ENERGY_QUAD_5, IPBUS_SEL_WIDTH)); -- energy_quad_5 / base 0x00050000 / mask 0x00070000
    elsif std_match(addr, "-------------110----------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_ENERGY_QUAD_6, IPBUS_SEL_WIDTH)); -- energy_quad_6 / base 0x00060000 / mask 0x00070000
-- END automatically generated VHDL

    else
        sel := ipbus_sel_t(to_unsigned(N_SLAVES, IPBUS_SEL_WIDTH));
    end if;

    return sel;

  end function ipbus_sel_energy_input;

end ipbus_decode_energy_input;

