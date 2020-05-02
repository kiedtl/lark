local api      = require('api')
local config   = require('config')
local handlers = require('core.handlers')
local util     = require('core.util')
local printf   = util.printf

local core = {}

function core.init()
	local server = config.server or "irc.freenode.net"
	local port   = config.port or 6667

	-- TODO: handle disconnects, errors
	-- connect to server
	api.connect(server, port)

	-- set username, realname, etc
	api.sendf(
		"USER %s %s %s :%s",
		config.username,
		util.getHostname(),
		config.server,
		config.realname
	)

	-- set nickname
	api.sendf("NICK %s", config.nickname)

	-- send password
	api.sendf("PASS %s", config.password or "")
end

function core.on_receive(usr, cmd, pars, txt)
	local handler = handlers[cmd]

	if handler then
		handler(usr, pars, txt)
	else
		printf("%12s %s: %s\n", "-?-", cmd, txt)
	end
end

function core.on_timeout(last_receive)
	if os.time() - last_receive >= 512 then
		-- we pinged the server but they didn't respond,
		-- get the hell outta here
		io.stderr:write("leirc: error: timeout reached.\n")
		core.on_quit()
	else
		-- ping the server to check if they're still
		-- there
		api.sendf("PING %s", config.server);
	end
end

function core.on_error(err)
	io.stderr:write(debug.traceback(err, 2))
	io.stderr:write("\n")
	core.on_quit()
end

-- handle errors, SIGINT, etc
function core.on_quit()
	printf("%12s %s", "-!-", "sending quit... ")
	api.sendf("QUIT :%s", config.parting)
	printf("done\n")

	os.exit(1)
end

return core
