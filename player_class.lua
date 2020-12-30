-- code for the player class
player = {
 -- draw information
 sidx = 3,
 x = 64,
 y = 24,

 -- camera position
 cx = 0,
 cy = 0,

 -- world position
 world_x = 0,
 world_y = -10000,

 -- physics attributes

 steer_speed = (180 / 60) * (1 / 360),
 tuck_steer_multiplier = 0.33,

 drag_coef = 0.4 / 30, -- how much drag, dimensionless
 tuck_drag_multiplier = 0.7,
 g = 1 / 60,
 brake_coef = 0.04 / 30,

 -- physics state

 steer_angle = 0,

 vx = 0,
 vy = 0,

 v_angle = 0,

 d_vx = 0,
 d_vy = 0,

 tuck = false,

 -- physics debug
 steer_p_unit = 0,
 steer_unit = 0,

 -- draw and update functions
 draw = function(self)

  circfill(self.x, self.y, 1, 1)
  self:_force_draw()

 end,

 update = function(self)

  -- controls
  self:_input()

  -- physics
  self:_u_speed()

  -- position updates
  self.cy = self.cy + self.vy
  self.cx = self.cx + self.vx
  self.world_y = self.world_y + self.vy
  self.world_x = self.world_x + self.vx
 end,

 _u_speed = function(self)

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
  self.steer_dvx = steer_dvx
  self.steer_dvy = steer_dvy

  self.g_dvx = g_dvx
  self.g_dvy = g_dvy

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

  steer_unit = {
   cos(self.steer_angle),
   -sin(self.steer_angle)
  }

  -- draw line for steer angle
  line(
   self.x, self.y,
   self.x + steer_unit[2] * 10,
   self.y + steer_unit[1] * 10,
   12
  )

  -- line for drag force
  line(
   self.x, self.y,
   self.x + self.drag_dvx * 200,
   self.y + self.drag_dvy * 200,
   8
  )

  -- line for g force
  line(
   self.x, self.y,
   self.x + self.g_dvx * 200,
   self.y + self.g_dvy * 200,
   11
  )

  -- line for steering force
  line(
   self.x, self.y,
   self.x + self.steer_dvx * 200,
   self.y + self.steer_dvy * 200,
   9
  )

  -- line for velocity
  line(
   self.x, self.y,
   self.x + self.vx * 10,
   self.y + self.vy * 10,
   1
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
