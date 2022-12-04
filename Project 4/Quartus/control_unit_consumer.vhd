library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.project_pkg.all;

entity control_unit_consumer is
	generic (
		ADDR_WIDTH : natural := 6
	);
	port (
		clock: in std_logic;
		reset: in std_logic;
		head_ptr: in natural range 0 to 2**ADDR_WIDTH - 1;
		tail_ptr: buffer natural range 0 to 2**ADDR_WIDTH - 1
	);
end entity control_unit_consumer;

architecture cons_fsm of control_unit_consumer is
	-- Start sends signal to adc to start conversion
	-- Waiting waits for eoc signal AND for head ptr
	-- to be ahead or far enough behind the tail ptr (wrap around).
	-- Increment increments the head ptr.
	type state_type is
		(Init, Start, Waiting, Reading, Increment);

	signal state, next_state: state_type := Init;
	
	function abs_difference(
			a, b: in natural
		) return natural
	is
	begin
		if a > b then
			return a - b;
		else
			return b - a;
		end if;
	end function abs_difference;
	
	function valid_ptrs(
			head, tail: in natural
		) return boolean
	is
	begin
		if tail < head then
			return (head - tail) > 1;
		elsif tail = 2**ADDR_WIDTH - 1 then
			return head /= 0;
		else
			return true;
		end if;
	end function valid_ptrs;
begin
	transition_function: process(state) is
	begin
		next_state <= state;
		case (state) is
			when Init => next_state <= Start;
			when Start => next_state <= Waiting;
			when Waiting =>
				if valid_ptrs(head_ptr, tail_ptr) then
					next_state <= Increment;
				end if;
			when Increment => next_state <= Waiting;
			when others => next_state <= Start;
		end case;
	end process transition_function;
	
	save_state: process(clock) is
	begin
		if reset = '0' then
			state <= Init;
		elsif rising_edge(clock) then
			state <= next_state;
		end if;
	end process save_state;
	
	output_function: process(clock) is
	begin
		if reset = '0' then
			tail_ptr <= 2**ADDR_WIDTH - 1;
		elsif rising_edge(clock) then	
			if state = Init then
				tail_ptr <= 2**ADDR_WIDTH - 1;
			end if;
		
			if state = Increment then
				if tail_ptr >= 2**ADDR_WIDTH - 1 then
					tail_ptr <= 0;
				else
					tail_ptr <= tail_ptr + 1;
				end if;
			end if;
		end if;
	end process output_function;
end architecture cons_fsm;
