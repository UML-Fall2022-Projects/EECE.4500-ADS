library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.seven_segment_pkg.all;

entity seven_segment_agent is
	generic (
		lamp_mode_common_anode: boolean := true;
		decimal_support: boolean := true;
		blank_zeros_support: boolean := true;
		implementer: natural := 232;
		revision: natural := 0
	);
	port (
		clk: in std_logic;
		
		-- Active low synchronous
		reset_n: in std_logic;
		
		-- Address bu. Must be 2 bits wide
		address: in std_logic_vector(1 downto 0);
		
		-- Active high signal indicating read transaction.
		read: in std_logic;
		
		-- Read data bus. Must be 32 bits wide.
		readdata: out std_logic_vector(31 downto 0);
		
		-- Active high signal indicating a write transaction.
		write: in std_logic;
		
		-- Write data bus. Must be 32 bits wide.
		writedata: in std_logic_vector(31 downto 0);
		
		-- Lamps output. Must be 42 bits wide.
		lamps: out std_logic_vector((6 * 7 - 1) downto 0)
	);
end entity seven_segment_agent;

architecture sseg_impl of seven_segment_agent is
	function lamp_mode return lamp_configuration is
	begin
		if lamp_mode_common_anode then
			return common_anode;
		end if;
		return common_cathode;
	end function lamp_mode;

	signal data: std_logic_vector(31 downto 0) := (others => '0');
	signal control: std_logic_vector(31 downto 0) := (others => '0');
	
	function to_bcd(
			data_value: in std_logic_vector(15 downto 0)
		) return std_logic_vector
	is
		variable ret: std_logic_vector(19 downto 0);
		variable temp: std_logic_vector(data_value'range);
	begin
		temp := data_value;
		ret := (others => '0');
		for i in data_value'range loop
			for j in 0 to ret'length/4 - 1 loop
				if unsigned(ret(4 * j + 3 downto 4 * j)) >= 5 then
					ret(4 * j + 3 downto 4 * j) :=
					std_logic_vector(unsigned(ret(4*j + 3 downto 4 * j)) + 3);
				end if;
			end loop;
			ret := ret(ret'high - 1 downto 0) & temp(temp'high);
			temp := temp(temp'high - 1 downto 0) & '0';
		end loop;
		return ret;
	end function to_bcd;
	
	function concatenate_sseg_configs(
			seg_displays: in sseg_conf_array(5 downto 0)
		) return std_logic_vector
	is
		variable ret: std_logic_vector((7 * 6 - 1) downto 0);
	begin
		for i in 0 to 5 loop
			ret(0 + i * 7) := seg_displays(i).a;
			ret(1 + i * 7) := seg_displays(i).b;
			ret(2 + i * 7) := seg_displays(i).c;
			ret(3 + i * 7) := seg_displays(i).d;
			ret(4 + i * 7) := seg_displays(i).e;
			ret(5 + i * 7) := seg_displays(i).f;
			ret(6 + i * 7) := seg_displays(i).g;
		end loop;
		return ret;
	end function concatenate_sseg_configs;
	
	function generate_features
		return std_logic_vector
	is
		variable ret: std_logic_vector(31 downto 0);
	begin
		ret := (others => '0');
		if decimal_support then
			ret(0) := '1';
		else
			ret(0) := '0';
		end if;
        
        if blank_zeros_support then
            ret(2) := '1';
        else
            ret(2) := '0';
        end if;
		
		if lamp_mode = common_anode then
			ret(3) := '1';
		else
			ret(3) := '0';
		end if;
		
		ret(23 downto 16) := std_logic_vector(to_unsigned(revision, 8));
		ret(31 downto 24) := std_logic_vector(to_unsigned(implementer, 8));
		return ret;
	end function generate_features;
	
	constant features: std_logic_vector(31 downto 0) := generate_features;
	
	function data_to_lamps(
			data: in std_logic_vector(31 downto 0);
			control: in std_logic_vector(31 downto 0)
		) return std_logic_vector
	is
		variable ret: std_logic_vector((6 * 7 - 1) downto 0);
		variable bcd: std_logic_vector(19 downto 0);
        variable bcd_int: integer;
		variable sseg_array: sseg_conf_array(5 downto 0);
	begin
        if control(0) = '0' then
            sseg_array := (others => lamps_off(lamp_mode));
        elsif decimal_support and control(1) = '1' then
            if control(2) = '1' then
                sseg_array := (others => lamps_off(lamp_mode));
            else
                sseg_array := (others => get_hex_digit(0, lamp_mode));
            end if;
            bcd := to_bcd(data(15 downto 0));
            for i in 0 to 4 loop
                bcd_int := to_integer(unsigned(bcd(3 + i * 4 downto i * 4)));
                if bcd_int /= 0 then
                    sseg_array(i) := get_hex_digit(bcd_int, lamp_mode);
                end if;
            end loop;
        else
            sseg_array := (others => get_hex_digit(0, lamp_mode));
            for i in 0 to 5 loop
                sseg_array(i) := get_hex_digit(to_integer(unsigned(data(3 + i * 4 downto i * 4))), lamp_mode);
            end loop;
        end if;
		return concatenate_sseg_configs(sseg_array);
	end function data_to_lamps;
begin

	lamps <= data_to_lamps(data, control);

	process(clk) is
	begin
		if rising_edge(clk) then
			if reset_n = '0' then
				data <= (others => '0');
				control <= (others => '0');
			elsif read = '1' then
				case address is
					when "00" => readdata <= data;
					when "01" => readdata <= control;
					when "10" => readdata <= features;
					when "11" => readdata <= std_logic_vector(to_unsigned(16#41445335#, 32));
                    when others => null;
                end case;
			elsif write = '1' then
				case address is
					when "00" => data <= writedata;
					when "01" =>
                        control(0) <= writedata(0);
                        
						if decimal_support then
							control(1) <= writedata(1);
						end if;
                        
                        if blank_zeros_support then
                            control(2) <= writedata(2);
                        end if;
					when others => null;
				end case;
			end if;
		end if;
	end process;
end architecture sseg_impl;