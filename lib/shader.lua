local Shader = {}

Shader.__index = Shader

function Shader.new(...)
  local self = setmetatable({}, Shader)
  if self.__ctor then
    self:__ctor(...)
  end
  return self
end

local function compile(shader, defines, variables)
  local code = love.filesystem.getInfo(shader) and love.filesystem.read(shader) or shader

  if defines then
    local found = {}
    code = code:gsub('(#define%s+)([^%s]+)(%s+)([^%s]+)', -- Match existing macros, replace value and mark as found.
      function(define, identifier, spaces, value)
        local v = defines[identifier]
        if not v then
          return define .. identifier .. spaces .. value
        end
        found[identifier] = true
        return define .. identifier .. spaces .. v
      end)
    for identifier, value in pairs(defines) do -- Pre-prend unknow defines.
      if not found[identifier] then
        code = string.format('#define %s %s\n', identifier, value) .. code
      end
    end
  end

  if variables then
    for identifier, value in pairs(variables) do -- Replace custom variables.
      code = code:gsub(string.format('${%s}', identifier), value)
    end
  end

  return love.graphics.newShader(code)
end

function Shader:__ctor(code, defines, variables)
  self.shader = compile(code, defines, variables)
end

function Shader:activate()
  love.graphics.setShader(self.shader)
end

function Shader:deactivate()
  love.graphics.setShader()
end

function Shader:send(id, value)
  self.shader:send(id, value)
end

return Shader
