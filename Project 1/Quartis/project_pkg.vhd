library ieee;
use ieee.std_logic_1164.all;

package project_pkg is
	---- component declarations
	--ring_oscillator
	component ring_oscillator is
		generic(
			ro_length: positive := 13
		);
		port (
			enable: in std_logic;
			osc_out: out std_logic
		);
	end component ring_oscillator;
end package;

package body project_pkg is
end package body project_pkg;