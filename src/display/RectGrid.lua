local defineClass = require('utils/defineClass')

local RectGrid = defineClass({
  init = function(self, x, y, width, height, cols, rows, options)
    self._x = x
    self._y = y
    self._width = width
    self._height = height
    self._cols = cols
    self._rows = rows
    self._bleed = options and options.bleed or 0
  end,
  getRect = function(self, n)
    local col = ((n - 1) % self._cols) + 1
    local row = (math.floor((n - 1) / self._cols) % self._rows) + 1
    local x = self._x + self._width * (col - 1) + self._bleed
    local y = self._y + self._height * (row - 1) + self._bleed
    local width = self._width - 2 * self._bleed
    local height = self._height - 2 * self._bleed
    return { x, y, width, height }
  end,
  getRects = function(self, n, m)
    local rects = {}
    for i = n, m do
      table.insert(rects, self:getRect(i))
    end
    return rects
  end
})

return RectGrid
