library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adder_4 is
    port(
       -- clk: in std_logic;
        inp_a: in std_logic_vector(15 downto 0);
        adder_out: out std_logic_vector(15 downto 0)
    );
end entity;

architecture behav of adder_4 is

begin
    
    adder_4: process(inp_a) is
    constant temp_b : std_logic_vector(15 downto 0) := "0000000000000100";
    variable temp_out, temp_a : std_logic_vector(15 downto 0);
    begin
            temp_a := inp_a;
            temp_out := std_logic_vector(unsigned(temp_a) + unsigned(temp_b)); 
            adder_out <= temp_out ;
    end process adder_4 ;

end architecture behav;
