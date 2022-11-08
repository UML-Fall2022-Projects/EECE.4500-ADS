library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.fractal_pkg.all;

library vga;
use vga.vga_data.all;
use vga.vga_fsm_pkg.all;

library ads;
use ads.ads_fixed.all;
use ads.ads_complex_pkg.all;

entity fractal is
	generic (
		vga_res: vga_timing := vga_res_640x480;
		iterations: natural := 28
	);
	port (
		system_clock: in std_logic;
		reset: in std_logic;
		enable: in std_logic;
		
		r: out std_logic_vector(0 to 3);
		g: out std_logic_vector(0 to 3);
		b: out std_logic_vector(0 to 3);
		hsync: out std_logic;
		vsync: out std_logic
	);
end entity fractal;

architecture pipeline of fractal is
	signal pixel: coordinate;
	signal pixel_valid: boolean;
	
	signal complex_coord: ads_complex;
	
	signal vga_clock: std_logic;
	
	signal gen_vsync: std_logic;
	signal gen_hsync: std_logic;
	
	signal color_index: natural;
		
	type logic_vector_array is array (natural range <>) of std_logic_vector(0 to 11);
	
	function colors(num_colors: in natural) return logic_vector_array is
		variable color_array: logic_vector_array(0 to num_colors - 1) := (others => (others => '1'));
		constant max_color: natural := 2**12 - 1;
		constant delta_color: natural := max_color / color_array'length;
	begin
		for i in color_array'range loop
			color_array(color_array'length - i - 1) := std_logic_vector(to_unsigned(i * delta_color, 12));
		end loop;
		color_array(iterations - 1) := (others => '0');
		return color_array;
	end function;
	
	constant color_array: logic_vector_array(0 to iterations - 1) := colors(iterations);
	
	component pll
		port (
			inclk0: IN STD_LOGIC := '0';
			c0: OUT STD_LOGIC 
		);
	end component pll;
begin
	pll_inst: pll
		port map (
			inclk0 => system_clock,
			c0	 => vga_clock
		);

	vga_fsm_inst: vga_fsm
		generic map (
			vga_res => vga_res
		)
		port map (
			vga_clock => vga_clock,
			reset => reset,
			enable => enable,

			point => pixel,
			point_valid => pixel_valid,

			h_sync => gen_hsync,
			v_sync => gen_vsync
		);
		
	sync_delay: delay
		generic map (
			-- complex_converter: 1 clk
			-- mandelbrot_gen: iterations + 1 clk
			clock_delay => iterations + 2
		)
		port map (
			vga_clock => vga_clock,
			reset => reset,
			enable => enable,
		
			in_vsync => gen_vsync,
			in_hsync => gen_hsync,
			out_vsync => vsync,
			out_hsync => hsync
		);
		
	cmplx_conv_inst: complex_converter
		generic map (
			vga_res => vga_res
		)
		port map (
			vga_clock => vga_clock,
			reset => reset,
			enable => enable,
			
			pixel_coord => pixel,
			complex_coord => complex_coord
		);
		
	mndl_gen: mandelbrot_gen
		generic map (
			iterations => iterations,
			threshold => 4
		)
		port map (
			coords => complex_coord,
			vga_clock => vga_clock,
			reset => reset,
			enable => enable,
			
			index_o => color_index
		);
	
	r <= color_array(color_index)(0 to 3) when pixel_valid else (others => '0');
	g <= color_array(color_index)(4 to 7) when pixel_valid else (others => '0');
	b <= color_array(color_index)(8 to 11) when pixel_valid else (others => '0');
end architecture pipeline;
