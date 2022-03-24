--[[

Copyright (c) 2018 by Marco Lizza (marco.lizza@gmail.com)

This software is provided 'as-is', without any express or implied
warranty. In no event will the authors be held liable for any damages
arising from the use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:

1. The origin of this software must not be misrepresented; you must not
   claim that you wrote the original software. If you use this software
   in a product, an acknowledgement in the product documentation would be
   appreciated but is not required.
2. Altered source versions must be plainly marked as such, and must not be
   misrepresented as being the original software.
3. This notice may not be removed or altered from any source distribution.

]]--

local function forward(t, looped)
  local n = #t
  local i = 0
  return function()
      i = i + 1
      if i > n then
        if looped and looped(t) then
          return nil
        end
        i = 0
      end
      return t[i]
    end
end

local function reverse(t, looped)
  local n = #t
  local i = n + 1
  return function()
      i = i - 1
      if i < 1 then
        if looped and looped(t) then
          return nil
        end
        i = n
      end
      return t[i]
    end
end

local function circular(t, looped)
  local n = #t
  local i = 0
  return function()
      i = i + 1
      if i > n then
        if looped and looped(t) then
          return nil
        end
        i = 1
      end
      return t[i]
    end
end

local function bounce(t, bounced)
  local n = #t
  local d = 1
  local i = 0
  return function()
      i = i + d
      if d > 0 and i >= n then
        if bounced and bounced(t) then
          return nil
        end
        i = n
        d = -1
      elseif d < 0 and i <= 1 then
        if bounced and bounced(t) then
          return nil
        end
        i = 1
        d = 1
      end
      return t[i]
    end
end

-- Safe iterators that exclude the `nil` entries and additional check.
local function ipairs(table, check)
  return function(a, i)
      while true do
        i = i + 1
        local v = a[i]
        if not v then
          return nil, nil
        end
        if not check or check(v) then
          return i, v
        end
      end
    end, table, 0
end

local function pairs(table, check)
  return function(t, k)
      while true do
        local v = next(t, k)
        if not v then
          return nil, nil
        end
        if not check or check(v) then
          return k, v
        end
      end
    end, table, nil
end

return {
  forward = forward,
  reverse = reverse,
  circular = circular,
  bounce = bounce,
  ipairs = ipairs,
  pairs = pairs
}