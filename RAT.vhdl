--Mayank

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.SchedulerTypes.all;


entity RAT is

port(clock,reset: in std_logic;
		-- RD_OPR : in std_logic_vector(17 downto 0);         -- Read operands 2* operands(3bits) *3(int,int,load_store)
		-- OPR_EN : in std_logic_vector(5 downto 0);           -- 6 bits corresponds to 6 operands (2 in 3 each )
		-- WB_A : in std_logic_vector(5 downto 0);            -- destination bits for 2 different instructions
		assign_add : in std_logic_vector(5 downto 0);      -- 3 bits each , actual register value (0-8)
		-- Retire_en : in std_logic_vector(2 downto 0);           -- 0 if branch , 1 if write ..each write is independent 
		Retire_en : in std_logic_vector(1 downto 0);           -- 0 if branch , 1 if write ..each write is independent 
		RAT_en : in std_logic_vector(1 downto 0);          -- 
		Retire_reg : in std_logic_vector(5 downto 0);
		opr_reg1 : in std_logic_vector(5 downto 0);
		opr_reg2 : in std_logic_vector(5 downto 0);
		Retire_tag : in std_logic_vector(11 downto 0);
		
		opr_hd : out std_logic_vector(23 downto 0);
		hd_not_to_reset : out HeadArray(7 downto 0);
		-- CNT_WR_TAG : out std_logic_vector(11 downto 0);    -- current write TAG 
		cnt_head : out std_logic_vector(11 downto 0);      -- current Head 
		Retire_hd: out std_logic_vector(11 downto 0)
);
end entity;

architecture behav of RAT is
	
type reg is array(0 to 7) of std_logic_vector(5 downto 0);

signal reg_file: reg:=(
	0 => "000000",
	1 => "000001",
	2 => "000010",
	3 => "000011",
	4 => "000100",
	5 => "000100",
	6 => "000101",
	7 => "000111");
begin

process(clock,reset, assign_add, Retire_en, RAT_en, Retire_reg, opr_reg1, opr_reg2, Retire_tag)
begin
	if reset='1' then 
		reg_file <= (others=>(others=>'0'));

	elsif rising_edge(clock) then

		
		

		--Dispatch
		if RAT_en(1) ='1' then
			cnt_head(11 downto 6) <= reg_file(to_integer(unsigned(assign_add(5 downto 3))));
		end if;
		if RAT_en(0) ='1' then
			cnt_head(5 downto 0) <= reg_file(to_integer(unsigned(assign_add(2 downto 0))));
		end if;

		
		--Retire
		Retire_hd(11 downto 6) <= reg_file(to_integer(unsigned(Retire_reg(5 downto 3))));
		Retire_hd(5 downto 0) <= reg_file(to_integer(unsigned(Retire_reg(2 downto 0))));

		--Read operands
			
		opr_hd(23 downto 18) <= reg_file(to_integer(unsigned(opr_reg1(5 downto 3))));

		opr_hd(17 downto 12) <= reg_file(to_integer(unsigned(opr_reg1(2 downto 0))));

		opr_hd(11 downto 6) <= reg_file(to_integer(unsigned(opr_reg2(5 downto 3))));
		opr_hd(5 downto 0) <= reg_file(to_integer(unsigned(opr_reg2(2 downto 0))));

		
		L1: for i in 0 to 7 loop
			hd_not_to_reset(i) <= reg_file(i);
		end loop L1;
		
	elsif falling_edge(clock) then
		
		--Write Tags
		if Retire_en(1)='1' then
			reg_file(to_integer(unsigned(Retire_reg(5 downto 3)))) <= Retire_tag(11 downto 6);
			-- CNT_WR_TAG(11 downto 6) <= WB_A(5 downto 3);
		end if;
		if Retire_en(0)='1' then
			reg_file(to_integer(unsigned(Retire_reg(2 downto 0)))) <= Retire_tag(5 downto 0);
			-- CNT_WR_TAG(5 downto 0) <= WB_A(2 downto 0);
		end if;
		
	end if;
	
end process;


-- process(reg_file)
-- begin 
    -- report "R1--------------------->"&integer'image(to_integer(unsigned(reg_file(1))));
    -- report "R2--------------------->"&integer'image(to_integer(unsigned(reg_file(2))));
    -- report "R3--------------------->"&integer'image(to_integer(unsigned(reg_file(3))));
    -- report "R4--------------------->"&integer'image(to_integer(unsigned(reg_file(4))));
    -- report "R5--------------------->"&integer'image(to_integer(unsigned(reg_file(5))));
    -- report "R6--------------------->"&integer'image(to_integer(unsigned(reg_file(6))));
    -- report "R7--------------------->"&integer'image(to_integer(unsigned(reg_file(7))));
    -- report "PC--------------------->"&integer'image(to_integer(unsigned(reg_file(0))));

-- end process;

end architecture behav; 