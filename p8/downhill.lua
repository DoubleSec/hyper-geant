downhill = {

 -- pre-set attributes
 y_gap_r = {72, 128},
 x_gap_r = {48, 96},
 x_offset_r = {-128, 128},
 gates_r = {25, 40},

 -- constructor
 -- base_pos is y coordinate of start, seed is random seed value
 new = function(self, base_pos, seed, pname, best)

  new_dh = {}
  setmetatable(new_dh, downhill)
  new_dh.seed = seed

  new_dh.pname = pname

  srand(seed)

  -- Generate the path
  new_dh.gates = {}
  new_dh.n_gates = self.gates_r[1] +
                   flr(rnd(self.gates_r[2] - self.gates_r[1] + 1))
  new_dh.n_passed = 0
  new_dh.gate_missed = false
  new_dh.course_start = 0
  new_dh.course_end = 0

  -- intermediate timing
  new_dh.time_gates = {
   flr(new_dh.n_gates * 0.25),
   flr(new_dh.n_gates * 0.50),
   flr(new_dh.n_gates * 0.75)
  }

  -- initialize best time and current time
  new_dh.best = {}
  if best != nil then
   new_dh.best = best
  end
  
  new_dh.times = {}

  new_dh.gates[1] = {base_pos + 50, 0, 50, -1}

  for i = 2, new_dh.n_gates, 1 do

   -- choose y
   local y = new_dh.gates[i-1][1] + self.y_gap_r[1] +
             rnd(self.y_gap_r[2] - self.y_gap_r[1])

   -- choose x
   -- x format is {center, width}
   local x_last = new_dh.gates[i-1][2]

   local x_center = x_last + self.x_offset_r[1] +
              rnd(self.x_offset_r[2] - self.x_offset_r[1])
   local x_width = self.x_gap_r[1] + rnd(self.x_gap_r[2] - self.x_gap_r[1])

   local is_timing = -1
   for j, gidx in pairs(new_dh.time_gates) do
    if i == gidx then
     is_timing = j
    end
   end

   add(new_dh.gates, {y, x_center, x_width, is_timing})

  end

  new_dh.len = new_dh.gates[new_dh.n_gates][1] - base_pos

  -- set the course as not completed
  gpio_set_course_status(0)

  return new_dh

 end,

 -- draw
 draw = function(self, player)

  -- draw gates
  -- TODO binary search for performance
  for i = 1, self.n_gates do
   if self.gates[i][1] > player.world_y - 128 and self.gates[i][1] < player.world_y + 256 then

    x_left = (self.gates[i][2] - self.gates[i][3] / 2) - player.world_x + player.x
    x_right = (self.gates[i][2] + self.gates[i][3] / 2) - player.world_x + player.x
    y = self.gates[i][1] - player.world_y + player.y

    -- border lines
    if i != 1 then

     -- previous gate info
     prev_x_left = (self.gates[i-1][2] - self.gates[i-1][3] / 2) - player.world_x + player.x
     prev_x_right = (self.gates[i-1][2] + self.gates[i-1][3] / 2) - player.world_x + player.x
     prev_y = self.gates[i-1][1] - player.world_y + player.y

     -- start/finish line
     if (i == self.n_gates) line(x_left - 20, y, x_right + 20, y, 12)

     -- left border, right border
     line(prev_x_left, prev_y, x_left, y, 12)
     line(prev_x_right, prev_y, x_right, y, 12)

    end

    -- left side, right side
    line(x_left, y, x_left, y - 5, 8)
    line(x_right, y, x_right, y - 5, 8)

    -- timing line
    if self.gates[i][4] > 0 then
     line(x_left - 20, y, x_left, y, 14)
     line(x_right + 20, y, x_right, y, 14)
    end

   end

  end

  print(self.n_passed.."/"..self.n_gates, 2, 2, 5)

  -- setup time printing
  if self.course_start == 0 then
   t = 0
   c = 5
   complete = false
  elseif self.course_end == 0 then
   t = time() - self.course_start
   c = 5
   complete = false
  else
   complete = true
  end

  if self.gate_missed then
   print("out", 2, 8, 8)
  elseif not complete then
   print(self.pname:to_str()..': '..flr(t * 10) / 10, 2, 8, c)
  end

  -- delta printing
  if self.delta != nil then
   if self.delta < 0 then
    sym = ""
    dc = 3
   else 
    sym = "+"
    dc = 8
   end
   rectfill(1, 14, 21, 20, dc)
   print(sym..(flr(self.delta * 100) / 100), 2, 15, 7)
  end

  -- end of run
  if complete then
   if (self.best_delta == nil) or (self.best_delta < 0) then
    ec = 3
    sym = ' ('
   else
    ec = 5
    sym = ' (+'
   end
   if self.best_delta != nil then 
    res_string = (flr(self.times[4] * 100) / 100)..sym..(flr(self.best_delta * 100) / 100)..")"
    rectfill(63-#res_string*2, 59, 63+#res_string*2, 65, ec)
    print(res_string, 64-#res_string*2, 60, 7)
   else
    res_string = tostr((flr(self.times[4] * 100) / 100))
    rectfill(63-#res_string*2, 59, 63+#res_string*2, 65, ec)
    print(res_string, 64-#res_string*2, 60, 7)
   end
  end

  if player.vx == 0 and player.vy == 0 then
   print('hold \142 to tuck and go faster', 2, 40, 2)
   print('hold \151 to restart', 2, 50, 2)
   if self.best[4] != nil then print("pb: "..(flr(self.best[4] * 100) / 100), 2, 60, 3) end
  end

 end,

 -- update
 update = function(self, player)

  -- gate checking
  crossing_idx = gate_search(self.gates, player)

  -- if crossing a gate
  if crossing_idx ~= -1 then
   crossing_gate = self.gates[crossing_idx]
   -- interpolate the x position at the point player crosses
   cross_fraction = (crossing_gate[1] - player.world_y) / player.vy
   x_lerp = player.world_x + (player.vx * cross_fraction)

   x_left = crossing_gate[2] - (crossing_gate[3] / 2)
   x_right = crossing_gate[2] + (crossing_gate[3] / 2)

   if x_lerp >= x_left and x_lerp <= x_right then
    self.n_passed = self.n_passed + 1
    if crossing_idx == 1 then
     self.course_start = time()
    end
   else
    self.gate_missed = true
   end

   -- check on intermediate sectors if not out
   if (not self.gate_missed) and crossing_gate[4] > 0 then

    i = crossing_gate[4]
    self.times[i] = time() - self.course_start
     
    if self.best[i] != nil then
     self.delta = self.times[i] - self.best[i] 
    end
   end

   -- if course completed
   if (crossing_idx == count(self.gates) and not self.gate_missed) then
    self.course_end = time()
    self.times[4] = self.course_end - self.course_start
    if count(self.best) != 0 then
     self.best_delta = self.times[4] - self.best[4]
     self.delta = self.best_delta
    end
    -- set best time
    if ((count(self.best) == 0) or (self.times[4] < self.best[4])) then
     self.best = self.times
    end
    -- write the course-completed status bit
    gpio_set_course_status(1)
    -- write the finishing time to gpio pins
    gpio_set_course_time(self.times[4])
   end

  end

 end,

 -- debug
 debug = function(self)

 end
}

downhill.__index = downhill

-- convert fixed point time to something we can write
convert_time = function(t)

 local seconds = flr(t)
 local hundredths = flr((t - flr(t)) * 100)

 return {seconds, hundredths}

end

-- gates is a table of gate data, {y, x_center, x_width, passed}
gate_search = function(gates, player)

 y = player.world_y
 n = count(gates)
 l = 1
 r = n
 while l <= r do
  m = flr((l+r)/2)
  if gates[m][1] < y then
   l = m + 1
  elseif gates[m][1] > y + player.vy then
   r = m - 1
  else
   return m
  end
 end

 -- failed to find
 return -1

end
