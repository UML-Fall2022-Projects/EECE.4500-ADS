library ieee;
use ieee.std_logic_1164.all;

entity ring_oscillator is
	generic(
		ro_length: positive := 13
	);
	port (
		enable: in std_logic;
		osc_out: out std_logic
	);
end entity ring_oscillator;

architecture rtl of ring_oscillator is
	-- Array of inverter inputs
	signal p_inv_inp: std_logic_vector(ro_length - 1 downto 0);
	
	-- Prevent Quartis from optimizing out inverters
	attribute keep: boolean;
	attribute keep of p_inv_inp: signal is true;
begin
	assert(ro_length rem 2) = 1 report "invalid ro length" severity error;
	
	-- outputs
	osc_out <= p_inv_inp(ro_length - 1);
	
	p_inv_inp(0) <= enable nand p_inv_inp(ro_length - 1);
	
	ro: for i in 1 to ro_length - 1 generate
		p_inv_inp(i) <= not p_inv_inp(i - 1);
	end generate ro;
end architecture rtl;