local controllers = require('input/controllers')
local Game = require('game/Game')

-- Update loop
-- 1. Don't do anything to static platforms
-- 2. Update moving platforms
-- 3. Update enemies, checking for collisions
-- 4. Update player position in steps, checking for collision after each step
-- 5. Check for hits
-- 6. Update camera
-- 7. Add new entities to the game

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
local game

function love.load()
  -- Initialize the game
  game = Game:new()
end

function love.update(dt)
  -- Update controllers
  controllers:update(dt)
  -- Update the game
  game:update(dt)
end

function love.draw()
  -- Clear the screen
  love.graphics.clear(0, 0, 0)
  -- Draw the game
  game:draw()
end
