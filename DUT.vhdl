library ieee;
use ieee.std_logic_1164.all;
entity DUT is
   port(input_vector: in std_logic_vector(1 downto 0);
       output_vector: out std_logic_vector(127 downto 0)
			);
end entity;

architecture DutWrap of DUT is
	component Datapath is
		port(
			CLK, RST :in std_logic;
			Register_0, Register_1, Register_2, Register_3, Register_4, Register_5, Register_6, Register_7: out std_logic_vector(15 downto 0)
																	);
	end component;
begin
   -- input/output vector element ordering is critical,
   -- and must match the ordering in the trace file!
  dut_instance : Datapath 
		port map(
			CLK => input_vector(1),
			RST => input_vector(0),
			Register_0 => output_vector(127 downto 112),
			Register_1 => output_vector(111 downto 96),
			Register_2 => output_vector(95 downto 80),
			Register_3 => output_vector(79 downto 64),
			Register_4 => output_vector(63 downto 48),
			Register_5 => output_vector(47 downto 32),
			Register_6 => output_vector(31 downto 16),
			Register_7 => output_vector(15 downto 0)
			
			);

end DutWrap;
