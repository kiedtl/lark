#ifndef API_H
#define API_H

#include <lua.h>

int api_connect(lua_State *pL);
int api_send(lua_State *pL);

#endif
