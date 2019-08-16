local defineClass = require('utils/defineClass')
local tableUtils = require('utils/table')

local Entity = defineClass({
  x = 0,
  y = 0,
  width = 50,
  height = 50,
  vx = 0,
  vy = 0,
  init = function(self, props)
    tableUtils.assign(self, props)
  end,
  update = function(self, dt)
    self.x = self.x + self.vx * dt
    self.y = self.y + self.vy * dt
  end,
  draw = function(self)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle('line', self.x, self.y, self.width, self.height)
  end
})

return Entity
