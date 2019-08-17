local defineClass = require('utils/defineClass')
local Entity = require('entity/Entity')

local Platform = defineClass(Entity, {
  groups = { 'platforms' }
})

return Platform
