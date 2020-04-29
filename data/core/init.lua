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

function core.on_receive(cmd, pars, txt)
	local handlers = require('core.handlers')
	local handler = handlers[cmd]

	if handler then
		handler(pars, txt)
	else
		print(string.format(">< %s (%s): %s", cmd, pars, txt))
	end
end

function core.on_error(err)
	print(debug.traceback(err, 2))
	os.exit(2)
end

function core.parse_prefix(prefix)
	-- TODO: move to irc module
	local user = {}

	if prefix then
		user.type,
		user.nickname,
		user.username,
		user.hostname = prefix:match("^([%+@]*)(.+)!(.+)@(.+)$")
	end

	if user.type then
		local type = {op = false, halfop = false, voice = false}

		for c in user.type:gmatch(".") do
			if     c == "@" then type.op = true
			elseif c == "%" then type.halfop = true
			elseif c == "+" then type.voice = true
			end
		end

		user.type = type
	end

	return user
end

return core
