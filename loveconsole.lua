console = {}

local lines = 0

function console:init()
    utf8 = require 'utf8'

    love.keyboard.setKeyRepeat(true)
    self.x = 90
    self.y = 90
    self.w = 640
    self.h = 480
    self.binds = {}
    self.binds.submit = "return"
    self.binds.removeChar = "backspace"
    self.binds.open = "f1"
    self.meta = {}
    self.terminal = {}
    self.commands = {
        {
            name = "help",
            description = "this is the help message",
            run = function()
                console:trace("Showing " .. #self.commands .. " commands", 0)
                console:trace("===============================================", 0)
                for h = 1, #self.commands, 1 do
                    console:trace(self.commands[h].name .. " | " .. self.commands[h].description)
                end
            end
        },
        {
            name = "trace",
            description = "this is the help message",
            run = function(...)
                local data = {...}
                console:trace("[" .. os.date("%H:%M:%S") .. "] "..  table.concat(data, " "), 2)
            end
        },
        {
            name = "color",
            description = "change the color",
            run = function(color)
                if color == nil then
                    console:trace("[:ERROR:] This command require argument")
                    return
                end
                if tonumber(color) <= 1 then
                    self.theme.textColorID = 1
                elseif tonumber(color) >= #self.theme.textColors then
                    self.theme.textColorID = #self.theme.textColors
                else
                    self.theme.textColorID = tonumber(color)
                end
            end
        }
    }
    self.meta.objects = {}
    self.meta.form = {}
    self.meta.form.command = ""
    self.meta.isEnable = false
    self.meta.dragging = {}
    self.meta.dragging.active = false
    self.meta.dragging.diffX = 0
    self.meta.dragging.diffY = 0
    self.theme = {}
    self.theme.bg = {116, 155, 76}
    self.theme.fg = {67,90, 43}
    self.theme.fontsize = 12
    self.theme.fontpath = nil
    self.theme.textColors = {
        {255, 255, 255},
        {128, 128, 128},
        {0, 0, 0},
        {255, 0, 0},
        {128, 0, 0},
        {0, 255, 0},
        {0, 128, 0},
        {0, 0, 255},
        {0, 0, 128},
        {255, 255, 0},
        {128, 128, 0},
        {0, 255, 255},
        {0, 128, 128},
        {255, 0, 255},
        {128, 0, 128}
    }
    self.theme.textColorID = 1
    if self.theme.fontpath == nil then
        self.meta.objects.font = love.graphics.newFont(self.theme.fontsize)
    else
        self.meta.objects.font = love.graphics.newFont(self.theme.fontpath, self.theme.fontsize)
    end
    self.registry = {}
    self.registry.showTraceback = false
    love.graphics.setFont(self.meta.objects.font)
end

function console:render()
    if not self then
        error("[:ERROR:] Console is not initialized")
    end
    if self.meta.isEnable then
        lines = math.ceil(self.meta.objects.font:getWidth(self.meta.form.command) / (self.w - 20))
        --% The back of the window %--
        love.graphics.setColor(self.theme.bg[1] / 255, self.theme.bg[2] / 255, self.theme.bg[3] / 255)
        if lines > 1 then
            love.graphics.rectangle("fill", self.x, self.y, self.w, self.h + (lines * self.meta.objects.font:getHeight()) - 14, 5, 5)
        else
            love.graphics.rectangle("fill", self.x, self.y, self.w, self.h , 5, 5)
        end
        love.graphics.setColor(1, 1, 1, 1)
        --% The hole of the window %--  
        love.graphics.setColor(self.theme.fg[1] / 255, self.theme.fg[2] / 255, self.theme.fg[3] / 255)
        love.graphics.rectangle("fill", self.x + 10, self.y + 10, self.w - 20, self.h - 60, 5, 5)
        love.graphics.setColor(1, 1, 1, 1)
        --% TheInput hole %--  
        love.graphics.setColor(self.theme.fg[1] / 255, self.theme.fg[2] / 255, self.theme.fg[3] / 255)
        --print(self.meta.objects.font:getHeight(self.meta.form.fullCommand))
        if lines > 1 then
            love.graphics.rectangle("fill", self.x + 10, (self.y + self.h) - 40, self.w - 20, (lines * self.meta.objects.font:getHeight()) + 14 , 5, 5)
        else
            love.graphics.rectangle("fill", self.x + 10, (self.y + self.h) - 40, self.w - 20, 32 , 5, 5)
        end
        love.graphics.setColor(1, 1, 1, 1)
        --% render the text %--
        love.graphics.printf(self.meta.form.command .. "_", self.x + 13, (self.y + self.h) - 32, self.w - 20, "left")
        --% render the terminal stuff %--
        --print(self.theme.textColors[self.theme.textColorID][1], self.theme.textColors[self.theme.textColorID][2], self.theme.textColors[self.theme.textColorID][3])
        love.graphics.setColor(self.theme.textColors[self.theme.textColorID][1] / 255, self.theme.textColors[self.theme.textColorID][2] / 255, self.theme.textColors[self.theme.textColorID][3] / 255)
        love.graphics.printf(table.concat(self.terminal, "\n"), self.x + 10, self.y + 10, self.w - 20, "left")
        love.graphics.setColor(1, 1, 1, 1)
    end
end

function console:update(elapsed)
    if not self then
        error("[:ERROR:] Console is not initialized")
    end
    local width, terminalLines = self.meta.objects.font:getWrap(table.concat(self.terminal, "\n"), self.w - 20)
    if #terminalLines * self.meta.objects.font:getHeight() > self.h - 60  then
        table.remove(self.terminal, 1)
    end
    if self.meta.isEnable then
        if self.meta.dragging.active then
            self.x = love.mouse.getX() - self.meta.dragging.diffX
            self.y = love.mouse.getY() - self.meta.dragging.diffY
        end
    end
end

function console:textinput(t)
    if not self then
        error("[:ERROR:] Console is not initialized")
    end
    if self.meta.isEnable then
        self.meta.form.command = self.meta.form.command .. t
    end
end

function console:keypressed(k)
    if not self then
        error("[:ERROR:] Console is not initialized")
    end
    if k == self.binds.open then
        if self.meta.isEnable then
            self.meta.isEnable = false
        else
            self.meta.isEnable = true
        end
    end
    if k == self.binds.removeChar then
        local byteoffset = utf8.offset(self.meta.form.command, -1)
        if byteoffset then
            self.meta.form.command = string.sub(self.meta.form.command, 1, byteoffset - 1)
        end
    end
    if k == self.binds.submit then
        console:submit()
    end
end

function console:mousepressed(x, y, button)
    if not self then
        error("[:ERROR:] Console is not initialized")
    end
    if button == 1
    and x > self.x and x < self.x + self.w
    and y > self.y and y < self.y + self.h
    and self.meta.isEnable
    then
        self.meta.dragging.active = true
        self.meta.dragging.diffX = x - self.x
        self.meta.dragging.diffY = y - self.y
    else
        self.meta.dragging.active = false
    end
end

function console:mousereleased(x, y, button)
    if not self then
        error("[:ERROR:] Console is not initialized")
    end
    if button == 1 then
        self.meta.dragging.active = false
    end
end

--------------------=[ Special Functions ]=--------------------------


--- run a command on the console
---@param cmd string
function console:run(cmd)
    local tkn = _tokenize(cmd, " ")
    for _, commands in ipairs(self.commands) do
        if commands.name == tkn[1] then
            table.remove(tkn, 1)
            sucess, error = pcall(commands.run, unpack(tkn))
            if self.registry.showTraceback then
                console:trace(error)
            end
        end
    end
    tkn = {}
end

function console:submit()
    if self.meta.isEnable then
        if self.meta.form.command ~= "" then
            table.insert(self.terminal, self.meta.form.command)
            console:run(self.meta.form.command)
            self.meta.form.command = ""
            --print(debug.getTableContent(self.terminal))
        end
    end
end

--- Create your custom commands
---@param commandName string
---@param helpDescription string
---@param priorityLevel number
---@param func function
function console:registerCommand(commandName, helpDescription, func)
    Command = {}
    Command.name = commandName or "defaultCommand"
    Command.description = helpDescription or ""
    Command.run = func or function()
        console:trace("please replace it with console:registerCommand()", 2)
    end
    table.insert(self.commands, Command)
end

--- rebind keys
---@param keys table
function console:rebind(keys)
    self.binds.submit = keys.submit or "return"
    self.binds.open = keys.open or "f1"
    self.binds.removeChar = keys.removeChar or "backspace"
end

--- enable the console directly from code
---@param bool boolean
function console:enable(bool)
    self.meta.isEnable = bool
end

--- echo to the console
---@param text string
function console:trace(text)
    table.insert(self.terminal, text)
end

--- Edt the console theme
---@param theme table
function console:setTheme(theme)
    self.theme.bg = theme.bg or self.theme.bg
    self.theme.fg = theme.fg or self.theme.fg
    self.theme.textColors = theme.textColor or self.theme.textColors
end

----------------------=[ Local functions ]=------------------------

function _tokenize(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

return console