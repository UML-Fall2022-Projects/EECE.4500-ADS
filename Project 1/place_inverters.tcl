set name "ro_puf:puf|ring_oscillator:\\ring_oscillators:%s:u0|p_inv_inp\[%s\]"
#set special_name "${name}~clkctrl"

set osc_list_x [ list 54 55 56 57 58 59 60 61 62 63 64 65 66 67 69 70 ]
set osc_y 53

for {set i 0} {${i} < 16} {incr i} {
	set x [lindex ${osc_list_x} ${i}]
	for {set j 0} {${j} < 13} {incr j} {	
		set inverter_location "LCCOMB_X${x}_Y${osc_y}_N[expr 2*${j}]"
		
		set name_fmt [ format ${name} ${i} ${j}]
		
		set_location_assignment ${inverter_location} -to "${name_fmt}"
		#puts "set_location_assignment ${inverter_location} -to \"${name_fmt}\""
	}
}
