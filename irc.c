#include <errno.h>
#include <lauxlib.h>
#include <lua.h>
#include <lualib.h>
#include <stdio.h>
#include <string.h>

#include "dial.h"
#include "irc.h"
#include "types.h"

FILE *server;

/*
 * connect to server.
 * leirc_connect(server, port)
 */
int
leirc_connect(lua_State *L)
{
	char *server = luaL_checkstring(L, 1);
	char *port   = luaL_checkstring(L, 2);

	int fd = dial(server, port);
	if (!fd) {
		return luaL_error(L, "error:"
			"unable to resolve server: %s\n",
			strerror(errno));
	}

	server = fdopen(dial(server, port), "r+");

	if (!server) {
		return luaL_error(L, "error:"
			"unable to connect to server: %s\n",
			strerror(errno));
	}

	return 0;
}
