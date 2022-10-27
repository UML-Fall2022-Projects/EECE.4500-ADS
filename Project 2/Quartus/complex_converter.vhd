library ieee;
use ieee.std_logic_1164.all;

library vga;
use vga.vga_data.all;
use vga.vga_fsm_pkg.all;

library ads;
use ads.ads_fixed.all;
use ads.ads_complex_pkg.all;

entity complex_converter is
	generic (
		vga_res: vga_timing := vga_res_default
	);
	port (
		system_clock: in std_logic;
		reset: in std_logic;
		
		pixel_coord: in coordinate;
		complex_coord: out ads_complex
	);
end entity complex_converter;

architecture test of complex_converter is
	constant width: natural := vga_res.horizontal.active;
	constant height: natural := vga_res.vertical.active;
	constant aspect_ratio: real := real(width) / real(height);
	
	constant normalized_width: real := real(4);
	constant normalized_height: real := real(normalized_width) / aspect_ratio;
	constant dx: ads_sfixed := to_ads_sfixed(normalized_width / real(width));
	constant dy: ads_sfixed := to_ads_sfixed(normalized_height / real(height));
begin
	convert: process(system_clock, reset) is
		variable normal_space: ads_complex;
	begin
		if reset = '0' then
			complex_coord <= ads_cmplx(to_ads_sfixed(0), to_ads_sfixed(0));
		elsif rising_edge(system_clock) then
			normal_space.re := to_ads_sfixed(pixel_coord.x) * dx;
			normal_space.im := to_ads_sfixed(pixel_coord.y) * dy;
			
			complex_coord.re <= normal_space.re - to_ads_sfixed(normalized_width / real(2));
			complex_coord.im <= to_ads_sfixed(normalized_height / real(2)) - normal_space.im;
		end if;
	end process convert;
end architecture test;
