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

]] --

function normalize(colors)
  local unpack = unpack or table.unpack -- compatibility w/ 5.2 and later.
  local palette = {}
  for _, rgb in ipairs(colors) do
    local r, g, b = unpack(rgb)
    palette[#palette + 1] = { r / 255.0, g / 255.0, b / 255.0 }
  end
  return palette
end

return {
  normalize = normalize
}
