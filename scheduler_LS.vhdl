--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;

--package SchedulerTypes is
--  type OneBitArray is array (natural range <>) of std_logic;
--  type ControlArray is array (natural range <>) of std_logic_vector(41 downto 0);
--end package;

library ieee;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.SchedulerTypes.all;

entity scheduler is
  Port (
    clk : in STD_LOGIC;
    reset : in STD_LOGIC;
    Ready : in OneBitArray(63 downto 0);
    control_bits : in ControlArray(63 downto 0);
    indices : out STD_LOGIC_VECTOR(11 downto 0);
    issued : out std_logic_vector(1 downto 0)
  );
end scheduler;

architecture Behavioral of scheduler is
--  signal count_l : integer := 0;
  signal count_i : integer := 0;
  signal issue : std_logic_vector(1 downto 0):= "00";

begin
  process(clk, reset)
  begin
    if reset = '1' then
        -- count_l <= 0;
        count_i <= 0;
        indices <= (others => '0');
    elsif rising_edge(clk) then 
      -- count_l <= 0;
      count_i <= 0;
      for i in 0 to 63 loop
            -- if count_l < 1 and (control_bits(i)(3) = '1' or control_bits(i)(4) = '1')and Ready(i) = '1' then
            --     indices(17 downto 12) <= std_logic_vector(to_unsigned(i,6));
            --     issue(2) <= '1'; 
            --     count_l <= 1;
            -- end if;    
            if count_i < 2 and (control_bits(i)(3) = '0' and control_bits(i)(4) = '0')and Ready(i) = '1' then
                indices(count_i * 6 + 5 downto count_i * 6) <= std_logic_vector(to_unsigned(i,6));
                issue(count_i) <= '1'; 
                count_i <= count_i + 1;    
            end if;
            if  count_i = 2 then
                exit;
            end if;
                  
        end loop;

    end if;
  end process;
issued <= issue; 
end Behavioral;