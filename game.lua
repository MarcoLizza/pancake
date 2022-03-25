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

local Palette = require("lib/palette")

local MovingBunny = require("lib/moving_bunny")
local StaticBunny = require("lib/static_bunny")

local INITIAL_BUNNIES = 15000
local LITTER_SIZE = 250
local MAX_BUNNIES = 32768

local WIDTH, HEIGHT = 512, 512

local Game = {}

Game.__index = Game

--local COLORS = require('assets/palettes/arne16')
local COLORS = require('assets/palettes/sms')

function Game.new(...)
  local self = setmetatable({}, Game)
  if self.__ctor then
    self:__ctor(...)
  end
  return self
end

local function create_image(width, height, step, colors)
  local canvas = love.graphics.newCanvas(width, height)

  local count = #colors

  love.graphics.setCanvas(canvas)

  local index = 0
  for y = 0, height - step, step do
    for x = 0, width - step, step do
      love.graphics.setColor(Palette.index_to_rgba(index))
      love.graphics.rectangle("fill", x, y, step, step)
      index = (index + 1) % count
    end
  end

  love.graphics.setCanvas()

  return love.graphics.newImage(canvas:newImageData())
end

function Game:__ctor()
  self.palette = Palette.new(COLORS)
  self.objects = {
    { image = create_image(128, 128, 16, COLORS), x = 32, y = 32 },
    { image = self.palette:load_image("assets/images/logo.png"), x = 256, y = 32 }
  }
  self.index = self.palette:match(255, 0, 0)
  self.amount = 0
end

function Game:update(dt)
end

function Game:draw()
  self.palette:render_with(function()
    for _, object in ipairs(self.objects) do
      love.graphics.draw(object.image, object.x, object.y)
    end
  end)
end

function Game:on_key_pressed(key, scancode, isrepeat)
  if key == 'f1' then
    self.amount = self.amount + 1
    self.palette:set_shift(self.index, self.amount)
  end
end

return Game
