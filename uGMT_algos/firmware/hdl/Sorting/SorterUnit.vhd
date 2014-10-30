library ieee;
use ieee.std_logic_1164.all;
use ieee.NUMERIC_STD.all;
use work.GMTTypes.all;
--

package SorterUnit is
  -- Greater-Equal Matrix 
  type TGEMatrix18 is array (integer range 17 downto 0, integer range 17 downto 0) of std_logic;
  type TGEMatrix24 is array (integer range 23 downto 0, integer range 23 downto 0) of std_logic;
  type TGEMatrix32 is array (integer range 31 downto 0, integer range 31 downto 0) of std_logic;
  type TGEMatrix36 is array (integer range 35 downto 0, integer range 35 downto 0) of std_logic;
  
  procedure count_wins18 (
    iGEMatrix       : in  TGEMatrix18;
    iEmpty          : in  std_logic_vector(17 downto 0);
    signal oSelBits : out TSelBits_1_of_18_vec);

  procedure count_wins24 (
    iGEMatrix       : in  TGEMatrix24;
    iEmpty          : in  std_logic_vector(23 downto 0);
    signal oSelBits : out TSelBits_1_of_24_vec);

  procedure count_wins32 (
    iGEMatrix       : in  TGEMatrix32;
    iEmpty          : in  std_logic_vector(31 downto 0);
    signal oSelBits : out TSelBits_1_of_32_vec);

  procedure count_wins36 (
    iGEMatrix       : in  TGEMatrix36;
    iEmpty          : in  std_logic_vector(35 downto 0);
    signal oSelBits : out TSelBits_1_of_36_vec);

end SorterUnit;

package body SorterUnit is

  procedure count_wins18 (
    iGEMatrix       : in  TGEMatrix18;
    iEmpty          : in  std_logic_vector(17 downto 0);
    signal oSelBits : out TSelBits_1_of_18_vec) is

    variable nwin : integer range 0 to 18;
  begin  -- procedure count_wins18
    for i in 0 to 17 loop
      nwin := 0;
      for j in 0 to 17 loop
        if i /= j then
          if iGEMatrix(i, j) = '1' or iEmpty(j) = '1' then
            nwin := nwin + 1;
          end if;
        end if;
      end loop;  -- j
      if iEmpty(i) = '0' then
        for iplace in oSelBits'range loop
          if nwin = 17-iplace then
            oSelBits(iplace)(i) <= '1';
          else
            oSelBits(iplace)(i) <= '0';
          end if;
        end loop;  -- iplace
      else
        for iplace in oSelBits'range loop
          oSelBits(iplace)(i) <= '0';
        end loop;  -- iplace
      end if;
    end loop;  -- i
  end;

  procedure count_wins24 (
    iGEMatrix       : in  TGEMatrix24;
    iEmpty          : in  std_logic_vector(23 downto 0);
    signal oSelBits : out TSelBits_1_of_24_vec) is

    variable nwin : integer range 0 to 24;
  begin  -- procedure count_wins24
    for i in 0 to 23 loop
      nwin := 0;
      for j in 0 to 23 loop
        if i /= j then
          if iGEMatrix(i, j) = '1' or iEmpty(j) = '1' then
            nwin := nwin + 1;
          end if;
        end if;
      end loop;  -- j
      if iEmpty(i) = '0' then
        for iplace in oSelBits'range loop
          if nwin = 23-iplace then
            oSelBits(iplace)(i) <= '1';
          else
            oSelBits(iplace)(i) <= '0';
          end if;
        end loop;  -- iplace
      else
        for iplace in oSelBits'range loop
          oSelBits(iplace)(i) <= '0';
        end loop;  -- iplace
      end if;
    end loop;  -- i
  end;
  
  procedure count_wins32 (
    iGEMatrix       : in  TGEMatrix32;
    iEmpty          : in  std_logic_vector(31 downto 0);
    signal oSelBits : out TSelBits_1_of_32_vec) is

    variable nwin : integer range 0 to 31;
  begin  -- procedure count_wins32
    for i in 0 to 31 loop
      nwin := 0;
      for j in 0 to 31 loop
        if i /= j then
          if iGEMatrix(i, j) = '1' or iEmpty(j) = '1' then
            nwin := nwin + 1;
          end if;
        end if;
      end loop;  -- j
      if iEmpty(i) = '0' then
        for iplace in oSelBits'range loop
          if nwin = 31-iplace then
            oSelBits(iplace)(i) <= '1';
          else
            oSelBits(iplace)(i) <= '0';
          end if;
        end loop;  -- iplace
      else
        for iplace in oSelBits'range loop
          oSelBits(iplace)(i) <= '0';
        end loop;  -- iplace
      end if;
    end loop;  -- i
  end;

  procedure count_wins36 (
    iGEMatrix       : in  TGEMatrix36;
    iEmpty          : in  std_logic_vector(35 downto 0);
    signal oSelBits : out TSelBits_1_of_36_vec) is

    variable nwin : integer range 0 to 35;
  begin  -- procedure count_wins36
    for i in 0 to 35 loop
      nwin := 0;
      for j in 0 to 35 loop
        if i /= j then
          if iGEMatrix(i, j) = '1' or iEmpty(j) = '1' then
            nwin := nwin + 1;
          end if;
        end if;
      end loop;  -- j
      if iEmpty(i) = '0' then
        for iplace in oSelBits'range loop
          if nwin = 35-iplace then
            oSelBits(iplace)(i) <= '1';
          else
            oSelBits(iplace)(i) <= '0';
          end if;
        end loop;  -- iplace
      else
        for iplace in oSelBits'range loop
          oSelBits(iplace)(i) <= '0';
        end loop;  -- iplace
      end if;
    end loop;  -- i
  end;
end package body SorterUnit;

