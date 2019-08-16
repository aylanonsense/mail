local defineClass = require('utils/defineClass')
local Controller = require('input/Controller')

local KeyboardController = defineClass(Controller, {
  update = function(self, dt)
    self.superclass.update(self, dt)
    -- Also check for any buttons that were released
    for button, buttonState in pairs(self._buttons) do
      if buttonState.isDown and not love.keyboard.isDown(button) then
        buttonState.isDown = false
        buttonState.release = 0
        self:_pipeRelease(button)
      end
    end
  end,
  keypressed = function(self, key, scancode, isRepeat)
    if not isRepeat then
      self:recordPress(key)
    end
  end,
  keyreleased = function(self, key, scancode)
    self:recordRelease(key)
  end
})

return KeyboardController
