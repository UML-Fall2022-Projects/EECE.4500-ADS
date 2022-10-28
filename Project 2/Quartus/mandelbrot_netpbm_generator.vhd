library ieee;
use ieee.std_logic_1164.all;

use std.textio.all;

library work;
use work.netpbm_config.all;

library ads;
use ads.ads_fixed.all;
use ads.ads_complex_pkg.all;

entity mandelbrot_netpbm_generator is
end entity mandelbrot_netpbm_generator;

architecture test_fixture of mandelbrot_netpbm_generator is
	component mandelbrot_gen is
		generic (
            iterations: natural := 16;
            threshold: natural := 4
        );
        port (
            coords: in ads_complex;
            vga_clock: in std_logic;
            reset: in std_logic;
            enable: in std_logic;
            
            index_o: out natural
        );
	end component mandelbrot_gen;

	signal iteration_test: natural range 0 to iterations + 1;

	signal seed: ads_complex;
	signal clock: std_logic	:= '0';
	signal reset: std_logic	:= '0';
	signal enable: std_logic := '0';

	signal iteration_count: natural;
	signal output_valid_counter: natural := 0;

	signal finished: boolean := false;
    
    signal threshold: natural := 4;
begin

	clock <= not clock after 1 ps when not finished else '0';
        
    generator: mandelbrot_gen
		generic map (
            iterations => iterations,
            threshold => threshold
        )
        port map (
            coords => seed,
            vga_clock => clock,
            reset => reset,
            enable => enable,
            
            index_o => iteration_count
        );
	
	make_pgm: process
		variable x_coord: ads_sfixed;
		variable y_coord: ads_sfixed;
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
			y_coord := to_ads_sfixed(y_range.min) + to_ads_sfixed(y_pt) * dy;
			for x_pt in 0 to x_steps-1 loop
				x_coord := to_ads_sfixed(x_range.min) + to_ads_sfixed(x_pt) * dx;

				-- set seed
				seed <= ads_cmplx(x_coord, y_coord);
				wait until rising_edge(clock);
                
                if output_valid_counter < iterations + 1 then
                    output_valid_counter <= output_valid_counter + 1;
                else
					write(output_line, integer'image(iterations - 1 - iteration_count));
					writeline(output, output_line);
				end if;
			end loop;
		end loop;

		for i in 0 to iterations - 1 loop
			wait until rising_edge(clock);
			write(output_line, integer'image(iterations - 1 - iteration_count));
			writeline(output, output_line);
		end loop;

		-- all done
		finished <= true;
		wait;
	end process make_pgm;

end architecture test_fixture;
