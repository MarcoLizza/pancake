local Game = require('game')

local game = nil

function love.load(args)
  love.graphics.setDefaultFilter('nearest', 'nearest', 1)

  love.mouse.setVisible(true)
  love.mouse.setGrabbed(false)

  if love.joystick and love.filesystem.getInfo("assets/mappings/gamecontrollerdb.txt") then
    love.joystick.loadGamepadMappings("assets/mappings/gamecontrollerdb.txt")
  end

  math.randomseed(os.time())
  for _ = 1, 1000 do
    math.random()
  end

  game = Game.new()
end

function love.update(dt)
  game:update(dt)
end

function love.draw()
  love.graphics.push()
  game:draw()
  love.graphics.pop()

  love.graphics.setColor(1.0, 1.0, 1.0)
  love.graphics.print(love.timer.getFPS() .. ' FPS', 0, 0)
end

function love.keypressed(key, scancode, isrepeat)
  game:on_key_pressed(key, scancode, isrepeat)
end
