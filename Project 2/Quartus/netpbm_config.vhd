library ieee;
use ieee.fixed_pkg.all;
use ieee.fixed_float_types.all;

package netpbm_config is
	-- record for minimum and maximum
	type plot_range is
	record
		min:	sfixed;
		max:	sfixed;
	end record plot_range;

	-- test fixture parameters
	constant int_bits: natural range 3 to 12 := 12;
	constant fract_bits: natural range 6 to 18 := 18;

	constant iterations: natural := 32;
	constant escape: sfixed := to_sfixed(32, int_bits, -fract_bits);

	constant x_range: plot_range := (
			min => to_sfixed(-2.2, int_bits, -fract_bits),
			max => to_sfixed(1, int_bits, -fract_bits)
		);
	constant y_range: plot_range := (
			min => to_sfixed(-1.2, int_bits, -fract_bits),
			max => to_sfixed(1.2, int_bits, -fract_bits)
		);

	constant y_steps: natural range 10 to natural'high := 480;
	constant x_steps: natural range 10 to natural'high := 640;

	-- other stuff
	constant dy: sfixed := resize((y_range.max - y_range.min) / y_steps,
										int_bits, -fract_bits,
									overflow_style => fixed_saturate,
									round_style => fixed_truncate);
	constant dx: sfixed := resize((x_range.max - x_range.min) / x_steps,
										int_bits, -fract_bits,
									overflow_style => fixed_saturate,
									round_style => fixed_truncate);

end package netpbm_config;
