	library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PCF is

port(clock,reset: in std_logic;
		WR_Tags : in std_logic_vector(11 downto 0);
		WR_CYs : in std_logic_vector(1 downto 0);
		WR_EN : in std_logic_vector(1 downto 0);
		valid_en : in std_logic_vector(1 downto 0);
		Retire_en : in std_logic_vector(1 downto 0);
		retire_valid : in std_logic_vector(1 downto 0);
		RD_Tags : in std_logic_vector(11 downto 0);
		opr_carry : in std_logic_vector(5 downto 0);
		Retire_hd: in std_logic_vector(11 downto 0);
		Retire_tag : in std_logic_vector(11 downto 0);

		carry_valid : out std_logic;
		CY_out1 : out std_logic;
		CY_out0 : out std_logic
		);
end entity;

architecture behav of PCF is
	
type reg is array(0 to 63) of std_logic;

signal reg_file: reg:=(others=>'0');
signal valid: std_logic_vector(63 downto 0);
begin

process(clock,reset,reg_file)
begin
	if reset='1' then 
		reg_file <= (others=>'0');
		valid <= (others=>'0');
		
	elsif falling_edge(clock) then
		if WR_EN(0)='1' then
			reg_file(to_integer(unsigned(WR_Tags(5 downto 0)))) <= WR_CYs(0);
			if valid_en(0)='1' then
				valid(to_integer(unsigned(WR_Tags(5 downto 0)))) <= '1';
			else
				valid(to_integer(unsigned(WR_Tags(5 downto 0)))) <= '0';
			end if;	
		end if;
		
		if WR_EN(1)='1' then
			reg_file(to_integer(unsigned(WR_Tags(11 downto 6)))) <= WR_CYs(1);
			if valid_en(1)='1' then
				valid(to_integer(unsigned(WR_Tags(11 downto 6)))) <= '1';
			else
				valid(to_integer(unsigned(WR_Tags(11 downto 6)))) <= '0';
			end if;
		end if;
		
		-- Retire
		if Retire_en(0)='1' then
			valid(to_integer(unsigned(Retire_hd(5 downto 0)))) <= '0';
			if retire_valid(0)='1' then
				valid(to_integer(unsigned(Retire_tag(5 downto 0)))) <= '1';
			end if;
				
		end if;

		if Retire_en(1)='1' then
			valid(to_integer(unsigned(Retire_hd(11 downto 6)))) <= '0';
			if retire_valid(1)='1' then
				valid(to_integer(unsigned(Retire_tag(11 downto 6)))) <= '1';
			end if;
		end if;

	end if;
	
end process;

--process(rf_a1,rf_a2,reg_file)
--begin
process(clock)
begin
	if falling_edge(clock) then
		CY_out0 <= reg_file(to_integer(unsigned(RD_Tags(5 downto 0))));
		CY_out1 <= reg_file(to_integer(unsigned(RD_Tags(11 downto 6))));
		carry_valid<= valid(to_integer(unsigned(opr_carry)));
	end if;

end process;
-- process(reg_file)
-- begin 
--     report "R1--------------------->"&integer'image(to_integer(unsigned(reg_file(1))));
--     report "R2--------------------->"&integer'image(to_integer(unsigned(reg_file(2))));
--     report "R3--------------------->"&integer'image(to_integer(unsigned(reg_file(3))));
--     report "R4--------------------->"&integer'image(to_integer(unsigned(reg_file(4))));
--     report "R5--------------------->"&integer'image(to_integer(unsigned(reg_file(5))));
--     report "R6--------------------->"&integer'image(to_integer(unsigned(reg_file(6))));
--     report "R7--------------------->"&integer'image(to_integer(unsigned(reg_file(7))));
--     report "PC--------------------->"&integer'image(to_integer(unsigned(reg_file(0))));

-- end process;

end architecture behav; 