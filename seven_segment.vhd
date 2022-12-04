library ieee;
use ieee.std_logic_1164.all;

use work.seven_segment_utils_pkg.all;

entity seven_segment is
	port (
		in_num: in natural range 0 to 2**12 - 1;
		out_displays: out sseg_conf_array(0 to 2) 
	);
end entity seven_segment;

architecture sseg of seven_segment is
	type num_arr is array (natural range<>) of std_logic_vector(0 to 3);
	signal nums: num_arr(0 to 2);
	
	signal in_vec: std_logic_vector(0 to 11);
begin
	in_vec <= std_logic_vector(to_unsigned(in_num, 12));
	
	splice: for i in 0 to 2 generate
		nums(i) <= in_vec(i * 4 to i * 4 + 3);
		out_displays(i) <= get_hex_digit(to_integer(unsigned(nums(i))));
	end generate;
end architecture sseg;
