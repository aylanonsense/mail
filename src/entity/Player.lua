local defineClass = require('utils/defineClass')
local Entity = require('entity/Entity')

local Player = defineClass(Entity, {
  width = 20,
  height = 30,
  controller = nil,
  update = function(self, dt)
    -- Adjust velocity
    local moveX = (self.controller:isDown('right') and 1 or 0) - (self.controller:isDown('left') and 1 or 0)
    -- Apply velocity
    self.vx = 60 * moveX
    self.vy = self.vy + 170 * dt
    self.x = self.x + self.vx * dt
    self.y = self.y + self.vy * dt
    -- Check for collisions
    -- ...
  end
})

return Player
