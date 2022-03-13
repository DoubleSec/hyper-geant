-- functions to read/write gpio, to save us a bunch of magic numbers later

-- get seed to generate terrain/course
function gpio_get_seed()
 return $0x5f90
end

-- set complete (1) or not complete (0) status for course
function gpio_set_course_status(status)
 poke(0x5f87, status)
end

-- write time to gpio
function gpio_set_course_time(t)
 local seconds = flr(t)
 local hundredths = flr((t - flr(t)) * 100)
 poke(0x5f85, seconds, hundredths)
end

-- write player name to gpio
function gpio_set_pname(pname)
 local lids = pname:to_nums()
 poke(0x5f80, lids[1], lids[2], lids[3])
end