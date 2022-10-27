library ieee;
use ieee.std_logic_1164.all;

library vga;
use vga.vga_data.all;

package vga_fsm_pkg is
	component vga_fsm is
		generic (
			vga_res:	vga_timing := vga_res_default
		);
		port (
			vga_clock:		in	std_logic;
			reset:			in	std_logic;
			enable:			in std_logic;

			point:			out	coordinate;
			point_valid:	out	boolean;

			h_sync:			out	std_logic;
			v_sync:			out std_logic
		);
	end component vga_fsm;
end package vga_fsm_pkg;

library ieee;
use ieee.std_logic_1164.all;

library vga;
use vga.vga_data.all;

entity vga_fsm is
	generic (
		vga_res:	vga_timing := vga_res_default
	);
	port (
		vga_clock:		in	std_logic;
		reset:			in	std_logic;
		enable:			in std_logic;

		point:			out	coordinate;
		point_valid:	out	boolean;

		h_sync:			out	std_logic;
		v_sync:			out std_logic
	);
end entity vga_fsm;

architecture fsm of vga_fsm is
	signal coord: coordinate := make_coordinate(0, 0);
begin
	output_function: process(vga_clock, reset) is
	begin
		if reset = '0' then
			coord <= make_coordinate(0, 0);
			h_sync <= do_horizontal_sync(coord, vga_res);
			v_sync <= do_vertical_sync(coord, vga_res);
			point_valid <= point_visible(coord, vga_res);
			point <= coord;
		elsif enable = '1' and rising_edge(vga_clock) then
			coord <= next_coordinate(coord, vga_res);
			h_sync <= do_horizontal_sync(coord, vga_res);
			v_sync <= do_vertical_sync(coord, vga_res);
			point_valid <= point_visible(coord, vga_res);
			point <= coord;
		end if;
	end process output_function;
end architecture fsm;
