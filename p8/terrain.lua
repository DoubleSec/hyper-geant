terrain = {

 -- base attributes
 n_changes = {8, 15},
 grade = {0.3, 0.8},
 g = 3,

 -- constructor
 new = function(self, base_pos, length, seed)

  -- create new terrain object
  new_t = {}
  setmetatable(new_t, terrain)
  new_t.seed = seed

  --srand(seed)
  srand(seed)

  new_t.n = self.n_changes[1] + flr(rnd(self.n_changes[2] - self.n_changes[1] + 1))
  new_t.ter = {}

  -- generate fractions
  lens = partition_one(new_t.n, 2, length)

  curr_pos = base_pos

  for i=1,count(lens) do

   gr = self.grade[1] + rnd(self.grade[2] - self.grade[1])
   curr_pos = curr_pos + lens[i]
   add(new_t.ter, {curr_pos, gr})
  end

  -- calculate contour lines
  new_t.isoh = {}
  y = base_pos
  curr_slope = 1
  z_step = 8

  while y < base_pos + length do

   add(new_t.isoh, y)
   next = y + (z_step / new_t.ter[curr_slope][2])

   -- check if slope changes
   if next > new_t.ter[curr_slope][1] then

    z_rem = z_step - (new_t.ter[curr_slope][2] * (new_t.ter[curr_slope][1] - y))

    if curr_slope ~= new_t.n then
     next = new_t.ter[curr_slope][1] + z_rem / new_t.ter[curr_slope + 1][2]
    else
     next = y + 5000
    end

    curr_slope = curr_slope + 1
   end

   y = next

  end

  return new_t

 end,

 draw = function(self, player)

  screen_top = player.world_y - player.y
  screen_bottom = screen_top + 128

  visible_idx = frame_search(self.isoh, screen_top, screen_bottom)

  for i = visible_idx[1], visible_idx[2] do
   line_y = self.isoh[i] - player.world_y + player.y
   line(0, line_y, 128, line_y, 6)
  end

 end,

 update = function(self)

 end,

 -- this can be optimized
 get_g = function(self, y)

  for i in all(self.ter) do
   if (i[1] > y) return (i[2] * self.g) / 60
  end

  -- if past end of course
  return 0

 end

}

terrain.__index = terrain

-- get n positive values that sum to one
-- n is number of sections, max_ratio is maximum ratio of size between any two
partition_one = function(n, max_ratio, t_size)

 total = 0
 fracs = {}

 -- Get the raw values and the total
 for i=1,n do
  x = 1 + rnd(max_ratio - 1)
  total = total + x
  add(fracs, x)
 end

 -- divide the raws by the total
 for i=1,n do
  fracs[i] = (fracs[i] / total) * (t_size or 1)
 end

 return fracs

end

-- in a sorted table of numbers y, find the indices such that the values are
--   between low and high
frame_search = function(y, low, high)

 n = count(y)
 res = {}

 for x in all({low, high}) do

 l = 1
 r = n

  while abs(l-r) > 1 do
   m = flr((l+r)/2)
   if y[m] < x then
    l = m
   elseif y[m] > x then
    r = m
   else
    -- if exact found
    add(res, {m, m})
    break -- breaks the while loop
   end
  end

  -- halted and returned range
  add(res, {l, r})

 end

 -- return the two inside values
 return {res[1][2], res[2][1]}
end
