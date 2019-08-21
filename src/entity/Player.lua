local defineClass = require('utils/defineClass')
local Entity = require('entity/Entity')
local geomUtils = require('utils/geom')
local sprites = require('display/sprites')

local Player = defineClass(Entity, {
  groups = { 'players' },
  width = 14,
  height = 28,
  controller = nil,
  _horizontalCollisionPadding = 4,
  _verticalCollisionPadding = 8,
  update = function(self, dt)
    -- Adjust velocity
    local moveX = (self.controller:isDown('right') and 1 or 0) - (self.controller:isDown('left') and 1 or 0)
    local moveY = (self.controller:isDown('down') and 1 or 0) - (self.controller:isDown('up') and 1 or 0)
    -- Apply velocity
    self.vx = self.vx + 5 * moveX
    self.vy = self.vy + 5 * moveY -- self.vy + 170 * dt
    self.x = self.x + self.vx * dt
    self.y = self.y + self.vy * dt
    -- Check for bottom collisions
    self:_checkForCollisions(self.x + self._horizontalCollisionPadding, self.y + self.height / 2, self.width - 2 * self._horizontalCollisionPadding, self.height / 2, function(platform)
      self.y = platform.y - self.height
      self.vy = math.min(self.vy, platform.vy)
    end)
    -- Check for left collisions
    self:_checkForCollisions(self.x, self.y + self._verticalCollisionPadding, self.width / 2, self.height - 2 * self._verticalCollisionPadding, function(platform)
        self.x = platform.x + platform.width
        self.vx = math.max(self.vx, platform.vx)
    end)
    -- Check for right collisions
    self:_checkForCollisions(self.x + self.width / 2, self.y + self._verticalCollisionPadding, self.width / 2, self.height - 2 * self._verticalCollisionPadding, function(platform)
        self.x = platform.x - self.width
        self.vx = math.min(self.vx, platform.vx)
    end)
    -- Check for top collisions
    self:_checkForCollisions(self.x + self._horizontalCollisionPadding, self.y, self.width - 2 * self._horizontalCollisionPadding, self.height / 2, function(platform)
      self.y = platform.y + platform.height
      self.vy = math.max(self.vy, platform.vy)
    end)
  end,
  draw = function(self)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle('line', self.x, self.y + self._verticalCollisionPadding, self.width / 2, self.height - 2 * self._verticalCollisionPadding)
    love.graphics.setColor(0, 0, 1)
    love.graphics.rectangle('line', self.x + self.width / 2, self.y + self._verticalCollisionPadding, self.width / 2, self.height - 2 * self._verticalCollisionPadding)
    love.graphics.setColor(1, 1, 0)
    love.graphics.rectangle('line', self.x + self._horizontalCollisionPadding, self.y, self.width - 2 * self._horizontalCollisionPadding, self.height / 2)
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle('line', self.x + self._horizontalCollisionPadding, self.y + self.height / 2, self.width - 2 * self._horizontalCollisionPadding, self.height / 2)
    love.graphics.setColor(1, 1, 1)
    sprites.mailgirl.standing:draw(self.x - 14, self.y - 15)
  end,
  _checkForCollisions = function(self, x, y, width, height, callback)
    for _, platform in ipairs(self.game.platforms) do
      if geomUtils.rectsOverlapping(x, y, width, height, platform.x, platform.y, platform.width, platform.height) then
        callback(platform)
      end
    end
  end
})

return Player
