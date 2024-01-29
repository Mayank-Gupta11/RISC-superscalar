--Mayank
--Condition to check result is of which instr

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ROB is

port(
		clock,reset: in std_logic;
		Data_ls : in std_logic_vector(15 downto 0);
		mispredict_bit1 : in std_logic;
		mispredict_bit2 : in std_logic;
		PC : in std_logic_vector(15 downto 0);
		Ex_out1 : in std_logic_vector(15 downto 0);
		Ex_out2 : in std_logic_vector(15 downto 0);
		Free_Tags : in std_logic_vector(11 downto 0);
		tag_I1 : in std_logic;--enables to check if instr is there
		tag_I2 : in std_logic;
		tag_ls : in std_logic;
		c1_ifcarry,z1_ifzero : in std_logic;
		c2_ifcarry,z2_ifzero : in std_logic;
		c2_modify,z2_modify : in std_logic;
		c1_modify,z1_modify : in std_logic;
		PC_I1 : in std_logic_vector(15 downto 0);--enables to check if instr is there
		PC_I2 : in std_logic_vector(15 downto 0);
		PC_ls : in std_logic_vector(15 downto 0);
		dest_reg1 : in std_logic_vector(2 downto 0);
		dest_reg2 : in std_logic_vector(2 downto 0);
		c1 : in std_logic; 
		z1 : in std_logic; 
		c2 : in std_logic; 
		z2 : in std_logic; 
		zl : in std_logic; 
		br_en1, br_en2 : in std_logic;

		reset_all : out std_logic;
		-- tag_assign : out std_logic_vector(11 downto 0);
		Retire_tag : out std_logic_vector(11 downto 0);
		Retire_en : out std_logic_vector(1 downto 0);
		Retire_reg : out std_logic_vector(5 downto 0);
		RAT_en : out std_logic_vector(1 downto 0);
		PC_src_sel : out std_logic;
		btb_in : out std_logic_vector(15 downto 0);
		PC_EN : out std_logic;
		WR_CYs : out std_logic_vector(1 downto 0);
		RF_WR_A : out std_logic_vector(17 downto 0);
		RF_WR_D : out std_logic_vector(47 downto 0);
		WR_en_for_RAT : out std_logic_vector(2 downto 0);          -- 0 if branch , 1 if write ..each write is independent 
		retire_valid : out std_logic_vector(1 downto 0); --1 if ADC valid, otherwise 0 (retire)
		c_outp,z_outp: out std_logic;
		valid_en : out std_logic_vector(1 downto 0) --Execute
		);
end entity;

architecture behav of ROB is

type pc_data is array(0 to 63) of std_logic_vector(15 downto 0);
type vals is array(0 to 2) of std_logic_vector(15 downto 0);
type reg_rename is array(0 to 63) of std_logic_vector(5 downto 0);
type six_bit is array(0 to 63) of std_logic_vector(5 downto 0);
type three_bit is array(0 to 63) of std_logic_vector(2 downto 0);
-- type six_bit1 is array(0 to 63) of natural;

type one_bit_arr is array(0 to 63) of std_logic;
signal c,z: std_logic:='0';
signal reg_rename_tags: reg_rename:=(others=>(others=>'0'));
signal PC_stored:pc_data:=(others=>(others=>'0'));
signal dest: three_bit:=(others=>(others=>'0'));
signal executed, br_en: one_bit_arr:=(others=>'0');
signal carry: one_bit_arr:=(others=>'0');
signal zero, make_valid_1: one_bit_arr:=(others=>'0');
signal misprediction: one_bit_arr:=(others=>'0');
signal c_modify, z_modify: one_bit_arr:=(others=>'0');
signal c_ifcarry: one_bit_arr:=(others=>'0');
signal z_ifzero: one_bit_arr:=(others=>'0');
constant addend1 : natural:=1;
constant addend2 : natural:=2;

begin
process(clock, reset)
variable head : natural:=0;
variable tail : natural:=0;
begin
	if reset='1' then 
		reset_all <='1';
		reg_rename_tags<=(others=>(others=>'0'));
		PC_stored<=(others=>(others=>'0'));
		dest<=(others=>(others=>'0'));
		head:=0;
		tail :=0;
		executed<=(others=>'0');
		br_en<=(others=>'0');
		carry<=(others=>'0');
		zero<=(others=>'0');
	elsif rising_edge(clock) then
		c_outp <= c;
		z_outp <= z;
	elsif falling_edge(clock) then
	
		--Dispatch
		PC_stored(tail) <= PC;
		PC_stored(tail + addend1) <= std_logic_vector(unsigned(PC) + addend1);
		reg_rename_tags(tail+addend1)<=Free_Tags(11 downto 6);
		reg_rename_tags(tail)<=Free_Tags(5 downto 0);
		dest(tail) <= dest_reg1;
		dest(tail+addend1) <= dest_reg2;
		c_ifcarry(tail)<=c1_ifcarry;
		c_ifcarry(tail+addend1)<=c2_ifcarry;
		c_modify(tail) <= c1_modify;
		c_modify(tail+addend1) <= c2_modify;
		z_ifzero(tail) <= z1_ifzero;
		z_ifzero(tail+addend1) <= z2_ifzero;
		z_modify(tail) <= z1_modify;
		z_modify(tail+addend1) <= z2_modify;
		RAT_en <= "11";
		br_en(tail) <= br_en1;
		br_en(tail+addend1) <= br_en2;
		executed(tail) <= '0';
		executed(tail+addend1) <= '0';
		if tail=62 then
			tail:=0;
		elsif tail=63 then
			tail:=1;
		else
			tail :=tail+addend2;
		end if;
		
		--Execute
		if tail>=head then
			L1: for i in 0 to 63 loop 
				if i>=head and i<=tail then
					if tag_ls='1' and PC_ls=PC_stored(i) then
						executed(i)<= '1';
						RF_WR_A(17 downto 12) <=reg_rename_tags(i);
						RF_WR_D(47 downto 32)<= Data_ls;
						WR_en_for_RAT(2) <= '1';
						zero(i)<= zl;
						
					end if;
					if tag_I1='1' and PC_I1=PC_stored(i) then
						executed(i)<= '1';
						RF_WR_A(11 downto 6) <=reg_rename_tags(i);
						RF_WR_D(31 downto 16)<= Ex_out1;
						WR_en_for_RAT(1) <= '1';
						carry(i)<= c1;
						WR_CYs(1)<=c1;
						zero(i)<= z1;
						misprediction(i)<=mispredict_bit1;
						
						if (c_ifcarry(i)='1' or z_ifzero(i)='1') then
							valid_en(1) <='0';
						else
							valid_en(1) <='1';
						end if;
					end if;
					if tag_I2='1' and PC_I2=PC_stored(i) then
						executed(i)<= '1';
						RF_WR_A(5 downto 0) <=reg_rename_tags(i);
						RF_WR_D(15 downto 0)<= Ex_out2;
						WR_en_for_RAT(0) <= '1';
						carry(i)<= c2;
						WR_CYs(0)<=c1;
						zero(i)<= z2;
						misprediction(i)<=mispredict_bit2;
						c_ifcarry(i)<=c2_ifcarry;
						if (c_ifcarry(i)='1' or z_ifzero(i)='1') then
							valid_en(0) <='0';
						else
							valid_en(0) <='1';
						end if;
					end if;
				end if;
			end loop L1;

		
		else
			L2: for i in 0 to 63 loop
				if i>=head then
					
					if tag_ls='1' and PC_ls=PC_stored(i) then
						executed(i)<= '1';
						RF_WR_A(17 downto 12) <=reg_rename_tags(i);
						RF_WR_D(47 downto 32)<= Data_ls;
						WR_en_for_RAT(2) <= '1';
						zero(i)<= zl;
						
					end if;
					if tag_I1='1' and PC_I1=PC_stored(i) then
						executed(i)<= '1';
						RF_WR_A(11 downto 6) <=reg_rename_tags(i);
						RF_WR_D(31 downto 16)<= Ex_out1;
						WR_en_for_RAT(1) <= '1';
						carry(i)<= c1;
						WR_CYs(1)<=c1;
						zero(i)<= z1;
						misprediction(i)<=mispredict_bit1;
						
						if (c_ifcarry(i)='1' or z_ifzero(i)='1') then
							valid_en(1) <='0';
						else
							valid_en(1) <='1';
						end if;
					end if;
					if tag_I2='1' and PC_I2=PC_stored(i) then
						executed(i)<= '1';
						RF_WR_A(5 downto 0) <=reg_rename_tags(i);
						RF_WR_D(15 downto 0)<= Ex_out2;
						WR_en_for_RAT(0) <= '1';
						carry(i)<= c2;
						WR_CYs(0)<=c1;
						zero(i)<= z2;
						misprediction(i)<=mispredict_bit2;
						c_ifcarry(i)<=c2_ifcarry;
						if (c_ifcarry(i)='1' or z_ifzero(i)='1') then
							valid_en(0) <='0';
						else
							valid_en(0) <='1';
						end if;
					end if;
				end if;
			end loop L2;
			
			L3: for i in 0 to 63 loop
				if i<= tail then
					--Execute
					if tag_ls='1' and PC_ls=PC_stored(i) then
						executed(i)<= '1';
						RF_WR_A(17 downto 12) <=reg_rename_tags(i);
						RF_WR_D(47 downto 32)<= Data_ls;
						WR_en_for_RAT(2) <= '1';
						zero(i)<= zl;
						
					end if;
					if tag_I1='1' and PC_I1=PC_stored(i) then
						executed(i)<= '1';
						RF_WR_A(11 downto 6) <=reg_rename_tags(i);
						RF_WR_D(31 downto 16)<= Ex_out1;
						WR_en_for_RAT(1) <= '1';
						carry(i)<= c1;
						WR_CYs(1)<=c1;
						zero(i)<= z1;
						misprediction(i)<=mispredict_bit1;
						
						if (c_ifcarry(i)='1' or z_ifzero(i)='1') then
							valid_en(1) <='0';
						else
							valid_en(1) <='1';
						end if;
					end if;
					if tag_I2='1' and PC_I2=PC_stored(i) then
						executed(i)<= '1';
						RF_WR_A(5 downto 0) <=reg_rename_tags(i);
						RF_WR_D(15 downto 0)<= Ex_out2;
						WR_en_for_RAT(0) <= '1';
						carry(i)<= c2;
						WR_CYs(0)<=c1;
						zero(i)<= z2;
						misprediction(i)<=mispredict_bit2;
						c_ifcarry(i)<=c2_ifcarry;
						if (c_ifcarry(i)='1' or z_ifzero(i)='1') then
							valid_en(0) <='0';
						else
							valid_en(0) <='1';
						end if;
					end if;
				end if;
			end loop L3;
		end if;
		
		--Retire
		if executed(head)='1' then
			if (misprediction(head)='0' or br_en(head) = '0') then
				Retire_reg(5 downto 3) <= dest(head);
				Retire_tag(11 downto 6) <= reg_rename_tags(head);
				Retire_en(1) <= '1';
				if c_ifcarry(head)='1' then
					if c='1' then 
						retire_valid(1)<='1';
						if c_modify(head)='1' then
							c<=carry(head);
						end if;
						if z_modify(head)='1' then
							z<=zero(head);
						end if;
					else 
						retire_valid(1) <='0';
					end if;
				elsif z_ifzero(head)='1' then
					if z='1' then
						retire_valid(1)<='1';
						if c_modify(head)='1' then
							c<=carry(head);
						end if;
						if z_modify(head)='1' then
							z<=zero(head);
						end if;
					else
						retire_valid(1)<='0';
					end if;
				else 
					retire_valid(1)<='0';
					if c_modify(head)='1' then
						c<=carry(head);
					end if;
					if z_modify(head)='1' then
						z<=zero(head);
					end if;				
				end if;
				
				
				head:=head+addend1;
				if executed(head)='1' then
					if (misprediction(head)='0' or br_en(head) = '0') then
						Retire_reg(2 downto 0) <= dest(head);
						Retire_tag(5 downto 0) <= reg_rename_tags(head);
						Retire_en(0) <= '1';
						if c_ifcarry(head)='1' then
							if c='1' then 
								retire_valid(0)<='1';
								if c_modify(head)='1' then
									c<=carry(head);
								end if;
								if z_modify(head)='1' then
									z<=zero(head);
								end if;
							else 
								retire_valid(0) <='0';
							end if;
						elsif z_ifzero(head)='1' then
							if z='1' then
								retire_valid(0)<='1';
								if c_modify(head)='1' then
									c<=carry(head);
								end if;
								if z_modify(head)='1' then
									z<=zero(head);
								end if;
							else
								retire_valid(0)<='0';
							end if;
						else 
							retire_valid(0)<='0';
							if c_modify(head)='1' then
								c<=carry(head);
							end if;
							if z_modify(head)='1' then
								z<=zero(head);
							end if;				
						end if;
						head:=head+addend1;
						PC_src_sel <='0';
						reset_all <='0';
					else
						btb_in <= PC_stored(head);
						reset_all <='1';
						reg_rename_tags<=(others=>(others=>'0'));
						PC_stored<=(others=>(others=>'0'));
						dest<=(others=>(others=>'0'));
						head:=0;
						tail :=0;
						executed<=(others=>'0');
						br_en<=(others=>'0');
						carry<=(others=>'0');
						zero<=(others=>'0');
						PC_src_sel <='1';
					end if;
				else
					Retire_en(0)<='0';
				end if;
			else
				btb_in <= PC_stored(head);
				reset_all <='1';
				reg_rename_tags<=(others=>(others=>'0'));
				PC_stored<=(others=>(others=>'0'));
				dest<=(others=>(others=>'0'));
				head:=0;
				tail :=0;
				executed<=(others=>'0');
				br_en<=(others=>'0');
				carry<=(others=>'0');
				zero<=(others=>'0');
				PC_src_sel <='1';
			end if;
		else
			Retire_en<="00";
		end if;

	end if;
	
end process;
PC_EN<='1';
end architecture behav; 
			
			-- 		NEW_WR_TAG(5 downto 0) <= reg_rename_tags(i);
			-- 		WB_A(2 downto 0) <= dest(i);
			-- 		RF_WR_D(15 downto 0) <= values(i);
			-- 		WR_CYs(0) <= carry(i);
			-- 		WR_en_for_RAT(0) <='1';
			-- 		executed_count <= "01";
					
			-- 	elsif executed_count="01" then
			-- 		NEW_WR_TAG(11 downto 6) <= reg_rename_tags(i);
			-- 		WB_A(5 downto 3) <= dest(i);
			-- 		RF_WR_D(31 downto 16) <= values(i);
			-- 		WR_CYs(1) <= carry(i);
			-- 		WR_en_for_RAT(1) <='1';
			-- 		executed_count <= "10";
			-- 	elsif executed_count="10" then
			-- 		NEW_WR_TAG(17 downto 12) <= reg_rename_tags(i);
			-- 		WB_A(8 downto 6) <= dest(i);
			-- 		RF_WR_D(47 downto 32) <= values(i);
			-- 		WR_CYs(2) <= carry(i);
			-- 		WR_en_for_RAT(2) <='1';
			-- 		executed_count <= "11";
					
			-- end if;