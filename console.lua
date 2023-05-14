console = {
    author = "StrawberryChocolate",
    Version = "1.0"
}

utf8 = require 'utf8'

---  Create a new console (if nil it will create a console at x: 90 y: 90)
---@param x number
---@param y number
function console:new(x, y)
    self.x = x or 90
    self.y = y or 90
    self.w = 640
    self.h = 480
    self.binds = {}
    self.binds.submit = "return"
    self.binds.open = "f1"
    self.binds.removeChar = "backspace"
    self.binds.previousCommand = "up"
    self.binds.nextCommand = "down"
    self.meta = {}
    self.meta.terminal = {}
    self.meta.commands = {
        -- pre-registred commands --
        {
            name = "clear",
            description = "this is the help message",
            priority = 0,
            func = function()
                self.meta.terminal = {}
            end
        },
        {
            name = "engine",
            description = "this is the help message",
            priority = 2,
            func = function(...)
                local tokens = cunpack(cpack({...}))
                if tokens == nil then
                    console:trace("This command require an argument to run correctly", 2)
                else
                    if tokens[1] == "draw" then
                        if tokens[2] == "wireframe" then
                            if tokens[3] == nil then
                                console:trace("This command require an argument to run correctly :: required boolean", 2)
                            else
                                love.graphics.setWireframe(toboolean(tokens[3]))
                            end
                        else
                            console:trace("Invalid property", 2)
                        end
                    else
                        console:trace("Invalid property", 2)
                    end
                end
            end
        },
        {
            name = "help",
            description = "this is the help message",
            priority = 0,
            func = function()
                console:trace("Showing " .. #self.meta.commands .. " commands", 0)
                console:trace("----------------------------------------------", 0)
                for h = 1, #self.meta.commands, 1 do
                    console:trace(self.meta.commands[h].name .. " | " .. self.meta.commands[h].description, self.meta.commands[h].priority)
                end
            end
        },
        {
            name = "echo",
            description = "show a message on the console",
            priority = 0,
            func = function(...)
                local tkns = cpack({...})
                if ... == nil then
                    console:trace("no output", 2)
                else
                    console:trace(table.concat(cunpack(tkns), " "), 3)
                end
            end
        },
        {
            name = "event",
            description = "execute a event",
            priority = 2,
            func = function(arg)
                if arg == nil then
                    console:trace("Failed to run 'app' command :: no arguments found :: usage | app <argument>" , 2)
                else
                    if arg == "quit" then
                        love.event.quit()
                    elseif arg == "restart" or arg == "reset" then
                        love.event.quit("restart")
                    else
                        console:trace("Invalid argument : " .. "'" .. arg .. "'", 2)
                    end
                end
            end
        },
        {
            name = "window",
            description = "control window",
            priority = 2,
            func = function(...)
                local tokens = cunpack(cpack({...}))
                if ... == nil then
                    console:trace("This command require arguments", 2)
                else
                    if tokens[1] == "title" then
                        if tokens[2] == nil then
                            console:trace("This command require arguments", 2)
                        else
                            love.window.setTitle(tostring(tokens[2]))
                        end
                    elseif tokens[1] == "position" then
                        if type(tonumber(tokens[2])) == "number" then
                            if type(tonumber(tokens[3])) == "number" then
                                love.window.setPosition(tokens[2], tokens[3])
                            else
                                console:trace("This command require arguments in number type", 2)
                            end
                        else
                            console:trace("This command require arguments in number type", 2)
                        end
                    else
                        console:trace("This command require arguments", 2)
                    end
                end
            end
        },
    }
    self.meta.consoleEnable = false
    self.meta.dragging = {}
    self.meta.dragging.active = false
    self.meta.dragging.diffX = 0
    self.meta.dragging.diffY = 0
    self.meta.currentItem = 1
    self.meta.maxRender = 26
    self.meta.fontSize = 12
    self.meta.textCommand = ""
    self.meta.font = love.graphics.newFont(self.meta.fontSize)
    self.meta.commandHistory = {}
    self.meta.commandHistorySelection = 1
    console:announce("LoveConsole v" .. console.Version)
    console:announce("By " .. console.author)
    console:announce("Love version : " .. string.format("%d.%d.%d - %s", love.getVersion()))
    console:trace("Loaded " .. #self.meta.commands .. " commands", 3)
end


function console:render()
    local textY = self.y + 20
    if self.meta.consoleEnable then
        love.graphics.setColor(100 / 255, 100 / 255, 100 / 255)
        love.graphics.rectangle("fill", self.x, self.y, self.w, self.h, 10, 10)
        love.graphics.setColor(255 / 255, 255 / 255, 255 / 255)
        love.graphics.setColor(40 / 255, 40 / 255, 40 / 255)
        love.graphics.rectangle("fill", self.x + 10, self.y + 20, self.w - 20, self.h - 30, 10, 10)
        love.graphics.setColor(255 / 255, 255 / 255, 255 / 255, 255 / 255)
        love.graphics.print("Console", self.x + 15, self.y + 5)
        love.graphics.print("> " .. tostring(self.meta.textCommand) .. "_", self.meta.font, self.x + 13, self.y + (self.h - 32))
        for ti = 1, #self.meta.terminal, 1 do
            if #self.meta.terminal > 0 then
                if self.meta.terminal[ti].type == "trace" then
                    love.graphics.setColor(self.meta.terminal[ti].levelColor)
                    love.graphics.print("] " .. self.meta.terminal[ti].text, self.meta.font, self.x + 13, textY)
                    love.graphics.setColor(255 / 255, 255 / 255, 255 / 255, 255 / 255)
                elseif self.meta.terminal[ti].type == "announce" then
                    love.graphics.setColor(77 / 255, 33 / 255, 8 / 255)
                    love.graphics.print("] " .. self.meta.terminal[ti].text, self.meta.font, self.x + 13, textY + 1)
                    love.graphics.setColor(255 / 255, 255 / 255, 255 / 255, 255 / 255)
                    love.graphics.setColor(203 / 255, 138 / 255, 76 / 255)
                    love.graphics.print("] " .. self.meta.terminal[ti].text, self.meta.font, self.x + 13, textY - 1)
                    love.graphics.setColor(255 / 255, 255 / 255, 255 / 255, 255 / 255)
                    love.graphics.setColor(155 / 255, 102 / 255, 51 / 255)
                    love.graphics.print("] " .. self.meta.terminal[ti].text, self.meta.font, self.x + 13, textY)
                    love.graphics.setColor(255 / 255, 255 / 255, 255 / 255, 255 / 255)
                else
                    love.graphics.setColor(255 / 255, 255 / 255, 255 / 255, 255 / 255)
                    love.graphics.print("] " .. self.meta.terminal[ti], self.meta.font, self.x + 13, textY)
                end
                textY = textY + self.meta.fontSize
            end
        end
        love.graphics.setColor(255 / 255, 255 / 255, 255 / 255)
    end
end


function console:update(elapsed)
    --[[
    if self.meta.currentItem < 1 then
        self.meta.currentItem = 1
    end
    if self.meta.currentItem > #self.meta.terminal then
        self.meta.currentItem = #self.meta.terminal
    end
    ]]--
    if #self.meta.terminal > 28 then
        table.remove(self.meta.terminal, 1)
    end

    if self.meta.consoleEnable then
        if self.meta.dragging.active then
            self.x = love.mouse.getX() - self.meta.dragging.diffX
            self.y = love.mouse.getY() - self.meta.dragging.diffY
        end
    end
end


function console:textinput(inp)
    if self.meta.consoleEnable then
        if inp ~= self.binds.open then
            self.meta.textCommand = self.meta.textCommand .. inp
        end
    end
end

function console:keypressed(k)
    if k == self.binds.open then
        if self.meta.consoleEnable then
            self.meta.consoleEnable = false
        else
            self.meta.consoleEnable = true
        end
    end
    if self.meta.consoleEnable then
        if k == self.binds.removeChar then
            if #self.meta.textCommand > 0 then
                local byteOffset = utf8.offset(self.meta.textCommand, -1)
                if byteOffset then
                    self.meta.textCommand = string.sub(self.meta.textCommand, 1, byteOffset - 1)
                end
            end
        end
        if k == self.binds.submit then
            console:submit()
        end
        if k == self.binds.previousCommand then
            if #self.meta.commandHistory > 0 then
                self.meta.commandHistorySelection = self.meta.commandHistorySelection - 1
                if self.meta.commandHistorySelection < 1 then
                    self.meta.commandHistorySelection = 1
                end

                if self.meta.commandHistorySelection > #self.meta.commandHistory then
                    self.meta.commandHistorySelection = #self.meta.commandHistory
                end
                self.meta.textCommand = self.meta.commandHistory[self.meta.commandHistorySelection]
            end
        end
        if k == self.binds.nextCommand then
            if #self.meta.commandHistory > 0 then
                self.meta.commandHistorySelection = self.meta.commandHistorySelection + 1
                
                if self.meta.commandHistorySelection < 1 then
                    self.meta.commandHistorySelection = 1
                end

                if self.meta.commandHistorySelection > #self.meta.commandHistory then
                    self.meta.commandHistorySelection = #self.meta.commandHistory
                end
                self.meta.textCommand = self.meta.commandHistory[self.meta.commandHistorySelection]
            end
        end
    end
end

function console:mousepressed(x, y, button)
    if button == 1
    and x > self.x and x < self.x + self.w
    and y > self.y and y < self.y + self.h
    and self.meta.consoleEnable
    then
        self.meta.dragging.active = true
        self.meta.dragging.diffX = x - self.x
        self.meta.dragging.diffY = y - self.y
    else
        self.meta.dragging.active = false
    end
end

function console:mousereleased(x, y, button)
    if button == 1 then
        self.meta.dragging.active = false
    end
end

-------------------------------

--- run a command on the console
---@param cmd string
function console:run(cmd)
    local tkn = tokenize(cmd, " ")
    for _, commands in ipairs(self.meta.commands) do
        if commands.name == tkn[1] then
            table.remove(tkn, 1)
            sucess, error = pcall(commands.func, unpack(tkn))
        end
    end
    tkn = {}
end

function console:submit()
    if self.meta.consoleEnable then
        if self.meta.textCommand ~= "" then
            console:trace(self.meta.textCommand, 0)
            console:run(self.meta.textCommand)
            table.insert(self.meta.commandHistory, self.meta.textCommand)
            self.meta.commandHistoryCurrentItem = #self.meta.commandHistory
            self.meta.textCommand = ""
        end
    end
end

--- Create your custom commands
---@param commandName string
---@param helpDescription string
---@param priorityLevel number
---@param func function
function console:registerCommand(commandName, helpDescription, priorityLevel, func)
    Command = {}
    Command.name = commandName or "defaultCommand"
    Command.priority = priorityLevel or 0
    Command.description = helpDescription or ""
    Command.func = func or function()
        console:trace("please replace it with console:registerCommand()", 2)
    end
    table.insert(self.meta.commands, Command)
end

--- Rebind the console special keys with a table presenting the custom keys
---@param keys table
---@alias keyname
---| "submit"  # ---#DESTAIL 'keys.submit'
---| "open"  # ---#DESTAIL 'keys.open'
---| "removeChar"  # ---#DESTAIL 'keys.removeChar'
---| "previousCommand"  # ---#DESTAIL 'keys.previousCommand'
---| "nextCommand"  # ---#DESTAIL 'keys.nextCommand'
function console:rebind(keys)
    self.binds.submit = keys.submit or "return"
    self.binds.open = keys.open or "f1"
    self.binds.removeChar = keys.removeChar or "backspace"
    self.binds.previousCommand = keys.previousCommand or "up"
    self.binds.nextCommand = keys.nextCommand or "down"
end

--- Check if the console is consoleEnable
---@return boolean
function console:isConsoleEnabled()
    return self.meta.consoleEnable
end

--- Write a message on the console
---@param message string
---@param level number
function console:trace(message, level)
    Message = {}
    Message.type = "trace"
    Message.text = tostring(message) or ""
    if type(level) == "number" then
        if level == nil then
            level = 0
        end
        if level > 3 then
            level = 0
        end
    else
        error("Can't use string as parameter, use a 'number' type", 1)
    end
        if level == 0 then
            Message.levelColor = {255 / 255, 255 / 255, 255 / 255}
        end
        if level == 1 then
            Message.levelColor = {255 / 255, 255 / 255, 0 / 255}
        end
        if level == 2 then
            Message.levelColor = {255 / 255, 0 / 255, 0 / 255}
        end
        if level == 3 then
            Message.levelColor = {0 / 255, 255 / 255, 255 / 255}
        end
    table.insert(self.meta.terminal, Message)
end

--- Special function : with special text formating
---@param message string
function console:announce(message)
    Message = {}
    Message.type = "announce"
    Message.text = tostring(message) or ""
    table.insert(self.meta.terminal, Message)
end

------------- special functions ------------------

function tokenize(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

function cpack(t, drop, indent)
	assert(type(t) == "table", "Can only TSerial.pack tables.")
	local s, indent = "{"..(indent and "\n" or ""), indent and math.max(type(indent)=="number" and indent or 0,0)
	for k, v in pairs(t) do
		local tk, tv, skip = type(k), type(v)
		if tk == "boolean" then k = k and "[true]" or "[false]"
		elseif tk == "string" then if string.format("%q",k) ~= '"'..k..'"' then k = '['..string.format("%q",k)..']' end
		elseif tk == "number" then k = "["..k.."]"
		elseif tk == "table" then k = "["..cpack(k, drop, indent and indent+1).."]"
		elseif type(drop) == "function" then k = "["..string.format("%q",drop(k)).."]"
		elseif drop then skip = true
		else error("Attempted to TSerial.pack a table with an invalid key: "..tostring(k))
		end
		if tv == "boolean" then v = v and "true" or "false"
		elseif tv == "string" then v = string.format("%q", v)
		elseif tv == "number" then	-- no change needed
		elseif tv == "table" then v = cpack(v, drop, indent and indent+1)
		elseif type(drop) == "function" then v = "["..string.format("%q",drop(v)).."]"
		elseif drop then skip = true
		else error("Attempted to TSerial.pack a table with an invalid value: "..tostring(v))
		end
		if not skip then s = s..string.rep("\t",indent or 0)..k.."="..v..","..(indent and "\n" or "") end
	end
	return s..string.rep("\t",(indent or 1)-1).."}"
end

function cunpack(s)
	assert(type(s) == "string", "Can only TSerial.unpack strings.")
	assert(loadstring("ctable="..s))()
	local t = ctable
	ctable = nil
	return t
end

function toboolean(str)
    local bool = false
    if string.lower(str) == "true" then
        bool = true
    end
    return bool
end

return console