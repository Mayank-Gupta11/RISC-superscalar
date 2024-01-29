-- Devesh
-- (10% branch+10% jump 64) 20% of 64 = 12~ 16 size of BTB buffer
-- | PC | Target address |
-- 16 bit comparator
-- ROB makes pc_en =0 if mispeculated predicted

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity BTB is 

port(clock,reset: in std_logic;
	 PC_in1 : in std_logic_vector(15 downto 0);        -- PC_in1 for storing instruction 1 pc
     PC_in2 : in std_logic_vector(15 downto 0);        -- PC_in2 for storing instruction 2 pc
     TA_in1 : in std_logic_vector(15 downto 0);
     TA_in2 : in std_logic_vector(15 downto 0);
     btb_in : in std_logic_vector(15 downto 0);        -- pc value to be compared after mispredict was found
   	 btb_out : out std_logic_vector(15 downto 0);      -- ouptus 16 bit mispredict target values
     wr_en1 , wr_en2 : in std_logic);
end entity;

architecture behav of BTB is

type reg is array(0 to 15) of std_logic_vector(15 downto 0);
type addr is array(0 to 15) of std_logic_vector(3 downto 0);

signal PC_value: reg:=(others=>(others=>'0'));
signal target_value: reg:=(others=>(others=>'0'));
signal pc_addr: std_logic_vector(3 downto 0):= "0000";
begin

process(clock,reset,PC_in1,PC_in2,TA_in1,TA_in2,btb_in,PC_value,target_value,pc_addr)
begin
	if reset='1' then 
		PC_value <= (others=>(others=>'0'));
		target_value <= (others=>(others=>'0'));
		pc_addr <= "0000";
	elsif falling_edge(clock) then
		if wr_en1 = '1' and wr_en2 = '0' then
			PC_value(to_integer(unsigned(pc_addr))) <= PC_in1;
			target_value(to_integer(unsigned(pc_addr))) <= TA_in1;	
			pc_addr	<= std_logic_vector(unsigned(pc_addr) + 1);			 		  
		elsif wr_en1 = '0' and wr_en2 = '1' then 
			PC_value(to_integer(unsigned(pc_addr))) <= PC_in2;
			target_value(to_integer(unsigned(pc_addr))) <= TA_in2;	
			pc_addr	<= std_logic_vector(unsigned(pc_addr) + 1);			 		  
		elsif wr_en1 = '1' and wr_en2 = '1' then
			PC_value(to_integer(unsigned(pc_addr))) <= PC_in1;
			target_value(to_integer(unsigned(pc_addr))) <= TA_in1;
			PC_value(to_integer(unsigned(pc_addr)) +1) <= PC_in2;
			target_value(to_integer(unsigned(pc_addr))+1) <= TA_in2;	
			pc_addr	<= std_logic_vector(unsigned(pc_addr) + 2);			 		  
		end if;
	end if;
end process;

process(clock, reset, btb_in, PC_value, target_value)
begin
    if reset = '1' then
        btb_out <= (others => '0');
    elsif rising_edge(clock) then
        -- Default value if no match found
        --btb_out <= (others => '0');

		for i in 0 to 15 loop                      -- Iterate through stored PC values
            if PC_value(i) = btb_in then
                btb_out <= target_value(i);        -- Match found, assign corresponding target value
                exit;                              -- Exit loop since we found a match
            end if;
        end loop;
    end if;
end process;

end architecture behav;			
