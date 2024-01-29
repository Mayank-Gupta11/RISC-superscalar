library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity LM_SM is
    port(
        CLK, RST, FU_wr_en : in std_logic;
        ID_in: in std_logic_vector(15 downto 0);
        LW_sel,wr_en: out std_logic;
        LW_inst: out std_logic_vector(15 downto 0)
        );
end entity;

architecture hehe of LM_SM is
    
    component Flip3 is
        port (
          D: in std_logic_vector(2 downto 0);
          EN: in std_logic;
          RST: in std_logic;
          CLK: in std_logic;
          Q: out std_logic_vector(2 downto 0));
      end component Flip3;
      
    component Flip8 is
        port(D: in std_logic_vector(7 downto 0);
              EN: in std_logic;
              RST: in std_logic;
              CLK: in std_logic;
              Q: out std_logic_vector(7 downto 0));
    end component Flip8;
    
    component adder_3 is
        port(
        inp_a: in std_logic_vector(2 downto 0);
        adder_out: out std_logic_vector(2 downto 0);
        inp_b: in std_logic_vector(2 downto 0));
    end component;
        
    component Logical_Unit is
        port(
            ID_in: in std_logic_vector(15 downto 0);
            FU_wr_en: in std_logic;
            Imm3_in: in std_logic_vector(2 downto 0);
            Reg8_in: in std_logic_vector(7 downto 0); -- Flip Flop input 
            Reg8_out: out std_logic_vector(7 downto 0); -- output to flip flop Reg
            LW_Inst: out std_logic_vector(15 downto 0); -- which bit has one in the 8 bit given 
            PR1_en,LW_sel,Internal_Imm3_reset: out std_logic
        );
    end component;

signal int_rst: std_logic;
signal Imm3_in,Imm3_out: std_logic_vector(2 downto 0);
signal Imm8_in,Imm8_out: std_logic_vector(7 downto 0);
signal Add_imm_rs: std_logic;

begin
    Add_imm_rs <= RST or int_rst;

    Add_imm : Flip3
        port map(
          D => Imm3_in ,
          EN => FU_wr_en,
          RST => Add_imm_rs ,
          CLK =>CLK ,
          Q => imm3_out
        );    
    Imm8 : Flip8
        port map(
            D => Imm8_in,
            EN => FU_wr_en,
            RST =>RST,
            CLK =>CLK,
            Q => Imm8_out
            );
    LU: Logical_Unit 
        port map(
            ID_in => ID_in,
            FU_wr_en => FU_wr_en,
            Imm3_in => Imm3_out,
            Reg8_in => Imm8_out, -- input from Flip Flop
            Reg8_out =>Imm8_in, -- output to flip flop Reg
            LW_Inst => LW_Inst, -- which bit has one in the 8 bit given 
            PR1_en => wr_en,
            LW_sel => LW_sel,
            Internal_Imm3_reset => int_rst
            );

    AdderLM : adder_3 
        port map(
            inp_a => imm3_out,
            adder_out => imm3_in,
            inp_b => "001"
        );
    
process(Imm8_out,Imm3_out,Imm8_in,Imm3_in)
begin
    report "Imm3_in-------> "&integer'image(to_integer(unsigned(Imm3_in)));
    report "Imm8_in-------> "&integer'image(to_integer(unsigned(Imm8_in)));
    report "Imm3_out-------> "&integer'image(to_integer(unsigned(Imm3_out)));
    report "Imm8_out-------> "&integer'image(to_integer(unsigned(Imm8_out)));

end process;
    
end architecture;