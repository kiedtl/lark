#ifndef IRC_H
#define IRC_H

#include <lua.h>
#define IRC_MSG_MAX 512

int leirc_connect(lua_State *L);
int leirc_write(lua_State *L);
int leirc_read(lua_State *L);
int leirc_nodelay(lua_State *L);
int leirc_disconnect(lua_State *L);

#endif
