-- Determine whether two rectangles are overlapping
local function rectsOverlapping(x1, y1, w1, h1, x2, y2, w2, h2)
  return x1 + w1 > x2 and x2 + w2 > x1 and y1 + h1 > y2 and y2 + h2 > y1
end

return {
  rectsOverlapping = rectsOverlapping
}
