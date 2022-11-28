library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.project_pkg.all;

entity cross_domain is
	generic (
		input_width: positive := 16
	);
	port (
		clock1: in std_logic; -- clock at side 1
		clock2: in std_logic; -- clock at side 2
		din1: in std_logic_vector(input_width - 1 downto 0); -- input at side 1
		din2: in std_logic_vector(input_width - 1 downto 0); -- input at side 2
		dout1: out std_logic_vector(input_width - 1 downto 0); -- output at side 1
		dout2: out std_logic_vector(input_width - 1 downto 0) -- output at side 2
	);
end entity cross_domain;

architecture crossing of cross_domain is
	signal gray_out1: std_logic_vector(din1'range);
	signal gray_out2: std_logic_vector(din2'range);
	
	signal gray_cross1: std_logic_vector(gray_out1'range);
	signal gray_cross2: std_logic_vector(gray_out2'range);
	
	signal bin_out1: std_logic_vector(dout1'range);
	signal bin_out2: std_logic_vector(dout2'range);
begin
	bin_to_gray1: bin_to_gray
		generic map (
			input_width => input_width
		)
		port map (
			bin_in => din1,
			gray_out => gray_out1
		);
		
	bin_to_gray2: bin_to_gray
		generic map (
			input_width => input_width
		)
		port map (
			bin_in => din2,
			gray_out => gray_out2
		);
	
	a_to_b: for i in gray_out1'range generate
		internal1: domain_cross_internal
			port map (
				clock1 => clock1,
				clock2 => clock2,
				din => gray_out1(i),
				dout => gray_cross1(i)
			);
	end generate;
	
	b_to_a: for i in gray_out2'range generate
		internal2: domain_cross_internal
			port map (
				clock1 => clock1,
				clock2 => clock2,
				din => gray_out2(i),
				dout => gray_cross2(i)
			);
	end generate;
	
	gray_to_bin1: gray_to_bin
		generic map (
			input_width => input_width
		)
		port map (
			gray_in => gray_cross1,
			bin_out => bin_out1
		);
		
	gray_to_bin2: gray_to_bin
		generic map (
			input_width => input_width
		)
		port map (
			gray_in => gray_cross2,
			bin_out => bin_out2
		);
end architecture crossing;