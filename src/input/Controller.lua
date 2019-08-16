local defineClass = require('utils/defineClass')

local Controller = defineClass({
  _buttons = nil,
  _connections = nil,
  init = function(self)
    self._buttons = {}
    self._connections = {}
  end,
  update = function(self, dt)
    -- Increment all button states
    for _, buttonState in pairs(self._buttons) do
      if buttonState.press then
        buttonState.press = buttonState.press + 1
      end
      if buttonState.release then
        buttonState.release = buttonState.release + 1
      end
    end
  end,
  recordButton = function(self, button, isDown)
    if not self._buttons[button] then
      self._buttons[button] = {}
    end
    -- Update the isDown state of the button
    local wasDown = self._buttons[button].isDown
    self._buttons[button].isDown = isDown
    -- This may effectively cause the button to become "pressed" or "released"
    if not wasDown and isDown then
      self._buttons[button].press = 0
      self:_pipePress(button)
    elseif wasDown and not isDown then
      self._buttons[button].release = 0
      self:_pipeRelease(button)
    end
  end,
  recordPress = function(self, button)
    if not self._buttons[button] then
      self._buttons[button] = {}
    end
    -- Record the button press
    self._buttons[button].press = 0
    self._buttons[button].isDown = true
    -- Tell connected controllers
    self:_pipePress(button)
  end,
  recordRelease = function(self, button)
    if not self._buttons[button] then
      self._buttons[button] = {}
    end
    -- Record the button release
    self._buttons[button].release = 0
    self._buttons[button].isDown = false
    -- Tell connected controllers
    self:_pipeRelease(button)
  end,
  -- Return true if the button is held down
  isDown = function(self, button)
    if self._buttons[button] then
      return self._buttons[button].isDown
    else
      return false
    end
  end,
  -- Return true if the button was pressed recently
  justPressed = function(self, button, buffer, consume)
    local buttonState = self._buttons[button]
    if buttonState and buttonState.press and buttonState.press <= (buffer or 0) then
      -- Consume the button press in the process
      if consume then
        buttonState.press = nil
      end
      return true
    else
      return false
    end
  end,
  -- Return true if the button was released recently
  justReleased = function(self, button, buffer, consume)
    local buttonState = self._buttons[button]
    if buttonState and buttonState.release and buttonState.release <= (buffer or 0) then
      -- Consume the button release in the process
      if consume then
        buttonState.release = nil
      end
      return true
    else
      return false
    end
  end,
  consumePress = function(self, button)
    if self._buttons[button] then
      self._buttons[button].press = nil
    end
  end,
  consumeRelease = function(self, button)
    if self._buttons[button] then
      self._buttons[button].release = nil
    end
  end,
  pipe = function(self, controller, mapping)
    table.insert(self._connections, { controller = controller, mapping = mapping })
  end,
  unpipe = function(self, controller)
    for i = #self._connections, 1, -1 do
      if self._connections[i].controller == controller then
        table.remove(self._connections, i)
      end
    end
  end,
  _pipePress = function(self, button)
    for _, connection in ipairs(self._connections) do
      local controller = connection.controller
      local mapping = connection.mapping
      local mappedButton
      if mapping then
        mappedButton = mapping[button]
      else
        mappedButton = button
      end
      if mappedButton then
        controller:recordPress(mappedButton)
      end
    end
  end,
  _pipeRelease = function(self, button)
    for _, connection in ipairs(self._connections) do
      local controller = connection.controller
      local mapping = connection.mapping
      local mappedButton
      if mapping then
        mappedButton = mapping[button]
      else
        mappedButton = button
      end
      if mappedButton then
        controller:recordRelease(mappedButton)
      end
    end
  end
})

return Controller
