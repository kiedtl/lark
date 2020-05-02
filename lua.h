#ifndef LUA_H
#define LUA_H

#include <signal.h>

void init_lua(void);
void run_init(void);
void run_receive_handler(char *usr, char *cmd, char *par, char *txt);
void run_timeout_handler(int trespond);
void run_sig_handler(int sig, siginfo_t *si, void *unused);

#endif
