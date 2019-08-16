local controllers = require('input/controllers')
local Player = require('entity/Player')
local Platform = require('entity/Platform')

-- Constants
local KEYBOARD_CONTROLS = {
  w = 'up',
  a = 'left',
  s = 'down',
  d = 'right',
  up = 'up',
  left = 'left',
  down = 'down',
  right = 'right'
}

-- Game variables
local entities

function love.load()
  -- Initialize controllers
  local playerController = controllers:newController()
  controllers.keyboard:pipe(playerController, KEYBOARD_CONTROLS)
  -- Spawn entities
  entities = {}
  table.insert(entities, Player:new({
    controller = playerController,
    x = 50,
    y = 50,
    width = 10,
    height = 20
  }))
  table.insert(entities, Platform:new({
    x = 40,
    y = 100,
    width = 200,
    height = 25
  }))
end

function love.update(dt)
  -- Update controllers
  controllers:update(dt)
  -- Update entities
  for _, entity in ipairs(entities) do
    entity:update(dt)
  end
end

function love.draw()
  -- Clear the screen
  love.graphics.clear(0.1, 0.1, 0.1)
  -- Draw entities
  for _, entity in ipairs(entities) do
    entity:draw()
  end
end
