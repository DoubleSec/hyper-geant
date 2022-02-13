-- since we don't have fancy string operations, we have to do this nonsense
course_name = {

 lookup = {
  a = 1, b = 2, c = 3, d = 4,
  e = 5, f = 6, g = 7, h = 8,
  i = 9, j = 10, k = 11, l = 12,
  m = 13, n = 14, o = 15, p = 16,
  q = 17, r = 18, s = 19, t = 20,
  u = 21, v = 22, w = 23, x = 24,
  y = 25, z = 26, _ = 27
 },

 new = function(self, letters)

  n = {}
  setmetatable(n, course_name)

   -- make a reverse lookup table
  rev = {}
  for k, v in pairs(self.lookup) do
   rev[v] = k
  end
  n.rev = rev

  if count(letters) == 0 then
   
   n.letters = {}
   for i=1,5 do
    add(n.letters, n.rev[1 + flr(rnd(26))])
   end

  else
   n.letters = letters
  end

  return n
 end,

 -- turn the course name into a number
 to_seed = function(self)

  return self.lookup[self.letters[1]] * 1000 +
         self.lookup[self.letters[2]] * 100 +
         self.lookup[self.letters[3]] * 10 +
         self.lookup[self.letters[4]] +
         self.lookup[self.letters[5]] * 0.1
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
course_name.__index = course_name
