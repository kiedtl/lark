local api = require("api")
local irc = {}

function irc.connect(server, port)
	local srv = server or "irc.freenode.net"
	local prt = port   or 6667

	api.connect(srv, prt)
end

function irc.sendUser(username, hostname, server, realname)
	api.sendf(
                "USER %s %s %s :%s",
                username, hostname,
                server, realname
        )
end

function irc.sendNick(nickname)
	api.sendf("NICK %s", nickname)
end

function irc.sendPassword(password)
	if password then
		api.sendf("PASS %s", password)
	end
end

function irc.sendPing(server)
	api.sendf("PING %s", server)
end

function irc.sendPong(code)
	api.sendf("PONG %s", code)
end

function irc.sendQuit(reason)
	api.sendf("QUIT :%s", reason)
end

function irc.joinChannel(channel)
	if channel then
		api.sendf("JOIN %s", channel)
	end
end

return irc
