-- TODO: move to config

local api    = require('api')
local core   = require('core')
local parse_prefix = core.parse_prefix
local config = require('config')

local handlers = {}

handlers["PONG"] = function(prefix, args)
	-- do nothing, server recieved our ping
	-- and responded.
end

handlers["PING"] = function(prefix, args)
	-- so it seems we were inactive for some time,
	-- server is pinging us to see if we're still there
	api.sendf("PONG :%s", args)
end

handlers["PRIVMSG"] = function(prefix, args)
	local user = parse_prefix(prefix)
	print(string.format("%14s %s", user, args))
end

handlers["NOTICE"] = function(prefix, args)
	print(string.format("%14s %s", "NOTE", args))
end

handlers["JOIN"] = function(prefix, args)
	local user = parse_prefix(prefix)
	print(string.format("%14s %s has joined", "-->", user))
end

handlers["PART"] = function(prefix, args)
	local user = parse_prefix(prefix)
	print(string.format("%14s %s has left %s", "<--", user, args))
end

handlers["QUIT"] = function(prefix, args)
	local user = parse_prefix(prefix)
	print(string.format("%14s %s has quit (quit: %s) ", "<--", user, args))
end

handlers["NICK"] = function(prefix, args)
	local user = parse_prefix(prefix)
	print(string.format("%14s %s is now known as %s", user, args))
	if user == config.username then
		config.username = user
	end
end

return handlers
