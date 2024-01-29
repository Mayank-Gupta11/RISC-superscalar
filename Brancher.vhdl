library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity brancher is
	port(
	br_type: in std_logic_vector(1 downto 0);
    PC_en,C_flag,Z_flag: in std_logic;
	PC_src: out std_logic
	);
end entity brancher;

architecture behav of brancher is

begin
    process(br_type,PC_en,C_flag,Z_flag)
    begin
        if(br_type="00") then 
            PC_src <=PC_en;
        elsif(br_type="01") then
            if(Z_flag = '1') then
                PC_src <= '1'; 
            else PC_src <= '0';
            end if;
        elsif(br_type="10") then
            if(C_flag='1') then
                PC_src <= '1';
            else PC_src <= '0';
            end if;
        else
            if(C_flag = '1' or Z_flag = '1') then
                PC_src <= '1';
            else 
                PC_src <= '0';
            end if;
        end if;
        
    end process;
end architecture;