library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity adder_16 is
    port(
    inp_a: in std_logic_vector(15 downto 0);
    adder_out: out std_logic_vector(15 downto 0);
    inp_b: in std_logic_vector(15 downto 0));
end entity;

architecture behav of adder_16 is
    
begin
    
   adder_16: process(inp_a,inp_b)
   variable temp_out, temp_a, temp_b : std_logic_vector(15 downto 0);
   begin
    temp_out := (others => '0');
        temp_a(15 downto 0) := inp_a;
        temp_b(15 downto 0) := inp_b;
        -- temp_a(16) := '0';
        -- temp_b(16) := '0';
        temp_out := std_logic_vector(unsigned(temp_a)+unsigned(temp_b)); 
     adder_out<= temp_out(15 downto 0);
   end process adder_16 ;
    
end architecture behav;

library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity adder_3 is
    port(
    inp_a: in std_logic_vector(2 downto 0);
    adder_out: out std_logic_vector(2 downto 0);
    inp_b: in std_logic_vector(2 downto 0));
end entity;

architecture behav of adder_3 is
    
begin
    
   adder_16: process(inp_a,inp_b)
   variable temp_out, temp_a, temp_b : std_logic_vector(2 downto 0);
   begin
    temp_out := (others => '0');
        temp_a(2 downto 0) := inp_a;
        temp_b(2 downto 0) := inp_b;
        -- temp_a(16) := '0';
        -- temp_b(16) := '0';
        temp_out := std_logic_vector(unsigned(temp_a)+unsigned(temp_b)); 
     adder_out<= temp_out(2 downto 0);
   end process adder_16 ;
    
end architecture behav;