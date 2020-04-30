local api    = require('api')
local config = require('config')

local core = {}

function core.init()
	api.sendf(
		"USER %s 0 * :%s",
		config.username,
		config.realname
	)
	api.sendf("NICK %s", config.nickname)
	api.sendf("PASS %s", config.password or "")
end

function core.on_receive(usr, cmd, pars, txt)
	local handlers = require('core.handlers')
	local handler = handlers[cmd]

	if handler then
		handler(usr, pars, txt)
	else
		core.printf("%12s %s: %s", "-?-", cmd, txt)
	end
end

function core.on_error(err)
	print(debug.traceback(err, 2))
	os.exit(2)
end

function core.printf(fmt, ...)
	-- TODO: move to core.common
	print(string.format(fmt, ...))
end

return core
