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

package ipbus_decode_ugmt_serdes is

  constant IPBUS_SEL_WIDTH: positive := 5; -- Should be enough for now?
  subtype ipbus_sel_t is std_logic_vector(IPBUS_SEL_WIDTH - 1 downto 0);
  function ipbus_sel_ugmt_serdes(addr : in std_logic_vector(31 downto 0)) return ipbus_sel_t;

-- START automatically  generated VHDL the Tue May  5 23:34:42 2015 
  constant N_SLV_MU_DESERIALIZATION: integer := 0;
  constant N_SLV_ENERGY_DESERIALIZATION: integer := 1;
  constant N_SLV_UGMT: integer := 2;
  constant N_SLV_INPUT_DISABLE_REG: integer := 3;
  constant N_SLAVES: integer := 4;
-- END automatically generated VHDL

    
end ipbus_decode_ugmt_serdes;

package body ipbus_decode_ugmt_serdes is

  function ipbus_sel_ugmt_serdes(addr : in std_logic_vector(31 downto 0)) return ipbus_sel_t is
    variable sel: ipbus_sel_t;
  begin

-- START automatically  generated VHDL the Tue May  5 23:34:42 2015 
    if    std_match(addr, "----00-----0--------------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_MU_DESERIALIZATION, IPBUS_SEL_WIDTH)); -- mu_deserialization / base 0x00000000 / mask 0x0c100000
    elsif std_match(addr, "----00-----1--------------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_ENERGY_DESERIALIZATION, IPBUS_SEL_WIDTH)); -- energy_deserialization / base 0x00100000 / mask 0x0c100000
    elsif std_match(addr, "----01--------------------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_UGMT, IPBUS_SEL_WIDTH)); -- ugmt / base 0x04000000 / mask 0x0c000000
    elsif std_match(addr, "----10-----0--------------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_INPUT_DISABLE_REG, IPBUS_SEL_WIDTH)); -- input_disable_reg / base 0x08000000 / mask 0x0c100000
-- END automatically generated VHDL

    else
        sel := ipbus_sel_t(to_unsigned(N_SLAVES, IPBUS_SEL_WIDTH));
    end if;

    return sel;

  end function ipbus_sel_ugmt_serdes;

end ipbus_decode_ugmt_serdes;

