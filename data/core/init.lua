local core = {}

function core.init()
	leirc_connect("irc.freenode.net", 6667)

	sleep(5)

	leirc_write("NICK leirc_test")
	leirc_write("USER leirc_test - - :leirc_test")
	leirc_write("PASS ")
	leirc_write("JOIN #test")
	leirc_write("PRIVMSG #test :test")

	while true do
		print(leirc_read())
	end

	leirc_disconnect()
end

local function sleep(n)
	local start = os.clock()
	while os.clock() - start < n do end
end

return core