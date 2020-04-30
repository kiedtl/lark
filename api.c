#include <errno.h>
#include <lauxlib.h>
#include <lua.h>
#include <stdio.h>
#include <string.h>

#include "api.h"
#include "util.h"

extern FILE *srv;

int
api_connect(lua_State *pL)
{
	char *host = luaL_checkstring(pL, 1);
	char *port = luaL_checkstring(pL, 2);

	int fd = dial(host, port);
	if (!fd) {
		return luaL_error(pL, "error:"
			"unable to resolve server: %s\n",
			strerror(errno));
	}

	srv = fdopen(fd, "r+");

	if (!srv) {
		return luaL_error(pL, "error:"
			"unable to connect to server: %s\n",
			strerror(errno));
	}

	return 0;
}

int
api_send(lua_State *pL)
{
	char *data = luaL_checkstring(pL, 1);
	fprintf(srv, "%s\r\n", data);
	return 0;
}

