#include <curses.h>
#include <errno.h>
#include <lauxlib.h>
#include <lua.h>
#include <lualib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

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
	char *host = luaL_checkstring(L, 1);
	char *port = luaL_checkstring(L, 2);

	int fd = dial(host, port);
	if (!fd) {
		return luaL_error(L, "error:"
			"unable to resolve server: %s\n",
			strerror(errno));
	}

	server = fdopen(fd, "r+");

	if (!server) {
		return luaL_error(L, "error:"
			"unable to connect to server: %s\n",
			strerror(errno));
	}

	return 0;
}

/*
 * send to server
 */
int
leirc_write(lua_State *L)
{
	char *data = luaL_checkstring(L, 1);
	fprintf(server, "%s\r\n", data);

	return 0;
}

/*
 * read from server
 */
int
leirc_read(lua_State *L)
{
	static char buf[IRC_MSG_MAX];

	char *rd = NULL;
	if ((rd = fgets((char*) &buf, sizeof(buf), server)) == NULL)
		return luaL_error(L, "error: broken pipe.\n");

	/* remove trailing newline */
	char *p = (char*) &buf;
	while (*p) ++p;
	*(--p) = '\0';

	lua_pushstring(L, (char*) &buf);
	return 1;
}

int
leirc_nodelay(lua_State *L)
{
	WINDOW **w = (WINDOW**) luaL_checkudata(L, 1, "curses:window");
	if (w == NULL) luaL_argerror(L, 1, "invalid window");
	if (*w == NULL) luaL_argerror(L, 1, "attempt to use closed window");

	bool bf = lua_toboolean(L, 2);
	lua_pushboolean(L, (int) (nodelay(*w, bf) == NULL));
	return 1;
}

/*
 * disconnect from server.
 */
int
leirc_disconnect(lua_State *L)
{
	fclose(server);
	return 0;
}
