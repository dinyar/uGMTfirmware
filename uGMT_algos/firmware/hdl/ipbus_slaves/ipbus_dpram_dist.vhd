-- ipbus_dpram_dist
--
-- Dual-port (one input, two outputs) RAM that should synthesise as distributed
-- RAM. Requires data file with one value per line in hexadecimal notation (no
-- '0x' though) for initialization.
--
-- Modelled after ipbus_dpram core by D. Newbold.
--
-- Note the wait state on ipbus access - full speed access is not possible
-- Can combine with peephole_ram access method for full speed access.
--
-- Dinyar Rabady, March 2015

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.ipbus.all;

use STD.TEXTIO.all;
use ieee.std_logic_textio.all;

entity ipbus_dpram_dist is
	generic(
	    DATA_FILE: string;
		ADDR_WIDTH: natural;
		WORD_WIDTH: natural := 32
	);
	port(
		clk: in std_logic;
		ipb_in: in ipb_wbus;
		ipb_out: out ipb_rbus;
		rclk: in std_logic;
		q: out std_logic_vector(WORD_WIDTH - 1 downto 0);
		addr: in std_logic_vector(ADDR_WIDTH - 1 downto 0)
	);

end ipbus_dpram_dist;

architecture rtl of ipbus_dpram_dist is

	-- Direction of array important to make first word in data file correspond
	-- to first address.
	type ram_array is array(0 to 2 ** ADDR_WIDTH - 1) of std_logic_vector(WORD_WIDTH - 1 downto 0);

    impure function InitRamFromFile (file_name : in string) return ram_array is
        file F : text open read_mode is file_name;
        variable L : line;
        variable ram : ram_array;
    begin
        for i in ram_array'range loop
            readline (F, L);
            read (L, ram(i));
        end loop;
        return ram;
    end function;

	shared variable ram: ram_array := InitRamFromFile(DATA_FILE);
    attribute ram_style : string;
	attribute ram_style of ram : variable is "distributed";

	signal sel, rsel: integer range 0 to 2 ** ADDR_WIDTH - 1 := 0;
	signal ack: std_logic;

    signal reduced_ipbus_in, reduced_ipbus_out : std_logic_vector(WORD_WIDTH - 1 downto 0);

begin

	sel <= to_integer(unsigned(ipb_in.ipb_addr(ADDR_WIDTH - 1 downto 0)));
	reduced_ipbus_in <= ipb_in.ipb_wdata(WORD_WIDTH - 1 downto 0);

	process(clk)
	begin
		if rising_edge(clk) then
			reduced_ipbus_out <= ram(sel); -- Order of statements is important to infer read-first RAM!
			if ipb_in.ipb_strobe='1' and ipb_in.ipb_write='1' then
				ram(sel) := reduced_ipbus_in;
			end if;
			ack <= ipb_in.ipb_strobe and not ack;
		end if;
	end process;

	ipb_out.ipb_rdata(WORD_WIDTH - 1 downto 0) <= reduced_ipbus_out;
	ipb_out.ipb_ack <= ack;
	ipb_out.ipb_err <= '0';

	rsel <= to_integer(unsigned(addr));

	process(rclk)
	begin
		if rising_edge(rclk) then
			q <= ram(rsel);
		end if;
	end process;


end rtl;
