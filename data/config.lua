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
-- that issent to servers that require a password
-- for connecting. It IS NOT a NickServ password.
config.username = "kiedtl"
config.realname = "Mister Sir"
config.nickname = "wchar_t"
config.password = nil

-- --- --- --- ---

-- default parting message that is send with
-- the /quit or /part commands.
config.parting = "Bye bye"

-- character that inputs must be prefixed with
-- to be recognized as a command.
config.commandPrefix = "/"

-- TODO:
--   default mode

return config
