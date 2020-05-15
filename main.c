/* See LICENSE file for license details. */
#include <ctype.h>
#include <errno.h>
#include <lua.h>
#include <signal.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/select.h>
#include <time.h>
#include <unistd.h>

#include "arg.h"
#include "die.h"
#include "lua.h"

char *argv0;
lua_State *L;
FILE *srv;

static char bufin[4096];
static time_t trespond;

#undef strlcpy
#include "strlcpy.h"
#include "util.h"

static void
parsesrv(char *cmd) {
	char *usr = "", *par, *txt;

	if(!cmd || !*cmd)
		return;
	if(cmd[0] == ':') {
		usr = cmd + 1;
		cmd = skip(usr, ' ');
		if(cmd[0] == '\0')
			return;
		skip(usr, '!');
	}
	skip(cmd, '\r');
	par = skip(cmd, ' ');
	txt = skip(par, ':');
	trim(par);
	
	run_receive_handler(usr, cmd, par, txt);
}

int
main(int argc, char *argv[]) {
	struct timeval tv;
	int n;
	fd_set rd;

	init_lua();

	/* TODO: move argument parsing to Lua */
	ARGBEGIN {
	case 'V':
		printf("lark v%s\n", VERSION);
		return 0;
		break;
	case 'h':
		printf("usage: %s [-h] [-V]\n", argv0);
		return 0;
		break;
	default:
		die("lark: invalid option -- '%c'\n", ARGC());
		break;
	} ARGEND;

	/* init */
	run_init(); /* connect, login and set things up */
	fflush(srv);
	setbuf(stdout, NULL);
	setbuf(srv, NULL);
	setbuf(stdin, NULL);

	struct sigaction sa;
	sa.sa_flags = SA_SIGINFO;
	sigemptyset(&sa.sa_mask);
	sa.sa_sigaction = run_sig_handler;
	sigaction(SIGINT, &sa, NULL);
	
	for(;;) { /* main loop */
		FD_ZERO(&rd);
		FD_SET(fileno(srv), &rd);
		tv.tv_sec = 120;
		tv.tv_usec = 0;
		n = select(fileno(srv) + 1, &rd, 0, 0, &tv);
		if (n < 0) {
			if(errno == EINTR)
				continue;
			die("sic: error on select():");
		} else if (n == 0) {
			run_timeout_handler(trespond);
		}

		if(FD_ISSET(fileno(srv), &rd)) {
			if(fgets(bufin, sizeof bufin, srv) == NULL) {
				/* TODO: add on_closedconnection handler */
				die("sic: remote host closed connection\n");
			}

			parsesrv(bufin);
			trespond = time(NULL);
		}
	}

	lua_close(L);
	return 0;
}
