library ieee;
use ieee.std_logic_1164.all;

library ads;
use ads.ads_fixed.all;
use ads.ads_complex_pkg.all;

package seed_table is
	type seed_rom_type is array (natural range<>) of ads_complex;
	constant seed_rom: seed_rom_type := (
		ads_cmplx(to_ads_sfixed(-0.7), to_ads_sfixed(0.6)),
		ads_cmplx(to_ads_sfixed(-0.6), to_ads_sfixed(0.6)),
		ads_cmplx(to_ads_sfixed(-0.5), to_ads_sfixed(0.6)),
		ads_cmplx(to_ads_sfixed(-0.4), to_ads_sfixed(0.6)),
		ads_cmplx(to_ads_sfixed(-0.3), to_ads_sfixed(0.6)),
		ads_cmplx(to_ads_sfixed(-0.6), to_ads_sfixed(0.5)),
		ads_cmplx(to_ads_sfixed(-0.8), to_ads_sfixed(0.2)),
		ads_cmplx(to_ads_sfixed(-0.8), to_ads_sfixed(0.3))
	);
	
	constant seed_rom_total: natural := seed_rom'length;
	subtype seed_index_type is natural range 0 to seed_rom_total - 1;
	
	function get_next_seed_index (
		index: in seed_index_type
	) return seed_index_type;
end package seed_table;

package body seed_table is
	function get_next_seed_index (
		index: in seed_index_type
	) return seed_index_type is
	begin
		if index = index'high then
			return 0;
		end if;
		return index + 1;
	end function get_next_seed_index;
end package body seed_table;