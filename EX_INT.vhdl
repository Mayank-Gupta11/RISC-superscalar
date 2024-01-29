--Aaryan 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity EXEC_INT is
	port(
	CLK, RST :in std_logic;
	PC, Immediate_in,RegB, RegA: in std_logic_vector(15 downto 0);
    alu_control_out: in std_logic_vector(2 downto 0);
    br_type: in std_logic_vector(1 downto 0);
    Alu_out_sel,alu_b_sel,RA_sel, RB_sel,PC_en,carry_in: in std_logic;
    PC_jmp,Ex_out: out std_logic_vector(15 downto 0);
    z_out,c_out,mispredict_bit: out std_logic
	); -- removed zflag_en cflag_en CZ
end entity EXEC_INT; 

architecture behav of EXEC_INT is

    component ALU is
    port(alu_op: in std_logic_vector(1 downto 0);
    inp_a: in std_logic_vector(15 downto 0);
    inp_b: in std_logic_vector(15 downto 0);
    in_carry,comp: in std_logic;
    out_c: out std_logic;
    out_z: out std_logic;
    alu_out: out std_logic_vector(15 downto 0));
    end component;

    component Flip1 is
        port(
            D: in std_logic;
            EN: in std_logic;
            RST: in std_logic;
            CLK: in std_logic;
            Q: out std_logic);
    end component;

    component mux_2x1_16bit is
        port (inp_0: in std_logic_vector(15 downto 0);
        inp_1: in std_logic_vector(15 downto 0);
        outp: out std_logic_vector(15 downto 0);
        mux_op: in std_logic);
    end component;

    component mux_4x1_3bit is
        port (inp_0: in std_logic_vector(2 downto 0);
        inp_1: in std_logic_vector(2 downto 0);
        inp_2: in std_logic_vector(2 downto 0);
        inp_3: in std_logic_vector(2 downto 0);
        outp: out std_logic_vector(2 downto 0);
        mux_op: in std_logic_vector(1 downto 0)
        );
    end component mux_4x1_3bit;

    component adder_2 is
        port(
            inp_a: in std_logic_vector(15 downto 0);
            adder_out: out std_logic_vector(15 downto 0)
        );
    end component;
        
    component adder_16 is                                              
        port(
        inp_a: in std_logic_vector(15 downto 0);
        adder_out: out std_logic_vector(15 downto 0);
        inp_b: in std_logic_vector(15 downto 0));
    end component;

    component left_shift1 is 
        port(
        input: in std_logic_vector(15 downto 0);
        output: out std_logic_vector(15 downto 0));
    end component;
    
    component brancher is
        port(
        br_type: in std_logic_vector(1 downto 0);
        PC_en,C_flag,Z_flag: in std_logic;
        PC_src: out std_logic
        );
    end component brancher;

    signal alu_b_src_out,alu_outp,PC_2,IMM_x2,Adder_mux,PC_RA_out,PC_RIn: std_logic_vector(15 downto 0);
    signal zflag, cflag: std_logic:= '0';

begin
    
    alu_out_Set_MUX: mux_2x1_16bit port map(
        inp_0 => PC_2, 
        inp_1 => alu_outp,
        mux_op => Alu_out_sel, 
        outp => Ex_out);

    ALU_SRC_b: mux_2x1_16bit port map(
        inp_0 => RegB, 
        inp_1 => Immediate_in, 
        mux_op => alu_b_sel, 
        outp => alu_b_src_out);

    ALU1: ALU port map(
        alu_op => alu_control_out(2 downto 1),
        inp_a => RegA,
        inp_b => alu_b_src_out,
        in_carry => carry_in,
        comp =>alu_control_out(0),
        out_c => cflag,
        out_z => zflag,
        alu_out => alu_outp
        );
            
    Add2:adder_2 port map(
        inp_a =>PC,
        adder_out =>PC_2
    );

    brancher1: brancher
        port map(
            br_type => br_type,
            PC_en => PC_en,
            C_flag => cflag,
            Z_flag => zflag,
            PC_src => mispredict_bit
        );

    Adder1: adder_16 port map(
        inp_a => PC_RIn,
        inp_b => Adder_mux,
        adder_out => PC_jmp);

    left_shifter: left_shift1 port map(
        input => Immediate_in,
        output => IMM_x2);

    PC_RA_MUX: mux_2x1_16bit port map(
        inp_0 =>PC,
        inp_1 => RegA, 
        mux_op => RA_sel, 
        outp => PC_RA_out);

    PC_RB_MUX: mux_2x1_16bit port map(
        inp_0 => PC_RA_out, 
        inp_1 => RegB, 
        mux_op => RB_sel, 
        outp => PC_RIn);

    Imm_0_MUX: mux_2x1_16bit port map(
        inp_0 => IMM_x2, 
        inp_1 => "0000000000000000", 
        mux_op => RB_sel, 
        outp => Adder_mux);

    z_out <= zflag;
    c_out <= cflag;

end architecture;