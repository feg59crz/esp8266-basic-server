local html = {}
html.nav = [[<header>
<nav>
    <ul>
        <li><a href="/">HOME</a></li>
        <li><a href="/boards">Boards</a></li>
    </ul>
</nav>
</header>]]
function html.listboards(list)
    local str = ""
    for k, v in pairs(list) do
        print("k", k)
        print("v", v)
        str = str .. '<li><a href="' .. k .. '">' .. app.boards[k].name .. "</li>\n"
    end
    return str
end

return html
