library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity OR16 is
    port (inp_0: in std_logic_vector(15 downto 0);
    outp: out std_logic
    );
end entity OR16;

architecture beh_2x1_3bit of OR16 is
    signal sig: std_logic := '0';
begin
    process(inp_0,sig)
    begin
        sig <='0';
        for i in 0 to 14 loop 
            sig <= inp_0(i) or sig;

        end loop;                     
    end process ;
    outp <=not(sig);
    
end architecture beh_2x1_3bit;
