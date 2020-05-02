/* See LICENSE file for license details. */
#include <ctype.h>
#include <curses.h>
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
#include "config.h"
#include "lua.h"

char *argv0;
lua_State *L;
FILE *srv;
char bufout[4096];

static char nick[32];
static char bufin[4096];
static char channel[256];
static time_t trespond;

#undef strlcpy
#include "strlcpy.h"
#include "util.h"

static void
pout(char *channel, char *fmt, ...) {
	static char timestr[80];
	time_t t;
	va_list ap;

	va_start(ap, fmt);
	vsnprintf(bufout, sizeof bufout, fmt, ap);
	va_end(ap);
	t = time(NULL);
	strftime(timestr, sizeof timestr, TIMESTAMP_FORMAT, localtime(&t));
	fprintf(stdout, "%-12s: %s %s\n", channel, timestr, bufout);
}

static void
sout(char *fmt, ...) {
	va_list ap;

	va_start(ap, fmt);
	vsnprintf(bufout, sizeof bufout, fmt, ap);
	va_end(ap);
	fprintf(srv, "%s\r\n", bufout);
}

static void
privmsg(char *channel, char *msg) {
	if(channel[0] == '\0') {
		pout("", "No channel to send to");
		return;
	}
	pout(channel, "<%s> %s", nick, msg);
	sout("PRIVMSG %s :%s", channel, msg);
}

static void
parsein(char *s) {
	char c, *p;

	if(s[0] == '\0')
		return;
	skip(s, '\n');
	if(s[0] != COMMAND_PREFIX_CHARACTER) {
		privmsg(channel, s);
		return;
	}
	c = *++s;
	if(c != '\0' && isspace(s[1])) {
		p = s + 2;
		switch(c) {
		case 'j':
			sout("JOIN %s", p);
			if(channel[0] == '\0')
				strlcpy(channel, p, sizeof channel);
			return;
		case 'l':
			s = eat(p, isspace, 1);
			p = eat(s, isspace, 0);
			if(!*s)
				s = channel;
			if(*p)
				*p++ = '\0';
			if(!*p)
				p = DEFAULT_PARTING_MESSAGE;
			sout("PART %s :%s", s, p);
			return;
		case 'm':
			s = eat(p, isspace, 1);
			p = eat(s, isspace, 0);
			if(*p)
				*p++ = '\0';
			privmsg(s, p);
			return;
		case 's':
			strlcpy(channel, p, sizeof channel);
			return;
		}
	}
	sout("%s", s);
}

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
	//if(!strcmp("PONG", cmd))
	//	return;
	//if(!strcmp("PRIVMSG", cmd))
	//	pout(par, "<%s> %s", usr, txt);
	//else if(!strcmp("PING", cmd))
	//	sout("PONG %s", txt);
	//else {
	//	pout(usr, ">< %s (%s): %s", cmd, par, txt);
	//	if(!strcmp("NICK", cmd) && !strcmp(usr, nick))
	//		strlcpy(nick, txt, sizeof nick);
	//}
	
	run_receive_handler(usr, cmd, par, txt);
}

int
main(int argc, char *argv[]) {
	struct timeval tv;
	const char *user = getenv("USER");
	int n;
	fd_set rd;

	init_lua();

	strlcpy(nick, user ? user : "unknown", sizeof nick);
	ARGBEGIN {
	case 'V':
		printf("leirc v%s\n", VERSION);
		return 0;
		break;
	case 'h':
		printf("usage: %s [-h] [-V]\n", argv0);
		return 0;
		break;
	default:
		eprint("leirc: invalid option -- '%c'\n", ARGC());
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
		FD_SET(0, &rd);
		FD_SET(fileno(srv), &rd);
		tv.tv_sec = 120;
		tv.tv_usec = 0;
		n = select(fileno(srv) + 1, &rd, 0, 0, &tv);
		if (n < 0) {
			if(errno == EINTR)
				continue;
			eprint("sic: error on select():");
		} else if (n == 0) {
			run_timeout_handler(trespond);
		}

		if(FD_ISSET(fileno(srv), &rd)) {
			if(fgets(bufin, sizeof bufin, srv) == NULL) {
				/* TODO: add on_closedconnection handler */
				eprint("sic: remote host closed connection\n");
			}

			/* TODO: port parsesrv() to lua */
			parsesrv(bufin);
			trespond = time(NULL);
		}

		if(FD_ISSET(0, &rd)) {
			if(fgets(bufin, sizeof bufin, stdin) == NULL)
				eprint("sic: broken pipe\n");
			parsein(bufin);
		}
	}

	lua_close(L);
	return 0;
}
