local controllers = require('input/controllers')
local Game = require('game/Game')

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
