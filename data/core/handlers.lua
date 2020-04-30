-- TODO: move to config

local api    = require('api')
local core   = require('core')
local parse_prefix = core.parse_prefix
local printf = core.printf
local config = require('config')

local handlers = {}

function handler_generic(user, prefix, args)
	-- handler random server messages
	-- e.g. MOTD output, etc

	printf("%12s %s", "", args)
end

-- --- --- --- ---

handlers["PONG"] = function(user, prefix, args)
	-- do nothing, server recieved our ping
	-- and responded.
end

handlers["PING"] = function(user, prefix, args)
	-- so it seems we were inactive for some time,
	-- server is pinging us to see if we're still there
	api.sendf("PONG :%s", args)
end

handlers["PRIVMSG"] = function(user, prefix, args)
	printf("%12s %s", user, args)
end

handlers["NOTICE"] = function(user, prefix, args)
	printf("%12s %s", "NOTE", args)
end

handlers["JOIN"] = function(user, prefix, args)
	printf("%12s %s has joined %s", "-->", user, args)
end

handlers["PART"] = function(user, prefix, args)
	printf("%12s %s has left %s", "<--", user, args)
end

handlers["QUIT"] = function(user, prefix, args)
	print(string.format("%12s %s has quit (quit: %s) ", "<--", user, args))
end

handlers["NICK"] = function(user, prefix, args)
	print(string.format("%12s %s is now known as %s", "--@", user, args))
	if user == config.nickname then
		config.nickname = user
	end
end

handlers["001"] = handler_generic
handlers["002"] = handler_generic
handlers["003"] = handler_generic
handlers["004"] = handler_generic
handlers["005"] = handler_generic
handlers["250"] = handler_generic
handlers["251"] = handler_generic
handlers["252"] = handler_generic
handlers["253"] = handler_generic
handlers["254"] = handler_generic
handlers["255"] = handler_generic
handlers["265"] = handler_generic
handlers["266"] = handler_generic
handlers["372"] = handler_generic
handlers["375"] = handler_generic
handlers["376"] = handler_generic

return handlers
