local defineClass = require('utils/defineClass')
local Entity = require('entity/Entity')
local geomUtils = require('utils/geom')
local sprites = require('display/sprites')

local Player = defineClass(Entity, {
  minimumGroundSpeed = 4,
  initialJumpSpeed = 222,
  minimumAirSpeed = 1,
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
  verticalVelocitySource = nil,
  vxWorld = 0,
  update = function(self, dt)
    self.spriteFrames = self.spriteFrames + 1
    local moveX = (self.controller:isDown('right') and 1 or 0) - (self.controller:isDown('left') and 1 or 0)
    local moveY = (self.controller:isDown('down') and 1 or 0) - (self.controller:isDown('up') and 1 or 0)
    -- Figure out the speed of the ground the player is standing on or the air
    if self.isStanding then
      self.vxWorld = self.standingPlatform.vx
    else
      self.vxWorld = 0
    end
    -- Movement while on the ground
    if self.isStanding then
      -- Get velocity relative to the platform being stood on
      local vxRelative = self.vx - self.vxWorld
      local speed = math.abs(vxRelative)
      -- Passively decelerate
      if moveX == 0 then
        if speed < self.minimumGroundSpeed then
          vxRelative = 0
        else
          vxRelative = (vxRelative < 0 and -1 or 1) * self:decelerateGroundSpeed(speed, false)
        end
      -- Start moving
      elseif speed == 0 then
        vxRelative = moveX * self:accelerateGroundSpeed(speed)
        self.groundedMoveSprite = 1
        self.spriteFrames = 0
      -- Accelerate
      elseif (vxRelative > 0) == (moveX > 0) then
        vxRelative = (vxRelative < 0 and -1 or 1) * self:accelerateGroundSpeed(speed)
      -- Actively decelerate
      else
        if speed < self.minimumGroundSpeed then
          vxRelative = moveX * self:accelerateGroundSpeed(0)
          self.groundedMoveSprite = 1
          self.spriteFrames = 0
        else
          vxRelative = (vxRelative < 0 and -1 or 1) * self:decelerateGroundSpeed(speed, true)
        end
      end
      -- Update facing
      if vxRelative > 0 and moveX > 0 then
        self.facingDir = 1
      elseif vxRelative < 0 and moveX < 0 then 
        self.facingDir = -1
      end
      -- Set velocity
      self.vx = vxRelative + self.vxWorld
    -- Movement while airborne
    else
      local vxRelative = self.vx - self.vxWorld
      local speed = math.abs(vxRelative)
      -- Passively decelerate
      if moveX == 0 then
        if speed < self.minimumAirSpeed then
          vxRelative = 0
        else
          vxRelative = (vxRelative < 0 and -1 or 1) * self:decelerateAirSpeed(speed, false)
        end
      -- Start moving
      elseif speed == 0 then
        vxRelative = moveX * self:accelerateAirSpeed(speed)
      -- Accelerate
      elseif (vxRelative > 0) == (moveX > 0) then
        vxRelative = (vxRelative < 0 and -1 or 1) * self:accelerateAirSpeed(speed)
      -- Actively decelerate
      else
        vxRelative = (vxRelative < 0 and -1 or 1) * self:decelerateAirSpeed(speed, true)
      end
      -- Updating facing
      if vxRelative > 0 and moveX > 0 then
        self.facingDir = 1
      elseif vxRelative < 0 and moveX < 0 then 
        self.facingDir = -1
      end
      self.vx = vxRelative + self.vxWorld
    end
    -- Jump
    local justJumped = false
    if self.isStanding and self.controller:justPressed('jump', 6, true) then
      justJumped = true
      self.vy = -self.initialJumpSpeed
      self.isStanding = false
      self.standingPlatform = nil
      self.verticalVelocitySource = 'jump'
      if moveX ~= 0 then
        local vxRelative = self.vx - self.vxWorld
        local speed = math.abs(vxRelative)
        if speed == 0 then
          vxRelative = moveX * self:accelerateJumpSpeed(speed)
        elseif (moveX > 0) == (vxRelative > 0) then
          vxRelative = (vxRelative > 0 and 1 or -1) * self:accelerateJumpSpeed(speed)
        else
          vxRelative = (vxRelative > 0 and 1 or -1) * self:decelerateJumpSpeed(speed)
        end
        self.vx = vxRelative + self.vxWorld
      end
    end
    -- Update grounded movement sprite
    if self.isStanding then
      local speedRelative = math.abs(self.vx - self.vxWorld)
      local stepFrames, airFrames
      if speedRelative <= 75 then
        stepFrames, airFrames = 8, 14
      elseif speedRelative <= 200 then
        stepFrames, airFrames = 5, 8
      elseif speedRelative <= 250 then
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
    -- Apply gravity
    if not justJumped then
      self.vy = self:applyGravity(self.vy, self.verticalVelocitySource)
    end
    -- Apply velocity
    self.x = self.x + self.vx * dt
    self.y = self.y + self.vy * dt
    local wasStanding = self.isStanding
    self.isStanding = false
    self.standingPlatform = nil
    -- Check for bottom collisions
    self:checkForCollisions(self.x + self.horizontalCollisionPadding, self.y + self.height / 2, self.width - 2 * self.horizontalCollisionPadding, self.height / 2, function(platform)
      self.y = platform.y - self.height
      self.vy = math.min(self.vy, platform.vy)
      self.standingPlatform = platform
      self.vxWorld = self.standingPlatform.vx
      self.verticalVelocitySource = nil
      if not self.isStanding and not wasStanding then
        self.groundedMoveSprite = 1
        self.spriteFrames = 0
        if moveX ~= 0 then
          local vxRelative = self.vx - self.vxWorld
          if vxRelative ~= 0 and (vxRelative > 0) ~= (moveX > 0) then
            local speed = math.abs(vxRelative)
            vxRelative = (vxRelative > 0 and 1 or -1) * self:decelerateLandingSpeed(speed)
            self.vx = vxRelative + self.vxWorld
          end
        end
      end
      self.isStanding = true
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
    if wasStanding and not self.isStanding then
      self.verticalVelocitySource = 'fall'
    end
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
    local speedRelative = math.abs(self.vx - self.vxWorld)
    if self.isStanding and speedRelative >= 10 then
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
  applyGravity = function(self, vy, source)
    local change
    -- On the way up, apply a lot of gravity
    if vy >= 5 then
      change = 15
    -- Toward the apex, apply less
    elseif vy >= -2 then
      change = 4.5
    -- Then apply a bit more on the way down
    else
      change = 9
    end
    return vy + change
  end,
  accelerateGroundSpeed = function(self, speed)
    local change
    -- Accelerate quickly
    if speed <= 175 then
      change = 5.5
    -- Then start slowing down acceleration
    elseif speed <= 225 then
      change = 1.5
    else
      change = 0.5
    end
    return math.max(10, speed, math.min(250, speed + change))
  end,
  decelerateGroundSpeed = function(self, speed, active)
    local change
    if active then
      if speed <= 100 then
        change = 20
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
  end,
  accelerateAirSpeed = function(self, speed)
    local change
    if speed <= 20 then
      change = 10
    elseif speed <= 150 then
      change = 3.5
    else
      change = 1.5
    end
    return math.max(15, math.min(250, speed + change), speed)
  end,
  decelerateAirSpeed = function(self, speed, active)
    if active then
      local change
      if speed <= 50 then
        change = 10
      elseif speed <= 125 then
        change = 6
      elseif speed <= 225 then
        change = 5
      else
        change = 10
      end
      return math.max(-1, speed - change)
    else
      return speed
    end
  end,
  accelerateJumpSpeed = function(self, speed)
    return math.max(speed, math.min(speed + 15, 150))
  end,
  decelerateJumpSpeed = function(self, speed)
    return math.max(0, speed - 30)
  end,
  decelerateLandingSpeed = function(self, speed)
    return math.max(math.min(speed, 10), speed - 15)
  end
})

return Player
