library ieee;
use ieee.std_logic_1164.all;

library vga;
use vga.vga_data.all;
use vga.vga_fsm_pkg.all;

library ads;
use ads.ads_fixed.all;
use ads.ads_complex_pkg.all;

package fractal_pkg is
	component complex_converter is
		generic (
			vga_res: vga_timing := vga_res_default
		);
		port (
			system_clock: in std_logic;
			reset: in std_logic;
			
			pixel_coord: in coordinate;
			complex_coord: out ads_complex
		);
	end component complex_converter;
	
	component mandelbrot_gen is
		generic (
			iterations: natural := 16;
			threshold: natural := 4
		);
		port (
			coords: in ads_complex;
			system_clock: in std_logic;
			reset: in std_logic;
			
			index_o: out natural
		);
	end component mandelbrot_gen;
	
	component delay is
		generic (
			-- complex_converter: 1 clk.
			-- mandelbrot_gen: iterations + 1 clk
			clock_delay: natural := 18
		);
		port (
			system_clock: in std_logic;
			reset: in std_logic;
		
			in_vsync: in std_logic;
			in_hsync: in std_logic;
			out_vsync: out std_logic;
			out_hsync: out std_logic
		);
	end component delay;
end package fractal_pkg;
