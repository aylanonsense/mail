-- Helper method to define a new class
local function defineClass(superclass, class)
  if not class then
    class, superclass = superclass, nil
  end
  -- Set a superclass if one was given
  if superclass then
    class.superclass = superclass
    setmetatable(class, { __index = superclass })
  end
  -- Add a :new method onto the class
  class.new = function(self, ...)
    local instance = {}
    setmetatable(instance, { __index = self })
    if instance.init then
      instance:init(...)
    end
    return instance
  end
  -- Add a :newFromObject method onto the class
  class.newFromObject = function(self, instance, ...)
    setmetatable(instance, { __index = self })
    if instance.init then
      instance:init(...)
    end
    return instance
  end
  -- Return the class
  return class
end

return defineClass
