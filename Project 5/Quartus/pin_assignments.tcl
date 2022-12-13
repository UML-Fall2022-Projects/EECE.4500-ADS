set sseg_lamps {\
    { AE26 AE27 AE28 AG27 AF28 AG28 AH28 }\
    { AJ29 AH29 AH30 AG30 AF29 AF30 AD27 }\
    { AB23 AE29 AD29 AC28 AD30 AC29 AC30 }\
    { AD26 AC27 AD25 AC25 AB28 AB25 AB22 }\
    { AA24 Y23  Y24  W22  W24  V23  W25  }\
    { V25  AA28 Y27  AB27 AB26 AA26 AA25 }\
}

proc set_pins { digits { name "lamps_export" } } {
    global sseg_lamps
    for { set i 0 } { ${i} < ${digits} } { incr i } {
        for { set j 0 } { ${j} < 7 } { incr j } {
            set location [ lindex [ lindex ${sseg_lamps} ${i} ] ${j} ]
            set index [ expr ${i} * 7 + ${j} ]
            set_location_assignment PIN_${location} -to ${name}\[${index}\]
        }
    }
}