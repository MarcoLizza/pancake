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

local Copperlist = {}

Copperlist.__index = Copperlist

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

function Copperlist.new(...)
  local self = setmetatable({}, Copperlist)
  if self.__ctor then
    self:__ctor(...)
  end
  return self
end

local LEVEL = 400

function create_copperlist(width, height)
  local image = love.image.newImageData(1, height)

  local half_width = width * 0.25
  for y = 0, height - 1 do
    local ox, oy = 0, 0
    local v = math.sin(y / height * math.pi * 7) * 8
    ox = _to_texture_space(v, width)
    if y > LEVEL then
      oy = _to_texture_space((LEVEL - y) * 2, height)
    end
--    print(ox, oy)
    local r, g, b, a = 0, 0, 0, 0
    if ox >= 0.0 then
      r = ox
    else
      g = -ox
    end
    if oy >= 0.0 then
      b = oy
    else
      a = -oy
    end
    image:setPixel(0, y, r, g, b, a)
  end

  return love.graphics.newImage(image), image
end

function Copperlist:__ctor(width, height)
  self.width = width
  self.height = height

  self.shader = Shader.new("assets/shaders/copperlist.glsl")
  self.texture, self.image = create_copperlist(width, height)

  self.shader:send("u_copperlist", self.texture)
end

function Copperlist:render_with(callback)
  self.shader:activate()
    callback()
  self.shader:deactivate()
end

return Copperlist
