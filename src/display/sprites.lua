local Sprite = require('display/Sprite')
local RectGrid = require('display/RectGrid')

-- Load images
love.graphics.setDefaultFilter('nearest', 'nearest')
local mailgirlSpriteSheet = love.graphics.newImage('../img/mailgirl.png')

-- Define rectangles
local mailgirlGrid = RectGrid:new(0, 0, 44, 52, 6, 2, { bleed = 1 })
local mailgirlRects = {
  standing = mailgirlGrid:getRect(1),
  running = mailgirlGrid:getRects(2, 5)
}

-- Generates sprites from an image and set of rectangles
local function generateSprites(img, rects)
  local sprites = {}
  for k, v in pairs(rects) do
    local sprite
    if type(v[1]) == 'number' then
      sprites[k] = Sprite:new(img, v)
    else
      sprites[k] = {}
      for _, rect in ipairs(v) do
        table.insert(sprites[k], Sprite:new(img, rect))
      end
    end
  end
  return sprites
end

-- Return generated sprites
return {
  mailgirl = generateSprites(mailgirlSpriteSheet, mailgirlRects)
}
