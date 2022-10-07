library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

package project_pkg is
	-- type declarations
	type arr_std_logic is array (natural range <>) of std_logic_vector(0 to 7);
	
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
	
	--counter
	component counter is
		generic(
			count_size: positive := 8
		);

		port(
			count: in std_logic;
			reset: in std_logic;
			enable: in std_logic;
			q: out std_logic_vector(8 - 1 downto 0)
		);
	end component counter;
	
	--ro_puf
	component ro_puf is
		generic (
			ro_length: positive := 13;
			ro_count: positive := 4
		);
		port (
			reset: in std_logic;
			enable: in std_logic;
			challenge: in std_logic_vector(0 to positive(ceil(log2(real(ro_count)))) - 1);
			response: out std_logic
		);
	end component ro_puf;
	
	-- mux
	component mux is
		generic (
			select_size: positive
		);
		port(
			sel: in std_logic_vector(0 to select_size - 1);
			input: in arr_std_logic(0 to 2**select_size-1);
			output: out std_logic_vector(0 to 7)
		);
	end component mux;
	
	component ram is
		port (
			address: IN STD_LOGIC_VECTOR (5 DOWNTO 0);
			clock: IN STD_LOGIC  := '1';
			data: IN STD_LOGIC_VECTOR (0 DOWNTO 0);
			wren: IN STD_LOGIC;
			q: OUT STD_LOGIC_VECTOR (0 DOWNTO 0)
		);
	end component ram;
end package;

package body project_pkg is
end package body project_pkg;