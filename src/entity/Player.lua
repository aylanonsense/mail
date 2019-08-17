local defineClass = require('utils/defineClass')
local Entity = require('entity/Entity')
local geomUtils = require('utils/geom')

local Player = defineClass(Entity, {
  groups = { 'players' },
  width = 20,
  height = 30,
  controller = nil,
  update = function(self, dt)
    -- Adjust velocity
    local moveX = (self.controller:isDown('right') and 1 or 0) - (self.controller:isDown('left') and 1 or 0)
    local moveY = (self.controller:isDown('down') and 1 or 0) - (self.controller:isDown('up') and 1 or 0)
    -- Apply velocity
    self.vx = 60 * moveX
    self.vy = 60 * moveY -- self.vy + 170 * dt
    self.x = self.x + self.vx * dt
    self.y = self.y + self.vy * dt
    -- Check for bottom collisions
    for _, platform in ipairs(self.game.platforms) do
      local x1, y1, w1, h1 = self.x + 5, self.y + self.height / 2, self.width - 10, self.height / 2
      local x2, y2, w2, h2 = platform.x, platform.y, platform.width, platform.height
      if geomUtils.rectsOverlapping(x1, y1, w1, h1, x2, y2, w2, h2) then
        self.y = platform.y - self.height
        self.vy = math.min(self.vy, platform.vy)
      end
    end
    -- Check for left + right collisions
    for _, platform in ipairs(self.game.platforms) do
      local x1, y1, w1, h1 = self.x, self.y + 7, self.width / 2, self.height - 14
      local x2, y2, w2, h2 = platform.x, platform.y, platform.width, platform.height
      if geomUtils.rectsOverlapping(x1, y1, w1, h1, x2, y2, w2, h2) then
        self.x = platform.x + platform.width
        self.vx = math.max(self.vx, platform.vx)
      end
      x1 = self.x + self.width / 2
      if geomUtils.rectsOverlapping(x1, y1, w1, h1, x2, y2, w2, h2) then
        self.x = platform.x - self.width
        self.vx = math.min(self.vx, platform.vx)
      end
    end
    -- Check for top collisions
    for _, platform in ipairs(self.game.platforms) do
      local x1, y1, w1, h1 = self.x + 5, self.y, self.width - 10, self.height / 2
      local x2, y2, w2, h2 = platform.x, platform.y, platform.width, platform.height
      if geomUtils.rectsOverlapping(x1, y1, w1, h1, x2, y2, w2, h2) then
        self.y = platform.y + platform.height
        self.vy = math.max(self.vy, platform.vy)
      end
    end
  end,
  draw = function(self)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle('line', self.x, self.y, self.width, self.height)
    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle('line', self.x, self.y + 7, self.width / 2, self.height - 14)
    love.graphics.setColor(0, 0, 1)
    love.graphics.rectangle('line', self.x + self.width / 2, self.y + 7, self.width / 2, self.height - 14)
    love.graphics.setColor(1, 1, 0)
    love.graphics.rectangle('line', self.x + 5, self.y, self.width - 10, self.height / 2)
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle('line', self.x + 5, self.y + self.height / 2, self.width - 10, self.height / 2)
  end
})

return Player
