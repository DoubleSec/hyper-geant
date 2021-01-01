downhill = {

 -- pre-set attributes
 y_gap_r = {72, 128},
 x_gap_r = {48, 96},
 x_offset_r = {-128, 128},
 gates_r = {25, 40},

 -- constructor
 -- base_pos is y coordinate of start, seed is random seed value
 new = function(self, base_pos, seed)

  new_dh = {}
  setmetatable(new_dh, downhill)
  new_dh.seed = seed

  --srand(seed)

  -- Generate the path
  new_dh.gates = {}
  new_dh.n_gates = self.gates_r[1] +
                   flr(rnd(self.gates_r[2] - self.gates_r[1] + 1))
  new_dh.n_passed = 0
  new_dh.gate_missed = false
  new_dh.course_start = 0
  new_dh.course_end = 0

  new_dh.gates[1] = {base_pos + 50, 0, 50}

  for i = 2, new_dh.n_gates, 1 do

   -- choose y
   y = new_dh.gates[i-1][1] + self.y_gap_r[1] +
       rnd(self.y_gap_r[2] - self.y_gap_r[1])

   -- choose x
   -- x format is {center, width}
   x_last = new_dh.gates[i-1][2]

   x_center = x_last + self.x_offset_r[1] +
              rnd(self.x_offset_r[2] - self.x_offset_r[1])
   x_width = self.x_gap_r[1] + rnd(self.x_gap_r[2] - self.x_gap_r[1])

   add(new_dh.gates, {y, x_center, x_width})

  end

  new_dh.len = new_dh.gates[new_dh.n_gates][1] - base_pos

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

     -- previous late info
     prev_x_left = (self.gates[i-1][2] - self.gates[i-1][3] / 2) - player.world_x + player.x
     prev_x_right = (self.gates[i-1][2] + self.gates[i-1][3] / 2) - player.world_x + player.x
     prev_y = self.gates[i-1][1] - player.world_y + player.y

     -- start/finish line
     if (i == self.n_gates) line(x_left - 20, y, x_right + 20, y, 12)

     -- left border, right border
     line(prev_x_left, prev_y, x_left, y, 8)
     line(prev_x_right, prev_y, x_right, y, 8)

    end

    -- left side, right side
    line(x_left, y, x_left, y - 5, 5)
    line(x_right, y, x_right, y - 5, 5)

   end

  end

  print(self.n_passed.."/"..self.n_gates)

  if self.course_start == 0 then
   t = 0
   c = 5
  elseif self.course_end == 0 then
   t = time() - self.course_start
   c = 5
  else
   t = self.course_end - self.course_start
   c = 3
  end

  if self.gate_missed then
   print("out", 8)
  else
   print(flr(t * 100) / 100, c)
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

   if (crossing_idx == count(self.gates) and not self.gate_missed) then
    self.course_end = time()
   end

  end


 end,

 -- debug
 debug = function(self)

 end
}

downhill.__index = downhill

-- gates is a table of gate data, {x, x_center, x_width, passed}
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
