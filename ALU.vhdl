--Aaryan 

library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ALU is
    port(alu_op: in std_logic_vector(1 downto 0);
    inp_a: in std_logic_vector(15 downto 0);
    inp_b: in std_logic_vector(15 downto 0);
    in_carry,comp: in std_logic;
    out_c: out std_logic;
    out_z: out std_logic;
    alu_out: out std_logic_vector(15 downto 0));
end entity;

architecture behav of ALU is
    
begin
   Alu: process(alu_op, inp_a, inp_b, in_carry,comp)
   variable temp_out, temp_a, temp_b : std_logic_vector(16 downto 0);
   variable in_carry_sig: std_logic:= '0';
   begin

    temp_out := (others => '0');

    temp_a(15 downto 0) := inp_a;
    temp_a(16) := '0';

    if comp='1' then 
        temp_b(15 downto 0):=not(inp_b);
    else temp_b(15 downto 0):=inp_b;
	 end if;
	 
    temp_b(16) := '0';

    if alu_op = "00" then
        temp_out := std_logic_vector(unsigned(temp_a)+unsigned(temp_b));
    elsif alu_op = "01" then
        temp_out := std_logic_vector(unsigned(temp_a)+unsigned(temp_b)+1);
    elsif alu_op = "10" then
        temp_out(15 downto 0) := inp_a nand inp_b;
        temp_out(16) := '0';
    elsif comp='0' then
        temp_out := std_logic_vector(unsigned(temp_a)-unsigned(temp_b));
    else
        temp_out:=temp_b;
        temp_out(16) := '0';
    end if;

    if temp_out(15 downto 0) = "0000000000000000" then
        out_z <= '1';
    else
        out_z <= '0';
    end if;

    out_c <= temp_out(16);
    alu_out <= temp_out(15 downto 0);
    
   end process Alu;
    
end architecture behav;