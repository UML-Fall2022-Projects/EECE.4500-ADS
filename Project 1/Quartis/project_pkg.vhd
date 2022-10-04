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
	
	--ro_puf
	component ro_puf is
		generic (
			ro_length: positive := 13;
			ro_count: positive := 4
		);
		port (
			reset: in std_logic;
			enable: in std_logic;
			challenge: in std_logic_vector(0 to LOG(2, ro_count) - 1);
			response: out std_logic;
		);
	end component ro_puf;
end package;

package body project_pkg is
end package body project_pkg;