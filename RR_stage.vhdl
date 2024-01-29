library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.SchedulerTypes.all;

entity reg_read is
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
end entity reg_read;

architecture behav of reg_read is

    component PRF is
        port(clock,reset: in std_logic;
		RF_A : in std_logic_vector(35 downto 0);
		RF_WR_A : in std_logic_vector(17 downto 0);
		RF_WR_D : in std_logic_vector(47 downto 0);
		
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
		reset_all : in std_logic;
		
		opr_ptr : out std_logic_vector(23 downto 0);
		opr_v : out std_logic_vector(3 downto 0);
		RF_L_D : out std_logic_vector(31 downto 0);
		RF_I1_D : out std_logic_vector(31 downto 0);
		RF_I2_D : out std_logic_vector(31 downto 0);
		pc_present : out std_logic_vector(15 downto 0);
		busy_out : out std_logic_vector(63 downto 0);
		Register_0, Register_1, Register_2, Register_3, Register_4, Register_5, Register_6, Register_7: out std_logic_vector(15 downto 0)
		
		);
    end component;

    component RAT is

		port(clock,reset: in std_logic;
			-- RD_OPR : in std_logic_vector(17 downto 0);         -- Read operands 2* operands(3bits) *3(int,int,load_store)
			-- OPR_EN : in std_logic_vector(5 downto 0);           -- 6 bits corresponds to 6 operands (2 in 3 each )
			-- WB_A : in std_logic_vector(5 downto 0);            -- destination bits for 2 different instructions
			assign_add : in std_logic_vector(5 downto 0);      -- 3 bits each , actual register value (0-8)
			-- Retire_en : in std_logic_vector(2 downto 0);           -- 0 if branch , 1 if write ..each write is independent 
			Retire_en : in std_logic_vector(1 downto 0);           -- 0 if branch , 1 if write ..each write is independent 
			RAT_en : in std_logic_vector(1 downto 0);          -- 
			Retire_reg : in std_logic_vector(5 downto 0);
			opr_reg1 : in std_logic_vector(5 downto 0);
			opr_reg2 : in std_logic_vector(5 downto 0);
			Retire_tag : in std_logic_vector(11 downto 0);
			
			
			hd_not_to_reset : out HeadArray(7 downto 0);
			opr_hd : out std_logic_vector(23 downto 0);
			-- CNT_WR_TAG : out std_logic_vector(11 downto 0);    -- current write TAG 
			cnt_head : out std_logic_vector(11 downto 0);      -- current Head 
			Retire_hd: out std_logic_vector(11 downto 0)
		);
		end component;

    component Free_Tags is
        Port (
            clk : in STD_LOGIC;
            reset : in STD_LOGIC;
            busy : in STD_LOGIC_VECTOR(63 downto 0);
            indices : out STD_LOGIC_VECTOR(11 downto 0)
          );
    end component;   

    component PCF is
        port(clock,reset: in std_logic;
		WR_Tags : in std_logic_vector(11 downto 0);
		WR_CYs : in std_logic_vector(1 downto 0);
		WR_EN : in std_logic_vector(1 downto 0);
		valid_en : in std_logic_vector(1 downto 0);
		Retire_en : in std_logic_vector(1 downto 0);
		retire_valid : in std_logic_vector(1 downto 0);
		RD_Tags : in std_logic_vector(11 downto 0);
		opr_carry : in std_logic_vector(5 downto 0);
		Retire_hd: in std_logic_vector(11 downto 0);
		Retire_tag : in std_logic_vector(11 downto 0);

		carry_valid : out std_logic;
		CY_out1 : out std_logic;
		CY_out0 : out std_logic
		);
    end component;

--signal prvs_tag_sig, cnt_head_sig, cnt_wr_tag_sig  : std_logic_vector(11 downto 0);
--signal rf_d1_sig: std_logic_vector(35 downto 0);
signal opr_hd_signal: std_logic_vector(23 downto 0);
signal busy_out_sig: std_logic_vector(63 downto 0);	
signal retire_head_signal, new_ptrs_signal,cnt_head_sig: std_logic_vector(11 downto 0); 
signal heads: HeadArray(7 downto 0);
  
begin
    PRF1: PRF port map(
		clock => CLK,
		reset => RST,
        RF_A => RF_A,
		RF_WR_A => RF_WR_A,
		RF_WR_D => RF_WR_D,
		
		cnt_head => cnt_head_sig,
		new_ptrs => new_ptrs_signal,
		pc_next => pc_next,
		wr_en => wr_en1,
		RAT_en => RAT_en,
		-- RD_en : in std_logic_vector(1 downto 0);
		pc_en => pc_en,
		Retire_hd=> retire_head_signal, 
		Retire_tag => Retire_tag,
		Retire_en => Retire_en,
		opr_hd => opr_hd_signal,
		valid_en => valid_en,
		retire_valid => retire_valid,--1 if ADC valid, otherwise 0
		hd_not_to_reset => heads,
		reset_all => reset_all,
		
		opr_ptr => opr_ptr,
		opr_v => opr_v,
		RF_L_D => RF_L_D,
		RF_I1_D => RF_I1_D,
		RF_I2_D => RF_I2_D,
		pc_present => pc_present,
		busy_out => busy_out_sig,
		Register_0 => Register_0,
        Register_1 => Register_1,
        Register_2 => Register_2,
        Register_3 => Register_3,
        Register_4 => Register_4,
        Register_5 => Register_5,
        Register_6 => Register_6,
        Register_7 => Register_7
		
        );  

    RAT1: RAT port map(
        clock => CLK,
        reset => RST,
		assign_add  => assign_add,     -- 3 bits each , actual register value (0-8)
		-- Retire_en : in std_logic_vector(2 downto 0);           -- 0 if branch , 1 if write ..each write is independent 
		Retire_en  =>  Retire_en ,      -- 0 if branch , 1 if write ..each write is independent 
		RAT_en  =>  RAT_en,      -- 
		Retire_reg  => Retire_reg,
		opr_reg1  => opr_reg1,
		opr_reg2  => opr_reg2,
		Retire_tag  => Retire_tag,
		
		opr_hd  => opr_hd_signal,
		hd_not_to_reset => heads,
		-- CNT_WR_TAG : out std_logic_vector(11 downto 0);    -- current write TAG 
		cnt_head  =>  cnt_head_sig,   -- current Head 
		Retire_hd => retire_head_signal
    );

    free_tags1: Free_Tags port map(
        clk => CLK,
        reset => RST,
        busy => busy_out_sig,
        indices => new_ptrs_signal
    );

    PCF1: PCF port map(
        clock =>CLK,
        reset=> reset_all,
		WR_Tags => WR_Tags,
		WR_CYs => WR_CYs,
		WR_EN=> wr_en2,
		valid_en => valid_en,
		Retire_en => Retire_en,
		retire_valid =>retire_valid,
		RD_Tags =>RD_TAGS,
		opr_carry => opr_carry,
		Retire_hd=> retire_head_signal,
		Retire_tag => Retire_tag,

		carry_valid => carry_valid,
		CY_out1 =>CY_out1,
		CY_out0 =>CY_out0
    );
    INDICES<=new_ptrs_signal;
end architecture;