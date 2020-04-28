local api    = require('api')
local config = require('config')
local curses = require('curses')

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

function core.on_error(err)
	curses.endwin()
	print(debug.traceback(err, 2))
	os.exit(2)
end

return core
