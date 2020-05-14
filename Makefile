#
# leirc: extensible IRC client
# (c) Kied Llaentenn
# See the LICENSE for more information
#

VERSION = 0.1.0

NAME    = leirc
WARNING = -Wall -Wextra -pedantic -Wmissing-prototypes \
	  -Wold-style-definition -Wno-unused-parameter \
	  -Wno-discarded-qualifiers
DEF     = -D_POSIX_C_SOURCE -DVERSION=\"${VERSION}\" -D_GNU_SOURCE
INC     = -I/usr/include/lua5.3 -Iccommon/include

CC      = cc
CFLAGS  = -std=c99 $(WARNING) $(INC) $(DEF)
LDFLAGS = -fuse-ld=gold -L/usr/include/ -llua5.3 -lm

SRC     = main.c api.c lua.c strlcpy.c util.c ccommon/src/die.c
OBJ     = $(SRC:.c=.o)

DESTDIR = /
PREFIX  = /usr/local/

all: debug

clean:
	rm -f $(NAME) $(OBJ) unity.c

.c.o:
	$(CC) $(CFLAGS) $(CFLAGS_OPT) -c $< -o $(<:.c=.o)

debug: CFLAGS_OPT := -ggdb
debug: $(NAME)

release: CFLAGS_OPT := -Os -s
release:
	echo > unity.c
	for f in $(SRC); do echo "#include \"$$f\"" >> unity.c; done
	$(CC) -o $(NAME) unity.c $(CFLAGS) $(CFLAGS_OPT) $(LDFLAGS)
	rm -f unity.c

$(NAME): $(OBJ)
	$(CC) -o $@ $^ $(CFLAGS) $(CFLAGS_OPT) $(LDFLAGS)

.PHONY: all debug release clean install uninstall
