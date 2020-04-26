#include <stdio.h>
#include <lauxlib.h>
#include <lua.h>
#include <lualib.h>
#include <string.h>
#include <unistd.h>

#include "irc.h"

lua_State *L;

int
main(int argc, char **argv)
{
	L = luaL_newstate();

	luaL_openlibs(L);

	luaopen_table(L);
	luaopen_io(L);
	luaopen_string(L);
	luaopen_math(L);

	lua_newtable(L);
	for (int i = 0; i < argc; i++) {
		lua_pushstring(L, argv[i]);
		lua_rawseti(L, -2, i + 1);
	}
	lua_setglobal(L, "_ARGS");

	lua_pushcfunction(L, leirc_connect);
	lua_setglobal(L, "leirc_connect");

	char buf[4096];
	char path[512];
	sprintf(path, "/proc/%d/exe", getpid());
	int len = readlink(path, buf, sizeof(buf) - 1);
	buf[len] = '\0';

	for (int i = strlen(buf) - 1; i > 0; i--) {
		if (buf[i] == '/' || buf[i] == '\\') {
			buf[i] = '\0';
			break;
		}
	}
	
	//printf("debug: exedir: %s\n", buf);

	lua_pushstring(L, buf);
	lua_setglobal(L, "_EXEDIR");

	(void) luaL_dostring(L,
		"dofile(_EXEDIR .. '/data/init.lua')\n"
		"init()\n"
	);

	lua_close(L);
	return 0;
}
