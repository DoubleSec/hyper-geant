-- since we don't have fancy string operations, we have to do this nonsense
player_name = {

 lookup = {
  a = 1, b = 2, c = 3, d = 4,
  e = 5, f = 6, g = 7, h = 8,
  i = 9, j = 10, k = 11, l = 12,
  m = 13, n = 14, o = 15, p = 16,
  q = 17, r = 18, s = 19, t = 20,
  u = 21, v = 22, w = 23, x = 24,
  y = 25, z = 26
 },

 new = function(self, letters)

  n = {}
  setmetatable(n, player_name)

   -- make a reverse lookup table
  rev = {}
  for k, v in pairs(self.lookup) do
   rev[v] = k
  end
  n.rev = rev

  if count(letters) == 0 then
   
   n.letters = {}
   for i=1,3 do
    add(n.letters, n.rev[1 + flr(rnd(25))])
   end

  else
   n.letters = letters
  end

  return n
 end,

 -- letters as numbers for gpio
 to_nums = function(self)
  
  local nums = {}

  for i in all(self.letters) do
   add(nums, self.lookup[i])
  end

  return nums
 end,

 to_str = function(self)

  local res = ''

  for i in all(self.letters) do
   res = res..i
  end

  return res
 end
}
player_name.__index = player_name
