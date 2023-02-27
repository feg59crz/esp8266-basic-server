utils = require("utils")
local sv = net.createServer(net.TCP)


app = {}
app.VERSION = "0.0.1"
app.IP = wifi.sta.getip()
app.boards = {}


html = require("html")

main_board = tostring(node.chipid()) or "main"
app.boards[main_board] = utils.newBoard("main")


local function format_header(header_name, header_value)
    return header_name .. ": " .. header_value .. "\r\n"
end

function receiver(sck, payload)
    local method, path = payload:match("(%a+)%s+(/%S*)")
    print(method, path)


    if (method == "GET") and (path == "/") then
        local headers = {
            format_header("Content-Type", "text/html"),
            format_header("Server", "NodeMCU Lua server"),
            format_header("Connection", "close")
        }

        local response_headers = table.concat(headers)
        local res = "HTTP/1.0 200 OK\r\n"
        res = res .. response_headers .. "\r\n\r\n"

        str = utils.sendHTML("web/index.html")
        res = res .. str
        sck:send(res)
    end


    if (method == "GET") and (path == "/favicon.ico") then
        local headers = {
            format_header("Content-Type", "image/avif"),
            format_header("Server", "NodeMCU Lua server"),
            format_header("Connection", "close")
        }

        local response_headers = table.concat(headers)
        local res = "HTTP/1.0 200 OK\r\n"
        res = res .. response_headers .. "\r\n"
        local ico = file.open("web/favicon.ico", "rb")
        ico_data = ico:read()
        res = res .. ico_data
        sck:send(res)
    end
    -- boards HTML
    if (method == "GET") and (path == "/boards") then
        local headers = {
            format_header("Content-Type", "text/html"),
            format_header("Server", "NodeMCU Lua server"),
            format_header("Connection", "close")
        }

        local response_headers = table.concat(headers)
        local res = "HTTP/1.0 200 OK\r\n"
        res = res .. response_headers .. "\r\n\r\n"

        str = utils.sendHTML("web/boards.html")
        res = res .. str
        sck:send(res)
    end
    -- Specific board html
    if (method == "GET") and (string.find(path, "/boards/")) then
        local bd = path:gsub("/boards/", "")
        app.slctd_bd = bd
        local headers = {
            format_header("Content-Type", "text/html"),
            format_header("Server", "NodeMCU Lua server"),
            format_header("Connection", "close")
        }
        local response_headers = table.concat(headers)
        local res = "HTTP/1.0 200 OK\r\n"
        res = res .. response_headers .. "\r\n\r\n"
        res = res .. utils.sendHTML("web/board.html")
        sck:send(res)
        app.slctd_bd = nil
    end

    if method == "POST" and path == "/update_pin" then
        local header_end = payload:find("\r\n\r\n")
        local data
        local data_v = {}
        if header_end then
            data = payload:sub(header_end + 4)
            -- do something with the data
        end
        print(data)


        for k, v in string.gmatch(data, "(%w+)=(%w+)") do
            data_v[k] = v
        end

        if data_v.board == main_board then
            local pin = app.boards[data_v.board].pins[data_v.pin].pin
            pin = tonumber(pin)
            gpio.mode(pin, gpio[data_v.pinmode])
            if data_v.pinmode == "OUTPUT" and data_v.pinvalue == "HIGH" or "LOW" then
                gpio.write(pin, gpio[data_v.pinvalue])
            end
        end
        app.boards[data_v.board].pins[data_v.pin].mode = data_v.pinmode
        local headers = {
            format_header("Location", "/"),
            format_header("Server", "NodeMCU Lua server"),
            format_header("Connection", "close")
        }

        local response_headers = table.concat(headers)
        local res = "HTTP/1.1 302 Found\r\n"
        res = res .. response_headers .. "\r\n\r\n"
        sck:send(res)

        -- handle other requests as needed
        -- ...
    end

    if (method == "GET") and (path == "/up-pin") then
        local headers = {
            format_header("Content-Type", "text/html"),
            format_header("Server", "NodeMCU Lua server"),
            format_header("Connection", "close")
        }

        local response_headers = table.concat(headers)
        local res = "HTTP/1.0 200 OK\r\n"
        res = res .. response_headers .. "\r\n"

        str = utils.sendHTML("web/up-pin.html")
        res = res .. str
        sck:send(res)
    end
end

if sv then
    sv:listen(80, function(conn)
        conn:on("receive", receiver)
        conn:on("sent", function(sck) sck:close() end)
    end)
end
