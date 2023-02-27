local utils = {}

--[[
    str = 'print("Hello world")'
> str = "return " .. str
> b = loadstring(str)
> b()

--]]
utils.pinRef = {
    "GPIO0",
    "GPIO1",
    "GPIO2",
    "GPIO3",
    "GPIO4",
    "GPIO5",
    "GPIO9",
    "GPIO10",
    "GPIO12",
    "GPIO13",
    "GPIO14",
    "GPIO15",
    "GPIO16",
}



function utils.newBoard(name)
    local board = {}
    board.name = name
    board.pins = {
        GPIO0 = { pin = 3, mode = "OUTPUT" },
        GPIO1 = { pin = 10, mode = "OUTPUT" },
        GPIO2 = { pin = 4, mode = "OUTPUT" },
        GPIO3 = { pin = 9, mode = "OUTPUT" },
        GPIO4 = { pin = 2, mode = "OUTPUT" },
        GPIO5 = { pin = 1, mode = "OUTPUT" },
        GPIO9 = { pin = 11, mode = "OUTPUT" },
        GPIO10 = { pin = 12, mode = "OUTPUT" },
        GPIO12 = { pin = 6, mode = "OUTPUT" },
        GPIO13 = { pin = 7, mode = "OUTPUT" },
        GPIO14 = { pin = 5, mode = "OUTPUT" },
        GPIO15 = { pin = 8, mode = "OUTPUT" },
        GPIO16 = { pin = 0, mode = "OUTPUT" },
    }
    return board
end

function utils.looklua(line)
    local l = line
    repeat
        local change = l:match("{~.-~}") -- {~lua code~}
        if change then -- if have a code into the line then
            local code
            code = change:match("{~(.*)~}") -- the code itself
            local toexec = loadstring(code) -- new function() code end
            change = change:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?%^]", "%%%0") -- add scape elements to the {~lua code~} because gsub
            l = l:gsub(change, toexec()) -- change the {~~}~with the result of toexec
        end
    until (change == nil) -- if no more codes then return the line
    return l
end

function utils.sendHTML(site)
    local site = file.open(site, "r")
    local str = ""
    repeat
        local readline = site:readline()
        if readline ~= nil then
            str = str .. utils.looklua(readline) -- look in the html line for lua code or variables
        end
    until (readline == nil)
    site:close()
    return str
end

return utils
