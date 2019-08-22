local constants = require('constants')
local defineClass = require('utils/defineClass')
local controllers = require('input/controllers')
local Player = require('entity/Player')
local Platform = require('entity/Platform')

-- Update loop:
-- 1. Don't do anything to static platforms
-- 2. Update moving platforms
-- 3. Update enemies, checking for collisions
-- 4. Update player position in steps, checking for collision after each step
-- 5. Check for hits
-- 6. Update camera
-- 7. Add new entities to the game

local Game = defineClass({
  entities = nil,
  player = nil,
  players = nil,
  platforms = nil,
  init = function(self)
    self.entities = {}
    self.players = {}
    self.platforms = {}
    -- Create a new controller for the playerController
    local playerController = controllers:newController()
    controllers.keyboard:pipe(playerController, constants.KEYBOARD_CONTROLS)
    -- Spawn initial entities
    self.player = self:spawnEntity(Player, {
      controller = playerController,
      x = 0,
      y = 0
    })
    self:spawnEntity(Platform, {
      x = -999,
      y = 0,
      width = 9999,
      height = 200
    })
    self:spawnEntity(Platform, {
      x = -100,
      y = -8,
      width = 8,
      height = 8
    })
    self:spawnEntity(Platform, {
      x = -200,
      y = -16,
      width = 16,
      height = 16
    })
    self:spawnEntity(Platform, {
      x = -300,
      y = -32,
      width = 32,
      height = 32
    })
    self:spawnEntity(Platform, {
      x = -450,
      y = -56,
      width = 56,
      height = 56
    })
    self:spawnEntity(Platform, {
      x = -600,
      y = -64,
      width = 64,
      height = 64
    })
    self:spawnEntity(Platform, {
      x = 500,
      y = 100,
      width = 25,
      height = 25
    })
    self:spawnEntity(Platform, {
      x = 750,
      y = 100,
      width = 25,
      height = 25
    })
    self:spawnEntity(Platform, {
      x = 1000,
      y = 100,
      width = 25,
      height = 25
    })
    self:spawnEntity(Platform, {
      x = 200,
      y = -100,
      width = 8,
      height = 8
    })
    self:spawnEntity(Platform, {
      x = 400,
      y = -100,
      width = 8,
      height = 8
    })
    self:spawnEntity(Platform, {
      x = 600,
      y = -100,
      width = 8,
      height = 8
    })
    self:spawnEntity(Platform, {
      x = 800,
      y = -100,
      width = 8,
      height = 8
    })
  end,
  update = function(self, dt)
    -- Update entities
    for _, entity in ipairs(self.entities) do
      entity:baseUpdate(dt)
    end
    for _, entity in ipairs(self.entities) do
      entity:update(dt)
    end
  end,
  draw = function(self)
    -- Clear the screen
    love.graphics.clear(251 / 255, 235 / 255, 123 / 255)
    love.graphics.translate(150 - self.player.x, 185)
    -- Draw entities
    for _, entity in ipairs(self.entities) do
      entity:draw()
    end
  end,
  spawnEntity = function(self, class, ...)
    -- Create the entity
    local entity = class:newFromObject({ game = self }, ...)
    -- Add to groups
    if entity.groups then
      for _, group in ipairs(entity.groups) do
        table.insert(self.entities, entity)
        if group == 'players' then
          table.insert(self.players, entity)
        elseif group == 'platforms' then
          table.insert(self.platforms, entity)
        end
      end
    end
    -- Return the entitiy
    return entity
  end
})

return Game
