library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
package SchedulerTypes is
	type OneBitArray is array (natural range <>) of std_logic;
	type ControlArray is array (natural range <>) of std_logic_vector(41 downto 0);
	type HeadArray is array (natural range <>) of std_logic_vector(5 downto 0);
  end package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.SchedulerTypes.all;  
  
entity reservation_station is
port(clock,reset: in std_logic;
      OPR_TAGS : in std_logic_vector(23 downto 0);
	  OPR_V: in std_logic_vector(3 downto 0);
	  CTR1, CTR2 : in std_logic_vector(41 downto 0);
	  EX_EN : in std_logic_vector(2 downto 0);
	  RF_WR_A : in std_logic_vector(17 downto 0);  -- 3 destination execution tags
	  RETIRED_TAGS: in std_logic_vector(11 downto 0);
	  RETIRED_VALID_EN: in std_logic_vector(1 downto 0); -- if 00 means-(with/if carry/zero instr and predicted wrong)
	  AWC_EN: in std_logic_vector(1 downto 0);
	  RETIRED_EN : in std_logic_vector(1 downto 0);  --  instruction is retiring or not (never 01)
	  PC_in : in std_logic_vector(15 downto 0);     
	  INDICES: in std_logic_vector(11 downto 0);
	  CARRY_VALID: in std_logic;
	  dep1,dep2: in std_logic;

   	  RF_A : out std_logic_vector(35 downto 0);
	  PC_LS,PC_INT1,PC_INT2: out std_logic_vector(15 downto 0);
	  CNTRL_LS: out std_logic_vector(1 downto 0);
	  CNTRL_INT1,CNTRL_INT2: out std_logic_vector(9 downto 0);
	  Imm_LS,Imm_Int1,Imm_Int2 : out std_logic_vector(15 downto 0);
	  RD_TAGS : out std_logic_vector(11 downto 0);	 
	  tag_ls,tag_int1,tag_int2: out std_logic;
	  opr_carry: out std_logic_vector(5 downto 0)
   	    );
end entity;

architecture behav of reservation_station is

	component Flip6 is
		Port (
			D: in std_logic_vector(5 downto 0);
		  	EN: in std_logic;
		  	RST: in std_logic;
		  	CLK: in std_logic;
		  	Q: out std_logic_vector(5 downto 0)
		);
	end component;
		
	component Free_Tags is
		Port (
    		clk : in STD_LOGIC;
    		reset : in STD_LOGIC;
    		busy : in STD_LOGIC_VECTOR(63 downto 0);
    		indices : out STD_LOGIC_VECTOR(11 downto 0));
	end component;
	
	component scheduler is
		Port (
			clk : in STD_LOGIC;
			reset : in STD_LOGIC;
			Ready : in OneBitArray(63 downto 0);
			control_bits : in ControlArray(63 downto 0);
			indices : out STD_LOGIC_VECTOR(11 downto 0);
			issued : out std_logic_vector(1 downto 0)
				  );
	end component;	  


type sixteen_bit_array is array(0 to 63) of std_logic_vector(15 downto 0);
-- type valid_array is array(0 to 63) of std_logic;
type six_bit_array is array(0 to 63) of std_logic_vector(5 downto 0);
--type one_bit_array is array(0 to 63) of std_logic;
--type control_array is array(0 to 63) of std_logic_vector(41 downto 0);
type sixteen_bit_array_LS is array(0 to 15) of std_logic_vector(15 downto 0);
type six_bit_array_ls is array(0 to 15) of std_logic_vector(5 downto 0);


signal PC: sixteen_bit_array:=(others=>(others=>'0'));
signal busy_sig: OneBitArray(63 downto 0):=(others=>'0');
signal opr1: six_bit_array:=(others=>(others=>'0'));
signal opr2: six_bit_array:=(others=>(others=>'0'));
signal v1: OneBitArray(63 downto 0):=(others=>'0');
signal v2:OneBitArray(63 downto 0):=(others=>'0');
signal vc:OneBitArray(63 downto 0):=(others=>'0');
-- signal PRF:six_bit_array:=(others=>(others=>'0'));
signal control_bits:ControlArray(63 downto 0):=(others =>(others => '0'));
-- signal carry: six_bit_array:=(others=>(others=>'0'));
signal free_loc: std_logic_vector(11 downto 0);
signal Ready: OneBitArray(63 downto 0):=(others=>'0');
signal ready_for_exec: std_logic_vector(11 downto 0);
signal issue: std_logic_vector(1 downto 0);
signal immediate: sixteen_bit_array:=(others=>(others=>'0'));
signal Cin: six_bit_array:=(others=>(others=>'0'));           -- CRF has 64 entires

signal CurrCarry: std_logic_vector(5 downto 0);
signal CurrZero: std_logic_vector(5 downto 0);
signal Enable: std_logic;
signal carry_to_be_modified: std_logic_vector(5 downto 0);

signal PC_L_S: sixteen_bit_array_LS:=(others=>(others=>'0'));
signal opr1_LS:six_bit_array_ls:=(others=>(others=>'0'));
signal opr2_LS:six_bit_array_ls:=(others=>(others=>'0'));
signal v1_LS:OneBitArray(15 downto 0):=(others=>'0');
signal immediate_LS:sixteen_bit_array_LS:=(others=>(others=>'0'));
signal control_bits_LS:ControlArray(15 downto 0):=(others =>(others => '0'));
signal v2_LS:OneBitArray(15 downto 0):=(others=>'0');



begin

	free_RS_tags: Free_Tags port map(
		clk => clock,
		reset => reset,
		busy => std_logic_vector(busy_sig),
		indices => free_loc
	);

	scheduler1: scheduler port map(
		clk => clock,
		reset => reset,
		Ready => Ready,
		control_bits => control_bits, 
		indices => ready_for_exec,
		issued => issue
	);

	C6: Flip6 port map(
		D => carry_to_be_modified,
		EN => Enable,
		RST => reset,
		CLK => clock,
		Q => CurrCarry
	);
	
	
process(clock,reset,OPR_TAGS,OPR_V,CTR1,CTR2,EX_EN,RF_WR_A,PC_in,indices,free_loc,ready_for_exec,issue)
	variable head:natural:=0;
	variable tail:natural:=0; 
begin
	if reset='1' then 
		PC <= (others=>(others=>'0'));
		busy_sig <= (others=>'0');
		opr1 <= (others=>(others=>'0'));
		opr2 <= (others=>(others=>'0'));
		v1 <= (others=>'0');
		v2 <= (others=>'0');
		vc <= (others=>'0');
		-- PRF <= (others=>(others=>'0'));
--		carry <= (others=>(others=>'0'));
		-- Ready <= (others=>'0');
		immediate <= (others=>(others=>'0'));
		control_bits <= (others=>(others=>'0'));
		-- free_LSoc <= (others=>'0');
		-- issue <=(others=>'0');
		Cin <= (others=>(others=>'0'));
		
		PC_L_S <= (others=>(others=>'0'));
		opr1_LS <= (others=>(others=>'0'));
		opr2_LS <= (others=>(others=>'0'));
		v1_LS <= (others=>'0');
		v2_LS <= (others=>'0');
		immediate_LS <= (others=>(others=>'0'));
		control_bits_LS <= (others=>(others=>'0'));

	elsif falling_edge(clock) then
		-------------------------------INCOMING INSTRUCTION----------------------------------------------------
		--FOR FIRST INSTRUCTION
		if(CTR1(3)='1' or CTR1(4)='1') then 
			PC_L_S(tail) <= PC_in;
			opr1_LS(tail) <= opr_tags(23 downto 18);
			opr2_LS(tail) <= opr_tags(17 downto 12);
			v1_LS(tail) <= opr_v(3);
			-- PRF(tail) <= INDICES(11 downto 6);
			immediate_LS(tail) <= CTR1(32 downto 17);
			control_bits_LS(tail) <=CTR1(4 downto 3);
			v2_LS(tail) <= opr_v(2);
			tail:=tail+1;
			tail:=tail mod 64;
		else
			PC(to_integer(unsigned(free_loc(11 downto 6)))) <= PC_in;
			busy_sig(to_integer(unsigned(free_loc(11 downto 6)))) <= '1';
			opr1(to_integer(unsigned(free_loc(11 downto 6)))) <= opr_tags(23 downto 18);
			opr2(to_integer(unsigned(free_loc(11 downto 6)))) <= opr_tags(17 downto 12);
			v1(to_integer(unsigned(free_loc(11 downto 6)))) <= opr_v(3);
		-- PRF(to_integer(unsigned(free_loc(11 downto 6)))) <= INDICES(11 downto 6);
			immediate(to_integer(unsigned(free_loc(11 downto 6)))) <= CTR1(32 downto 17);
			control_bits(to_integer(unsigned(free_loc(11 downto 6)))) <=CTR1(16 downto 0);
			if (NOT(CTR1(11)='1') AND CTR1(10)='1') then --for add with carry type instr
				vc(to_integer(unsigned(free_loc(11 downto 6)))) <= CARRY_VALID;
			else 
				vc(to_integer(unsigned(free_loc(11 downto 6)))) <= '1';
			end if;
			if(CTR1(7)='1' or CTR1(8)='1') then	
				v2(to_integer(unsigned(free_loc(11 downto 6)))) <= '1';
			else v2(to_integer(unsigned(free_loc(11 downto 6)))) <= opr_v(2);
			end if;
		end if;

		--FOR SECOND INSTRUCTION
		if(CTR2(3)='1' or CTR2(4)='1') then 
			PC_L_S(tail) <= PC_in;
			opr1_LS(tail) <= opr_tags(23 downto 18);
			opr2_LS(tail) <= opr_tags(17 downto 12);
			v1_LS(tail) <= opr_v(3);
			-- PRF(tail) <= INDICES(11 downto 6);
			immediate_LS(tail) <= CTR1(32 downto 17);
			control_bits_LS(tail) <=CTR1(4 downto 3);
			v2_LS(tail) <= opr_v(2);
			tail:=tail+1;
			tail:=tail mod 64;
		else
			PC(to_integer(unsigned(free_loc(5 downto 0))))  <=std_logic_vector(unsigned(PC_in) + 2);
			busy_sig(to_integer(unsigned(free_loc(5  downto 0)))) <= '1';	
			immediate(to_integer(unsigned(free_loc(5 downto 0)))) <= CTR2(32 downto 17);
			control_bits(to_integer(unsigned(free_loc(5 downto 0)))) <=CTR2(16 downto 0);

			if(dep1='1') then 
				opr1(to_integer(unsigned(free_loc(5 downto 0)))) <= INDICES(11 downto 6);
				v1(to_integer(unsigned(free_loc(5 downto 0))))<= '0';
			else
				opr1(to_integer(unsigned(free_loc(5 downto 0)))) <= opr_tags(11 downto 6);
				v1(to_integer(unsigned(free_loc(5 downto 0))))<= opr_v(1);
			end if;

			if(CTR1(7)='1' or CTR1(8)='1') then	
				opr2(to_integer(unsigned(free_loc(5 downto 0)))) <= opr_tags(5 downto 0);	
				v2(to_integer(unsigned(free_loc(5 downto 0)))) <= '1';
			elsif(dep2='1') then 
				opr2(to_integer(unsigned(free_loc(5 downto 0)))) <= INDICES(11 downto 6);
				v2(to_integer(unsigned(free_loc(5 downto 0)))) <= '0';
			else 
				opr2(to_integer(unsigned(free_loc(5 downto 0)))) <= opr_tags(5 downto 0);	
				v2(to_integer(unsigned(free_loc(5 downto 0)))) <= opr_v(0);
			end if;
		end if;
		Enable <= CTR1(16) or CTR2(16);

		if(CTR1(16)='0') then 
			if(CTR2(16)='0') then --00
				Cin(to_integer(unsigned(free_loc(11 downto 6)))) <= CurrCarry;
				Cin(to_integer(unsigned(free_loc(5 downto 0)))) <= CurrCarry;
				carry_to_be_modified <= CurrCarry;
				
				vc(to_integer(unsigned(free_loc(5 downto 0)))) <= CARRY_VALID;
			else --01
				Cin(to_integer(unsigned(free_loc(11 downto 6)))) <= CurrCarry;
				Cin(to_integer(unsigned(free_loc(5 downto 0)))) <= CurrCarry;
				carry_to_be_modified <= INDICES(5 downto 0);
				-- vc(to_integer(unsigned(free_loc(5 downto 0)))) <= '0';
				if (NOT(CTR2(11)='1') AND CTR2(10)='1') then --for add with carry type instr
					vc(to_integer(unsigned(free_loc(5 downto 0)))) <= '0';
				else 
					vc(to_integer(unsigned(free_loc(5 downto 0)))) <= '1';
				end if;	

			end if;
		else	--10
			if(CTR2(16)='0') then
				Cin(to_integer(unsigned(free_loc(11 downto 6)))) <= CurrCarry;
				Cin(to_integer(unsigned(free_loc(5 downto 0)))) <= INDICES(11 downto 6);
				carry_to_be_modified <= INDICES(11 downto 6);
				vc(to_integer(unsigned(free_loc(5 downto 0)))) <= '0';
			else --11
				Cin(to_integer(unsigned(free_loc(11 downto 6)))) <= CurrCarry;
				Cin(to_integer(unsigned(free_loc(5 downto 0)))) <= INDICES(11 downto 6);
				carry_to_be_modified <= INDICES(5 downto 0);
				if (NOT(CTR2(11)='1') AND CTR2(10)='1') then --for add with carry type instr
					vc(to_integer(unsigned(free_loc(5 downto 0)))) <= '0';
				else 
					vc(to_integer(unsigned(free_loc(5 downto 0)))) <= '1';
				end if;	
			end if;
		end if;


		-------------------------------SCHEDULING----------------------------------------------------     --tag 1 bit add, control bits ,imm as diff column
		Imm_LS <=  immediate_LS(head);
		Imm_Int1 <=  immediate(to_integer(unsigned(ready_for_exec(11 downto 6))));
		Imm_Int2 <=  immediate(to_integer(unsigned(ready_for_exec(5 downto 0))));

		if (head = tail) then
			tag_ls <= '0';
		elsif (v1_LS(head) = '1' and v2_LS(head) = '1') then
			tag_ls <= '1';
			head:=head + 1;
			head:=head mod 64;
		else
			tag_ls <= '0';
		end if;
		
		tag_int1 <= issue(1);
		tag_int2 <= issue(0);
	
		PC_LS <= PC_L_S(head);
		PC_int1 <= PC(to_integer(unsigned(ready_for_exec(11 downto 6))));
		PC_int2 <= PC(to_integer(unsigned(ready_for_exec(5 downto 0))));
		
		CNTRL_LS <= control_bits_LS(head)(4 downto 3);

		CNTRL_INT1(0) <= control_bits(to_integer(unsigned(ready_for_exec(11 downto 6))))(1);
		CNTRL_INT1(1) <= control_bits(to_integer(unsigned(ready_for_exec(11 downto 6))))(2);
		CNTRL_INT1(3 downto 2) <= control_bits(to_integer(unsigned(ready_for_exec(11 downto 6))))(6 downto 5);
		CNTRL_INT1(4) <= control_bits(to_integer(unsigned(ready_for_exec(11 downto 6))))(7);
		CNTRL_INT1(5) <= control_bits(to_integer(unsigned(ready_for_exec(11 downto 6))))(8);
		CNTRL_INT1(6) <= control_bits(to_integer(unsigned(ready_for_exec(11 downto 6))))(9);
		CNTRL_INT1(9 downto 8) <= control_bits(to_integer(unsigned(ready_for_exec(11 downto 6))))(11 downto 10);
		CNTRL_INT1(7) <= control_bits(to_integer(unsigned(ready_for_exec(11 downto 6))))(14);

		CNTRL_INT2(0) <= control_bits(to_integer(unsigned(ready_for_exec(5 downto 0))))(1);
		CNTRL_INT2(1) <= control_bits(to_integer(unsigned(ready_for_exec(5 downto 0))))(2);
		CNTRL_INT2(3 downto 2) <= control_bits(to_integer(unsigned(ready_for_exec(5 downto 0))))(6 downto 5);
		CNTRL_INT2(4) <= control_bits(to_integer(unsigned(ready_for_exec(5 downto 0))))(7);
		CNTRL_INT2(5) <= control_bits(to_integer(unsigned(ready_for_exec(5 downto 0))))(8);
		CNTRL_INT2(6) <= control_bits(to_integer(unsigned(ready_for_exec(5 downto 0))))(9);
		CNTRL_INT2(9 downto 8) <= control_bits(to_integer(unsigned(ready_for_exec(5 downto 0))))(11 downto 10);
		CNTRL_INT2(7) <= control_bits(to_integer(unsigned(ready_for_exec(5 downto 0))))(14);

		RF_A(35 downto 30) <= opr1_LS(head);
		RF_A(29 downto 24) <= opr2_LS(head);
		RF_A(23 downto 18) <= opr1(to_integer(unsigned(ready_for_exec(11 downto 6))));
		RF_A(17 downto 12) <= opr2(to_integer(unsigned(ready_for_exec(11 downto 6))));
		RF_A(11 downto 6)  <= opr1(to_integer(unsigned(ready_for_exec(5 downto 0))));
		RF_A(5 downto 0)   <= opr2(to_integer(unsigned(ready_for_exec(5 downto 0))));
  
		RD_TAGS(11 downto 6) <= Cin(to_integer(unsigned(ready_for_exec(11 downto 6))));
		RD_TAGS(5 downto 0) <= Cin(to_integer(unsigned(ready_for_exec(5 downto 0))));

		--------------------------------------ROB-------------------------------------------------------
		--en teeno check take 6 bit tags poore rs table mein 6 bits kaha pe hai valid 1 kar dena with busy one

		if(not(RETIRED_VALID_EN(1)='1') and RETIRED_EN(1)='1') then   -- destination tag of instruction 1 and retired 
			for i in 0 to 63 loop                      
				if (opr1(i)=RETIRED_TAGS(11 downto 6)) then
					v1(i)<='1';
				else v1(i) <= v1(i);
				end if;
				if(opr2(i)=RETIRED_TAGS(11 downto 6)) then 
					v2(i) <='1';
				else v2(i) <= v2(i);
				end if;
				if(Cin(i)=RETIRED_TAGS(11 downto 6)) then 
					vc(i) <= '1';
				else vc(i) <= vc(i);
				end if;
			end loop;
		end if;

		if(RETIRED_VALID_EN(0)='0' and RETIRED_EN(0)='1') then           -- destination tag of instruction 2
			for i in 0 to 63 loop                      -- Iterate through stored PC values
				if (opr1(i)=RETIRED_TAGS(5 downto 0)) then
					v1(i)<='1';
				else v1(i) <= v1(i);
				end if;
				if(opr2(i)=RETIRED_TAGS(5 downto 0)) then 
					v2(i) <='1';
				else v2(i) <= v2(i);
				end if;
				if(Cin(i)=RETIRED_TAGS(5 downto 0)) then 
					vc(i) <= '1';
				else vc(i) <= vc(i);
				end if;
			end loop;		
		end if;

		if(EX_EN(2)='1') then     -- load store executed destination tag 
			for i in 0 to 63 loop                      
				if (opr1(i)=RF_WR_A(17 downto 12)) then
					v1(i)<='1';
				else v1(i) <= v1(i);
				end if;
				if(opr2(i)=RF_WR_A(17 downto 12)) then 
					v2(i) <='1';
				else v2(i) <= v2(i);
				end if;
				if(Cin(i)=RF_WR_A(17 downto 12)) then 
					vc(i) <= '1';
				else vc(i) <= vc(i);
				end if;
			end loop;
		end if;

		if(EX_EN(1)='1' and AWC_EN(1)='1') then     -- int1 executed destination tag  with AWC instruction 
			for i in 0 to 63 loop                      
				if (opr1(i)=RF_WR_A(11 downto 6)) then
					v1(i)<='1';
				else v1(i) <= v1(i);
				end if;
				if(opr2(i)=RF_WR_A(11 downto 6)) then 
					v2(i) <='1';
				else v2(i) <= v2(i);
				end if;
				if(Cin(i)=RF_WR_A(11 downto 6)) then 
					vc(i) <= '1';
				else vc(i) <= vc(i);
				end if;
			end loop;
		end if;

		if(EX_EN(0)='1' and AWC_EN(0)='1') then     -- int2 executed destination tag  with AWC instruction 
			for i in 0 to 63 loop                      
				if (opr1(i)=RF_WR_A(5 downto 0)) then
					v1(i)<='1';
				else v1(i) <= v1(i);
				end if;
				if(opr2(i)=RF_WR_A(5 downto 0)) then 
					v2(i) <='1';
				else v2(i) <= v2(i);
				end if;
				if(Cin(i)=RF_WR_A(5 downto 0)) then 
					vc(i) <= '1';
				else vc(i) <= vc(i);
				end if;
			end loop;
		end if;
	
	end if; -- falling edge

end process;

 process(v1,v2,vc,reset,clock)
 begin
	if reset='1' then
		Ready <= (others=>'0');
	elsif falling_edge(clock) then
--		Ready <= v1 and v2 and vc;
   	for i in 0 to 63 loop
			Ready(i) <= v1(i) and v2(i) and vc(i);
   	end loop;
	end if;
 	end process;

opr_carry <= CurrCarry;
end architecture behav; 