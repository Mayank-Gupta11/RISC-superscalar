library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Issue_buffer_int is
port(clock,reset: in std_logic;
		RF_I_D: in std_logic_vector(31 downto 0);
        PC_I: in std_logic_vector(15 downto 0);
		CARRY_IN: in std_logic;
		ISSUED: in std_logic;
		EXEC_CTRL: in std_logic_vector(9 downto 0);
		IMM_I: in std_logic_vector(15 downto 0);
		TAG_I: out std_logic;
		PC:out std_logic_vector(15 downto 0);
		RB_SEL: out std_logic;
		RA_SEL: out std_logic;
		ALU_OUT_SEL: out std_logic;
		BR_TYPE: out std_logic_vector(1 downto 0);
		PC_EN:out std_logic;
		REGA:out std_logic_vector(15 downto 0); --data
		ALU_B_SEL:out std_logic;
		REGB:out std_logic_vector(15 downto 0);
		IMM_IN:out std_logic_vector(15 downto 0);
		ALU_CONTROL_OUT:out std_logic_vector(2 downto 0);
		CARRY_OUT:out std_logic
		
	    );
end entity Issue_buffer_int;

architecture behav of Issue_buffer_int is
 signal reg: std_logic_vector(75 downto 0):= (others => '0');
begin
	
process(clock,reset,RF_I_D,PC_I,CARRY_IN,ISSUED,EXEC_CTRL,IMM_I)
 begin
	if reset='1' then 
 		reg <= (others=>'0');
 	elsif falling_edge(clock)  then
 		reg(31 downto 0) <= RF_I_D;
		reg(47 downto 32) <= PC_I;
		reg(48) <= CARRY_IN;
		reg(49) <= ISSUED;
		reg(59 downto 50) <= EXEC_CTRL;
		reg(75 downto 60) <= IMM_I;
	end if;
end process;


TAG_I <= reg(49);
PC <= reg(47 downto 32);
RB_SEL <= reg(50);
RA_SEL <= reg(51);
ALU_OUT_SEL <= reg(56);
BR_TYPE <= reg(53 downto 52);
PC_EN <= reg(54);
REGA <= reg(31 downto 16);
ALU_B_SEL <= reg(55);
REGB <= reg(15 downto 0);
IMM_IN <= reg(75 downto 60);
ALU_CONTROL_OUT <= reg(59 downto 57);
CARRY_OUT <= reg(48);

end architecture behav; 