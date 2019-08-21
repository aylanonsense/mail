local defineClass = require('utils/defineClass')

local Sprite = defineClass({
  init = function(self, img, quad)
    self._img = img
    self._quad = quad
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
      x,
      y,
      0,
      flipHorizontal and -1 or 1,
      flipVertical and -1 or 1)
  end
})

return Sprite
