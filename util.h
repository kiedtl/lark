#ifndef UTIL_H
#define UTIL_H

int dial(char *host, char *port);
char *eat(char *s, int (*p)(int), int r);
char *skip(char *s, char c);
void trim(char *s);

#endif
