library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--package SchedulerTypes is
--	type OneBitArray is array (natural range <>) of std_logic;
--	type ControlArray is array (natural range <>) of std_logic_vector(41 downto 0);
--  end package;

entity Datapath is
	port(
	CLK, RST: in std_logic;
    Register_0, Register_1, Register_2, Register_3, Register_4, Register_5, Register_6, Register_7: out std_logic_vector(15 downto 0)
    );
end entity Datapath;

architecture behav of Datapath is

    component IF_stage is
        port(
        CLK, RST :in std_logic;
        Target_Add, PC_out: in std_logic_vector(15 downto 0);
        PC_src_sel : in std_logic;
        PC_in: out std_logic_vector(15 downto 0);
        Inst_outp: out std_logic_vector(31 downto 0);
        PC: out std_logic_vector(15 downto 0)
        );
    end component;

    component decode_buffer is 
	port(clock,reset,wr_en: in std_logic;
		--br_en
		PC_in : in std_logic_vector(15 downto 0);
		Inst_in: in std_logic_vector(31 downto 0);
	    Inst_out: out std_logic_vector(31 downto 0);
		PC_out  : out std_logic_vector(15 downto 0)
		);
    end component;

    component ID_stage is
        port(
            CLK, RST : in std_logic;
            Instructions: in std_logic_vector(31 downto 0);
            PC_in  : in std_logic_vector(15 downto 0);
            PC_out  : out std_logic_vector(15 downto 0);
            CTR1_out,CTR2_out:out std_logic_vector(41 downto 0);
            dep1,dep2: out std_logic
        );
    end component;

    component reservation_station is

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
        end component;

        component reg_read is
            port(
            CLK, RST :in std_logic;
            RF_A : in std_logic_vector(35 downto 0);
            RF_WR_A : in std_logic_vector(17 downto 0);
            RF_WR_D : in std_logic_vector(47 downto 0);
            pc_next : in std_logic_vector(15 downto 0); 
            wr_en1 : in std_logic_vector(2 downto 0);
            RAT_en : in std_logic_vector(1 downto 0);
            pc_en,reset_all : in std_logic;
            Retire_tag : in std_logic_vector(11 downto 0);
            Retire_en : in std_logic_vector(1 downto 0);
            valid_en : in std_logic_vector(1 downto 0);
            
            assign_add : in std_logic_vector(5 downto 0);      -- 3 bits each , actual register value (0-8)
            Retire_reg : in std_logic_vector(5 downto 0);
            opr_reg1 : in std_logic_vector(5 downto 0);
            opr_reg2 : in std_logic_vector(5 downto 0);
        
            WR_Tags : in std_logic_vector(11 downto 0);
            WR_CYs : in std_logic_vector(1 downto 0);
            WR_EN2 : in std_logic_vector(1 downto 0);
            -- valid_en : in std_logic_vector(1 downto 0);
            retire_valid : in std_logic_vector(1 downto 0);
            RD_Tags : in std_logic_vector(11 downto 0);
            opr_carry : in std_logic_vector(5 downto 0);
            -- Retire_hd: in std_logic_vector(11 downto 0);
            
        
            indices : out STD_LOGIC_VECTOR(11 downto 0);
            opr_ptr : out std_logic_vector(23 downto 0);
            opr_v : out std_logic_vector(3 downto 0);
            RF_L_D : out std_logic_vector(31 downto 0);
            RF_I1_D : out std_logic_vector(31 downto 0);
            RF_I2_D : out std_logic_vector(31 downto 0);
            pc_present : out std_logic_vector(15 downto 0);
        
            --cnt_head : out std_logic_vector(11 downto 0);      -- current Head 
            carry_valid : out std_logic;
            CY_out1 : out std_logic;
            CY_out0 : out std_logic;
            Register_0, Register_1, Register_2, Register_3, Register_4, Register_5, Register_6, Register_7: out std_logic_vector(15 downto 0)
        
        
            );
        end component;
    
    
    component Issue_buffer_int is
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
                CARRY_OUT:out std_logic--
                
                );
        end component;
    
        component Issue_buffer_LS is
            port(clock,reset,issued: in std_logic;
                imm_in,PC_ls: in std_logic_vector(15 downto 0);
                RF_L_D: in std_logic_vector(31 downto 0);
                mem_ctrl: in std_logic_vector(1 downto 0);
                RegA,RegB,imm_out,PC_out: out std_logic_vector(15 downto 0);
                mem_wrt,mem_rd ,issue: out std_logic
            );
            end component;
            
        component EXEC_INT is
            port(
            CLK, RST :in std_logic;
            PC, Immediate_in,RegB, RegA: in std_logic_vector(15 downto 0);
            alu_control_out: in std_logic_vector(2 downto 0);
            br_type: in std_logic_vector(1 downto 0);
            Alu_out_sel,alu_b_sel,RA_sel, RB_sel,PC_en,carry_in: in std_logic;
            PC_jmp,Ex_out: out std_logic_vector(15 downto 0);
            z_out,c_out,mispredict_bit: out std_logic
            ); -- removed zflag_en cflag_en CZ
        end component; 
    
    component EXEC_LS is
        port(
        RegB,RegA,Immediate_in:in std_logic_vector(15 downto 0);
        clock,reset,mem_wrt,mem_rd:in std_logic;                                                  ----- NO RESET
        Data_out:out std_logic_vector(15 downto 0);
        ZL:out std_logic
            );
    end component EXEC_LS; 
    
    component ROB is

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
        end component;

    component BTB is 
    port(clock,reset: in std_logic;
            PC_in1 : in std_logic_vector(15 downto 0);        -- PC_in1 for storing instruction 1 pc
            PC_in2 : in std_logic_vector(15 downto 0);        -- PC_in2 for storing instruction 2 pc
            TA_in1 : in std_logic_vector(15 downto 0);
            TA_in2 : in std_logic_vector(15 downto 0);
            btb_in : in std_logic_vector(15 downto 0);        -- pc value to be compared after mispredict was found
            btb_out : out std_logic_vector(15 downto 0);      -- ouptus 16 bit mispredict target values
            wr_en1 , wr_en2 : in std_logic);
    end component;

    signal target_add_btb_out, PC_out_IF, PC_in_IF, PC_IF, PC_in_RS,PC_out_DB,PC_out_ID, Imm_LS_RR, Imm_Int1_RR, Imm_Int2_RR, PC_ls_RR, PC_int1_RR, PC_int2_RR, PC_int1_IB, PC_int2_IB, Ex_out1_ROB, Ex_out2_ROB : std_logic_vector(15 downto 0);
    signal PC_src_sel, tag_int1_RR, tag_int2_RR, tag_ls_RR: std_logic;
    signal Inst_out_DB,RF_L_D_LS_buffer,Inst_outp_IF: std_logic_vector(31 downto 0);
    signal CTR1_out_ID,CTR2_out_ID: std_logic_Vector(41 downto 0);
    signal CNTRL_LS_RR, retire_en_RR, retire_valid_en_RR, valid_en_RR : std_logic_vector(1 downto 0);
    signal CNTRL_INT1_RR, CNTRL_INT2_RR: std_logic_vector(9 downto 0);
    signal retire_tags_RR, INDICES_RR, RD_TAGS_RR,Retire_tag_ROB: std_logic_vector(11 downto 0);
    signal dep1_ID, dep2_ID, CARRY_VALID_RR,PC_src_sel_ROB,PC_EN_ROB: std_logic;
    signal opr_ptr_RR : std_logic_vector(23 downto 0);
    signal opr_v_RR : std_logic_vector(3 downto 0);
    signal RF_A_RR : std_logic_vector(35 downto 0);
    signal RF_WR_A_RR : std_logic_vector(17 downto 0);
    signal RAT_en_RR,Retire_en_ROB,WR_CYs_ROB,valid_en_ROB: std_logic_vector(1 downto 0);
    signal assign_add_RR, opr_carry_RR,Retire_reg_RR: std_logic_vector(5 downto 0);
    signal RF_WR_D_RR : std_logic_vector(47 downto 0);
    signal Retire_reg_ROB, opr_reg1_RR, opr_reg2_RR: std_logic_vector(5 downto 0);
    signal btb_in_ROB, TA_in1_btb, TA_in2_btb:std_logic_vector(15 downto 0);
    signal RF_I1_D_RR, RF_I2_D_RR: std_logic_vector(31 downto 0);
    signal TAG_I1, TAG_I2,mem_wrt_LS,mem_rd_LS: std_logic;
    signal dest_reg1_ROB, dest_reg2_ROB : std_logic_vector(2 downto 0);
    signal RB_sel_int1, RB_sel_int2,RA_sel_int1, RA_sel_int2 ,Alu_out_sel_int1,Alu_out_sel_int2,PC_en_int1,PC_en_int2, mispredict_bit1_ROB, mispredict_bit2_ROB, reset_all:std_logic;
    signal Alu_control_out_int1, Alu_control_out_int2,wr_en_RR:std_logic_vector(2 downto 0);
    signal br_type_int1,br_type_int2: std_logic_vector(1 downto 0);
    signal RegA_int1,RegA_int2,RegB_int1,RegB_int2,Imm_in_int1,Imm_in_int2:std_logic_vector(15 downto 0);
    signal alu_b_sel_int1,alu_b_sel_int2,carry_out_int1,carry_out_int2, z1_ROB, c1_ROB, z2_ROB, c2_ROB, carry_int1_PCF, carry_int2_PCF:std_logic;
    signal Data_out_EXLS,RegA_LS,RegB_LS,Imm_out_LS,PC_out_LS: std_logic_vector(15 downto 0);
    signal ZL_EXLS:std_logic;
    signal issue_LS: std_logic;
    
begin

    IF1: IF_stage 
    port map(
        CLK => CLK,
        RST => RST,
        Target_Add => target_add_btb_out,
        PC_out =>PC_out_IF,
        PC_src_sel => PC_src_sel_ROB,
        PC_in => PC_in_IF,
        Inst_outp =>Inst_outp_IF,
        PC => PC_IF
        );

    decode_buffer1: decode_buffer
    port map(
        clock => CLK,
        reset => RST,
        wr_en => '1',
        PC_in => PC_IF,
        Inst_in => Inst_outp_IF,
        Inst_out => Inst_out_DB,
        PC_out => PC_out_DB
        );    

    ID1: ID_stage 
    port map(
        CLK => CLK,
        RST => RST,
        Instructions => Inst_out_DB,
        PC_in => PC_out_DB,
        PC_out => PC_out_ID,
        CTR1_out => CTR1_out_ID,
        CTR2_out => CTR2_out_ID,
        dep1 => dep1_ID,
        dep2 => dep2_ID
    );

    RS: reservation_station 
    port map(
        clock => CLK,
        reset => reset_all,
        OPR_TAGS => opr_ptr_RR, 
        OPR_V => opr_v_RR,
        CTR1 => CTR1_out_ID,
        CTR2 => CTR2_out_ID,
        EX_EN => wr_en_RR,
        RF_WR_A => RF_WR_A_RR,
        RETIRED_TAGS => retire_tags_RR,
        RETIRED_VALID_EN => retire_valid_en_RR,
        AWC_EN => valid_en_RR,
        RETIRED_EN => retire_en_RR,   
        PC_in => PC_out_ID,
        INDICES => INDICES_RR,
        CARRY_VALID => CARRY_VALID_RR,
        dep1 => dep1_ID,
        dep2 => dep2_ID,
        RF_A => RF_A_RR,
        PC_LS => PC_ls_RR,
        PC_INT1 => PC_int1_RR,
        PC_INT2 => PC_int2_RR,
        CNTRL_LS => CNTRL_LS_RR,
        CNTRL_INT1 => CNTRL_INT1_RR,
        CNTRL_INT2 => CNTRL_INT2_RR,
        Imm_LS => Imm_LS_RR,
        Imm_Int1 => Imm_Int1_RR,
        Imm_Int2 => Imm_Int2_RR,
        RD_TAGS => RD_TAGS_RR,
        tag_ls => tag_ls_RR,
        tag_int1 => tag_int1_RR,
        tag_int2 => tag_int2_RR,
        opr_carry => opr_carry_RR 
    );    
    
    RR: reg_read
    port map(
        CLK => CLK,
        RST => RST,
        RF_A => RF_A_RR,
        RF_WR_A => RF_WR_A_RR,
        RF_WR_D => RF_WR_D_RR,
        pc_next => PC_in_IF,
        wr_en1 => wr_en_RR,
        RAT_en => RAT_en_RR,
        pc_en => PC_EN_ROB,
        Retire_tag => Retire_tags_RR,
        Retire_en => retire_en_RR,
        valid_en => valid_en_RR,
        assign_add => assign_add_RR,
        Retire_reg => Retire_reg_RR,
        opr_reg1 => opr_reg1_RR,
        opr_reg2 => opr_reg2_RR,
        WR_Tags => RF_WR_A_RR(11 downto 0),
        WR_CYs => WR_CYs_ROB,
        WR_EN2 => wr_en_RR(1 downto 0),
        retire_valid => retire_valid_en_RR,
        RD_Tags => RD_TAGS_RR,
        opr_carry => opr_carry_RR,
        -- Retire_hd => Retire_hd,
        indices => INDICES_RR,
        opr_ptr => opr_ptr_RR,
        opr_v => opr_v_RR,
        RF_L_D => RF_L_D_LS_buffer,
        RF_I1_D => RF_I1_D_RR,
        RF_I2_D => RF_I2_D_RR,
        pc_present => PC_out_IF,
        carry_valid => CARRY_VALID_RR,
        CY_out1 => carry_int1_PCF,
        CY_out0 => carry_int2_PCF,
		reset_all => reset_all,
        Register_0 => Register_0,
        Register_1 => Register_1,
        Register_2 => Register_2,
        Register_3 => Register_3,
        Register_4 => Register_4,
        Register_5 => Register_5,
        Register_6 => Register_6,
        Register_7 => Register_7

    );                        
    
    IB1: Issue_buffer_int
    port map(
        clock => CLK,
        reset => reset_all,
        RF_I_D => RF_I1_D_RR,
        PC_I => PC_int1_RR,
        CARRY_IN => carry_int1_PCF ,
        ISSUED => tag_int1_RR,
        EXEC_CTRL => CNTRL_INT1_RR,
        IMM_I => Imm_Int1_RR,
        TAG_I => TAG_I1,
        PC => PC_int1_IB,
        RB_SEL => RB_sel_int1,
        RA_SEL => RA_sel_int1,
        ALU_OUT_SEL => Alu_out_sel_int1,
        BR_TYPE => br_type_int1,
        PC_EN => PC_en_int1,
        REGA => RegA_int1,
        ALU_B_SEL => alu_b_sel_int1,
        REGB => RegB_int1,
        IMM_IN => Imm_in_int1,
        ALU_CONTROL_OUT => Alu_control_out_int1,
        CARRY_OUT =>  carry_out_int1  
    );

    IB2: Issue_buffer_int
    port map(
        clock => CLK,
        reset => reset_all,
        RF_I_D => RF_I2_D_RR,
        PC_I => PC_int2_RR,
        CARRY_IN => carry_int2_PCF,
        ISSUED => tag_int2_RR,
        EXEC_CTRL => CNTRL_INT2_RR,
        IMM_I => Imm_Int2_RR,
        TAG_I => TAG_I2,
        PC => PC_int2_IB,
        RB_SEL => RB_sel_int2,
        RA_SEL => RA_sel_int2,
        ALU_OUT_SEL => Alu_out_sel_int2,
        BR_TYPE => br_type_int2,
        PC_EN => PC_en_int2,
        REGA => RegA_int2,
        ALU_B_SEL => alu_b_sel_int2,
        REGB => RegB_int2,
        IMM_IN => Imm_in_int2,
        ALU_CONTROL_OUT => Alu_control_out_int2,
        CARRY_OUT =>   carry_out_int2 
    );

    IB_LS: Issue_buffer_LS
    port map(
        clock => CLK,
        reset => reset_all,
        issued => tag_ls_RR, 
        imm_in => Imm_LS_RR, 
        PC_ls => PC_ls_RR,
        RF_L_D => RF_L_D_LS_buffer, 
        mem_ctrl => CNTRL_LS_RR,
        RegA => RegA_LS,
        RegB => RegB_LS,
        imm_out => Imm_out_LS,
        PC_out => PC_out_LS,
        mem_wrt => mem_wrt_LS,
        mem_rd => mem_rd_LS,
        issue => issue_LS
    );
           
    EI1: EXEC_INT
    port map(
        CLK => CLK,
        RST => RST,
        PC => PC_int1_IB,
        Immediate_in => Imm_in_int1,
        RegB => RegB_int1,
        RegA => RegA_int1,
        alu_control_out =>Alu_control_out_int1 ,
        br_type => br_type_int1,
        Alu_out_sel => Alu_out_sel_int1,
        alu_b_sel => alu_b_sel_int1,
        RA_sel => RA_sel_int1,
        RB_sel => RB_sel_int1,
        PC_en => PC_en_int1,
        carry_in => carry_out_int1,
        PC_jmp => TA_in1_btb,
        Ex_out => Ex_out1_ROB,
        z_out => z1_ROB,
        c_out => c1_ROB,
        mispredict_bit => mispredict_bit1_ROB
    );

    EI2: EXEC_INT
    port map(
        CLK => CLK,
        RST => RST,
        PC => PC_int2_IB,
        Immediate_in => Imm_in_int2,
        RegB => RegB_int2,
        RegA => RegA_int2,
        alu_control_out =>Alu_control_out_int2 ,
        br_type => br_type_int2,
        Alu_out_sel => Alu_out_sel_int2,
        alu_b_sel => alu_b_sel_int2,
        RA_sel => RA_sel_int2,
        RB_sel => RB_sel_int2,
        PC_en => PC_en_int2,
        carry_in => carry_out_int2,
        PC_jmp => TA_in2_btb,
        Ex_out => Ex_out2_ROB,
        z_out => z2_ROB,
        c_out => c2_ROB,
        mispredict_bit => mispredict_bit2_ROB 
    );

    EL: EXEC_LS
    port map(
        RegB => RegB_LS,
        RegA => RegA_LS,
        Immediate_in => Imm_out_LS,
        clock => CLK,
        reset => RST,
        mem_wrt => mem_wrt_LS,
        mem_rd => mem_rd_LS,
        Data_out => Data_out_EXLS,
        ZL => ZL_EXLS
    );

    ROB1: ROB
    port map(
        clock => CLK,
        reset => RST,
        Data_ls => Data_out_EXLS,
        mispredict_bit1 => mispredict_bit1_ROB,
        mispredict_bit2 => mispredict_bit2_ROB,
        PC => PC_out_ID,
        Ex_out1 => Ex_out1_ROB,
        Ex_out2 => Ex_out2_ROB,
        Free_Tags => INDICES_RR,
        tag_I1 => TAG_I1,
        tag_I2 => TAG_I2,
        tag_ls => issue_LS,
        c1_ifcarry => CTR1_out_ID(2),
        z1_ifzero => CTR1_out_ID(1),
        c2_ifcarry => CTR2_out_ID(2),
        z2_ifzero => CTR2_out_ID(1),
        c2_modify => CTR2_out_ID(4),
        z2_modify => CTR2_out_ID(3),
        c1_modify => CTR1_out_ID(4),
        z1_modify => CTR2_out_ID(3),
        PC_I1 => PC_int1_IB,
        PC_I2 => PC_int2_IB,
        PC_ls => PC_out_LS,
        dest_reg1 => dest_reg1_ROB,
        dest_reg2 => dest_reg2_ROB,
        c1 => c1_ROB,
        z1 => z1_ROB,
        c2 => c2_ROB,
        z2 => z2_ROB,
        zl => ZL_EXLS,
        br_en1 => CTR1_out_ID(12),
        br_en2 => CTR2_out_ID(12),
        reset_all => reset_all,
        Retire_tag => Retire_tags_RR,
        Retire_en => Retire_en_RR,
        Retire_reg => Retire_reg_RR,
        RAT_en => RAT_en_RR,
        PC_src_sel => PC_src_sel_ROB,
        btb_in => btb_in_ROB,
        PC_EN => PC_EN_ROB,
        WR_CYs => WR_CYs_ROB,
        RF_WR_A => RF_WR_A_RR,
        RF_WR_D => RF_WR_D_RR,
        WR_en_for_RAT => wr_en_RR,
        retire_valid => retire_valid_en_RR,
        valid_en => valid_en_RR
    );
    
    BTB1: BTB
    port map(
        clock => CLK,
        reset => RST,
        PC_in1 => PC_int1_IB,
        PC_in2 => PC_int2_IB,
        TA_in1 => TA_in1_btb,
        TA_in2 => TA_in2_btb,
        btb_in => btb_in_ROB,
        btb_out => target_add_btb_out,
        wr_en1 => PC_en_int1,
        wr_en2 => PC_en_int2
    );
    
    opr_reg1_RR <= CTR1_out_ID(41 downto 39) & CTR1_out_ID(38 downto 36);
    opr_reg2_RR <= CTR2_out_ID(41 downto 39) & CTR2_out_ID(38 downto 36);
    dest_reg1_ROB <= CTR1_out_ID(35 downto 33);
    dest_reg2_ROB <= CTR2_out_ID(35 downto 33);
    assign_add_RR(5 downto 3) <= dest_reg1_ROB;
    assign_add_RR(2 downto 0) <= dest_reg2_ROB;
    -- Register_0 <= Inst_outp_IF(31 downto 16) ;
end architecture;