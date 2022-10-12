library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

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
		reset_ro_puf: out std_logic;
		enable_ro_puf: out std_logic;
		ram_write_enable: out std_logic;
		challenge: buffer std_logic_vector(0 to 2 * positive(ceil(log2(real(ro_count / 2)))) - 1);
		done: out std_logic
	);
end entity control_unit;

architecture cu1 of control_unit is
	type state_type is
		(Init, Reset_PUF, Provide_Challenge, Deassert_Reset,
			Assert_Enable, Wait_Time, Deassert_Enable,
			Set_Write_Enable, Next_Challenge, Done_State);

	constant num_challenges: positive := ro_count**2 / 4;
	constant clock_delay: integer := integer(real(clock_freq) / real(1e6) * real(probe_delay));
	
	signal wait_counter_value: integer := 0;
	signal state, next_state: state_type;
begin
	
	transition_function: process(state, wait_counter_value) is
	begin
		next_state <= state;
		case (state) is
			when Init => next_state <= Reset_PUF;
			when Reset_PUF => next_state <= Provide_Challenge;
			when Provide_Challenge => next_state <= Deassert_Reset;
			when Deassert_Reset => next_state <= Assert_Enable;
			when Assert_Enable => next_state <= Wait_Time;
			when Wait_Time =>
				-- Greater than is just to be safe.
				if wait_counter_value >= clock_delay then
					next_state <= Deassert_Enable;
				else
					next_state <= Wait_Time;
				end if;
			when Deassert_Enable => next_state <= Set_Write_Enable;
			when Set_Write_Enable =>
				if to_integer(unsigned(challenge)) < num_challenges - 1 then
					next_state <= Next_Challenge;
				else
					next_state <= Done_State;
				end if;
			when Next_Challenge => next_state <= Reset_PUF;
			when Done_State => next_state <= Done_State;
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
			reset_ro_puf <= '1';
			enable_ro_puf <= '0';
			ram_write_enable <= '0';
			wait_counter_value <= 0;
			challenge <= (others => '0');
			done <= '0';
		elsif rising_edge(clock) then
			if state = Init then
				reset_ro_puf <= '1';
				enable_ro_puf <= '0';
				ram_write_enable <= '0';
				wait_counter_value <= 0;
				challenge <= (others => '0');
				done <= '0';
			end if;
		
			if state = Reset_PUF then
				reset_ro_puf <= '0';
			else
				reset_ro_puf <= '1';
			end if;
			
			if state = Assert_Enable or state = Wait_Time then
				enable_ro_puf <= '1';
			else
				enable_ro_puf <= '0';
			end if;
			
			if state = Set_Write_Enable then
				ram_write_enable <= '1';
			else
				ram_write_enable <= '0';
			end if;
			
			if state = Wait_Time then
				wait_counter_value <= wait_counter_value + 1;
			else
				wait_counter_value <= 0;
			end if;
			
			if state = Next_Challenge then
				challenge <= challenge + 1;
			end if;
			
			if state = Done_State then
				done <= '1';
			else
				done <= '0';
			end if;
		end if;
	end process output_function;
end architecture cu1;
