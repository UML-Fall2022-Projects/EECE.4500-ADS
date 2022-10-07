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
		-- reset: in std_logic;
		clock: in std_logic;
		done: out std_logic
	);
end entity toplevel;

architecture toplevel1 of toplevel is
	constant num_challenges: positive :=  ro_count**2 / 4;
	
	signal reset: std_logic := '1';
	signal enable: std_logic := '0';
	signal current_challenge: std_logic_vector(0 to 2 * positive(ceil(log2(real(ro_count / 2)))) - 1);
	signal write_mem: std_logic := '1';
	signal response: std_logic;
	signal stage: std_logic;
	signal accumulated_time: positive;
begin
	assert ro_length >= 13 report "ro length too small!" severity error;
	assert ro_count >= 16 report "ro count too small!" severity error;
	
	process(clock) is
	begin
		
	end process;
	
	process(clock, reset) is
	begin
		if rising_edge(clock) then
			write_mem := '0';
			if reset = '0' then
				done <= '0';
				current_challenge <= (others => '0');
			end if;
			
			if done <= '1' then
				reset <= '0';
				enable <= '1';
				current_challenge <= std_logic_vector(to_unsigned(challenge, current_challenge'length));
				reset <= '1';
				--wait for probe_delay us;
				
				enable <= '0';
				-- Store to RAM
				write_mem = '1';
				
				if current_challenge = std_logic_vector(to_unsigned(num_challenge - 1, current_challenge'length)) then
					done <= '1';
				end if;
				
				-- increment challenge
				current_challenge <= std_logic_vector(to_unsigned(to_integer(unsigned(current_challenge)) + 1, current_challenge'length));
			end if;
		end if;
	end process;
	
	puf: ro_puf
		generic map (
			ro_length <= ro_length,
			ro_count <= ro_count
		)
		port map (
			reset <= reset,
			enable <= enable,
			challenge <= current_challenge,
			response <= response
		);
	
	mem: ram
		port map (
			address <= current_challenge,
			clock <= clock,
			data <= response,
			wren <= write_mem
		);
end architecture toplevel1;
