function love.load()
    loveconsole = require 'loveconsole'
    loveconsole:init()

    theme1 = {
        bg = {80, 79, 215},
        fg = {38, 37, 127}
    }
    theme2 = {
        bg = {247, 67, 67},
        fg = {127, 37, 37}
    }
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