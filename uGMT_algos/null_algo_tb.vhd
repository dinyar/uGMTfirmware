library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench is
end testbench;

architecture behavior of testbench is

  constant half_period_240 : time      := 25000ps/12;
  constant half_period_40  : time      := 25000ps/2;
  signal   clk240          : std_logic := '0';
  signal   clk40           : std_logic := '0';
  signal   input           : ldata(NCHAN-1 downto 0);
  signal   output          : ldata(NCHAN-1 downto 0);

begin

  -- Component Instantiation
  uut : entity work.null_algo
    port map(
      clk240 => clk240,
      clk40  => clk40,
      d      => input,
      q      => output
      );

  -- Clocks
  clk240 <= not clk240 after half_period_240;
  clk40  <= not clk40  after half_period_40;

  --  Test Bench Statements
  tb : process
  begin

    -- Reset all variables
    for i in input'range loop
      input(i).data  <= (others => '0');
      input(i).valid <= (others => '0');
    end loop;  -- i

    wait for 250 ns;  -- wait until global set/reset completes    

    -- Add user defined stimulus here
    for i in input'range loop
      input(i).data  <= (others => '0');
      input(i).valid <= (others => '1');
    end loop;  -- i
 
    wait for 25 ns;
   for i in input'range loop
      input(i).data  <= (others => '1');
      input(i).valid <= (others => '1');
    end loop;  -- i
    wait for 25 ns;
    for i in input'range loop
      input(i).data  <= (others => '0');
      input(i).valid <= (others => '1');
    end loop;  -- i
 
    wait for 25 ns;
   for i in input'range loop
      input(i).data  <= (others => '1');
      input(i).valid <= (others => '1');
    end loop;  -- i
    wait for 25 ns;
    for i in input'range loop
      input(i).data  <= (others => '0');
      input(i).valid <= (others => '1');
    end loop;  -- i
 
    wait for 25 ns;
   for i in input'range loop
      input(i).data  <= (others => '1');
      input(i).valid <= (others => '1');
    end loop;  -- i
    wait for 25 ns;
    for i in input'range loop
      input(i).data  <= (others => '0');
      input(i).valid <= (others => '1');
    end loop;  -- i
 
    wait for 25 ns;
   for i in input'range loop
      input(i).data  <= (others => '1');
      input(i).valid <= (others => '1');
    end loop;  -- i
    wait for 25 ns;

    wait for 25 ns;
    wait for 25 ns;
    wait for 25 ns;
    wait for 25 ns;
    wait for 25 ns;
    wait for 25 ns;
    wait for 25 ns;
    
    wait;                               -- will wait forever
  end process tb;
  --  End Test Bench

end;
