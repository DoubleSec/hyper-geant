-- code for the player class
player = {

 -- physics attributes
 name = "player",

 steer_speed = (180 / 60) * (1 / 360),
 tuck_steer_multiplier = 0.33,

 drag_coef = 0.4 / 30, -- how much drag, dimensionless
 tuck_drag_multiplier = 0.7,
 brake_coef = 0.04 / 30,

 tuck_time = 0.3 * 60,

 new = function(self, base_pos)

  new_p = {}
  setmetatable(new_p, player)

  -- physics state

  new_p.steer_angle = -0.25
  new_p.vx = 0
  new_p.vy = 0

  new_p.v_angle = 0
  new_p.name = "buttz"

  new_p.d_vx = 0
  new_p.d_vy = 0

  new_p.tuck = 0

  -- draw information
  new_p.x = 64
  new_p.y = 24

  -- camera position
  new_p.cx = 0
  new_p.cy = 0

  -- world position
  new_p.world_x = 0
  new_p.world_y = base_pos

  return new_p

 end,

 -- draw and update functions
 draw = function(self)

  self:_force_draw()
  circfill(self.x, self.y, 1, 1)

 end,

 update = function(self, terrain)

  printh(self.name)
  self.g = terrain:get_g(self.world_y)

  -- controls
  self:_input()

  -- physics
  self:_physics()

  -- position updates
  self.cy = self.cy + self.vy
  self.cx = self.cx + self.vx
  self.world_y = self.world_y + self.vy
  self.world_x = self.world_x + self.vx
 end,

 _physics = function(self)

  -- calculate units and angles
  steer_unit = {
   cos(self.steer_angle),
   -sin(self.steer_angle)
  }

  self.v_angle = 1-atan2(self.vy, self.vx)

  if self.v_angle > 0.5 then
   self.v_angle = self.v_angle - 1
  end

  if self.v_angle < -0.5 then
   self.v_angle = self.v_angle + 1
  end

  v_angle = self.v_angle

  v_unit = {
   cos(self.v_angle),
   -sin(self.v_angle)
  }

  if self.v_angle - self.steer_angle < 0 then
   ang_add = 0.25
  else
   ang_add = -0.25
  end

  v_ortho_unit = {
   cos(self.v_angle + ang_add),
   -sin(self.v_angle + ang_add)
  }

  -- angle diffs
  sv_angle_diff = abs(self.v_angle - self.steer_angle)

  -- force application

  -- steering
  steer_force = sin(sv_angle_diff) * self.brake_coef * (self.vx ^ 2 + self.vy ^ 2)

  steer_dvx =
   -cos(sv_angle_diff) * steer_force * v_ortho_unit[2] - -- orthogonal to v
   20 * sin(sv_angle_diff) * steer_force * v_unit[2] -- along v

  steer_dvy =
   -cos(sv_angle_diff) * steer_force * v_ortho_unit[1] - -- ortogonal to v
   20 * sin(sv_angle_diff) * steer_force * v_unit[1] -- along v

  -- g
  g_dvx = cos(self.steer_angle) * self.g * steer_unit[2]
  g_dvy = cos(self.steer_angle) * self.g * steer_unit[1]

  -- drag
  if self.tuck then
   mu = self.drag_coef * self.tuck_drag_multiplier
  else
   mu = self.drag_coef
  end

  drag_force = -(self.vx ^ 2 + self.vy ^ 2) * mu
  drag_dvx = drag_force * v_unit[2]
  drag_dvy = drag_force * v_unit[1]

  -- debug

  self.drag_dvx = drag_dvx
  self.drag_dvy = drag_dvy

  -- final step
  self.vx =
   self.vx +
   g_dvx +
   steer_dvx +
   drag_dvx

  self.vy =
   self.vy +
   g_dvy +
   steer_dvy +
   drag_dvy

 end,

 _force_draw = function(self)

  su = {
   cos(self.steer_angle),
   -sin(self.steer_angle)
  }
  x = self.x
  y = self.y

  -- draw skis
  line(x-1, y, x-1 - su[2] * 4, y - su[1] * 4, 12)
  line(x-1, y, x-1 + su[2] * 6, y + su[1] * 6, 12)
  line(x+1, y, x+1 - su[2] * 4, y - su[1] * 4, 12)
  line(x+1, y, x+1 + su[2] * 6, y + su[1] * 6, 12)

  -- line for drag force
  line(
   self.x, self.y,
   self.x + self.drag_dvx * 100,
   self.y + self.drag_dvy * 100,
   8
  )

 end,

 _input = function(self)

  self.tuck = btn(5)

  if self.tuck == true then
   steer_speed = self.steer_speed * self.tuck_steer_multiplier
  else
   steer_speed = self.steer_speed
  end

  if btn(0) then
  	self.steer_angle = self.steer_angle - steer_speed
  elseif btn(1) then
   self.steer_angle = self.steer_angle + steer_speed
  end

  if self.steer_angle > 0.5 then
   self.steer_angle = self.steer_angle - 1
  end

  if self.steer_angle < -0.5 then
   self.steer_angle = self.steer_angle + 1
  end

 end,


 debug = function(self)

  print("world position: "..self.world_x.." "..self.world_y, 8)

 end
}

player.__index = player
