local html = {}
html.nav = [[<header>
<nav>
    <ul>
        <li><a href="/">HOME</a></li>
        <li><a href="/boards">Boards</a></li>
        <li><a href="/up-pin">Update Pin</a></li>
    </ul>
</nav>
</header>]]
function html.listboards(list)
    local str = ""
    for k, v in pairs(list) do
        str = str .. '<li><a href="/boards/' .. k .. '">' .. app.boards[k].name .. "</li>\n"
    end
    return str
end

function html.listBoardPINStatus(bd)
    local bd = bd
    local str = ""
    for k, v in pairs(bd.pins) do
        str = str .. "<li>PIN: " .. k .. " Mode: " .. v.mode
        str = str .. "</li>"
    end
    return str
end

return html
