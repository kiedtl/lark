#
# signet: easy verification
# (c) Kied Llaentenn
# See the LICENSE for more information
#

NAME    = leirc
WARNING = -Wall -Wextra -pedantic -Wmissing-prototypes \
	  -Wold-style-definition -Wno-unused-parameter
DEF     = -D_POSIX_C_SOURCE
INC     = -I/usr/include/lua5.3 -Iccommon/include

CC      = gcc
CFLAGS  = -std=c99 $(WARNING) $(INC) $(DEF)
LDFLAGS = -fuse-ld=gold -L/usr/include/ -llua5.3 -lm -static

SRC     = main.c dial.c irc.c
OBJ     = $(SRC:.c=.o)

DESTDIR = /
PREFIX  = /usr/local/

all: debug

clean:
	rm -f $(NAME) $(OBJ)

.c.o:
	$(CC) $(CFLAGS) $(CFLAGS_OPT) -c $<

debug: CFLAGS_OPT := -ggdb
debug: $(NAME)

release: CFLAGS_OPT := -Os -s
release: $(NAME)

$(NAME): $(OBJ)
	$(CC) -o $@ $^ $(CFLAGS) $(CFLAGS_OPT) $(LDFLAGS)

.PHONY: all debug release clean install uninstall