library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.project_pkg.all;

entity domain_cross_internal is
	port (
		clock1: in std_logic;
		clock2: in std_logic;
		din: in std_logic;
		dout: out std_logic
	);
end entity domain_cross_internal;

architecture ffs of domain_cross_internal
is
	signal flip_flops: std_logic_vector(0 to 2);
begin
	dout <= flip_flops(2);

	clk1: process(clock1) is
	begin
		if rising_edge(clock1) then
			flip_flops(0) <= din;
		end if;
	end process clk1;
	
	clk2: process(clock2) is
	begin
		if rising_edge(clock2) then
			flip_flops(2) <= flip_flops(1);
			flip_flops(1) <= flip_flops(0);
		end if;
	end process clk2;
end architecture ffs;