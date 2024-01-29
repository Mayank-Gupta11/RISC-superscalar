library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Issue_buffer_LS is
port(clock,reset,issued: in std_logic;
	imm_in,PC_ls: in std_logic_vector(15 downto 0);
	RF_L_D: in std_logic_vector(31 downto 0);
	mem_ctrl: in std_logic_vector(1 downto 0);
	RegA,RegB,imm_out,PC_out: out std_logic_vector(15 downto 0);
	mem_wrt,mem_rd ,issue: out std_logic
);
end entity Issue_buffer_LS;

architecture behav of Issue_buffer_LS is
 signal reg: std_logic_vector(66 downto 0):= (others => '0');
begin
	
process(clock,reset,issued,imm_in,PC_ls,RF_L_D,mem_ctrl)
 begin
	if reset='1' then 
 		reg <= (others=>'0');
 	elsif falling_edge(clock) then
 		reg(1 downto 0) <= mem_ctrl;
		reg(33 downto 2) <= RF_L_D;
		reg(49 downto 34) <= PC_ls;
		reg(65 downto 50) <= imm_in;
		reg(66) <= issued;
	end if;
end process;

RegA <= reg(33 downto 18);
RegB <= reg(17 downto 2);
imm_out <= reg(65 downto 50);
PC_out <= reg(49 downto 34);
mem_wrt <= reg(1);
mem_rd <= reg(0);
issue <= reg(66);

end architecture behav; 