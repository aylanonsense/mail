local defineClass = require('utils/defineClass')
local Entity = require('entity/Entity')
local geomUtils = require('utils/geom')
local sprites = require('display/sprites')

local Player = defineClass(Entity, {
  minimumGroundSpeed = 4,
  initialGroundSpeed = 5,
  groups = { 'players' },
  vxRelative = 0,
  horizontalSpeedRelative = 0,
  width = 14,
  height = 28,
  controller = nil,
  horizontalCollisionPadding = 4,
  verticalCollisionPadding = 8,
  isStanding = false,
  standingPlatform = nil,
  facingDir = 1,
  groundedMoveSprite = 1,
  spriteFrames = 0,
  update = function(self, dt)
    self.spriteFrames = self.spriteFrames + 1
    local moveX = (self.controller:isDown('right') and 1 or 0) - (self.controller:isDown('left') and 1 or 0)
    local moveY = (self.controller:isDown('down') and 1 or 0) - (self.controller:isDown('up') and 1 or 0)
    -- Movement while on the ground
    if self.isStanding then
      -- Get velocity relative to the platform being stood on
      self.vxRelative = self.vx - self.standingPlatform.vx
      local speed = math.abs(self.vxRelative)
      -- Passively decelerate
      if moveX == 0 then
        if speed < self.minimumGroundSpeed then
          self.vxRelative = 0
        else
          self.vxRelative = (self.vxRelative < 0 and -1 or 1) * self:decelerateGroundSpeed(dt, speed, false)
        end
      -- Start moving
      elseif speed == 0 then
        self.vxRelative = self.initialGroundSpeed * moveX
        self.groundedMoveSprite = 1
        self.spriteFrames = 0
      -- Accelerate
      elseif (self.vxRelative > 0) == (moveX > 0) then
        self.vxRelative = (self.vxRelative < 0 and -1 or 1) * self:accelerateGroundSpeed(dt, speed)
      -- Actively decelerate
      else
        if speed < self.minimumGroundSpeed then
          self.vxRelative = self.initialGroundSpeed * moveX
          self.groundedMoveSprite = 1
          self.spriteFrames = 0
        else
          self.vxRelative = (self.vxRelative < 0 and -1 or 1) * self:decelerateGroundSpeed(dt, speed, true)
        end
      end
      -- Updating facing
      if self.vxRelative > 0 and moveX > 0 then
        self.facingDir = 1
      elseif self.vxRelative < 0 and moveX < 0 then 
        self.facingDir = -1
      end
      -- Set velocity
      self.vx = self.vxRelative + self.standingPlatform.vx
    else
      self.vxRelative = self.vx
    end
    self.horizontalSpeedRelative = math.abs(self.vxRelative)
    -- Jump
    if self.isStanding and self.controller:justPressed('jump', 6, true) then
      self.vy = -200
      self.isStanding = false
      self.standingPlatform = nil
    end
    -- Update grounded movement sprite
    if self.isStanding then
      local stepFrames, airFrames
      if self.horizontalSpeedRelative <= 75 then
        stepFrames, airFrames = 8, 14
      elseif self.horizontalSpeedRelative <= 200 then
        stepFrames, airFrames = 5, 8
      elseif self.horizontalSpeedRelative <= 250 then
        stepFrames, airFrames = 7, 14
      else
        stepFrames, airFrames = 7, 22
      end
      if self.groundedMoveSprite == 1 and self.spriteFrames >= stepFrames then
        self.groundedMoveSprite = 2
        self.spriteFrames = 0
      elseif self.groundedMoveSprite == 2 and self.spriteFrames >= airFrames then
        self.groundedMoveSprite = 3
        self.spriteFrames = 0
      elseif self.groundedMoveSprite == 3 and self.spriteFrames >= stepFrames then
        self.groundedMoveSprite = 4
        self.spriteFrames = 0
      elseif self.groundedMoveSprite == 4 and self.spriteFrames >= airFrames then
        self.groundedMoveSprite = 1
        self.spriteFrames = 0
      end
    end
    -- Apply velocity
    -- self.vx = self.vx + 5 * moveX
    self.vy = self.vy + 300 * dt
    self.x = self.x + self.vx * dt
    self.y = self.y + self.vy * dt
    local wasStanding = self.isStanding
    self.isStanding = false
    self.standingPlatform = nil
    -- Check for bottom collisions
    self:checkForCollisions(self.x + self.horizontalCollisionPadding, self.y + self.height / 2, self.width - 2 * self.horizontalCollisionPadding, self.height / 2, function(platform)
      self.y = platform.y - self.height
      self.vy = math.min(self.vy, platform.vy)
      self.isStanding = true
      self.standingPlatform = platform
      if not wasStanding then
        self.groundedMoveSprite = 1
        self.spriteFrames = 0
      end
    end)
    -- Check for left collisions
    self:checkForCollisions(self.x, self.y + self.verticalCollisionPadding, self.width / 2, self.height - 2 * self.verticalCollisionPadding, function(platform)
        self.x = platform.x + platform.width
        self.vx = math.max(self.vx, platform.vx)
    end)
    -- Check for right collisions
    self:checkForCollisions(self.x + self.width / 2, self.y + self.verticalCollisionPadding, self.width / 2, self.height - 2 * self.verticalCollisionPadding, function(platform)
        self.x = platform.x - self.width
        self.vx = math.min(self.vx, platform.vx)
    end)
    -- Check for top collisions
    self:checkForCollisions(self.x + self.horizontalCollisionPadding, self.y, self.width - 2 * self.horizontalCollisionPadding, self.height / 2, function(platform)
      self.y = platform.y + platform.height
      self.vy = math.max(self.vy, platform.vy)
    end)
  end,
  draw = function(self)
    -- love.graphics.setColor(1, 1, 1)
    -- love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
    -- love.graphics.print(math.floor(self.vx + 0.5), self.x, self.y - 20)
    -- love.graphics.setColor(0, 1, 0)
    -- love.graphics.rectangle('line', self.x, self.y + self.verticalCollisionPadding, self.width / 2, self.height - 2 * self.verticalCollisionPadding)
    -- love.graphics.setColor(0, 0, 1)
    -- love.graphics.rectangle('line', self.x + self.width / 2, self.y + self.verticalCollisionPadding, self.width / 2, self.height - 2 * self.verticalCollisionPadding)
    -- love.graphics.setColor(1, 1, 0)
    -- love.graphics.rectangle('line', self.x + self.horizontalCollisionPadding, self.y, self.width - 2 * self.horizontalCollisionPadding, self.height / 2)
    -- love.graphics.setColor(1, 0, 0)
    -- love.graphics.rectangle('line', self.x + self.horizontalCollisionPadding, self.y + self.height / 2, self.width - 2 * self.horizontalCollisionPadding, self.height / 2)
    local spriteSheet = sprites.mailgirl
    local sprite
    if self.isStanding and self.horizontalSpeedRelative >= self.initialGroundSpeed then
      sprite = spriteSheet.running[self.groundedMoveSprite]
    else
      sprite = spriteSheet.standing
    end
    love.graphics.setColor(1, 1, 1)
    sprite:draw(self.x - 14, self.y - 15, self.facingDir < 0)
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(math.floor(self.vx), self.x, self.y - 20)
  end,
  checkForCollisions = function(self, x, y, width, height, callback)
    for _, platform in ipairs(self.game.platforms) do
      if geomUtils.rectsOverlapping(x, y, width, height, platform.x, platform.y, platform.width, platform.height) then
        callback(platform)
      end
    end
  end,
  accelerateGroundSpeed = function(self, dt, speed)
    local change
    -- Accelerate quickly
    if speed <= 175 then
      change = 4.5
    -- Then start slowing down acceleration
    elseif speed <= 225 then
      change = 1.5
    else
      change = 0.5
    end
    return math.max(speed, math.min(275, speed + change))
  end,
  decelerateGroundSpeed = function(self, dt, speed, active)
    local change
    if active then
      if speed <= 100 then
        change = 10
      else
        change = 6
      end
    else
      if speed <= 25 then
        change = 1.5
      elseif speed <= 100 then
        change = 5
      else
        change = 3
      end
    end
    return math.max(0, speed - change)
  end
})

return Player
