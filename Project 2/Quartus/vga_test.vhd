library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library vga;
use vga.vga_data.all;
use vga.vga_fsm_pkg.all;

library ads;
use ads.ads_fixed.all;

entity vga_test is
	port (
		system_clock: in std_logic;
		reset: in std_logic;
		
		red: in std_logic_vector(0 to 3);
		blue: in std_logic_vector(0 to 3);
		
		r: out std_logic_vector(0 to 3);
		g: out std_logic_vector(0 to 3);
		b: out std_logic_vector(0 to 3);
		h_sync: out std_logic;
		v_sync: out std_logic
	);
end entity vga_test;

architecture test of vga_test is
	signal point: coordinate;
	signal point_valid: boolean;
	
	signal vga_clock: std_logic;
	
	--constant red: natural := 12;
	constant green: natural := 1;
	--constant blue: natural := 12;
	
	component pll
	PORT
	(
		inclk0: IN STD_LOGIC := '0';
		c0: OUT STD_LOGIC 
	);
end component;
begin
	pll_inst: pll
		port map (
			inclk0 => system_clock,
			c0	 => vga_clock
		);
		
	vga_fsm_inst: vga_fsm
		port map (
			vga_clock => vga_clock,
			reset => reset,

			point => point,
			point_valid => point_valid,

			h_sync => h_sync,
			v_sync => v_sync
		);
		
	r <= red when point_valid else (others => '0');
	g <= std_logic_vector(to_unsigned(green, 4)) when point_valid else (others => '0');
	b <= blue when point_valid else (others => '0');
end architecture test;
