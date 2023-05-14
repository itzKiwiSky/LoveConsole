function love.load()
    -- require the console library --
    console = require 'console'

    -- create a new console at x: 90, y: 90
    console:new(90, 90)
    
    console:registerCommand("myCoolCommandWithArgument", "This is the help message, it will appear with help command", 0, function(argument)
        console:trace("This is my cool command", 0)
        console:trace("And this is my argument" .. argument, 1)
    end)

    console:setFont("PerfectDOS.ttf", 15)
end

function love.draw()
    console:render()
end

function love.update(elapsed)
    console:update()
end

function love.textinput(text)
    console:textinput(text)
end

function love.keypressed(k)
    console:keypressed(k)
end

function love.mousepressed(x, y, button)
    console:mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
    console:mousereleased(x, y, button)
end