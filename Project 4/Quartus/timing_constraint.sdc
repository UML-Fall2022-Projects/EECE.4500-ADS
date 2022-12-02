# main 50 MHz clock
create_clock -period "50 MHz" [ get_ports consumer_clock ]
create_clock -period "50 MHz" -name main_clock_virt

# ADC 10 MHz clock
create_clock -period "1 MHz" [ get_ports adc_clock_raw ]
create_clock -period "1 MHz" -name adc_clock_virt

# ADC derived clock
#create_generated_clock -name clk_div -source [ get_ports adc_clock_raw ] \
#	-divide_by 10 -multiply_by 1 [ get_pins producer_clock~clkctrl|outclk ]
derive_pll_clocks