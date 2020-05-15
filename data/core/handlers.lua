-- TODO: move to config

local api    = require('api')
local util   = require('core.util')
local format = util.format
local config = require('config')

local handlers = {}

function handler_generic(user, pars, args)
	-- handler random server messages
	-- e.g. MOTD output, etc

	return format("%12s %s\n", "", args)
end

function handler_error(user, pars, args)
	return format("%12s %s\n", "-!-", args)
end

-- --- --- --- ---

handlers["PONG"] = function(user, pars, args)
	-- do nothing, server recieved our ping
	-- and responded.
end

handlers["PING"] = function(user, pars, args)
	-- so it seems we were inactive for some time,
	-- server is pinging us to see if we're still there
	api.sendf("PONG :%s", args)
end

handlers["PRIVMSG"] = function(user, pars, args)
	return format("%12s %s\n", user, args)
end

handlers["NOTICE"] = function(user, pars, args)
	return format("%12s %s\n", "NOTE", args)
end

handlers["JOIN"] = function(user, pars, args)
	return format("%12s %s has joined %s\n", "-->", user, args)
end

handlers["PART"] = function(user, pars, args)
	return format("%12s %s has left %s\n", "<--", user, args)
end

handlers["QUIT"] = function(user, pars, args)
	return format("%12s %s has quit (quit: %s)\n", "<--", user, args)
end

handlers["NICK"] = function(user, pars, args)
	if user == config.nickname then
		config.nickname = user
	end
	return format("%12s %s is now known as %s\n", "--@", user, args)
end

handlers["MODE"] = function(user, pars, args)
	return format("%12s mode change: %s\n", "-+-", args)
end

-- generic messages
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

-- error messages
handlers["ERROR"] = handler_error    -- generic error
handlers["401"]   = handler_error    -- ERR_NOSUCHNICK
handlers["402"]   = handler_error    -- ERR_NOSUCHSERVER
handlers["403"]   = handler_error    -- ERR_NOSUCHCHANNEL
handlers["404"]   = handler_error    -- ERR_CANNOTSENDTOCHAN
handlers["405"]   = handler_error    -- ERR_TOOMANYCHANNELS
handlers["406"]   = handler_error    -- ERR_WASNOSUCHNICK
handlers["407"]   = handler_error    -- ERR_TOOMANYTARGETS
handlers["409"]   = handler_error    -- ERR_NOORIGIN
handlers["411"]   = handler_error    -- ERR_NORECIPIENT
handlers["412"]   = handler_error    -- ERR_NOTEXTTOSEND
handlers["413"]   = handler_error    -- ERR_NOTOPLEVEL
handlers["414"]   = handler_error    -- ERR_WILDTOPLEVEL
handlers["421"]   = handler_error    -- ERR_UNKNOWNCOMMAND
handlers["422"]   = handler_error    -- ERR_NOMOTD
handlers["423"]   = handler_error    -- ERR_NOADMININFO
handlers["424"]   = handler_error    -- ERR_FILEERROR
handlers["431"]   = handler_error    -- ERR_NONICKNAMEGIVEN
handlers["432"]   = handler_error    -- ERR_ERRONEUSNICKNAME
handlers["433"]   = handler_error    -- ERR_NICKNAMEINUSER
handlers["436"]   = handler_error    -- ERR_NICKCOLLISION
handlers["441"]   = handler_error    -- ERR_USERNOTINCHANNEL
handlers["442"]   = handler_error    -- ERR_NOTONCHANNEL
handlers["443"]   = handler_error    -- ERR_USERONCHANNEL
handlers["444"]   = handler_error    -- ERR_NOLOGIN
handlers["445"]   = handler_error    -- ERR_SUMMONDISABLED
handlers["446"]   = handler_error    -- ERR_USERSDISABLED
handlers["451"]   = handler_error    -- ERR_NOTREGISTERED
handlers["461"]   = handler_error    -- ERR_NEEDMOREPARAMS
handlers["462"]   = handler_error    -- ERR_ALREADYREGISTERED
handlers["463"]   = handler_error    -- ERR_NOPERMFORHOST
handlers["464"]   = handler_error    -- ERR_PASSWDMISMATCH
handlers["465"]   = handler_error    -- ERR_YOUREBANNEDCREEP
handlers["467"]   = handler_error    -- ERR_KEYSET
handlers["471"]   = handler_error    -- ERR_CHANNELISFULL
handlers["472"]   = handler_error    -- ERR_UNKNOWNMODE
handlers["473"]   = handler_error    -- ERR_INVITEONLYCHAN
handlers["474"]   = handler_error    -- ERR_BANNEDFROMCHAN
handlers["475"]   = handler_error    -- ERR_BADCHANNELKEY
handlers["481"]   = handler_error    -- ERR_NOPRIVILEGES
handlers["682"]   = handler_error    -- ERR_CHANOPRIVSNEEDED
handlers["483"]   = handler_error    -- ERR_CANTKILLSERVER
handlers["491"]   = handler_error    -- ERR_NOOPERHOST
handlers["501"]   = handler_error    -- ERR_UMODEUNKNOWNFLAG
handlers["502"]   = handler_error    -- ERR_USERSDONTMATCH

return handlers
