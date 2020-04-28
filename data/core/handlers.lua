-- TODO: move to config

module "core"

handlers = {}

handlers["PING"] = function(prefix, args)
	leirc_write("PONG :" .. args)
end

handlers["PRIVMSG"] = function(prefix, args)
	local user = parsePrefix(prefix)
	print(string.format("%14s %s", user, args))
end

handlers["NOTICE"] = function(prefix, args)
	print(string.format("%14s %s", "NOTICE", args))
end

handlers["JOIN"] = function(prefix, args)
	print(string.format("%14s %s", "-->", args))
end

handlers["PART"] = function(prefix, args)
	print(string.format("%14s %s", "<--", args))
end
