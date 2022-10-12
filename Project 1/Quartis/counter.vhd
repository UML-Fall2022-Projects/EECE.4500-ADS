library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity counter is
	generic(
		count_size: positive := 8
	);

	port(
		count: in std_logic;
		reset: in std_logic;
		enable: in std_logic;
		q: out std_logic_vector(count_size - 1 downto 0)
	);
end counter;

architecture implcounter of counter is
	signal output: std_logic_vector(q'range)
		:= (others => '0');
begin
	process(count, reset)
	begin
		if reset = '0' then
			output <= (others => '0');
		elsif enable = '1' then
			if (count'event and count = '1') then
				output <= output + 1;
			end if;
		end if;
	end process;
	
	q <= output;
end architecture implcounter;