library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.project_pkg.all;

entity mux is
	generic (
		select_size: positive
	);
	port(
		sel: in std_logic_vector(0 to select_size - 1);
		input: in arr_std_logic(0 to 2**select_size-1);
		output: out std_logic_vector(0 to 7)
	);
end entity mux;

architecture mux1 of mux is

begin
	output <= input(to_integer(unsigned(sel)));
end architecture mux1;
