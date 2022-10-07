library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;

library work;
use work.project_pkg.all;

entity ro_puf is
	generic (
		ro_length: positive := 13;
		ro_count: positive := 2
	);
	port (
		reset: in std_logic;
		enable: in std_logic;
		challenge: in std_logic_vector(0 to 2 * positive(ceil(log2(real(ro_count / 2)))) - 1);
		response: out std_logic
	);
end entity ro_puf;

architecture ro_puf1 of ro_puf is
	signal counters_out: arr_std_logic(0 to ro_count - 1);
	signal counters_in: std_logic_vector(0 to ro_count - 1);
	
	signal mux_outs: arr_std_logic(0 to 1);
	
	constant mux_select_size: positive := challenge'length / 2;
		
	function power_of_two(num: in natural) return boolean is
		variable total_bits: integer := 0;
		variable iters: integer := 0;
		constant num_bits: integer := integer(ceil(log2(real(num))));
		constant num_vec: std_logic_vector := std_logic_vector(to_unsigned(num, num_bits));
	begin
		for i in num_vec'range loop
			iters := iters + 1;
			if num_vec(i) = '1' then
				total_bits := total_bits + 1;
			end if;
		end loop;
		return total_bits = 0;
	end function;
begin
	-- Ensure ro_count is a power of two (note: does not work as of now)
	assert power_of_two(ro_count) = true report "invalid ro count" severity error;
	
	counters: for stage in counters_out'range generate
		u0: counter
			port map (
				count => counters_in(stage),
				reset => reset,
				enable => enable,
				q => counters_out(stage)
			);
	end generate counters;
	
	ring_oscillators: for oscillator in counters_in'range generate
		u0: ring_oscillator
			generic map (
				ro_length => ro_length
			)
			port map (
				enable => enable,
				osc_out => counters_in(oscillator)
			);
	end generate ring_oscillators;
	
	muxes: for mu in 0 to 1 generate
		u0: mux
			generic map (
				select_size => mux_select_size
			)
			port map (
				sel => challenge(mu * challenge'length / 2 to challenge'length / 2 * (mu + 1) - 1),
				input => counters_out(mu * (counters_out'length / 2) to counters_out'length / 2 * (mu + 1) - 1),
				output => mux_outs(mu)
			);
	end generate muxes;
	
	response <= '1' when to_integer(unsigned(mux_outs(0))) > to_integer(unsigned(mux_outs(1))) else '0';
end architecture ro_puf1;