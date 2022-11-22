library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.project_pkg.all;

entity control_unit_producer is
	port (
		clock: in std_logic;
		eoc: in std_logic;
		out soc: out std_logic;
	);
end entity control_unit_producter;