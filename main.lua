function love.load()
    loveconsole = require 'loveconsole'
    loveconsole:init()
end

function love.draw()
    loveconsole:render()
end

function love.update(elapsed)
    loveconsole:update(elapsed)
end

function love.textinput(t)
    loveconsole:textinput(t)
end

function love.keypressed(k)
    loveconsole:keypressed(k)
end

function love.mousepressed(x, y, button)
    loveconsole:mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
    loveconsole:mousereleased(x, y, button)
end