--[[
MIT License

Copyright (c) 2022 Marco Lizza

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]--

local Shader = require("lib/shader")

local Palette = {}

Palette.__index = Palette

-- This has been asked a few times, but I don't have the links at hand, so a quick
-- and rough explanation. Let's say the texture is 8 pixels wide:
-- 
--  | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
--  ^   ^   ^   ^   ^   ^   ^   ^   ^
-- 0.0  |   |   |   |   |   |   |  1.0
--  |   |   |   |   |   |   |   |   |
-- 0/8 1/8 2/8 3/8 4/8 5/8 6/8 7/8 8/8

-- The digits denote the texture's pixels, the bars the edges of the texture and
-- in case of nearest filtering the border between pixels. You however want to hit
-- the pixels' centers. So you're interested in the texture coordinates
-- 
-- (0/8 + 1/8)/2 = 1 / (2 * 8)
-- 
-- (1/8 + 2/8)/2 = 3 / (2 * 8)
-- 
-- ...
-- 
-- (7/8 + 8/8)/2 = 15 / (2 * 8)
-- 
-- Or more generally for pixel i in a N wide texture the proper texture coordinate is
-- 
-- (2i + 1)/(2N)
-- 
-- However if you want to perfectly align your texture with the screen pixels,
-- remember that what you specify as coordinates are not a quad's pixels, but
-- edges, which, depending on projection may align with screen pixel edges, not
-- centers, thus may require other texture coordinates.
local function _to_texture_space(x, width)
  local u = (2 * x + 1) / (2 * width)
  --print(x, width, u)
  return u
end

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
