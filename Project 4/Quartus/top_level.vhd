library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.project_pkg.all;
use work.seven_segment_pkg.all;

entity top_level is
	generic (
		ADDR_WIDTH: natural := 12
	);
	port (
		consumer_clock: in std_logic;
		adc_clock_raw: in std_logic;
		displays: out sseg_conf_array(0 to 2)
	);
end entity top_level;

architecture driver of top_level is
	constant DATA_WIDTH: natural := 12;

	signal adc_clock: std_logic;
	signal producer_clock: std_logic;
	
	signal soc, eoc: std_logic;
	signal adc_out: natural range 0 to 2**DATA_WIDTH - 1;
	signal buffer_in: std_logic_vector((DATA_WIDTH - 1) downto 0);
	signal buffer_out: std_logic_vector((DATA_WIDTH - 1) downto 0);
	signal segment_in: natural range 0 to 2**DATA_WIDTH - 1;
	
	signal tail_ptr, head_ptr, tail_producer, head_consumer: natural range 0 to 2**ADDR_WIDTH - 1;
	signal buffer_write: std_logic;
begin
	adc_pll: pll
		port map (
			inclk0 => adc_clock_raw,
			c0 => adc_clock
		);
		
	adc: max10_adc
		port map (
			pll_clk => adc_clock,
			chsel => 0,
			soc => soc,
			tsen => '1',
			dout => adc_out,
			eoc => eoc,
			clk_dft => producer_clock
		);
		
	buffer_in <= std_logic_vector(to_unsigned(adc_out, DATA_WIDTH));
		
	memory: data_buffer
		generic map (
			DATA_WIDTH => DATA_WIDTH,
			ADDR_WIDTH => ADDR_WIDTH
		)
		port map (
			clk_a => consumer_clock,
			clk_b	=> producer_clock,
			addr_a => tail_ptr,
			addr_b => head_ptr,
			data_a => (others => '0'),
			data_b => buffer_in,
			we_a => '0',
			we_b => buffer_write,
			q_a => buffer_out,
			q_b => open
		);
	
	cross: cross_domain
		generic map (
			input_width => DATA_WIDTH
		)
		port map (
			clock1 => consumer_clock,
			clock2 => producer_clock,
			din1 => tail_ptr,
			din2 => head_ptr,
			dout1 => head_consumer,
			dout2 => tail_producer
		);
		
	producer_fsm: control_unit_producer
		generic map (
			ADDR_WIDTH => 12
		)
		port map (
			clock => producer_clock,
			reset => '1',
			tail_ptr => tail_producer,
			eoc => eoc,
			soc => soc,
			buffer_write => buffer_write,
			head_ptr => head_ptr
		);
		
	consumer_fsm: control_unit_consumer
		generic map (
			ADDR_WIDTH => 12
		)
		port map (
			clock => consumer_clock,
			reset => '1',
			head_ptr => head_consumer,
			tail_ptr => tail_ptr
		);
		
	segment_in <= to_integer(unsigned(buffer_out));
	displays <= get_hex_number(segment_in);
end architecture driver;
