local curses = require('curses')
local core = {}

function core.init()
	leirc_connect("irc.freenode.net", 6667)

	leirc_write("NICK leirc_test")
	leirc_write("USER leirc_test - - :leirc_test")
	leirc_write("PASS ")
	leirc_write("JOIN #test")
	leirc_write("PRIVMSG #test :test")

	while true do
		local data = leirc_read()
		local prefix, cmd, args = parse_irc(data)
		print(data)
	end

	leirc_disconnect()
end

function parsePrefix(prefix)
        local user = {}
        if prefix then
                user.access, user.nick, user.username, user.host = prefix:match("^([%+@]*)(.+)!(.+)@(.+)$")
        end
        user.access = parseAccess(user.access or "")
        return user
end

function parseAccess(accessString)
        local access = {op = false, halfop = false, voice = false}
        for c in accessString:gmatch(".") do
                if     c == "@" then access.op = true
                elseif c == "%" then access.halfop = true
                elseif c == "+" then access.voice = true
                end
        end
        return access
end

function parse_irc(line)
	local prefix
	local lineStart = 1
	local lineStop = line:len()
	if line:sub(1,1) == ":" then
		local space = line:find(" ")
		prefix = line:sub(2, space-1)
		lineStart = space
	end

	local _, trailToken = line:find("%s+:", lineStart)
	local trailing
	if trailToken then
		trailing = line:sub(trailToken + 1)
		lineStop = trailToken - 2
	end

	local args = {}

	local _, cmdEnd, cmd = line:find("(%S+)", lineStart)
	local pos = cmdEnd + 1

	while true do
		local _, stop, param = line:find("(%S+)", pos)

		if not param or stop > lineStop then
			break
		end

		pos = stop + 1
		args[#args + 1] = param
	end

	if trailing then
		args[#args + 1] = trailing
	end

	return prefix, cmd, args
end

function on_error(err)
	curses.endwin()
	print(debug.traceback(err, 2))
	os.exit(2)
end

function sleep(n)
	local start = os.clock()
	while os.clock() - start < n do end
end

return core
