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

package ipbus_decode_cancel_out_fo_wedge is

  constant IPBUS_SEL_WIDTH: positive := 5; -- Should be enough for now?
  subtype ipbus_sel_t is std_logic_vector(IPBUS_SEL_WIDTH - 1 downto 0);
  function ipbus_sel_cancel_out_fo_wedge(addr : in std_logic_vector(31 downto 0)) return ipbus_sel_t;

-- START automatically  generated VHDL the Thu Jun  4 15:37:25 2015 
  constant N_SLV_CANCEL_OUT_MEMS_0: integer := 0;
  constant N_SLV_CANCEL_OUT_MEMS_1: integer := 1;
  constant N_SLV_CANCEL_OUT_MEMS_2: integer := 2;
  constant N_SLAVES: integer := 3;
-- END automatically generated VHDL

    
end ipbus_decode_cancel_out_fo_wedge;

package body ipbus_decode_cancel_out_fo_wedge is

  function ipbus_sel_cancel_out_fo_wedge(addr : in std_logic_vector(31 downto 0)) return ipbus_sel_t is
    variable sel: ipbus_sel_t;
  begin

-- START automatically  generated VHDL the Thu Jun  4 15:37:25 2015 
    if    std_match(addr, "-------------------00-----------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_CANCEL_OUT_MEMS_0, IPBUS_SEL_WIDTH)); -- cancel_out_mems_0 / base 0x00000000 / mask 0x00001800
    elsif std_match(addr, "-------------------01-----------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_CANCEL_OUT_MEMS_1, IPBUS_SEL_WIDTH)); -- cancel_out_mems_1 / base 0x00000800 / mask 0x00001800
    elsif std_match(addr, "-------------------10-----------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_CANCEL_OUT_MEMS_2, IPBUS_SEL_WIDTH)); -- cancel_out_mems_2 / base 0x00001000 / mask 0x00001800
-- END automatically generated VHDL

    else
        sel := ipbus_sel_t(to_unsigned(N_SLAVES, IPBUS_SEL_WIDTH));
    end if;

    return sel;

  end function ipbus_sel_cancel_out_fo_wedge;

end ipbus_decode_cancel_out_fo_wedge;

