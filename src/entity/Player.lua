local defineClass = require('utils/defineClass')
local Entity = require('entity/Entity')

local Player = defineClass(Entity, {
  controller = nil,
  update = function(self, dt)
    local moveX = (self.controller:isDown('right') and 1 or 0) - (self.controller:isDown('left') and 1 or 0)
    local moveY = (self.controller:isDown('down') and 1 or 0) - (self.controller:isDown('up') and 1 or 0)
    self.vx = 60 * moveX
    self.vy = 60 * moveY
    self.x = self.x + self.vx * dt
    self.y = self.y + self.vy * dt
  end
})

return Player
