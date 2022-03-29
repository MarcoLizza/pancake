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

local function _to_texture_color(r8, g8, b8)
  return r8 / 255.0, g8 / 255.0, b8 / 255.0
end

local function _from_texture_color(r, g, b)
  return math.floor(r * 255.0 + 0.5), math.floor(g * 255.0 + 0.5), math.floor(b * 255.0 + 0.5)
end

function Palette.new(...)
  local self = setmetatable({}, Palette)
  if self.__ctor then
    self:__ctor(...)
  end
  return self
end

function create_palette(colors, scanlines)
  local unpack = unpack or table.unpack -- compatibility w/ 5.2 and later.

  local count = #colors
  image = love.image.newImageData(256, scanlines * 3) -- Up to 256 colors.

  for index, color in ipairs(colors) do
    local x = index - 1
    local r, g, b = _to_texture_color(unpack(color))
    local s = _to_texture_space(x, 256)

    for scanline = 0, scanlines - 1 do
      local y = scanline * 3
      image:setPixel(x, y + 0, r, g, b, 0.0) -- Components
      image:setPixel(x, y + 1, 0, 0, 0, 1.0) -- Transparency
      image:setPixel(x, y + 2, s, 0, 0, 0.0) -- Shifting
    end
  end
--  image:encode("png", "palette.png")
  return love.graphics.newImage(image), image
end

function Palette:__ctor(colors, scanlines)
  self.colors = colors
  self.scanlines = scanlines

  self.count = #colors
  self.shader = Shader.new("assets/shaders/palettizer.glsl")
  self.texture, self.image = create_palette(colors, scanlines)

  self.shader:send("u_palette", self.texture)
end

--[[

The palette is always controlled by a copperlist, which is compiled and encoded
into the `u_palette` uniform.

The copperlist UDT, thought its API, is populated with WAIT/COLOR/SHIFT/OFFSET
commands. Then, the commands are sorted/optimized and the texture is updated.

The default/base color doesn't properly exists, but setting it just means that
the whole copperlist/texture column.

]]

function Palette:set_color(index, r8, g8, b8)
  self.colors[index + 1] = { r8, g8,  b8 }

  local r, g, b = _to_texture_color(r8, g8, b8)
  for scanline = 0, self.scanlines - 1 do
    local y = scanline * 3
    self.image:setPixel(index, y + 0, r, g, b, 0.0)
  end
  self.texture:replacePixels(self.image) -- TODO: refresh only the changed part.
end

function Palette:set_color_at(index, from, r8, g8, b8)
  local r, g, b = _to_texture_color(r8, g8, b8)
  for scanline = from, self.scanlines - 1 do
    local y = scanline * 3
    self.image:setPixel(index, y + 0, r, g, b, 0.0)
  end
  self.texture:replacePixels(self.image)
end

function Palette:set_transparent(index, is_transparent)
  local a = is_transparent and 0.0 or 1.0
  for scanline = 0, self.scanlines - 1 do
    local y = scanline * 3
    self.image:setPixel(index, y + 1, 0.0, 0.0, 0.0, a)
  end
  self.texture:replacePixels(self.image)
end

function Palette:set_shift(index, to)
  local s = _to_texture_space(to % self.count, 256)
  for scanline = 0, self.scanlines - 1 do
    local y = scanline * 3
    self.image:setPixel(index, y + 2, s, 0.0, 0.0, 0.0)
  end
  self.texture:replacePixels(self.image)
end

function Palette:render_with(callback)
  self.shader:activate()
    callback()
  self.shader:deactivate()
end

function Palette:load_image(filename)
  local data = love.image.newImageData(filename)
  local pixel_function = function(x, y, r, g, b, a)
      local index = self:match(_from_texture_color(r, g, b))
      local u = _to_texture_space(index, 256)
      --print(r, g, b, index, u)
      return u, 0, 0, 0
    end
  data:mapPixel(pixel_function)
  return love.graphics.newImage(data)
end

function Palette:match(r8, g8, b8)
  local unpack = unpack or table.unpack -- compatibility w/ 5.2 and later.

  local i = -1
  local max_delta = math.huge
  for index, color in ipairs(self.colors) do
    local r, g, b = unpack(color)
    local delta_r = r8 - r
    local delta_g = g8 - g
    local delta_b = b8 - b
    local delta = delta_r * delta_r + delta_g * delta_g + delta_b * delta_b
    if max_delta > delta then
      max_delta = delta
      i = index - 1
    end
  end
  return i
end

function Palette.index_to_rgba(index)
  return _to_texture_space(index, 256), 0.0, 0.0, 1.0
end

return Palette
