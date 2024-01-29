	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sign_extender_6 is 
port(
    inpu : in std_logic_vector (5 downto 0) ;
    outpu : out std_logic_vector (15 downto 0)
    );
end entity sign_extender_6;

architecture arch of sign_extender_6 is
begin
    outpu(5 downto 0) <= inpu;
    outpu(15 downto 6) <= (others =>inpu(5));

end architecture ; -- arch


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sign_extender_9 is 
port(
    inpu : in std_logic_vector (8 downto 0) ;
    outpu : out std_logic_vector (15 downto 0)
    );
end entity sign_extender_9;

architecture arch of sign_extender_9 is
begin
    outpu(8 downto 0) <= inpu;
    outpu(15 downto 9) <= (others =>inpu(8));

end architecture ; -- arch





