library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;

library work;
use work.project_pkg.all;

entity control_unit is
	generic (
		clock_freq: positive := 50000000;
		probe_delay: positive := 100;
		ro_count: positive := 16
	);
	port (
		reset: in std_logic;
		clock: in std_logic;
		done: out std_logic
	);
end entity control_unit;

architecture cu1 of control_unit is
	type state_type is
		(Init, Reset_PUF, Provide_Challenge, Deassert_Reset,
			Assert_Enable, Wait_Time, Deassert_Enable,
			Set_Write_Enable, Next_Challenge, Done);

	constant num_challenges: positive := ro_count**2 / 4;
	
	--signal reset: std_logic := '1';
	--signal enable: std_logic := '0';
	signal challenge: std_logic_vector(0 to 2 * positive(ceil(log2(real(ro_count / 2)))) - 1);
	--signal write_mem: std_logic := '1';
	--signal response: std_logic;
	signal wait_counter_value: positive;
	signal state, next_state: state_type;
begin
	
	transition_function: process(state, challenge, wait_counter_value) is
	begin
		next_state <= state;
		case (state) is
			when Init => next_state <= Reset_PUF;
			when Reset_PUF => next_state <= Provide_Challenge;
			--- more when stuff
			when Wait_Time =>
	
				if wait_counter_value = some_top_value then
					next_state <= Deassert_Enable;
				else
					next_state <= Wait_Time;
				end if;
			-- more when statements
			when others => next_state <= Init;
		end case;
	end process transition_function;
	
	save_state: process(clock, reset) is
	begin
		if reset = '0' then
			state <= Init;
		elsif rising_edge(clock) then
			state <= next_state;
		end if;
	end process save_state;
	
	-- output function
	output_function: process(clock, reset) is
	begin
		if reset = '0' then
			reset_puf <= '0';
			enable_puf <= '0';
			ram_write_enable <= '0';
			wait_counter_value <= 0;
		elsif rising_edge(clock) then
			reset_puf <= '0' when state = Reset_PUF else '1';
			enable_puf <= '1' when state = Assert_Enable or state = Wait_Time else '0';
			ram_write_enable <= '1' when state = Set_Write_Enable else '0';
			wait_counter_value <= (wait_counter_value + 1) if state = Wait_Time else 0;
		end if;
	end process output_function;
	
	-- snip
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
end architecture cu1;
