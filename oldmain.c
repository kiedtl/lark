#include <curses.h>
#include <lauxlib.h>
#include <lua.h>
#include <lualib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

#include "irc.h"

lua_State *L;

int
main(int argc, char **argv)
{
	/* start ncurses */
	initscr();
	cbreak();
	noecho();
	keypad(stdscr, TRUE);
	nodelay(stdscr, TRUE);
	curs_set(FALSE);

	/* initialize lua */
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

	/* get executable path */
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
		"xpcall(function()\n"
		"  package.path  = _EXEDIR .. '/data/?.lua;' .. package.path\n"
		"  package.path  = _EXEDIR .. '/data/?/init.lua;' .. package.path\n"
		"  package.path  = _EXEDIR .. '/data/share/lua/5.3/?.lua;' .. package.path\n"
		"  package.cpath = _EXEDIR .. '/data/lib/lua/5.3/?.so;' .. package.cpath\n"
		"  core = require('core')\n"
		"  core.init()\n"
		"end, function(err)\n"
		"  print('Error: ' .. tostring(err))\n"
		"  print(debug.traceback(nil, 3))\n"
		"  if core and core.on_error then\n"
		"    pcall(core.on_error, err)\n"
		"  end\n"
		"  os.exit(1)\n"
	"end)");

	endwin();
	lua_close(L);
	return 0;
}
