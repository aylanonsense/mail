local defineClass = require('utils/defineClass')
local tableUtils = require('utils/table')

local Entity = defineClass({
  x = 0,
  y = 0,
  width = 50,
  height = 50,
  vx = 0,
  vy = 0,
  framesAlive = 0,
  timeAlive = 0.00,
  isAlive = true,
  init = function(self, props)
    tableUtils.assign(self, props)
  end,
  baseUpdate = function(self, dt)
    self.framesAlive = self.framesAlive + 1
    self.timeAlive = self.timeAlive + dt
  end,
  update = function(self, dt)
    self.x = self.x + self.vx * dt
    self.y = self.y + self.vy * dt
  end,
  draw = function(self)
    love.graphics.setColor(78 / 255, 39 / 255, 2 / 255)
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
  end
})

return Entity
