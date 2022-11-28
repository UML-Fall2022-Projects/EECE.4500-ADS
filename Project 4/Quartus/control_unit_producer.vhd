library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.project_pkg.all;

entity control_unit_producer is
	generic (
		ADDR_WIDTH : natural := 6;
		PTR_TOLERANCE: natural := 2
	);
	port (
		clock: in std_logic;
		reset: in std_logic;
		tail_ptr: in natural range 0 to 2**ADDR_WIDTH - 1;
		eoc: in std_logic;
		soc: out std_logic;
		buffer_write: out std_logic; -- TODO: ask if this is active high or low
		head_ptr: buffer natural range 0 to 2**ADDR_WIDTH - 1
	);
end entity control_unit_producer;

architecture prod_fsm of control_unit_producer is
	-- Start sends signal to adc to start conversion
	-- Waiting waits for eoc signal AND for head ptr
	-- to be ahead or far enough behind the tail ptr (wrap around).
	-- Increment increments the head ptr.
	type state_type is
		(Start, Waiting, Store, Increment);

	signal state, next_state: state_type := Start;
	
	-- Retains eoc signal if eoc goes high while waiting for head_ptr and
	-- tail_ptr to distance from each other
	signal saved_eoc: std_logic;
	
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
begin
	transition_function: process(state) is
	begin
		next_state <= state;
		case (state) is
			when Start => next_state <= Waiting;
			when Waiting =>
				if saved_eoc = '1' and abs_difference(head_ptr, tail_ptr) >= PTR_TOLERANCE then
					next_state <= Store;
				end if;
			when Store => next_state <= Increment;
			when Increment => next_state <= Start;
			when others => next_state <= Start;
		end case;
	end process transition_function;
	
	save_state: process(clock) is
	begin
		if reset = '0' then
			state <= Start;
		elsif rising_edge(clock) then
			state <= next_state;
		end if;
	end process save_state;
	
	output_function: process(clock) is
	begin
		if reset = '0' then
			soc <= '0';
			head_ptr <= 0;
			buffer_write <= '0'; -- TODO: See declaration
		elsif rising_edge(clock) then
			if state = Start then
				soc <= '1';
			else
				soc <= '0';
			end if;
			
			if state = Waiting then
				saved_eoc <= eoc or saved_eoc;
			else
				saved_eoc <= '0';
			end if;
			
			if state = Store then
				buffer_write <= '1';
			else
				buffer_write <= '0';
			end if;
			
			if state = Increment then
				if head_ptr >= 2**ADDR_WIDTH - 1 then
					head_ptr <= 0;
				else
					head_ptr <= head_ptr + 1;
				end if;
			end if;
		end if;
	end process output_function;
end architecture prod_fsm;
