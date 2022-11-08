library ads;
use ads.ads_fixed.all;

package netpbm_config is
	-- record for minimum and maximum
	type plot_range is
	record
		min: real;
		max: real;
	end record plot_range;

	-- test fixture parameters
	constant iterations: natural := 32;
	constant escape: ads_sfixed := to_ads_sfixed(32);

	constant x_range: plot_range := (
			min => -2.2,
			max => 1.0
		);
	constant y_range: plot_range := (
			min => -1.2,
			max => 1.2
		);

	constant y_steps: natural range 10 to natural'high := 200;
	constant x_steps: natural range 10 to natural'high := 200;

	-- other stuff
	constant dy: ads_sfixed := to_ads_sfixed((y_range.max - y_range.min) / real(y_steps));
	constant dx: ads_sfixed := to_ads_sfixed((x_range.max - x_range.min) / real(x_steps));

end package netpbm_config;
