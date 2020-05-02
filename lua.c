#include <lauxlib.h>
#include <lua.h>
#include <lualib.h>
#include <signal.h>
#include <string.h>
#include <unistd.h>

#include "api.h"
#include "lua.h"

extern lua_State *L;

void
init_lua(void)
{
	L = luaL_newstate();
	luaL_openlibs(L);
	luaopen_table(L);
	luaopen_io(L);
	luaopen_string(L);
	luaopen_math(L);

	/* register API funcs */
	lua_pushcfunction(L, api_connect);
	lua_setglobal(L, "_builtin_connect");
	lua_pushcfunction(L, api_send);
	lua_setglobal(L, "_builtin_send");

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
	
	lua_pushstring(L, buf);
	lua_setglobal(L, "_EXEDIR");

	/* set package path */
	(void) luaL_dostring(L,
		"xpcall(function()\n"
		"  package.path  = _EXEDIR .. '/data/?.lua;' .. package.path\n"
		"  package.path  = _EXEDIR .. '/data/?/init.lua;' .. package.path\n"
		"  package.path  = _EXEDIR .. '/data/share/lua/5.3/?.lua;' .. package.path\n"
		"  package.cpath = _EXEDIR .. '/data/lib/lua/5.3/?.so;' .. package.cpath\n"
		"end, function(err)\n"
		"  print('Error: ' .. tostring(err))\n"
		"  print(debug.traceback(nil, 3))\n"
		"  os.exit(1)\n"
	"end)");
}

void
run_init(void)
{
	(void) luaL_dostring(L,
		"xpcall(function()\n"
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
}

void
run_receive_handler(char *usr, char *cmd, char *par, char *txt)
{
	char buf[1048];
	sprintf((char*) &buf,
		"xpcall(function()\n"
		"  core.on_receive(\"%s\", \"%s\", \"%s\", \"%s\")\n"
		"end, function(err)\n"
		"  print('Error: ' .. tostring(err))\n"
		"  print(debug.traceback(nil, 3))\n"
		"  if core and core.on_error then\n"
		"    pcall(core.on_error, err)\n"
		"  end\n"
		"  os.exit(1)\n"
	"end)", usr, cmd, par, txt);
	(void) luaL_dostring(L, (char*) &buf);
}

void
run_timeout_handler(int trespond)
{
	char buf[512];
	sprintf((char*) &buf,
		"xpcall(function()\n"
		"  core.on_timeout(%i)\n"
		"end, function(err)\n"
		"  print('Error: ' .. tostring(err))\n"
		"  print(debug.traceback(nil, 3))\n"
		"  if core and core.on_error then\n"
		"    pcall(core.on_error, err)\n"
		"  end\n"
		"  os.exit(1)\n"
	"end)", trespond);
	(void) luaL_dostring(L, (char*) &buf);
}

void
run_sig_handler(int sig, siginfo_t *si, void *unused)
{
	/*
	 * TODO: currently only handles SIGINT,
	 * in future should also handle SIGTERM,
	 * SIGWINCH, etc
	 */
	(void) luaL_dostring(L,
		"xpcall(function()\n"
		"  core.on_quit()\n"
		"end, function(err)\n"
		"  print('Error: ' .. tostring(err))\n"
		"  print(debug.traceback(nil, 3))\n"
		"  if core and core.on_error then\n"
		"    pcall(core.on_error, err)\n"
		"  end\n"
		"  os.exit(1)\n"
	"end)");
}
