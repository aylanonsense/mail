local Sprite = require('display/Sprite')
local RectGrid = require('display/RectGrid')

-- Load images
love.graphics.setDefaultFilter('nearest', 'nearest')
local mailgirlSpriteSheet = love.graphics.newImage('../img/mailgirl.png')

-- Define rectangles
local mailgirlGrid = RectGrid:new(0, 0, 43, 51, 6, 2, { bleed = 1 })
local mailgirlRects = {
  standing = mailgirlGrid:getRect(1),
  running = mailgirlGrid:getRects(2, 7)
}

-- Generates sprites from an image and set of rectangles
local function generateSprites(img, rects)
  local sprites = {}
  local width, height = img:getDimensions()
  for k, v in pairs(rects) do
    local sprite
    if type(v[1]) == 'number' then
      sprites[k] = Sprite:new(img, love.graphics.newQuad(v[1], v[2], v[3], v[4], width, height))
    else
      sprites[k] = {}
      for i = 1, #v do
        table.insert(sprites[k], Sprite:new(img, love.graphics.newQuad(v[i][1], v[i][2], v[i][3], v[i][4], width, height)))
      end
    end
  end
  return sprites
end

-- Return generated sprites
return {
  mailgirl = generateSprites(mailgirlSpriteSheet, mailgirlRects)
}
