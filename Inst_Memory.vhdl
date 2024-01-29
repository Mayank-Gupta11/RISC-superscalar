--Aaryan

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Inst_Memory is 
port(clock: in std_logic;
    addr: in std_logic_vector(15 downto 0);  
    IM_output: out std_logic_vector(31 downto 0));
end entity;

architecture behav of Inst_Memory is 
    type mem_arr is array(0 to 31) of std_logic_vector(7 downto 0);
    signal PCH1,PCL1,PCH2,PCL2: std_logic_vector(7 downto 0);
constant instructions:mem_arr := (
    -- 0 => "00001101", --PCH
    -- 1 => "11000010", --PCL
    -- 2 => "00001011", --PCH
    -- 3 => "11000001", --PCL
    -- 4 => "00011111", --PCH
    0 => "00010010", --PCH
    1 => "10111000", --PCL
    2 => "00010111", --PCH
    3 => "00110000", --PCL
    4 => "11100000", --PCH
    5 => "10101000", --PCL
    6 => "00011001", --PCH
    7 => "10101000", --PCL
    8 => "00010111", --PCH
    9 => "10101000", --PCL
    10 => "00010101", --PCH
    11 => "01110000", --PCL
    12 => "00010011", --PCH
    13 => "01110000", --PCL
	 others=>"11100000");
signal new_add: std_logic_vector(15 downto 0):= "0000000000000000";
signal IM_output_1:std_logic_vector(15 downto 0);
signal IM_output_2:std_logic_vector(15 downto 0);
begin 
process(clock) 
begin
  if(rising_edge(clock)) then
    new_add(3 downto 0) <= addr(3 downto 0);
    new_add(15 downto 4) <= "000000000000";
    PCH1 <= instructions(to_integer(unsigned(new_add)));
    PCL1 <= instructions(to_integer(unsigned(new_add))+1);
    IM_output_1 <= PCH1 & PCL1;
    PCH2 <= instructions(to_integer(unsigned(new_add))+2);
    PCL2 <= instructions(to_integer(unsigned(new_add))+3);
    IM_output_2 <= PCH2 & PCL2;
    IM_output <= IM_output_1 & IM_output_2;
  end if;
end process;
end behav;

