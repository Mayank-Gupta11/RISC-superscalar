--Aaryan

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ID_stage is
    port(
        CLK, RST : in std_logic;
        Instructions: in std_logic_vector(31 downto 0);
		PC_in  : in std_logic_vector(15 downto 0);
		PC_out  : out std_logic_vector(15 downto 0);
		CTR1_out,CTR2_out:out std_logic_vector(41 downto 0);
        dep1,dep2: out std_logic
	);
end entity;

architecture behav of ID_stage is
    --PC_next <= ID_in(31 downto 16);
    component Decoder is
    port(
        ID_in: in std_logic_vector(15 downto 0);        --each instruction 16bits 

        RA: out std_logic_vector(2 downto 0);           -- 3bits will be converted to 6 bits in RAT 
        RB: out std_logic_vector(2 downto 0);
        dest: out std_logic_vector(2 downto 0);         --RC wala 
        Imm16: out std_logic_vector(15 downto 0);       -- sign extended immediate bits
        RB_sel: out std_logic;                          -- 
        RA_sel: out std_logic;
        br_type:out std_logic_vector(1 downto 0);       -- to be used in brancher 
        PC_en: out std_logic;      
        ALU_b_mux: out std_logic;                      
        Alu_out_sel:out std_logic;   -- 
        ALU_op:out std_logic_vector(1 downto 0);        -- Total 4 instructions + complement
        Complement: out std_logic;                      -- r type complement bit 
        m_wr_e: out std_logic;                          -- memory write enable
        m_r_e: out std_logic;                           -- memory read enable
        Flag_modify: out std_logic_vector(1 downto 0);  -- which to modify 
        CZ: out std_logic_vector(1 downto 0);           -- condition bits 
        wb: out std_logic
	);
end component;
    -- component LM_SM is
        -- port(
            -- CLK, RST, FU_wr_en : in std_logic;
            -- ID_in: in std_logic_vector(15 downto 0);
            -- LW_sel,wr_en: out std_logic;
            -- LW_inst: out std_logic_vector(15 downto 0)
        -- );
    -- end component;

    -- component mux_2x1_16bit is
        -- port (inp_0: in std_logic_vector(15 downto 0);
        -- inp_1: in std_logic_vector(15 downto 0);
        -- outp: out std_logic_vector(15 downto 0);
        -- mux_op: in std_logic);
    -- end component;
signal CTR1,CTR2: std_logic_vector(41 downto 0);

    
begin
    Instruction_Decoder1 : Decoder 
        port map(
		ID_in=> Instructions(31 downto 16),        --each instruction 16bits 
        RA=> CTR1(41 downto 39),           -- 3bits will be converted to 6 bits in RAT 
        RB=> CTR1(38 downto 36),
        dest=>CTR1(35 downto 33),         --RC wala 
        Imm16=>CTR1(32 downto 17),       -- sign extended immediate bits
        RB_sel=>CTR1(16),                 -- 
        RA_sel=>CTR1(15),
        br_type=>CTR1(14 downto 13),       -- to be used in brancher 
        PC_en=>CTR1(12),      
        ALU_b_mux=>CTR1(11),                      
        Alu_out_sel=>CTR1(10),   -- 
        ALU_op=>CTR1(9 downto 8),        -- Total 4 instructions + complement
        Complement=> CTR1(7),                      -- r type complement bit 
        m_wr_e=> CTR1(6),                      -- memory write enable
        m_r_e=> CTR1(5),                           -- memory read enable
        Flag_modify=> CTR1(4 downto 3),  -- which to modify 
        CZ=>  CTR1(2 downto 1),           -- condition bits 
        wb=>  CTR1(0)
        );
    
        Instruction_Decoder2 : Decoder 
        port map(
		ID_in=> Instructions(15 downto 0),        --each instruction 16bits 

        RA=> CTR2(41 downto 39),           -- 3bits will be converted to 6 bits in RAT 
        RB=> CTR2(38 downto 36),
        dest=>CTR2(35 downto 33),         --RC wala 
        Imm16=>CTR2(32 downto 17),       -- sign extended immediate bits
        RB_sel=>CTR2(16),                          -- 
        RA_sel=>CTR2(15),
        br_type=>CTR2(14 downto 13),       -- to be used in brancher 
        PC_en=>CTR2(12),      
        ALU_b_mux=>CTR2(11),                      
        Alu_out_sel=>CTR2(10),   -- 
        ALU_op=>CTR2(9 downto 8),        -- Total 4 instructions + complement
        Complement=> CTR2(7),                      -- r type complement bit 
        m_wr_e=> CTR2(6),                      -- memory write enable
        m_r_e=> CTR2(5),                           -- memory read enable
        Flag_modify=> CTR2(4 downto 3),  -- which to modify 
        CZ=>  CTR2(2 downto 1),           -- condition bits 
        wb=>  CTR2(0)
        );
    
    PC_out <= PC_in;
    
    process(CTR1,CTR2)
    begin
    if(CTR1(35 downto 33)=CTR2(41 downto 39)) then 
        dep1 <='1';
    else dep1 <= '0';
	 end if;
	 
    if(CTR1(35 downto 33)=CTR2(38 downto 36)) then 
        dep2 <='1';
    else dep2 <= '0';
	 end if;
    end process;

    CTR1_out <=CTR1;
    CTR2_out <= CTR2;
    end behav;