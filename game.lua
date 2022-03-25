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

function Game:__ctor()
  self.palette = Palette.new(COLORS)
  self.bank = self.palette:load_image("assets/images/sheet.png")
  self.bunnies = {}
  self.speed = 1.0
  self.running = false
  self.static = false

  local index = self.palette:match(0, 228, 54)
  self.palette:set_transparent(index, true)

  local Bunny = self.static and StaticBunny or MovingBunny
  for _ = 1, INITIAL_BUNNIES do
    table.insert(self.bunnies, Bunny.new(self.bank, WIDTH, HEIGHT))
  end
end

function Game:update(dt)
  if not self.running then
    return
  end

  for _, bunny in ipairs(self.bunnies) do
    bunny:update(dt * self.speed)
  end
end

function Game:draw()
  self.palette:render_with(function()
    for _, bunny in ipairs(self.bunnies) do
      bunny:draw()
    end
  end)
end

function Game:on_key_pressed(key, scancode, isrepeat)
  if key == 'f1' then
    local Bunny = self.static and StaticBunny or MovingBunny
    for _ = 1, LITTER_SIZE do
      table.insert(self.bunnies, Bunny.new(self.bank, WIDTH, HEIGHT))
    end
  elseif key == 'f2' then
    self.bunnies = {}
  elseif key == 'left' then
    self.speed = self.speed * 0.5
  elseif key == 'right' then
    self.speed = self.speed * 2.0
  elseif key == 'down' then
    self.speed = 1.0
  elseif key == 'space' then
    self.static = not self.static
  elseif key == 'p' then
    self.running = not self.running
  end
end

return Game
