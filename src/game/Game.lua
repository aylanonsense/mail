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
-- 7. Add new entities to the game\

local Game = defineClass({
  entities = nil,
  init = function(self)
    self.entities = {}
    -- Create a new controller for the playerController
    local playerController = controllers:newController()
    controllers.keyboard:pipe(playerController, constants.KEYBOARD_CONTROLS)
    -- Spawn initial entities
    self:spawnEntity(Player, {
      controller = playerController,
      x = 50,
      y = 50
    })
    self:spawnEntity(Platform, {
      x = 25,
      y = 175,
      width = 200,
      height = 25
    })
    self:spawnEntity(Platform, {
      x = 100,
      y = 100,
      width = 25,
      height = 75
    })
  end,
  update = function(self, dt)
    -- Update entities
    for _, entity in ipairs(self.entities) do
      entity:update(dt)
    end
  end,
  draw = function(self)
    -- Clear the screen
    love.graphics.clear(0.1, 0.1, 0.1)
    -- Draw entities
    for _, entity in ipairs(self.entities) do
      entity:draw()
    end
  end,
  spawnEntity = function(self, class, ...)
    local entity = class:newFromObject({ game = self }, ...)
    table.insert(self.entities, entity)
    return entity
  end
})

return Game
