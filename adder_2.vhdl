library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adder_2 is
    port(
       -- clk: in std_logic;
        inp_a: in std_logic_vector(15 downto 0);
        adder_out: out std_logic_vector(15 downto 0)
    );
end entity;

architecture behav of adder_2 is

begin
    
    adder_2: process(inp_a) is
    constant temp_b : std_logic_vector(15 downto 0) := "0000000000000010";
    variable temp_out, temp_a : std_logic_vector(15 downto 0);
    begin
            temp_a := inp_a;
            temp_out := std_logic_vector(unsigned(temp_a) + unsigned(temp_b)); 
            adder_out <= temp_out ;
    end process adder_2 ;

end architecture behav;


-- library ieee;
-- use IEEE.std_logic_1164.all;
-- use IEEE.numeric_std.all;

-- entity adder_2 is
--     port(
--     inp_a: in std_logic_vector(15 downto 0);
--     adder_out: out std_logic_vector(15 downto 0));
-- end entity;

-- architecture behav of adder_2 is

-- signal temp_out, temp_a : std_logic_vector(15 downto 0);

-- begin
-- process(inp_a)
--    constant temp_b : std_logic_vector(15 downto 0) := "0000000000000010";
--    begin
--     temp_out <= (others => '0');
--         temp_a(15 downto 0) <= inp_a;
--         temp_out <= std_logic_vector(unsigned(temp_a)+unsigned(temp_b)); 
--      adder_out<= temp_out(15 downto 0);
--    end process;
-- end architecture behav;