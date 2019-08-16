-- Makes a deep clone of a table
local function clone(obj, deep)
  if obj and type(obj) == 'table' then
    local clonedTable = {}
    for k, v in pairs(obj) do
      if deep then
        clonedTable[k] = clone(v)
      else
        clonedTable[k] = v
      end
    end
    return clonedTable
  else
    return obj
  end
end

-- Clears all the properties off of an object
local function strip(obj)
  for k, v in pairs(obj) do
    obj[k] = nil
  end
  return obj
end

-- Copies all properties from the source object to the target object
local function assign(targetObj, sourceObj, deep)
  for k, v in pairs(sourceObj) do
    if deep then
      targetObj[k] = clone(v)
    else
      targetObj[k] = v
    end
  end
  return targetObj
end

-- Returns true if the tables are equivalent, false otherwie
local function equals(obj1, obj2)
  local type1, type2 = type(obj1), type(obj2)
  if type1 == type2 then
    if type1 == 'table' then
      for k, v in pairs(obj1) do
        if not equals(v, obj2[k]) then
          return false
        end
      end
      for k, v in pairs(obj2) do
        if obj1[k] == nil then
          return false
        end
      end
      return true
    else
      return obj1 == obj2
    end
  else
    return false
  end
end

return {
  clone = clone,
  strip = strip,
  assign = assign,
  equals = equals
}
