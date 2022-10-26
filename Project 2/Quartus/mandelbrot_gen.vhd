library ieee;
use ieee.std_logic_1164.all;

library vga;
use vga.vga_data.all;
use vga.vga_fsm_pkg.all;

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
		system_clock: in std_logic;
		
		index_o: out natural
		
	);
end entity mandelbrot_gen;


architecture mandel_gen of mandelbrot_gen is
	type complex_array is array (natural range<>) of ads_complex;
	signal f_of_z: complex_array(0 to iterations) := (others => ads_cmplx(to_ads_sfixed(0), to_ads_sfixed(0)));
	signal coords_list: complex_array(0 to iterations) := (others => ads_cmplx(to_ads_sfixed(0), to_ads_sfixed(0)));
	
	signal thresholds: std_logic_vector(0 to iterations) := (others => '0');
	
	type iterated_array is array (natural range<>) of natural;
	signal iteration_signal: iterated_array(0 to iterations) := (others => 0);
begin
	
	process(system_clock) is
		variable re2: ads_sfixed;
		variable im2: ads_sfixed;
		variable re_im: ads_sfixed;
	begin
		if rising_edge(system_clock) then
			for i in iterations downto 1 loop
				re2 := f_of_z(i - 1).re * f_of_z(i - 1).re;
				im2 := f_of_z(i - 1).im * f_of_z(i - 1).im;
				re_im := f_of_z(i - 1).re * f_of_z(i - 1).im;
				
				f_of_z(i).re <= re2 - im2 + coords_list(i).re;
				f_of_z(i).im <= re_im + re_im + coords_list(i).im;
				
				coords_list(i) <= coords_list(i - 1);
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
			coords_list(0) <= coords;
			index_o <= iteration_signal(iterations);
		end if;
	end process;
	
end architecture mandel_gen;
	