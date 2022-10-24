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
		width: natural := 640;
		height: natural := 480
	);
	port (
		system_clock: in std_logic;
		pixel_coord: in coordinate;
		complex_coord: out ads_complex
	);
end entity complex_converter;

architecture test of complex_converter is
	constant half_width: natural := width / 2;
	constant half_height: natural := height / 2;
	
	signal pixel_space: coordinate;
begin
	convert: process(system_clock) is
	begin
		if rising_edge(system_clock) then
			pixel_space.x <= pixel_coord.x - half_width;
			pixel_space.y <= half_height - pixel_coord.y;
			complex_coord <= ads_cmplx(to_ads_sfixed(pixel_space.x), to_ads_sfixed(pixel_space.y));
		end if;
	end process convert;
end architecture test;
