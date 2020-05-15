local config  = {}

-- server and port configuration.
config.server = "irc.freenode.net"
config.port   = 6667

-- --- --- --- ---

-- user configuration.
--
-- If you don't want your realname
-- to be defined, simply set it to an empty
-- string.
--
-- NOTE: config.password is simply a password
-- that is sent to servers that require a password
-- for connecting. It IS NOT a NickServ password.
config.username = "larkbottest"
config.realname = "Lark Bot Account"
config.nickname = "larkbottest"
config.password = nil

-- --- --- --- ---

-- channels to join on startup
config.channels = { "#test", "#flood", "#botwar" }

-- default parting message that is sent on exit
config.parting = "lark: github.com/lptstr/lark"

-- TODO:
--   default mode

return config
