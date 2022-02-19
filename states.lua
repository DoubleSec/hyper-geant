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
intro_state = {

 name = 'intro',

 new = function(self, init_table)

  local n = {}
  setmetatable(n, intro_state)

  n.step = 0
  n.color_step = 0

  return n

 end,

 update = function(self, sm)

  -- listen for control
  if btnp(4) then
   sm:switch(select_state)
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

  self.step = (self.step + 1) % 12

  if self.step == 11 then
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
  pal()
 end
}
intro_state.__index = intro_state

select_state = {
 
 name = "select",

 new = function(self, init_table)
  
  local n = {}
  setmetatable(n, select_state)

  -- check if there's an existing player name
  if init_table.pname ~= nil then
   n.pname = init_table.pname
  else
   n.pname = player_name:new({})
  end

  n.iname = n.pname.letters

  n.blink = 0
  n.cur_pos = 0
  n.cur_val = n.pname.lookup[n.iname[1]] - 1

  return n
   
 end,

 update = function(self, sm)
  
  -- controls
  if btnp(0) then
   self.cur_pos = (self.cur_pos - 1) % 3
   self.cur_val = self.pname.lookup[self.iname[self.cur_pos + 1]] - 1
  elseif btnp(1) then
   self.cur_pos = (self.cur_pos + 1) % 3
   self.cur_val = self.pname.lookup[self.iname[self.cur_pos + 1]] - 1 
  elseif btnp(2) then
   self.cur_val = (self.cur_val - 1) % 26
  elseif btnp(3) then
   self.cur_val = (self.cur_val + 1) % 26
  elseif btnp(4) then
   self.pname.letters = self.iname
   sm:switch(game_state)
  end

  self.iname[self.cur_pos + 1] = self.pname.rev[self.cur_val + 1]

 end,

 draw = function(self)
  cls()

  self.blink = (self.blink + 1) % 60

  print("enter your initials!", 24, 28)

  for i, char in pairs(self.iname) do
   
   if i ~= self.cur_pos + 1 or self.blink < 30 then
    print(char, 43 + i * 10, 60)
   end
  end

  print("press \142 to confirm", 26, 92)

 end,

 del = function(self, store_table)
  pal()
  local lids = self.pname:to_nums()
  -- write the name of the course to gpio pins
  poke(0x5f80, lids[1], lids[2], lids[3])
  store_table.pname = self.pname
 end
}
select_state.__index = select_state

-- game state class
game_state = {

 name = "game",
 
 restart_count = 0,

 new = function(self, init_table)

  -- create the new instance
  local n = {}
  setmetatable(n, game_state)

  n.pname = init_table.pname

  -- initialize the object table  
  n.objs = {}

  -- retrieve the seed from gpio
  seed = $0x5f90

  -- add things to the object table
  n.objs["p1"] = player:new(-10000)
  -- eventually will come off gpio
  n.objs["course"] = downhill:new(-10000, seed, n.pname)
  n.objs["ter"] = terrain:new(-10000, n.objs.course.len + 50, seed)

  -- set up the map
  for x = 0,16 do
   for y = 0,16 do
    mset(x, y, 1)
   end
  end

  -- set the completed-status gpio pin
  poke(0x5f87, 0)

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
