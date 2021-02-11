-- state control for the game
state_machine = {

 -- create a new state machine, with a previously initialized state at the
 --  initial state
 new = function(self, init_state)

  local new_sm = {}
  setmetatable(new_sm, state_machine)

  new_sm.state = init_state

  -- any kind of necessary persistent data is stored here.
  new_sm.persistent = {}

  return new_sm

 end,

 -- update and draw are pretty obvious

 update = function(self)
  self.state:update(self)
 end,

 draw = function(self)
  self.state:draw()
 end,

 -- on state switch, the destructor of the current state is called, and then
 --  the constructor of the new state. any necessary messages or data that need
 --  to be passed are handled by the persistent attribute of the state machine.
 switch = function(self, to)
  self.state:del(self.persistent)
  self.state = to:new(self.persistent)
  --printh(self.state.name)
 end
}

state_machine.__index = state_machine

-- menu state class
menu_state = {

 name = 'menu',

 new = function(self, init_table)

  local n = {}
  setmetatable(n, menu_state)

  n.cn = course_name:new({})
  n.step = 0
  n.color_step = 0

  return n

 end,

 update = function(self, sm)

  -- listen for control
  if btnp(4) then
   sm:switch(game_state)
  end

 end,

 draw = function(self)

  cls()

  print('hyper geant', 40, 40, 9)
  print('hyper geant', 40, 48, 10)
  print('hyper geant', 40, 56, 11)
  print('hyper geant', 40, 64, 12)
  print('hyper geant', 40, 72, 13)
  print('hyper geant', 40, 80, 14)

  print('press \142 to start', 26, 96, 7)

  self.step = (self.step + 1) % 60

  if self.step == 59 then
   pal(9, 9 + (self.color_step + 5) % 6)
   pal(10, 9 + (self.color_step) % 6)
   pal(11, 9 + (self.color_step + 1) % 6)
   pal(12, 9 + (self.color_step + 2) % 6)
   pal(13, 9 + (self.color_step + 3) % 6)
   pal(14, 9 + (self.color_step + 4) % 6)
   self.color_step = (self.color_step + 1) % 6
  end

 end,

 del = function(self, store_table)
  store_table["cn"] = self.cn
  pal()
 end
}
menu_state.__index = menu_state

-- game state class
game_state = {

 name = "game",
 
 restart_count = 0,

 new = function(self, init_table)

  -- create the new instance
  local n = {}
  setmetatable(n, game_state)

  -- initialize the object table
  n.objs = {}

  -- add things to the object table
  n.objs["p1"] = player:new(-10000)
  n.objs["course"] = downhill:new(-10000, 1)
  n.objs["ter"] = terrain:new(-10000, n.objs.course.len + 50, 1)

  -- set up the map
  for x = 0,16 do
   for y = 0,16 do
    mset(x, y, 1)
   end
  end

  return n
 end,

 update = function(self, sm)
 
  -- listen for control
  if btn(4) then
   self.restart_count = self.restart_count + 1

   if self.restart_count > 90 then
    sm:switch(game_state)
   end
  else
   self.restart_count = 0
  end

  self.objs.p1:update(self.objs.ter)
  self.objs.course:update(self.objs.p1)

 end,

 draw = function(self)

  cls()

  -- draw map
  map(0, 0, 0, 0, 16, 16)

  self.objs.ter:draw(self.objs.p1)
  self.objs.course:draw(self.objs.p1)
  self.objs.p1:draw()

  -- print restarting message
  if btn(4) then
   print('restarting', 40, 60, 8)
   cursor()
  end

 end,

 del = function(self, store_table)

 end
}
game_state.__index = game_state
