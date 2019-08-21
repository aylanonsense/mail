local defineClass = require('utils/defineClass')

local Sprite = defineClass({
  init = function(self, img, rect)
    self._img = img
    self._rect = rect
    local width, height = img:getDimensions()
    self._quad = love.graphics.newQuad(rect[1], rect[2], rect[3], rect[4], width, height)
  end,
  draw = function(self, x, y, flipHorizontal, flipVertical)
    -- Apply defaults
    x = x or 0
    y = y or 0
    flipHorizontal = flipHorizontal or false
    flipVertical = flipVertical or false
    scaleX = scaleX or 1
    scaleY = scaleY or 1
    -- Draw the sprite
    love.graphics.draw(self._img,
      self._quad,
      x + (flipHorizontal and self._rect[3] or 0),
      y + (flipVertical and self._rect[4] or 0),
      0,
      flipHorizontal and -1 or 1,
      flipVertical and -1 or 1)
  end
})

return Sprite
