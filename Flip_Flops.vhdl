library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Flip3 is
  port (
    D: in std_logic_vector(2 downto 0);
    EN: in std_logic;
    RST: in std_logic;
    CLK: in std_logic;
    Q: out std_logic_vector(2 downto 0));
end entity Flip3;

architecture Behav of Flip3 is
begin
    process(D,En,CLK,rst)
	begin
	if rst = '1' then
		Q <= (others =>'0');
	elsif falling_edge(CLK) then
		if EN = '1' then
			Q <= D;
		end if;
	end if;
	end process;

    end architecture;


    library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Flip1 is
	port(D: in std_logic;
		  EN: in std_logic;
		  RST: in std_logic;
		  CLK: in std_logic;
		  Q: out std_logic);
end entity Flip1;

architecture Behav of Flip1 is

begin
	process(D,En,CLK,rst)
	begin
		if rst = '1' then
			Q <= '0';
		elsif falling_edge(CLK) then
			if EN = '1' then
				Q <= D;
			end if;
		end if;
	end process;

end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Flip6 is
	port(D: in std_logic_vector(5 downto 0);
		  EN: in std_logic;
		  RST: in std_logic;
		  CLK: in std_logic;
		  Q: out std_logic_vector(5 downto 0));
end entity Flip6;

architecture Behav of Flip6 is

begin
	process(D,En,CLK,rst)
	begin
		if rst = '1' then
			Q <= (others =>'0');
		elsif falling_edge(CLK) then
			if EN = '1' then
				Q <= D;
			end if;
		end if;
	end process;

end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Flip8 is
	port(D: in std_logic_vector(7 downto 0);
		  EN: in std_logic;
		  RST: in std_logic;
		  CLK: in std_logic;
		  Q: out std_logic_vector(7 downto 0));
end entity Flip8;

architecture Behav of Flip8 is

begin
	process(D,En,CLK,rst)
	begin
		if rst = '1' then
			Q <= (others =>'0');
		elsif falling_edge(CLK) then
			if EN = '1' then
				Q <= D;
			end if;
		end if;
	end process;

end architecture;