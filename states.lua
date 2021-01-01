-- state control for the game
state_machine = {

 -- create a new state machine, with a previously initialized state at the
 --  initial state
 new = function(self, init_state)

  new_sm = {}
  setmetatable(new_sm, state_machine)

  new_sm.state = init_state

  -- any kind of necessary persistent data is stored here.
  new_sm.persistent = {}

  return new_sm

 end,

 -- update and draw are pretty obvious

 update = function(self)
  self.state:update()
 end,

 draw = function(self)
  self.state:draw()
 end,

 -- on state switch, the destructor of the current state is called, and then
 --  the constructor of the new state. any necessary messages or data that need
 --  to be passed are handled by the persistent attribute of the state machine.
 switch = function(self, to)
  state:del(self.persistent)
  state = to:new(self.persistent)
 end
}

state_machine.__index = state_machine

-- menu state class
menu_state = {

 new = function(self, init_table)

 end,

 update = function(self)

 end,

 draw = function(self)

 end,

 del = function(self, store_table)

 end
}
menu_state.__index = menu_state

-- game state class
game_state = {

 new = function(self, init_table)

  -- create the new instance
  n = {}
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

 update = function(self)

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

 end,

 del = function(self, store_table)

 end
}
game_state.__index = game_state
