local api    = require('api')
local curses = require('curses')
local core = {}

function core.init()
end

function core.on_error(err)
	curses.endwin()
	print(debug.traceback(err, 2))
	os.exit(2)
end

return core
