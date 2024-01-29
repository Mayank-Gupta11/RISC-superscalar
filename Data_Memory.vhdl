library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Data_Memory is 
port(clock,wr_e,r_e,reset: in std_logic;
    data: in std_logic_vector(15 downto 0);
    ADDR: in std_logic_vector(15 downto 0);  
    outpu: out std_logic_vector(15 downto 0));
end entity;

architecture behav of Data_Memory is 
    type vector is array(0 to 31) of std_logic_vector(15 downto 0);

signal RAM:vector := (
    0=> "0000000000000000",
    1 => "0000000000000001",
    2 => "0000000000000010",
    3 => "0000000000000000",
    4 => "0000000000000100",
    others=>(others=>'0'));

begin 
    process(clock,ADDR,RAM,wr_e,reset)

        begin 
        if reset='1' then 
            RAM <= (others => (others => '0'));
        elsif falling_edge(clock) and wr_e='1' then 
            report "Mem_Data_3 -------> "&integer'image(to_integer(unsigned(RAM(3))));
            RAM(to_integer(unsigned(ADDR))) <= Data;
        end if;
end process;

process(clock,ADDR,RAM)

    variable temp_out : std_logic_vector(15 downto 0):= (others => '0');

begin
    if(rising_edge(clock)) then
        if to_integer(unsigned(ADDR)) < 32 then
            temp_out := RAM(to_integer(unsigned(ADDR)));
        else 
            temp_out := (others=>'0');
        end if;
    end if;
    outpu <= temp_out;

report "Mem_Data_out -------> "&integer'image(to_integer(unsigned(temp_out)));
end process;
end behav;

