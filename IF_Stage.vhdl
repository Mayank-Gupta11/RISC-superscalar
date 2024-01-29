--Aaryan
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity IF_stage is
	port(
	CLK, RST :in std_logic;
	Target_Add, PC_out: in std_logic_vector(15 downto 0);
	PC_src_sel : in std_logic;
	PC_in: out std_logic_vector(15 downto 0);
    Inst_outp: out std_logic_vector(31 downto 0);
    PC: out std_logic_vector(15 downto 0)
	);
end entity IF_stage;

architecture behav of IF_stage is
    
    component mux_2x1_16bit is
    port (inp_0: in std_logic_vector(15 downto 0);
    inp_1: in std_logic_vector(15 downto 0);
    outp: out std_logic_vector(15 downto 0);
    mux_op: in std_logic);
    end component;

    component adder_4 is
    port(
  --  clk: in std_logic;
    inp_a: in std_logic_vector(15 downto 0); 
    adder_out: out std_logic_vector(15 downto 0));
    end component;

    component Inst_Memory is 
    port(clock: in std_logic;
    addr: in std_logic_vector(15 downto 0);  
    IM_output: out std_logic_vector(31 downto 0));
    end component;

	signal PC_4_sig: std_logic_vector(15 downto 0):="0000000000000100";
    
begin

    PC_src1: mux_2x1_16bit port map(
        inp_0 => PC_4_sig,
        inp_1 => Target_Add, 
        mux_op=> PC_src_sel,
        outp=>PC_in);
	
    PC_add : adder_4 port map(
      --  Clk => CLK,
        inp_a =>PC_out,
        adder_out => PC_4_sig);

    Inst_Mm1: Inst_Memory port map(
        clock => CLK, 
        addr => PC_out,  
        IM_output=>Inst_outp);
    
-- process(PC_out)
-- begin 
--     PC_2_sig <= std_logic_vector(unsigned(pc_out) + 2);
-- end process;
    PC <= PC_out;

end architecture;
