library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;

library work;
use work.project_pkg.all;

entity toplevel is
	generic (
		clock_freq: positive := 50000000;
		probe_delay: positive := 100;
		ro_length: positive := 13;
		ro_count: positive := 16
	);
	port (
		reset: in std_logic;
		clock: in std_logic;
		done: out std_logic
	);
end entity toplevel;

architecture toplevel1 of toplevel is
	constant num_challenges: positive :=  ro_count**2 / 4;
	
	signal enable_puf, reset_puf: std_logic := '0';
	signal challenge: std_logic_vector(0 to 2 * positive(ceil(log2(real(ro_count / 2)))) - 1);
	signal write_mem: std_logic := '0';
	signal response: std_logic;
	signal response_vec: std_logic_vector(0 to 0) := (others => '0');
begin
	assert ro_length >= 13 report "ro length too small!" severity error;
	assert ro_count >= 16 report "ro count too small!" severity error;
	
	cu: control_unit
		generic map (
			clock_freq => clock_freq,
			probe_delay => probe_delay,
			ro_count => ro_count
		)
		port map (
			reset => reset,
			clock => clock,
			reset_ro_puf => reset_puf,
			enable_ro_puf => enable_puf,
			ram_write_enable => write_mem,
			challenge => challenge,
			done => done
		);
	
	puf: ro_puf
		generic map (
			ro_length => ro_length,
			ro_count => ro_count
		)
		port map (
			reset => reset_puf,
			enable => enable_puf,
			challenge => challenge,
			response => response
		);
	
	mem: ram
		port map (
			address => challenge,
			clock => clock,
			data => response_vec,
			wren => write_mem
		);
        
    response_vec(0) <= response;
end architecture toplevel1;
