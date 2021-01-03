-- since we don't have fancy string operations, we have to do this nonsense
course_name = {

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
  setmetatable(n, course_name)

  -- this is a list
  if count(letters) == 0 then

   -- make a reverse lookup table
   rev = {}
   for k, v in pairs(self.lookup) do
    rev[v] = k
   end

   n.letters = {}
   for i=1,5 do
    add(n.letters, 1 + flr(rnd(26)))
   end

  else
   n.letters = letters
  end

  return n
 end,

 -- turn the course name into a number
 to_num = function(self)

  t = {}

  -- fill in spaces
  for k, v in pairs(self.letters) do
   if v == ' ' then
    t[k] = 'a'
   else
    t[k] = v
   end
  end

  return t[1] * 1000 + t[2] * 100 + t[3] * 10 + t[4] + t[5] * 0.1
 end,

 to_str = function(self)

  res = ''

  for i in all(self.letters) do
   res = res..i
  end

  return res
 end
}
course_name.__index = course_name
