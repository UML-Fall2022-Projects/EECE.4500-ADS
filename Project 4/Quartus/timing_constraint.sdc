# main 50 MHz clock
create_clock -period 20 [ get_ports {consumer_clock} ]
create_clock -period 20 -name main_clock_virt

# ADC 10 MHz clock
create_clock -period 100 [ get_ports {adc_clock_raw} ]
create_clock -period 100 -name adc_clock_virt

# ADC derived clock
create_generated_clock -name clk_div -source [ get_pins {|top_level|pll:adc_pll|inclk0} ] \
	-divide_by 1 -multiply_by 10 [ get_pins {|top_level|max10_adc:adc|pll_clk} ]