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

local Bunny = {}

Bunny.__index = Bunny

function Bunny.new(...)
  local self = setmetatable({}, Bunny)
  if self.__ctor then
    self:__ctor(...)
  end
  return self
end

function Bunny:__ctor(bounds, batch, quad)
  self.bounds = bounds
  self.batch = batch
  self.quad = quad

  self.gravity = 30

  self.x = (bounds.right - bounds.left) / 2 -- Spawn in the top-center part of the screen.
  self.y = (bounds.bottom - bounds.top) / 8
  self.vx = math.random() * 200 - 100
  self.vy = math.random() * 200 - 100
end

function Bunny:update(delta_time)
  self.x = self.x + self.vx * delta_time
  self.y = self.y + self.vy * delta_time

  self.vy = self.vy + self.gravity * delta_time

  if self.x > self.bounds.right then
    self.vx = -self.vx
    self.x = self.bounds.right
  elseif self.x < self.bounds.left then
    self.vx = -self.vx
    self.x = self.bounds.left
  end

  if self.y > self.bounds.bottom then
    self.vy = self.vy * -0.85
    self.y = self.bounds.bottom
    if math.random() > 0.5 then
      self.vy = self.vy - math.random() * 200
    end
  elseif self.y < self.bounds.top then
    self.vy = 0
    self.y = self.bounds.top
  end
end

function Bunny:draw()
  self.batch:add(self.quad, self.x, self.y)
end

return Bunny