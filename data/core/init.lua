local irc      = require('irc')
local config   = require('config')
local util     = require('core.util')
local printf   = util.printf

local core = {}

function core.init()
	-- connect to server
	irc.connect(config.server, config.port)

	-- set username, realname, etc
	irc.sendUser(
		config.username,
		util.getHostname(),
		config.server,
		config.realname
	)

	-- set nickname
	irc.sendNick(config.nickname)

	-- send password
	irc.sendPassword(config.password)

	-- join channels
	for chan = 1, #config.channels do
		irc.joinChannel(config.channels[chan])
	end
end

function core.on_receive(usr, cmd, pars, txt)
	local chan    = config.server
	if cmd == "PRIVMSG" then
		chan = pars
	end

	printf("%s: %12s %s: %s\n", chan, "-?-", cmd, txt)
end

function core.on_timeout(last_receive)
	if os.time() - last_receive >= 512 then
		-- we pinged the server but they didn't respond,
		-- get the hell outta here
		io.stderr:write("lark: error: timeout reached.\n")
		os.exit(1)
	else
		-- ping the server to check if they're still
		-- there
		irc.sendPing(config.server)
	end
end

function core.on_error(err)
	io.stderr:write(debug.traceback(err, 2))
	io.stderr:write("\n")
	core.on_quit()
end

-- handle errors, SIGINT, etc
function core.on_quit()
	printf("warn: recieved exit, sending quit to host... ")

	irc.sendQuit(config.parting)
	printf("done\n")

	os.exit(1)
end

return core
