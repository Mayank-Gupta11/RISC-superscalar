library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity left_shift1 is 
port(
    input: in std_logic_vector(15 downto 0);
    output: out std_logic_vector(15 downto 0));
end entity;

architecture behav of left_shift1 is 
begin
		output(15 downto 1) <= input(14 downto 0);
		output(0 downto 0) <= (others=>'0');
end behav;