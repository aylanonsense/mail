-- Determine whether two rectangles are overlapping
local function rectsOverlapping(x1, y1, w1, h1, x2, y2, w2, h2)
  return x1 + w1 > x2 and x2 + w2 > x1 and y1 + h1 > y2 and y2 + h2 > y1
end

-- Finds a point on a line, and returns whether it's on the line segment
local function getPointOnLine(px, py, x1, y1, x2, y2)
  if not px and not py then
    px, py = x1, y1
  elseif not px or not py then
    local dx, dy = x2 - x1, y2 - y1
    -- Points
    if dx == 0 and dy == 0 then
      if not px then
        px = x1
      end
      if not py then
        py = y1
      end
    -- Horizontal-ish lines
    elseif math.abs(dx) > math.abs(dy) then
      local slope = dy / dx
      if not py then
        py = y1 + (px - x1) * slope
      elseif not px then
        if slope == 0 then
          px = x1
        else
          px = x1 + (py - y1) / slope
        end
      end
    -- Vertical-ish lines
    else
      local slope = dx / dy
      if not px then
        px = x1 + (py - y1) * slope
      elseif not py then
        if slope == 0 then
          py = y1
        else
          py = y1 + (px - x1) / slope
        end
      end
    end
  end
  local isOnSegment = x1 <= px and px <= x2 and y1 <= py and py <= y2
  return px, py, isOnSegment
end

-- Determine if a line segment is intersecting a rectangle
local function getLineRectIntersection(x1, y1, x2, y2, rx, ry, rw, rh)
  -- If the starting point is within the rectangle, return it
  if rx <= x1 and x1 <= rx + rw and ry <= y1 and y1 <= ry + rh then
    return x1, y1, true
  end
  local closestX, closestY, closestSquareDist
  -- Check for overlap with the rectangle's left side
  do
    local px, py, isOnSegment = getPointOnLine(rx, nil, x1, y1, x2, y2)
    if isOnSegment then
      -- print('yes1', px, py, isOnSegment)
    end
    if isOnSegment and ry <= py and py <= ry + rh then
      local squareDist = (px - x1) * (px - x1) + (py - y1) * (py - y1)
      if not closestSquareDist or squareDist < closestSquareDist then
        closestX, closestY, closestSquareDist = px, py, squareDist
      end
    end
  end
  -- Check for overlap with the rectangle's right side
  do
    local px, py, isOnSegment = getPointOnLine(rx + rw, nil, x1, y1, x2, y2)
    if isOnSegment then
      -- print('yes2', px, py, isOnSegment)
    end
    if isOnSegment and ry <= py and py <= ry + rh then
      local squareDist = (px - x1) * (px - x1) + (py - y1) * (py - y1)
      if not closestSquareDist or squareDist < closestSquareDist then
        closestX, closestY, closestSquareDist = px, py, squareDist
      end
    end
  end
  -- Check for overlap with the rectangle's top side
  do
    local px, py, isOnSegment = getPointOnLine(nil, ry, x1, y1, x2, y2)
    if isOnSegment then
      -- print('yes3', px, py, isOnSegment, rx <= px and px <= rx + rw)
    end
    if isOnSegment and rx <= px and px <= rx + rw then
      local squareDist = (px - x1) * (px - x1) + (py - y1) * (py - y1)
      if not closestSquareDist or squareDist < closestSquareDist then
        -- print('uh huh')
        closestX, closestY, closestSquareDist = px, py, squareDist
      end
    end
  end
  -- Check for overlap with the rectangle's bottom side
  do
    local px, py, isOnSegment = getPointOnLine(nil, ry + rh, x1, y1, x2, y2)
    if isOnSegment then
      -- print('yes4', px, py, isOnSegment, rx <= px and px <= rx + rw)
    end
    if isOnSegment and rx <= px and px <= rx + rw then
      local squareDist = (px - x1) * (px - x1) + (py - y1) * (py - y1)
      if not closestSquareDist or squareDist < closestSquareDist then
        -- print('uh huh')
        closestX, closestY, closestSquareDist = px, py, squareDist
      end
    end
  end
  -- Return the closest point
  local intersectionExists = closestX and closestY
  -- print(closestX, closestY, intersectionExists)
  return closestX, closestY, intersectionExists
end

return {
  rectsOverlapping = rectsOverlapping,
  getPointOnLine = getPointOnLine,
  getLineRectIntersection = getLineRectIntersection
}
