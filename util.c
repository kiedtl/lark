/* See LICENSE file for license details. */
#include <ctype.h>
#include <errno.h>
#include <netdb.h>
#include <netinet/in.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>

#include "util.h"

void
eprint(const char *fmt, ...) {
	char bufout[4096];

	va_list ap;
	va_start(ap, fmt);
	vsnprintf(bufout, sizeof bufout, fmt, ap);
	va_end(ap);
	fprintf(stderr, "%s", bufout);

	if(fmt[0] && fmt[strlen(fmt) - 1] == ':')
		fprintf(stderr, " %s\n", strerror(errno));

	exit(1);
}

int
dial(char *host, char *port) {
	static struct addrinfo hints;
	int srv = 0;
	struct addrinfo *res, *r;

	memset(&hints, 0, sizeof hints);
	hints.ai_family = AF_UNSPEC;
	hints.ai_socktype = SOCK_STREAM;
	if(getaddrinfo(host, port, &hints, &res) != 0)
		eprint("error: cannot resolve hostname '%s':", host);
	for(r = res; r; r = r->ai_next) {
		if((srv = socket(r->ai_family, r->ai_socktype, r->ai_protocol)) == -1)
			continue;
		if(connect(srv, r->ai_addr, r->ai_addrlen) == 0)
			break;
		close(srv);
	}
	freeaddrinfo(res);
	if(!r)
		eprint("error: cannot connect to host '%s'\n", host);
	return srv;
}

char *
eat(char *s, int (*p)(int), int r) {
	while(*s != '\0' && p(*s) == r)
		s++;
	return s;
}

char*
skip(char *s, char c) {
	while(*s != c && *s != '\0')
		s++;
	if(*s != '\0')
		*s++ = '\0';
	return s;
}

void
trim(char *s) {
	char *e;

	e = s + strlen(s) - 1;
	while(isspace(*e) && e > s)
		e--;
	*(e + 1) = '\0';
}
