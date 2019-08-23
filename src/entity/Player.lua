local defineClass = require('utils/defineClass')
local Entity = require('entity/Entity')
local geomUtils = require('utils/geom')
local sprites = require('display/sprites')

local Player = defineClass(Entity, {
  minimumGroundSpeed = 4,
  initialJumpSpeed = 240,
  initialDoubleJumpSpeed = 180,
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
  framesSinceLastStanding = 0,
  framesSinceJump = 0,
  vxWorld = 0,
  hasDoubleJump = false,
  update = function(self, dt)
    self.spriteFrames = self.spriteFrames + 1
    self.framesSinceLastStanding = self.framesSinceLastStanding + 1
    self.framesSinceJump = self.framesSinceJump + 1
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
      if moveX > 0 then
        self.facingDir = 1
      elseif moveX < 0 then
        self.facingDir = -1
      end
      self.vx = vxRelative + self.vxWorld
    end
    -- Jump
    local justJumped = false
    if (self.isStanding or (self.framesSinceLastStanding < 7 and self.verticalVelocitySource == 'fall')) and self.controller:justPressed('jump', 6, true) then
      justJumped = true
      self.vy = -self.initialJumpSpeed
      self.isStanding = false
      self.standingPlatform = nil
      self.verticalVelocitySource = 'jump'
      self.framesSinceJump = 0
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
    -- Double jump
    if self.hasDoubleJump and not self.isStanding and self.framesSinceLastStanding > 7 and self.controller:justPressed('jump', 5, true) then
      justJumped = true
      self.hasDoubleJump = false
      self.verticalVelocitySource = 'jump'
      self.vy = -self.initialDoubleJumpSpeed
      self.framesSinceJump = 0
      local vxRelative = self.vx - self.vxWorld
      local speed = math.abs(vxRelative)
      if moveX == 0 then
        vxRelative = (vxRelative > 0 and 1 or -1) * self:applyNeutralDoubleJump(speed)
      elseif speed == 0 then
        vxRelative = moveX * self:applyForwardDoubleJump(speed)
      elseif (moveX > 0) == (vxRelative > 0) then
        vxRelative = (vxRelative > 0 and 1 or -1) * self:applyForwardDoubleJump(speed)
      else
        vxRelative = (vxRelative > 0 and 1 or -1) * self:applyBackwardDoubleJump(speed)
      end
      self.vx = vxRelative + self.vxWorld
    end
    -- Cut jump short
    if self.verticalVelocitySource == 'jump' and self.framesSinceJump > 6 and not self.controller:isDown('jump') then
      self.vy = math.max(-90, self.vy)
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
      local vyRelative = self.vy - platform.vy
      if vyRelative >= -5 then
        -- Land on the platform
        vyRelative = 0
        self.vy = vyRelative + platform.vy
        self.standingPlatform = platform
        self.vxWorld = self.standingPlatform.vx
        self.verticalVelocitySource = nil
        if not self.isStanding and not wasStanding then
          self.groundedMoveSprite = 1
          self.spriteFrames = 0
          local vxRelative = self.vx - self.vxWorld
          if vxRelative ~= 0 and (moveX == 0 or (vxRelative > 0) ~= (moveX > 0)) then
            local speed = math.abs(vxRelative)
            vxRelative = (vxRelative > 0 and 1 or -1) * self:decelerateLandingSpeed(speed)
            self.vx = vxRelative + self.vxWorld
          end
        end
        self.isStanding = true
        self.framesSinceLastStanding = 0
        self.hasDoubleJump = true
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
    if wasStanding and not self.isStanding and not justJumped then
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
    elseif self.isStanding then
      sprite = spriteSheet.standing
    else
      sprite = spriteSheet.jumping
    end
    love.graphics.setColor(1, 1, 1)
    sprite:draw(self.x - 14, self.y - 15, self.facingDir < 0)
    love.graphics.setColor(0, 0, 0)
    -- love.graphics.print(math.floor(self.vy), self.x, self.y - 20)
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
    if vy <= -5 then
      change = 11
    -- Toward the apex, apply less
    elseif vy <= 5 then
      change = 5
    -- Then apply a bit more on the way down
    else
      change = 9
    end
    return math.min(math.max(300, vy), vy + change)
  end,
  accelerateGroundSpeed = function(self, speed)
    local change
    -- Accelerate quickly
    if speed <= 75 then
      change = 3.5
    elseif speed <= 175 then
      change = 5.0
    -- Then start slowing down acceleration
    elseif speed <= 225 then
      change = 1.5
    else
      change = 0.5
    end
    return math.max(15, speed, math.min(250, speed + change))
  end,
  decelerateGroundSpeed = function(self, speed, active)
    local change
    if active then
      if speed <= 100 then
        change = 20
      else
        change = 10
      end
    else
      if speed <= 25 then
        change = 2
      elseif speed <= 100 then
        change = 8
      else
        change = 5
      end
    end
    return math.max(0, speed - change)
  end,
  accelerateAirSpeed = function(self, speed)
    local change
    if speed <= 20 then
      change = 14
    elseif speed <= 125 then
      change = 3
    else
      change = 1
    end
    return math.max(0, math.min(250, speed + change), speed)
  end,
  decelerateAirSpeed = function(self, speed, active)
    if active then
      local change
      if speed <= 50 then
        change = 14
      elseif speed <= 125 then
        change = 10
      elseif speed <= 225 then
        change = 5
      else
        change = 10
      end
      return math.max(-1, speed - change)
    else
      return math.max(0, speed - 0.5)
    end
  end,
  accelerateJumpSpeed = function(self, speed)
    return math.max(speed, math.min(speed + 10, 150))
  end,
  decelerateJumpSpeed = function(self, speed)
    return math.max(0, speed - 20)
  end,
  decelerateLandingSpeed = function(self, speed)
    return math.max(math.min(speed, 10), speed - 15)
  end,
  applyNeutralDoubleJump = function(self, speed)
    return 0.8 * speed
  end,
  applyForwardDoubleJump = function(self, speed)
    local change = math.min(math.max(0, 25 * (1 - speed / 150)), 25)
    return math.min(math.max(250, speed), speed + change)
  end,
  applyBackwardDoubleJump = function(self, speed)
    local change = math.min(math.max(10, 10 + 35 * (speed / 150)), 45)
    return math.max(0, speed - change)
  end
})

return Player
