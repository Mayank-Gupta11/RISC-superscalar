library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Logical_Unit is
    port(
        ID_in: in std_logic_vector(15 downto 0);
        FU_wr_en: in std_logic;
        Imm3_in: in std_logic_vector(2 downto 0);
        Reg8_in: in std_logic_vector(7 downto 0); -- input from flip flop 
        Reg8_out: out std_logic_vector(7 downto 0); -- output to flip flop Reg
        LW_Inst: out std_logic_vector(15 downto 0); -- which bit has one in the 8 bit given 
        Internal_Imm3_reset: out std_logic := '0';
        PR1_en,LW_sel:out std_logic
	);
end entity;
architecture hehe of Logical_Unit is

signal last_bit,reg8_address: std_logic_vector(2 downto 0);
signal reg8_out_mask: std_logic_vector(7 downto 0) := "11111111";
signal start_sig: std_logic;    
signal fourcase: std_logic_vector(1 downto 0); 
signal LW_inst_sig: std_logic_vector(15 downto 0);

begin
proc : process(Reg8_in,FU_wr_en,ID_in,Imm3_in,fourcase,start_sig,reg8_address,last_bit)

begin

    --Check from R7 to R0 for the first register to be loaded
    if(reg8_in(0)='1') then
        reg8_address <= "111";
        reg8_out<= reg8_in and "11111110";
    elsif(reg8_in(1)='1') then
        reg8_address <= "110";
        reg8_out<= reg8_in and "11111101";
    elsif(reg8_in(2)='1') then
        reg8_address <= "101";
        reg8_out<= reg8_in and "11111011";
    elsif(reg8_in(3)='1') then
        reg8_address <= "100";
        reg8_out<= reg8_in and "11110111";
    elsif(reg8_in(4)='1') then
        reg8_address <= "011";
        reg8_out<= reg8_in and "11101111";
    elsif(reg8_in(5)='1') then
        reg8_address <= "010";
        reg8_out<= reg8_in and "11011111";
    elsif(reg8_in(6)='1') then
        reg8_address <= "001";
        reg8_out<= reg8_in and "10111111";
    elsif(reg8_in(7)='1') then
        reg8_address <= "000";
        reg8_out<= reg8_in and "01111111";
    elsif fourcase ="01" then 
        if(ID_in(7 downto 0)(0)='1') then
            reg8_address <= "111";
            reg8_out<= ID_in(7 downto 0) and "11111110";
        elsif(ID_in(7 downto 0)(1)='1') then
            reg8_address <= "110";
            reg8_out<= ID_in(7 downto 0) and "11111101";
        elsif(ID_in(7 downto 0)(2)='1') then
            reg8_address <= "101";
            reg8_out<= ID_in(7 downto 0) and "11111011";
        elsif(ID_in(7 downto 0)(3)='1') then
            reg8_address <= "100";
            reg8_out<= ID_in(7 downto 0) and "11110111";
        elsif(ID_in(7 downto 0)(4)='1') then
            reg8_address <= "011";
            reg8_out<= ID_in(7 downto 0) and "11101111";
        elsif(ID_in(7 downto 0)(5)='1') then
            reg8_address <= "010";
            reg8_out<= ID_in(7 downto 0) and "11011111";
        elsif(ID_in(7 downto 0)(6)='1') then
            reg8_address <= "001";
            reg8_out<= ID_in(7 downto 0) and "10111111";
        elsif(ID_in(7 downto 0)(7)='1') then
            reg8_address <= "000";
            reg8_out<= ID_in(7 downto 0) and "01111111";
        else 
            reg8_address <= "000";
            reg8_out <= reg8_in and "00000000";    
        end if;
    else 
        reg8_address <= "000";
        reg8_out <= reg8_in and "00000000";
    end if;
    
    if(reg8_in="00000000") then 
        start_sig <= '1';
    else start_sig <='0';
    end if;
    -- FINDING THE LAST BIT 
    if(reg8_in(7) = '1') then
        last_bit <= "000";
    elsif(reg8_in(6)='1') then
        last_bit <= "001";
    elsif(reg8_in(5)='1') then
        last_bit <= "010";
    elsif(reg8_in(4)='1') then
        last_bit <= "011";
    elsif(reg8_in(3)='1') then
        last_bit <= "100";
    elsif(reg8_in(2)='1') then
        last_bit <= "101";
    elsif(reg8_in(1)='1') then
        last_bit <= "101";
    elsif(reg8_in(0)='1') then
        last_bit <= "111";
    else 
        last_bit <= "111";
    end if;
end process proc;

process(ID_in,start_sig,last_bit,reg8_address)
begin

    if(not((ID_in(15 downto 12)="0110")or (ID_in(15 downto 12)="0111"))) then
        fourcase <= "00";
        Internal_Imm3_reset <= '1';
        
    elsif(start_sig ='1' and ((ID_in(15 downto 12)="0110") or (ID_in(15 downto 12)="0111"))) then
        fourcase <= "01";
        Internal_Imm3_reset <= '0';

    elsif (reg8_address=last_bit) then --COMPARING IF THE PRESENT BIT AND THE LAST BIT IS SAME
        fourcase <= "11";
        Internal_Imm3_reset <= '0';
    else 
        Internal_Imm3_reset <= '0';
        fourcase <= "10";
    end if;
end process;

process(FU_wr_en,fourcase,ID_in,reg8_address,Imm3_in)
begin
--PR1_en     
    if(FU_wr_en='1') then
        if(fourcase= "00" or fourcase="11") then
            PR1_en <='1';
        else
            PR1_en <='0';
        end if;
    else PR1_en <='0';
    end if;

--LW_sel 
    if(fourcase="00") then
        LW_sel <= '0';
        report "LW_sel-------> 0";

    else 
        LW_sel <= '1';
        report "LW_sel-------> 1";

    end if;

--Instruction OUT
    if(ID_in(15 downto 12)="0110") then
        LW_inst_sig(15 downto 12) <= "0100";
    elsif(ID_in(15 downto 12)="0111") then
        LW_inst_sig(15 downto 12)<= "0100";
    else LW_inst_sig(15 downto 12) <= "1110";
    end if;
end process;

process(LW_Inst_sig,fourcase) 
begin 
    report "LW_Inst-------> "&integer'image(to_integer(unsigned(LW_Inst_sig)));
    report "fourcase-------> "&integer'image(to_integer(unsigned(fourcase)));

end process;


LW_inst_sig(11 downto 9) <= reg8_address;
LW_inst_sig(8 downto 6) <= ID_in(11 downto 9);  
LW_inst_sig(5 downto 0) <= "000" & Imm3_in;

LW_inst <= LW_inst_sig;
end architecture;