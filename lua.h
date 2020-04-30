#ifndef LUA_H
#define LUA_H

void init_lua(void);
void run_init(void);
void run_receive_handler(char *usr, char *cmd, char *par, char *txt);

#endif
