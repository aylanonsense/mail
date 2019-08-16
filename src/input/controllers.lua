local ControllerSystem = require('input/ControllerSystem')

-- Create a singleton
local controllers = ControllerSystem:new()

-- Bind love methods
function love.keypressed(...)
  controllers:keypressed(...)
end
function love.keyreleased(...)
  controllers:keyreleased(...)
end

-- Return the singleton
return controllers
