local Shader = require("lib/shader")

local Palette = {}

Palette.__index = Palette

function Palette.new(...)
  local self = setmetatable({}, Palette)
  if self.__ctor then
    self:__ctor(...)
  end
  return self
end

function create_palette(colors)
  local unpack = unpack or table.unpack -- compatibility w/ 5.2 and later.

  local count = #colors
  image = love.image.newImageData(256, 3) -- Up to 256 colors.

  for index, color in ipairs(colors) do
    local x = index - 1
    local r, g, b = unpack(color)
    local s = x / 255.0
--    print(x, r, g, b, s)
    image:setPixel(x, 0, r, g, b, 0.0) -- Components
    image:setPixel(x, 1, 0, 0, 0, 1.0) -- Transparency
    image:setPixel(x, 2, s, 0, 0, 0.0) -- Shifting
  end
--  image:encode("png", "palette.png")
  return love.graphics.newImage(image), image
end

function Palette:__ctor(colors)
  self.colors = colors
  self.count = #colors
  self.shader = Shader.new("assets/shaders/palettizer.glsl")
  self.texture, self.image = create_palette(colors)

  self.shader:send("u_palette", self.texture)
end

function Palette:set_shift(index, amount)
  local s = (amount % self.count) / 255.0
  self.image:setPixel(index, 2, s, 0, 0, 0.0)
  self.texture:replacePixels(self.image)
end

function Palette:render_with(callback)
  self.shader:activate()
    callback()
  self.shader:deactivate()
end

local function find_nearest_color_index(r, g, b, colors)
  local unpack = unpack or table.unpack -- compatibility w/ 5.2 and later.

  local i = -1
  local delta = math.huge
  for index, color in ipairs(colors) do
    local ri, gi, bi = unpack(color)
    local dr = r - ri
    local dg = g - gi
    local db = b - bi
    local d = dr * dr + dg * dg + db * db
    if delta > d then
      delta = d
      i = index - i
    end
  end
  return i
end

function Palette:load_image(filename)
  local data = love.image.newImageData(filename)
  local pixel_function = function(x, y, r, g, b, a)
      local index = find_nearest_color_index(r, g, b, self.colors)
      local u = index / 255.0
      return u, 0, 0, 0
    end
  data:mapPixel(pixel_function)
  return love.graphics.newImage(data)
end

function Palette:match(r, g, b)
  return find_nearest_color_index(r, g, b, self.colors)
end

function Palette.index_to_rgba(index)
  return index / 255.0, 0.0, 0.0, 1.0
end

return Palette
