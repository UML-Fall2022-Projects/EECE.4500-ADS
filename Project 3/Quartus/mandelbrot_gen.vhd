library ieee;
use ieee.std_logic_1164.all;

library ads;
use ads.ads_fixed.all;
use ads.ads_complex_pkg.all;

entity mandelbrot_gen is
	generic (
		iterations: natural := 16;
		threshold: natural := 4
	);
	port (
		coords: in ads_complex;
		vga_clock: in std_logic;
		reset: in std_logic;
		enable: in std_logic;
		seed: in ads_complex;
		
		index_o: out natural
		
	);
end entity mandelbrot_gen;


architecture mandel_gen of mandelbrot_gen is
	type complex_array is array (natural range<>) of ads_complex;
	signal f_of_z: complex_array(0 to iterations) := (others => complex_zero);
	signal coords_list: complex_array(0 to iterations) := (others => complex_zero);
	
	signal thresholds: std_logic_vector(0 to iterations) := (others => '0');
	
	type iterated_array is array (natural range<>) of natural;
	signal iteration_signal: iterated_array(0 to iterations) := (others => 0);
begin
	
	process(vga_clock, reset) is
		variable re2: ads_sfixed;
		variable im2: ads_sfixed;
		variable re_im: ads_sfixed;
	begin
		if reset = '0' then
			f_of_z <= (others => complex_zero);
			coords_list <= (others => complex_zero);
			thresholds <= (others => '0');
			iteration_signal <= (others => 0);
		elsif enable = '1' and rising_edge(vga_clock) then
			coords_list(0) <= coords;
			f_of_z(0) <= seed;
			thresholds(0) <= '0';
			iteration_signal(0) <= 0;
			for i in iterations downto 1 loop
				coords_list(i) <= coords_list(i - 1);
			
				re2 := f_of_z(i - 1).re * f_of_z(i - 1).re;
				im2 := f_of_z(i - 1).im * f_of_z(i - 1).im;
				re_im := f_of_z(i - 1).re * f_of_z(i - 1).im;
				
				f_of_z(i).re <= re2 - im2 + coords_list(i).re;
				f_of_z(i).im <= re_im + re_im + coords_list(i).im;
				
				if thresholds(i - 1) = '1' then
					thresholds(i) <= thresholds(i - 1);
					iteration_signal(i) <= iteration_signal(i - 1);
				else
					iteration_signal(i) <= i - 1;
					if (re2 + im2) > to_ads_sfixed(threshold) then
						thresholds(i) <= '1';
					else
						thresholds(i) <= '0';
					end if;
				end if;
			end loop;
			index_o <= iteration_signal(iterations);
		end if;
	end process;
	
end architecture mandel_gen;
	