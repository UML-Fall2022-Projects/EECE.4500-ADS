library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package seven_segment_pkg is
	type seven_segment_config is
	record
		a: std_logic;
		b: std_logic;
		c: std_logic;
		d: std_logic;
		e: std_logic;
		f: std_logic;
		g: std_logic;
	end record seven_segment_config;
	
	type sseg_conf_array is array (natural range<>) of seven_segment_config;
	type num_arr is array (natural range<>) of std_logic_vector(0 to 3);

	type lamp_configuration is
		(common_anode, common_cathode);
		
	constant default_lamp_config: lamp_configuration := common_anode;

	constant seven_segment_table: sseg_conf_array := (
		0 => ('1', '1', '1', '1', '1', '1', '0'),
		1 => ('0', '1', '1', '0', '0', '0', '0'),
		2 => ('1', '1', '0', '1', '1', '0', '1'),
		3 => ('1', '1', '1', '1', '0', '0', '1'),
		4 => ('0', '1', '1', '0', '0', '1', '1'),
		5 => ('1', '0', '1', '1', '0', '1', '1'),
		6 => ('1', '0', '1', '1', '1', '1', '1'),
		7 => ('1', '1', '1', '0', '0', '0', '0'),
		8 => ('1', '1', '1', '1', '1', '1', '1'),
		9 => ('1', '1', '1', '1', '0', '1', '1'),
		10 => ('1', '1', '1', '0', '1', '1', '0'),
		11 => ('0', '0', '1', '1', '1', '1', '1'),
		12 => ('1', '0', '0', '1', '1', '1', '0'),
		13 => ('0', '1', '1', '1', '1', '1', '0'),
		14 => ('1', '0', '0', '1', '1', '1', '1'),
		15 => ('1', '0', '0', '0', '1', '1', '1')
	);
	
	subtype hex_digit is natural range 0 to 15;
	
	function get_hex_digit(
		digit: in hex_digit;
		lamp_mode: in lamp_configuration := default_lamp_config
	) return seven_segment_config;
	
	function lamps_off(
		lamp_mode: in lamp_configuration := default_lamp_config
	) return seven_segment_config;
end package seven_segment_pkg;

package body seven_segment_pkg is
	function get_hex_digit(
			digit: in hex_digit;
			lamp_mode: in lamp_configuration := default_lamp_config
		) return seven_segment_config
	is
		variable ret: seven_segment_config;
	begin
		ret := seven_segment_table(digit);
		if lamp_mode = common_anode then
			ret.a := not ret.a;
			ret.b := not ret.b;
			ret.c := not ret.c;
			ret.d := not ret.d;
			ret.e := not ret.e;
			ret.f := not ret.f;
			ret.g := not ret.g;
		end if;
		return ret;
	end function get_hex_digit;
	
	function lamps_off(
			lamp_mode: in lamp_configuration := default_lamp_config
		) return seven_segment_config
	is
		variable ret: seven_segment_config;
	begin
		if lamp_mode = common_cathode then
			ret := ('0', '0', '0', '0', '0', '0', '0');
		else
			ret := ('1', '1', '1', '1', '1', '1', '1');
		end if;
		return ret;
	end function lamps_off;
end package body seven_segment_pkg;
