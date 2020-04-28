#include <lauxlib.h>
#include <lua.h>
#include <stdio.h>

#include "api.h"

extern FILE *srv;

int
api_send(lua_State *pL)
{
	char *data = luaL_checkstring(pL, 1);
	fprintf(srv, "%s\r\n", data);
	return 0;
}
