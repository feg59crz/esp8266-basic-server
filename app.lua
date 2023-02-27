utils = require("utils")
local sv = net.createServer(net.TCP)


app = {}
app.VERSION = "0.0.1"
app.IP = wifi.sta.getip()
app.boards = {}

html = require("html")

main_board = tostring(node.chipid()) or "main"
print("main_board", main_board)
app.boards[main_board] = utils.newBoard("main")
print(app.boards[main_board].name)

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
        res = res .. response_headers .. "\r\n"

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

    if (method == "GET") and (path == "/boards") then
        local headers = {
            format_header("Content-Type", "text/html"),
            format_header("Server", "NodeMCU Lua server"),
            format_header("Connection", "close")
        }

        local response_headers = table.concat(headers)
        local res = "HTTP/1.0 200 OK\r\n"
        res = res .. response_headers .. "\r\n"

        str = utils.sendHTML("web/boards.html")
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
