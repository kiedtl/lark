local curses = require('curses')
local core = {}

function core.init()
	leirc_connect("irc.freenode.net", 6667)

	local stdscr = curses.initscr()
	curses.cbreak()
	curses.nl(false)
	curses.echo(true)
	leirc_nodelay(stdscr, true)

	leirc_write("NICK leirc_test")
	leirc_write("USER leirc_test - - :leirc_test")
	leirc_write("PASS ")
	leirc_write("JOIN #test")
	leirc_write("PRIVMSG #test :test")

	while true do
		print(leirc_read())

		local input = stdscr:getstr()
		if input then
			leirc_write(input)
		end
	end

	leirc_disconnect()
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
