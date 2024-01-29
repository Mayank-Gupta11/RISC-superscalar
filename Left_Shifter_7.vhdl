library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity left_shift7 is 
port(
    input: in std_logic_vector(8 downto 0);
    output: out std_logic_vector(15 downto 0));
end entity;

architecture behav of left_shift7 is 
begin
		output(15 downto 7) <= input;
		output(6 downto 0) <= (others=>'0');
end behav;

