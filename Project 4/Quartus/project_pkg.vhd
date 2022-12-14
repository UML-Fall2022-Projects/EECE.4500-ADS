library ieee;
use ieee.std_logic_1164.all;

package project_pkg is
	component max10_adc is
		port (
			pll_clk:	in	std_logic;
			chsel:		in	natural range 0 to 2**5 - 1;
			soc:		in	std_logic;
			tsen:		in	std_logic;
			dout:		out	natural range 0 to 2**12 - 1;
			eoc:		out	std_logic;
			clk_dft:	out	std_logic
		);
	end component max10_adc;
	
	component cross_domain is
		generic (
			input_width: positive := 16
		);
		port (
			clock1: in std_logic; -- clock at side 1
			clock2: in std_logic; -- clock at side 2
			din1: in natural range 0 to 2**input_width - 1;
			din2: in natural range 0 to 2**input_width - 1;
			dout1: out natural range 0 to 2**input_width - 1;
			dout2: out natural range 0 to 2**input_width - 1
		);
	end component cross_domain;
	
	component bin_to_gray is
		generic (
			input_width: positive := 16
		);
		port (
			bin_in: in std_logic_vector(input_width - 1 downto 0);
			gray_out: out std_logic_vector(input_width - 1 downto 0)
		);
	end component bin_to_gray;
	
	component gray_to_bin is
		generic (
			input_width: positive := 16
		);
		port (
			gray_in: in std_logic_vector(input_width - 1 downto 0);
			bin_out: out std_logic_vector(input_width - 1 downto 0)
		);
	end component gray_to_bin;
	
	component data_buffer is
		generic (
			DATA_WIDTH : natural := 8;
			ADDR_WIDTH : natural := 6
		);
		port (
			clk_a	: in std_logic;
			clk_b	: in std_logic;
			addr_a	: in natural range 0 to 2**ADDR_WIDTH - 1;
			addr_b	: in natural range 0 to 2**ADDR_WIDTH - 1;
			data_a	: in std_logic_vector((DATA_WIDTH-1) downto 0);
			data_b	: in std_logic_vector((DATA_WIDTH-1) downto 0);
			we_a	: in std_logic := '1';
			we_b	: in std_logic := '1';
			q_a		: out std_logic_vector((DATA_WIDTH -1) downto 0);
			q_b		: out std_logic_vector((DATA_WIDTH -1) downto 0)
		);
	end component data_buffer;
	
	component domain_cross_internal is
		port (
			clock1: in std_logic;
			clock2: in std_logic;
			din: in std_logic;
			dout: out std_logic
		);
	end component domain_cross_internal;
	
	component control_unit_producer is
		generic (
			ADDR_WIDTH : natural := 6
		);
		port (
			clock: in std_logic;
			reset: in std_logic;
			tail_ptr: in natural range 0 to 2**ADDR_WIDTH - 1;
			eoc: in std_logic;
			soc: out std_logic;
			buffer_write: out std_logic;
			head_ptr: buffer natural range 0 to 2**ADDR_WIDTH - 1
		);
	end component control_unit_producer;
	
	component control_unit_consumer is
		generic (
			ADDR_WIDTH : natural := 6
		);
		port (
			clock: in std_logic;
			reset: in std_logic;
			head_ptr: in natural range 0 to 2**ADDR_WIDTH - 1;
			tail_ptr: buffer natural range 0 to 2**ADDR_WIDTH - 1
		);
	end component control_unit_consumer;

	component pll
		port (
			inclk0: IN STD_LOGIC := '0';
			c0: OUT STD_LOGIC 
		);
	end component pll;
end package project_pkg;
