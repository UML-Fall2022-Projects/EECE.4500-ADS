library ieee;
use ieee.std_logic_1164.all;
use ieee.fixed_pkg.all;

use std.textio.all;

use work.fixed_complex.all;
use work.netpbm_config.all;

entity mandelbrot_netpbm_generator is
end entity mandelbrot_netpbm_generator;

architecture test_fixture of mandelbrot_netpbm_generator is

	component mandelbrot_pipeline is
		generic (
			iterations:	natural range 8 to 64		:= 32;
			int_bits:	natural range 3 to 12		:= 4;
			fract_bits:	natural range 6 to 36		:= 10;
			escape:		sfixed	:= to_sfixed(4, int_bits, -fract_bits)
		);
		port (
			enable:				in	std_logic;
			clock:				in	std_logic;
			reset:				in	std_logic;
			seed:				in	fcomplex(re(int_bits downto -fract_bits),
										im(int_bits downto -fract_bits));
	
			iteration_count:	out	natural range 0 to iterations - 1;
			output_valid:		out	boolean
		);
	end component mandelbrot_pipeline;


	signal iteration_test: natural range 0 to iterations + 1;

	signal seed: fcomplex(re(int_bits downto -fract_bits),
					im(int_bits downto -fract_bits));
	signal clock: std_logic		:= '0';
	signal reset: std_logic		:= '0';
	signal enable: std_logic	:= '0';

	signal iteration_count: natural range 0 to iterations;
	signal output_valid: boolean;

	signal finished: boolean	:= false;

begin

	clock <= not clock after 1 ps when not finished else '0';

	generator: mandelbrot_pipeline
		generic map (
			iterations => iterations,
			int_bits => int_bits,
			fract_bits => fract_bits,
			escape => escape
		)
		port map (
			enable => enable,
			clock => clock,
			reset => reset,
			seed => seed,

			iteration_count => iteration_count,
			output_valid => output_valid
		);
	
	make_pgm: process
		variable x_coord: sfixed(seed.re'range);
		variable y_coord: sfixed(seed.re'range);
		variable output_line: line;
	begin
		-- header information
		---- P2
		write(output_line, string'("P2"));
		writeline(output, output_line);
		---- resolution
		write(output_line, integer'image(x_steps) & string'(" ")
				& integer'image(y_steps));
		writeline(output, output_line);
		---- maximum value
		write(output_line, integer'image(iterations - 1));
		writeline(output, output_line);

		-- ensure generator is disabled
		enable <= '0';

		-- reset generator
		wait until rising_edge(clock);
		reset <= '1';
		wait until rising_edge(clock);
		reset <= '0';

		enable <= '1';

		for y_pt in 0 to y_steps-1 loop
			y_coord := resize(y_range.min + y_pt * dy,
						y_coord);
			for x_pt in 0 to x_steps-1 loop

				x_coord := resize(x_range.min + x_pt * dx, x_coord);

				-- set seed
				seed <= fcmplx(x_coord, y_coord);
				wait until rising_edge(clock);

				if output_valid then
					write(output_line, integer'image(iterations - 1 - iteration_count));
					writeline(output, output_line);
					flush(output);
				end if;
			end loop;
		end loop;

		for i in 0 to iterations - 1 loop
			wait until rising_edge(clock);
			write(output_line, integer'image(iterations - 1 - iteration_count));
			writeline(output, output_line);
			flush(output);
		end loop;

		-- all done
		finished <= true;
		wait;
	end process make_pgm;

end architecture test_fixture;
