--Aaryan Devesh

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Decoder is
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
end entity;

architecture behav of Decoder is
    --PC_next <= ID_in(31 downto 16);
    component sign_extender_6 is 
        port(
        inpu : in std_logic_vector (5 downto 0) ;
        outpu : out std_logic_vector (15 downto 0)
        );
    end component sign_extender_6;

    component sign_extender_9 is 
        port(
        inpu : in std_logic_vector (8 downto 0) ;
        outpu : out std_logic_vector (15 downto 0)
        );
    end component sign_extender_9;

signal SE6: std_logic_vector(5 downto 0);
signal SE9: std_logic_vector(8 downto 0);
signal se6_out,se9_out: std_logic_vector(15 downto 0);
signal OP_Code: std_logic_vector(3 downto 0);
begin

SE_6: sign_extender_6 port map(inpu => SE6, outpu => se6_out);
SE_9: sign_extender_9 port map(inpu => SE9, outpu => SE9_out);

PROCESS (ID_in,SE6_out,SE9_out,OP_Code)
variable var_imm16 : std_logic_vector(15 downto 0):= (others => '0');
begin
--Declarations are reamining
--    PC_next <= ID_in(31 downto 16)
OP_Code <= ID_in(15 downto 12);
RA <= ID_in(11 downto 9); 
RB <= ID_in(8 downto 6);
    -- RC <= ID_in(5 downto 3);

--RC
if(OP_Code = "0001" or OP_Code="0010") then
    dest <= ID_in(5 downto 3);
elsif(OP_Code = "0000") then
    dest <= ID_in(8 downto 6);
elsif(OP_Code = "1100" or OP_Code = "1101" or OP_Code = "0011") then
    dest <= ID_in(11 downto 9); 
else dest <= ID_in(5 downto 3);
end if;

--CZ & Complement
if (OP_Code = "0001") or (OP_Code = "0010")   then
    CZ <= ID_in(1 downto 0);
    Complement<= ID_in(2);
else 
    CZ <="00" ;
    Complement<= '0';
end if;

--Modify CZ
if (OP_Code(3 downto 1) = "000") then
    Flag_modify<= "11";
elsif(OP_Code = "0010" or OP_Code="0100") then 
    Flag_modify <= "01";
else Flag_modify <= "00";
end if;

--alu_op
if((OP_Code = "0001") or (OP_Code = "0000"))  then
    ALU_op(1) <= '0' ;
    ALU_op(0) <= ID_in(0) and ID_in(1) ;
    Complement <= ID_in(2);
elsif(OP_Code = "0010") then
    ALU_op(1) <= '1' ;
    ALU_op(0) <= '0' ;
    Complement <= ID_in(2);
elsif((OP_Code = "1000") or (OP_Code = "1001")) then
    ALU_op <="11";
    Complement <= '0';
elsif(OP_Code = "0011") then
    ALU_op <= "11";
    complement <= '1' ;
else
    ALU_op <= "00" ;
    complement <='0';
end if;

--Alu_out_sel
    if((OP_Code = "1100") or (OP_Code = "1101"))  then
    Alu_out_sel<='1' ;
    else
    Alu_out_sel<='0' ;
    end if;

--Alu_b_sel
if((OP_Code = "0000") or (OP_Code = "0011"))  then
    Alu_b_mux<='1' ;
else
    Alu_b_mux<='0' ;
end if;

--Pc_en
if(OP_Code(3) = '1')  then
    PC_en<='1' ;
else
    PC_en<='0' ;
end if;

--br_type
    if(OP_Code = "1000")   then
    br_type<="01" ;
    elsif(OP_Code = "1001") then
    br_type<="10" ;
    -- elsif(OP_Code = "1010") then
    -- br_type<="11" ;
    else 
     br_type<="00" ;
    end if;
    
--RA_sel
    if(OP_Code = "1111")   then
    RA_sel<='1' ;
    else 
    RA_sel<='0' ;
    end if;
--RB_sel
    if(OP_Code = "1101")   then
    RB_sel<='1' ;
    else 
    RB_sel<='0' ;
    end if;

--Mem_wrt and Mem_rd
if(OP_Code = "0100") then
    m_r_e  <='1';
    m_wr_e <='0';
elsif (OP_Code = "0101") then
    m_r_e  <='0';
    m_wr_e <='1';
else
    m_r_e  <='0';
    m_wr_e <='0';
end if;

--wb 
if(OP_Code = "0001" or OP_Code="0010" or OP_Code="0000" or OP_Code(3 downto 1)="110" or OP_Code="0011") then
    wb <='1';
else wb <='0';
end if;
--Imm
SE6 <= "000000";
SE9 <= "000000000";

if(ID_in(15 downto 12)="0001" or ID_in(15 downto 12)="0010") then
    SE6 <= "000000";
    SE9 <= "000000000";
elsif((ID_in(15 downto 12) = "0000") or (ID_in(15 downto 12) = "0100") or (ID_in(15 downto 12) = "0101") 
or (ID_in(15 downto 12) = "1000") or (ID_in(15 downto 12) = "1001") or (ID_in(15 downto 12) = "1010")
or (ID_in(15 downto 12) = "1101")) then 
    SE6 <= ID_in(5 downto 0);
elsif(not(ID_in(15 downto 12) = "0011" or ID_in(15 downto 12) = "1110")) then 
    SE9 <= ID_in(8 downto 0);
    end if;
end process;
--Imm
process (ID_in,SE9_out,se6_out,OP_Code)  

begin
if((OP_Code = "0001") or (OP_Code = "0010")) then
    Imm16 <= "0000000000000000";
elsif((OP_Code = "0000") or (OP_Code = "0100") or (OP_Code = "0101") 
or (OP_Code = "1000") or (OP_Code = "1001") or (OP_Code = "1010")
or (OP_Code = "1101")) then 
    Imm16 <= SE6_out;
else   
    if(not(OP_Code = "0011" or OP_Code = "1110")) then     
        Imm16 <= SE9_out;
    else 
        Imm16 <= "0000000" & ID_in(8 downto 0);
    end if;
end if ;
end process;

end behav;
