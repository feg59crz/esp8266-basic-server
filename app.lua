local sv = net.createServer(net.TCP)

local headers = {

}


function receiver(sck, payload)
    print(payload)
    sck:send("HTTP/1.0 200 OK\r\nContent-Type:text/html\r\n\r\n<p>hello</p>")
end

if sv then
    sv:listen(80, function(conn)
        conn:on("receive", receiver)
        conn:on("sent", function(sck) sck:close() end)
    end)
end
