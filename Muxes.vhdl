-- Samar Agarwal, MG
-- completed
--any required mux can be easily added using the below template


-- 4 bit 2x1 MUX
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mux_2x1_3bit is
    port (inp_0: in std_logic_vector(2 downto 0);
    inp_1: in std_logic_vector(2 downto 0);
    outp: out std_logic_vector(2 downto 0);
    mux_op: in std_logic
    );
end entity mux_2x1_3bit;

architecture beh_2x1_3bit of mux_2x1_3bit is
    
begin
    p_2x1 : process( mux_op, inp_0, inp_1)
    begin
        if (mux_op = '0') then
            outp <= inp_0;
        else
            outp <= inp_1;
        end if ;
    end process ; -- p_2x1_3bit
    
    
end architecture beh_2x1_3bit;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mux_2x1_4bit is
    port (inp_0: in std_logic_vector(3 downto 0);
    inp_1: in std_logic_vector(3 downto 0);
    outp: out std_logic_vector(3 downto 0);
    mux_op: in std_logic
    );
end entity mux_2x1_4bit;

architecture beh_2x1_4bit of mux_2x1_4bit is
    
begin
    p_2x1 : process( mux_op, inp_0, inp_1)
    begin
        if (mux_op = '0') then
            outp <= inp_0;
        else
            outp <= inp_1;
        end if ;
    end process ; -- p_2x1_4bit
    
    
end architecture beh_2x1_4bit;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;



entity mux_2x1_16bit is
    port (inp_0: in std_logic_vector(15 downto 0);
    inp_1: in std_logic_vector(15 downto 0);
    outp: out std_logic_vector(15 downto 0);
    mux_op: in std_logic
    );
end entity mux_2x1_16bit;

architecture beh_2x1_16bit of mux_2x1_16bit is
    
begin
    p_2x1_16bit : process (inp_0,inp_1,mux_op)is
    begin
        if (mux_op = '0') then
            outp <= inp_0;
        else
            outp <= inp_1;
        end if ;
    end process ; -- p_2x1_16bit
    
    
end architecture beh_2x1_16bit;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;



entity mux_4x1_3bit is
    port (inp_0: in std_logic_vector(2 downto 0);
    inp_1: in std_logic_vector(2 downto 0);
    inp_2: in std_logic_vector(2 downto 0);
    inp_3: in std_logic_vector(2 downto 0);
    outp: out std_logic_vector(2 downto 0);
    mux_op: in std_logic_vector(1 downto 0)
    );
end entity mux_4x1_3bit;

architecture beh_4x1_3bit of mux_4x1_3bit is
    
begin
    p_4x1_3bit : process( mux_op, inp_0, inp_1, inp_2, inp_3 )
    begin
        if (mux_op = "00") then
            outp <= inp_0;
        elsif (mux_op = "01") then
            outp <= inp_1;
        elsif (mux_op = "10") then
            outp <= inp_2;
        else 
            outp <= inp_3;
        end if ;
    end process ; -- p_4x1_3bit
    
    
end architecture beh_4x1_3bit;


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mux_4x1_16bit is
    port (inp_0: in std_logic_vector(15 downto 0);
    inp_1: in std_logic_vector(15 downto 0);
    inp_2: in std_logic_vector(15 downto 0);
    inp_3: in std_logic_vector(15 downto 0);
    outp: out std_logic_vector(15 downto 0);
    mux_op: in std_logic_vector(1 downto 0)
    );
end entity mux_4x1_16bit;

architecture beh_4x1_16bit of mux_4x1_16bit is
    
begin
    p_4x1_16bit : process( mux_op, inp_0, inp_1, inp_2, inp_3 )
    begin
        if (mux_op = "00") then
            outp <= inp_0;
        elsif (mux_op = "01") then
            outp <= inp_1;
        elsif (mux_op = "10") then
            outp <= inp_2;
        else
            outp <= inp_3;
        end if ;
    end process ; -- p_4x1_16bit
    
    
end architecture beh_4x1_16bit;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity mux_8x1_16bit is
    port (inp_0: in std_logic_vector(15 downto 0);
    inp_1: in std_logic_vector(15 downto 0);
    inp_2: in std_logic_vector(15 downto 0);
    inp_3: in std_logic_vector(15 downto 0);
    inp_4: in std_logic_vector(15 downto 0);
    inp_5: in std_logic_vector(15 downto 0);
    inp_6: in std_logic_vector(15 downto 0);
    inp_7: in std_logic_vector(15 downto 0);
    outp: out std_logic_vector(15 downto 0);
    mux_op: in std_logic_vector(2 downto 0)
    );
end entity mux_8x1_16bit;

architecture beh_8x1_16bit of mux_8x1_16bit is
    
begin
    p_8x1_16bit : process( mux_op, inp_0, inp_1, inp_2, inp_3, inp_4,inp_5, inp_6, inp_7 )
    begin
        if (mux_op = "000") then
            outp <= inp_0;
        elsif (mux_op = "001") then
            outp <= inp_1;
        elsif (mux_op = "010") then
            outp <= inp_2;
        elsif (mux_op = "011") then
            outp <= inp_3;
        elsif (mux_op = "100") then
            outp <= inp_4;
        elsif (mux_op = "101") then
            outp <= inp_5;
        elsif (mux_op = "110") then
            outp <= inp_6;
        else 
            outp <= inp_7;
        end if ;
    end process ; -- p_8x1_16bit
    
    
end architecture beh_8x1_16bit;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;



entity mux_2x1_16bit_clk is
    port (inp_0: in std_logic_vector(15 downto 0);
    inp_1: in std_logic_vector(15 downto 0);
    outp: out std_logic_vector(15 downto 0);
    clk: in std_logic;
    mux_op: in std_logic
    );
end entity mux_2x1_16bit_clk;

architecture beh_2x1_16bit of mux_2x1_16bit_clk is
    
begin
    p_2x1_16bit : process(clk) is
    begin
        if (mux_op = '0') then
            outp <= inp_0;
        else
            outp <= inp_1;
        end if ;
    end process ; -- p_2x1_16bit
    
    
end architecture beh_2x1_16bit;

-- 16 bit 4*1 Mux
-- 16 bit 2*1 MUx
-- 16 bit 8*1 Mux
-- 3 bit  4*1 Mux
-- 3 bit 2*1 Mux
