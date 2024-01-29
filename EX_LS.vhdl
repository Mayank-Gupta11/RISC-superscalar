--Aaryan 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity EXEC_LS is
	port(
    RegB,RegA,Immediate_in:in std_logic_vector(15 downto 0);
    clock,reset,mem_wrt,mem_rd:in std_logic;                                                  ----- NO RESET
    Data_out:out std_logic_vector(15 downto 0);
    ZL:out std_logic
        );
end entity EXEC_LS; 

architecture behav of EXEC_LS is
        
    component adder_16 is                                              
        port(
        inp_a: in std_logic_vector(15 downto 0);
        adder_out: out std_logic_vector(15 downto 0);
        inp_b: in std_logic_vector(15 downto 0));
    end component;

    component Data_Memory is 
        port(clock,wr_e,r_e,reset: in std_logic;
            data: in std_logic_vector(15 downto 0);
            ADDR: in std_logic_vector(15 downto 0);  
            outpu: out std_logic_vector(15 downto 0));
    end component;

	component OR16 is
    port (inp_0: in std_logic_vector(15 downto 0);
    outp: out std_logic
    );
	end component OR16;
	 
    signal Address,Data_out_sig:std_logic_vector(15 downto 0);

begin
    Adder1: adder_16 port map(
        inp_a => RegB,
        inp_b => Immediate_in,
        adder_out => Address);

    Data_mem:Data_Memory port map(
        clock =>clock,
        reset => reset,
        wr_e =>mem_wrt,
        r_e => mem_rd,
        data => Address,
        ADDR =>RegA,
        outpu => Data_out_sig);
    
    ORGATE: OR16 port map(
        inp_0 => Data_out_sig,
        outp => ZL
    );
    Data_out <= Data_out_sig;
end architecture;