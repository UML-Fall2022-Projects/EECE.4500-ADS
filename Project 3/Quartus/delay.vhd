library ieee;
use ieee.std_logic_1164.all;

entity delay is
	generic (
		-- complex_converter: 1 clk
		-- mandelbrot_gen: iterations + 1 clk
		clock_delay: natural := 18
	);
	port (
		vga_clock: in std_logic;
		reset: in std_logic;
		enable: in std_logic;
	
		in_vsync: in std_logic;
		in_hsync: in std_logic;
		out_vsync: out std_logic;
		out_hsync: out std_logic
	);
end entity delay;

architecture shift_reg_impl of delay is
	-- A register of n width takes n + 1 clocks from in to out.
	signal vreg: std_logic_vector(clock_delay - 2 downto 0) := (others => '0');
	signal hreg: std_logic_vector(clock_delay - 2 downto 0) := (others => '0');
begin
	shift: process(vga_clock, reset)
	begin
		if reset = '0' then
			vreg <= (others => '0');
			hreg <= (others => '0');
			out_vsync <= '0';
			out_hsync <= '0';
		elsif enable = '1' and rising_edge(vga_clock) then
			out_vsync <= vreg(vreg'left);
			out_hsync <= hreg(hreg'left);
			
			vreg <= vreg(vreg'left - 1 downto 0) & in_vsync;
			hreg <= hreg(hreg'left - 1 downto 0) & in_hsync;
		end if;
	end process shift;
end architecture shift_reg_impl;
