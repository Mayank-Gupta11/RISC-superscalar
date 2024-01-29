library IEEE;
use ieee.numeric_std.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity Free_Tags is
  Port (
    clk : in STD_LOGIC;
    reset : in STD_LOGIC;
    busy : in STD_LOGIC_VECTOR(63 downto 0);
    indices : out STD_LOGIC_VECTOR(11 downto 0)
  );
end Free_Tags;

architecture Behavioral of Free_Tags is
  
  begin
  
  process(clk, reset)
  	variable count : integer:= 0;
  begin
    if reset = '1' then
        count := 0;
        indices <= (others => '0');
    elsif rising_edge(clk) then 
        count := 0;
        for i in 0 to 63 loop
            if count < 2 then
                if busy(i) = '0' then
                    indices(count*6 + 5 downto count*6) <= std_logic_vector(to_unsigned(i, 6));
                    count :=count + 1;
                end if;
            elsif i = 63 then
                --PRF
            else
                exit;
            end if;
        end loop;

    end if;
  end process;
end Behavioral;