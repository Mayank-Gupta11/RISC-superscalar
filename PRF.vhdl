

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.SchedulerTypes.all;

entity PRF is

port(clock,reset: in std_logic;
		RF_A : in std_logic_vector(35 downto 0);
		RF_WR_A : in std_logic_vector(17 downto 0);
		RF_WR_D : in std_logic_vector(47 downto 0);
		reset_all : in std_logic;
		cnt_head : in std_logic_vector(11 downto 0);
		new_ptrs : in std_logic_vector(11 downto 0);
		pc_next : in std_logic_vector(15 downto 0); 
		wr_en : in std_logic_vector(2 downto 0);
		RAT_en : in std_logic_vector(1 downto 0);
		-- RD_en : in std_logic_vector(1 downto 0);
		pc_en : in std_logic;
		Retire_hd: in std_logic_vector(11 downto 0);
		Retire_tag : in std_logic_vector(11 downto 0);
		Retire_en : in std_logic_vector(1 downto 0);
		opr_hd : in std_logic_vector(23 downto 0);
		valid_en : in std_logic_vector(1 downto 0);
		retire_valid : in std_logic_vector(1 downto 0); --1 if ADC valid, otherwise 0
		hd_not_to_reset : in HeadArray(7 downto 0);
		
		opr_ptr : out std_logic_vector(23 downto 0);
		opr_v : out std_logic_vector(3 downto 0);
		RF_L_D : out std_logic_vector(31 downto 0);
		RF_I1_D : out std_logic_vector(31 downto 0);
		RF_I2_D : out std_logic_vector(31 downto 0);
		pc_present : out std_logic_vector(15 downto 0);
		busy_out : out std_logic_vector(63 downto 0);
		Register_0, Register_1, Register_2, Register_3, Register_4, Register_5, Register_6, Register_7: out std_logic_vector(15 downto 0)
		);
end entity;

architecture behav of PRF is
	
type reg is array(0 to 63) of std_logic_vector(15 downto 0);
type ptr is array(0 to 63) of std_logic_vector(5 downto 0);
type v is array(0 to 63) of std_logic;
-- type valid is array(0 to 63) of std_logic;

signal valid1: v:=(others=>'0');

signal reg_file: reg:=(
	1 => "1111111111111111",
	2 => "0000000000000000",
	3 => "0000000000001010",
	4 => "0000000000000010",
	others=>(others=>'0'));
signal busy_bits: std_logic_vector(63 downto 0);

signal pointer: ptr:=(
	others=>(others=>'0'));

begin

process(clock,reset, RF_A, RF_WR_A, RF_WR_D, cnt_head, new_ptrs, pc_next, wr_en, RAT_en, pc_en, Retire_hd, Retire_tag, Retire_en, opr_hd, valid_en, retire_valid)
begin
	if reset='1' then 
		reg_file <= (others=>(others=>'0'));
	elsif rising_edge(clock) then
		-- Read operands
		
			RF_L_D(31 downto 16) <= reg_file(to_integer(unsigned(RF_A(35 downto 30))));
		
			RF_L_D(15 downto 0) <= reg_file(to_integer(unsigned(RF_A(30 downto 24))));
		
			RF_I1_D(31 downto 16) <= reg_file(to_integer(unsigned(RF_A(23 downto 18))));
		
			RF_I1_D(15 downto 0) <= reg_file(to_integer(unsigned(RF_A(17 downto 12))));
		
			RF_I2_D(31 downto 16) <= reg_file(to_integer(unsigned(RF_A(11 downto 6))));
		
			RF_I2_D(15 downto 0) <= reg_file(to_integer(unsigned(RF_A(5 downto 0))));
			
			
			
			
		
	elsif falling_edge(clock) then
		
		if reset_all='1' then
			L2: for j in 0 to 7 loop
				L1: for i in 0 to 63 loop
					if i=to_integer(unsigned(hd_not_to_reset(j))) then
					
					else
						reg_file(i) <= (others=>'0');
					end if;
				end loop L1;
			end loop L2;
			
		end if;
		
		
		-- Execute
		if wr_en(0)='1' then
			reg_file(to_integer(unsigned(RF_WR_A(5 downto 0)))) <= RF_WR_D(15 downto 0);
			if valid_en(0)='1' then
				valid1(to_integer(unsigned(RF_WR_A(5 downto 0)))) <= '1';
			else
				valid1(to_integer(unsigned(RF_WR_A(5 downto 0)))) <= '0';
			end if;	

			
		end if;
		if wr_en(1)='1' then
			reg_file(to_integer(unsigned(RF_WR_A(11 downto 6)))) <= RF_WR_D(31 downto 16);
			if valid_en(1)='1' then
				valid1(to_integer(unsigned(RF_WR_A(11 downto 6)))) <= '1';
			else
				valid1(to_integer(unsigned(RF_WR_A(11 downto 6)))) <= '0';
			end if;	
		end if;
		
		if wr_en(2)='1' then
			reg_file(to_integer(unsigned(RF_WR_A(17 downto 12)))) <= RF_WR_D(47 downto 32);
			valid1(to_integer(unsigned(RF_WR_A(17 downto 12)))) <= '1';

			
		end if;
					
			
		
		-- Dispatch
		if RAT_en(1) ='1' then
			pointer(to_integer(unsigned(cnt_head(11 downto 6)))) <= new_ptrs(11 downto 6);	
			busy_bits(to_integer(unsigned(new_ptrs(11 downto 6)))) <= '1';
		end if;
		if RAT_en(0) ='1' then
			pointer(to_integer(unsigned(cnt_head(5 downto 0)))) <= new_ptrs(5 downto 0);	
			busy_bits(to_integer(unsigned(new_ptrs(5 downto 0)))) <= '1';
		end if;
		
		-- Retire
		if Retire_en(0)='1' then
			pointer(to_integer(unsigned(Retire_tag(5 downto 0)))) <= pointer(to_integer(unsigned(Retire_hd(5 downto 0))));
			busy_bits(to_integer(unsigned(Retire_hd(5 downto 0)))) <= '0';
			valid1(to_integer(unsigned(Retire_hd(5 downto 0)))) <= '0';
			if retire_valid(0)='1' then
				valid1(to_integer(unsigned(Retire_tag(5 downto 0)))) <= '1';
			end if;
				
		end if;

		if Retire_en(1)='1' then
			pointer(to_integer(unsigned(Retire_tag(11 downto 6)))) <= pointer(to_integer(unsigned(Retire_hd(11 downto 6))));
			busy_bits(to_integer(unsigned(Retire_hd(11 downto 6)))) <= '0';
			valid1(to_integer(unsigned(Retire_hd(11 downto 6)))) <= '0';
			if retire_valid(1)='1' then
				valid1(to_integer(unsigned(Retire_tag(11 downto 6)))) <= '1';
			end if;
		end if;

		if pc_en = '1' and reset='0' then
			reg_file(0) <= pc_next;
		end if;
	end if;
end process;


process(clock,opr_hd)
begin
	if rising_edge(clock) then
		Register_0 <= reg_file(to_integer(unsigned(hd_not_to_reset(0))));
		Register_1 <= reg_file(to_integer(unsigned(hd_not_to_reset(1))));
		Register_2 <= reg_file(to_integer(unsigned(hd_not_to_reset(2))));
		Register_3 <= reg_file(to_integer(unsigned(hd_not_to_reset(3))));
		Register_4 <= reg_file(to_integer(unsigned(hd_not_to_reset(4))));
		Register_5 <= reg_file(to_integer(unsigned(hd_not_to_reset(5))));
		Register_6 <= reg_file(to_integer(unsigned(hd_not_to_reset(6))));
		Register_7 <= reg_file(to_integer(unsigned(hd_not_to_reset(7))));
		
		opr_ptr(23 downto 18) <= pointer(to_integer(unsigned(opr_hd(23 downto 18))));
		opr_ptr(17 downto 12) <= pointer(to_integer(unsigned(opr_hd(17 downto 12))));
		opr_ptr(11 downto 6) <= pointer(to_integer(unsigned(opr_hd(11 downto 6))));
		opr_ptr(5 downto 0) <= pointer(to_integer(unsigned(opr_hd(5 downto 0))));

		opr_v(3) <= valid1(to_integer(unsigned(opr_hd(23 downto 18))));
		opr_v(2) <= valid1(to_integer(unsigned(opr_hd(17 downto 12))));
		opr_v(1) <= valid1(to_integer(unsigned(opr_hd(11 downto 6))));
		opr_v(0) <= valid1(to_integer(unsigned(opr_hd(5 downto 0))));
		busy_out<=busy_bits;
		pc_present <= reg_file(0);		
	end if;
end process;
	

--process(rf_a1,rf_a2,reg_file)
--begin

--end process;
process(reg_file)
begin 
    report "R1--------------------->"&integer'image(to_integer(unsigned(reg_file(1))));
    report "R2--------------------->"&integer'image(to_integer(unsigned(reg_file(2))));
    report "R3--------------------->"&integer'image(to_integer(unsigned(reg_file(3))));
    report "R4--------------------->"&integer'image(to_integer(unsigned(reg_file(4))));
    report "R5--------------------->"&integer'image(to_integer(unsigned(reg_file(5))));
    report "R6--------------------->"&integer'image(to_integer(unsigned(reg_file(6))));
    report "R7--------------------->"&integer'image(to_integer(unsigned(reg_file(7))));
    report "PC--------------------->"&integer'image(to_integer(unsigned(reg_file(0))));

end process;

end architecture behav; 