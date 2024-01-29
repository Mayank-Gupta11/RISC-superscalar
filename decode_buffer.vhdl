library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity decode_buffer is 
	port(clock,reset,wr_en: in std_logic;
		--br_en
		PC_in : in std_logic_vector(15 downto 0);
		Inst_in: in std_logic_vector(31 downto 0);
	    Inst_out: out std_logic_vector(31 downto 0);
		PC_out  : out std_logic_vector(15 downto 0)
		);
end entity decode_buffer;

architecture behav of decode_buffer is
	
 signal reg: std_logic_vector(47 downto 0):=(others => '0');   --"00000000000000001110101010101010";
begin
	
process(clock,reset,PC_in,Inst_in,wr_en)
 begin
	if reset='1' then 
 		reg <= (others => '0');  --"00000000000000001110101010101010";
 	elsif falling_edge(clock) and wr_en='1' then
		reg(47 downto 32) <= PC_in;
		-- if br_en = '0' then
		-- 	reg(15 downto 0) <= Inst_in;
		-- else
			reg(31 downto 0) <= Inst_in;
		-- end if; 
	end if;
end process ;

Inst_out <= reg(31 downto 0);
PC_out <= reg(47 downto 32);

end architecture behav; 