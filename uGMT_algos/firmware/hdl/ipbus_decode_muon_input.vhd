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

package ipbus_decode_muon_input is

  constant IPBUS_SEL_WIDTH: positive := 5; -- Should be enough for now?
  subtype ipbus_sel_t is std_logic_vector(IPBUS_SEL_WIDTH - 1 downto 0);
  function ipbus_sel_muon_input(addr : in std_logic_vector(31 downto 0)) return ipbus_sel_t;

-- START automatically  generated VHDL the Thu Mar  3 03:05:20 2016 
  constant N_SLV_MU_QUAD_0: integer := 0;
  constant N_SLV_MU_QUAD_1: integer := 1;
  constant N_SLV_MU_QUAD_2: integer := 2;
  constant N_SLV_MU_QUAD_3: integer := 3;
  constant N_SLV_MU_QUAD_4: integer := 4;
  constant N_SLV_MU_QUAD_5: integer := 5;
  constant N_SLV_MU_QUAD_6: integer := 6;
  constant N_SLV_MU_QUAD_7: integer := 7;
  constant N_SLV_MU_QUAD_8: integer := 8;
  constant N_SLV_GEN_CALO_IDX_BITS_QUAD_0: integer := 9;
  constant N_SLV_GEN_CALO_IDX_BITS_QUAD_1: integer := 10;
  constant N_SLV_GEN_CALO_IDX_BITS_QUAD_2: integer := 11;
  constant N_SLV_GEN_CALO_IDX_BITS_QUAD_3: integer := 12;
  constant N_SLV_GEN_CALO_IDX_BITS_QUAD_4: integer := 13;
  constant N_SLV_GEN_CALO_IDX_BITS_QUAD_5: integer := 14;
  constant N_SLV_GEN_CALO_IDX_BITS_QUAD_6: integer := 15;
  constant N_SLV_GEN_CALO_IDX_BITS_QUAD_7: integer := 16;
  constant N_SLV_GEN_CALO_IDX_BITS_QUAD_8: integer := 17;
  constant N_SLAVES: integer := 18;
-- END automatically generated VHDL

    
end ipbus_decode_muon_input;

package body ipbus_decode_muon_input is

  function ipbus_sel_muon_input(addr : in std_logic_vector(31 downto 0)) return ipbus_sel_t is
    variable sel: ipbus_sel_t;
  begin

-- START automatically  generated VHDL the Thu Mar  3 03:05:20 2016 
    if    std_match(addr, "-------000000000----------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_MU_QUAD_0, IPBUS_SEL_WIDTH)); -- mu_quad_0 / base 0x00000000 / mask 0x01ff0000
    elsif std_match(addr, "-------000000001----------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_MU_QUAD_1, IPBUS_SEL_WIDTH)); -- mu_quad_1 / base 0x00010000 / mask 0x01ff0000
    elsif std_match(addr, "-------000000010----------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_MU_QUAD_2, IPBUS_SEL_WIDTH)); -- mu_quad_2 / base 0x00020000 / mask 0x01ff0000
    elsif std_match(addr, "-------000000011----------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_MU_QUAD_3, IPBUS_SEL_WIDTH)); -- mu_quad_3 / base 0x00030000 / mask 0x01ff0000
    elsif std_match(addr, "-------000000100----------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_MU_QUAD_4, IPBUS_SEL_WIDTH)); -- mu_quad_4 / base 0x00040000 / mask 0x01ff0000
    elsif std_match(addr, "-------000000101----------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_MU_QUAD_5, IPBUS_SEL_WIDTH)); -- mu_quad_5 / base 0x00050000 / mask 0x01ff0000
    elsif std_match(addr, "-------000000110----------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_MU_QUAD_6, IPBUS_SEL_WIDTH)); -- mu_quad_6 / base 0x00060000 / mask 0x01ff0000
    elsif std_match(addr, "-------000000111----------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_MU_QUAD_7, IPBUS_SEL_WIDTH)); -- mu_quad_7 / base 0x00070000 / mask 0x01ff0000
    elsif std_match(addr, "-------000001000----------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_MU_QUAD_8, IPBUS_SEL_WIDTH)); -- mu_quad_8 / base 0x00080000 / mask 0x01ff0000
    elsif std_match(addr, "-------00001000-----------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_GEN_CALO_IDX_BITS_QUAD_0, IPBUS_SEL_WIDTH)); -- gen_calo_idx_bits_quad_0 / base 0x00100000 / mask 0x01fe0000
    elsif std_match(addr, "-------00001001-----------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_GEN_CALO_IDX_BITS_QUAD_1, IPBUS_SEL_WIDTH)); -- gen_calo_idx_bits_quad_1 / base 0x00120000 / mask 0x01fe0000
    elsif std_match(addr, "-------00001010-----------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_GEN_CALO_IDX_BITS_QUAD_2, IPBUS_SEL_WIDTH)); -- gen_calo_idx_bits_quad_2 / base 0x00140000 / mask 0x01fe0000
    elsif std_match(addr, "-------00001011-----------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_GEN_CALO_IDX_BITS_QUAD_3, IPBUS_SEL_WIDTH)); -- gen_calo_idx_bits_quad_3 / base 0x00160000 / mask 0x01fe0000
    elsif std_match(addr, "-------00001100-----------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_GEN_CALO_IDX_BITS_QUAD_4, IPBUS_SEL_WIDTH)); -- gen_calo_idx_bits_quad_4 / base 0x00180000 / mask 0x01fe0000
    elsif std_match(addr, "-------01010000-----------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_GEN_CALO_IDX_BITS_QUAD_5, IPBUS_SEL_WIDTH)); -- gen_calo_idx_bits_quad_5 / base 0x00a00000 / mask 0x01fe0000
    elsif std_match(addr, "-------01100000-----------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_GEN_CALO_IDX_BITS_QUAD_6, IPBUS_SEL_WIDTH)); -- gen_calo_idx_bits_quad_6 / base 0x00c00000 / mask 0x01fe0000
    elsif std_match(addr, "-------01110000-----------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_GEN_CALO_IDX_BITS_QUAD_7, IPBUS_SEL_WIDTH)); -- gen_calo_idx_bits_quad_7 / base 0x00e00000 / mask 0x01fe0000
    elsif std_match(addr, "-------10000000-----------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_GEN_CALO_IDX_BITS_QUAD_8, IPBUS_SEL_WIDTH)); -- gen_calo_idx_bits_quad_8 / base 0x01000000 / mask 0x01fe0000
-- END automatically generated VHDL

    else
        sel := ipbus_sel_t(to_unsigned(N_SLAVES, IPBUS_SEL_WIDTH));
    end if;

    return sel;

  end function ipbus_sel_muon_input;

end ipbus_decode_muon_input;

