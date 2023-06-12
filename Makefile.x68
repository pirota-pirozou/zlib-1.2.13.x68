# Makefile for zlib, derived from Makefile.dj2.
# Modified for mingw32 by C. Spieler, 6/16/98.
# Updated for zlib 1.2.x by Christian Spieler and Cosmin Truta, Mar-2003.
# Last updated: Mar 2012.
# Tested under Cygwin and MinGW.

# Copyright (C) 1995-2003 Jean-loup Gailly.
# For conditions of distribution and use, see copyright notice in zlib.h

# To compile, or to compile and test, type from the top level zlib directory:
#
#   make -fwin32/Makefile.gcc;  make test testdll -fwin32/Makefile.gcc
#
# To install libz.a, zconf.h and zlib.h in the system directories, type:
#
#   make install -fwin32/Makefile.gcc
#
# BINARY_PATH, INCLUDE_PATH and LIBRARY_PATH must be set.
#
# To install the shared lib, append SHARED_MODE=1 to the make command :
#
#   make install -fwin32/Makefile.gcc SHARED_MODE=1

STATICLIB = libz.a

# X68000 gcc mariko version

#
# Set to 1 if shared object needs to be installed
#
SHARED_MODE=0

#LOC = -DZLIB_DEBUG -g

#
PREFIX =
CC = $(PREFIX)gcc
CFLAGS = $(LOC) -O -Wall -cpp-stack=8192000 -z-stack=65536 # -DNO_STRERROR -DNO_snprintf -DNO_vsnprintf -DALLMEM

AS = $(CC)
ASFLAGS = $(LOC) -Wall

LD = $(CC)
LDFLAGS = $(LOC)

AR = $(PREFIX)ar
ARFLAGS =

# RC = $(PREFIX)windres
# RCFLAGS = --define GCC_WINDRES

STRIP = $(PREFIX)strip

CP = cp -fp
# If GNU install is available, replace $(CP) with install.
INSTALL = $(CP)
RM = rm -f

prefix ?= /usr/local
exec_prefix = $(prefix)

OBJS = adler32.o compress.o crc32.o deflate.o gzclose.o gzlib.o gzread.o \
       gzwrite.o infback.o inffast.o inflate.o inftrees.o trees.o uncompr.o zutil.o
OBJA =

all: $(STATICLIB) example.x minigzip.x

test: example.x minigzip.x
	example
	echo hello world | minigzip | minigzip -d

.c.o:
	$(CC) $(CFLAGS) -c -o $@ $<

.S.o:
	$(AS) $(ASFLAGS) -c -o $@ $<

$(STATICLIB): $(OBJS) $(OBJA)
	$(AR) $(ARFLAGS) $@ $(OBJS) $(OBJA)

example.x: example.o $(STATICLIB)
	$(LD) $(LDFLAGS) -o $@ example.o $(STATICLIB) B:\\lib\\FLOATFNC.l
	$(STRIP) $@

minigzip.x: minigzip.o $(STATICLIB)
	$(LD) $(LDFLAGS) -o $@ minigzip.o $(STATICLIB) b:\\lib\\FLOATFNC.l
	$(STRIP) $@

example.o: test/example.c zlib.h zconf.h
	$(CC) $(CFLAGS) -I. -c -o $@ test/example.c

minigzip.o: test/minigzip.c zlib.h zconf.h
	$(CC) $(CFLAGS) -I. -c -o $@ test/minigzip.c

.PHONY: install uninstall clean

install: zlib.h zconf.h $(STATICLIB)
	@if test -z "$(DESTDIR)$(INCLUDE_PATH)" -o -z "$(DESTDIR)$(LIBRARY_PATH)" -o -z "$(DESTDIR)$(BINARY_PATH)"; then \
		echo INCLUDE_PATH, LIBRARY_PATH, and BINARY_PATH must be specified; \
		exit 1; \
	fi
	-@mkdir -p '$(DESTDIR)$(INCLUDE_PATH)'
	-@mkdir -p '$(DESTDIR)$(LIBRARY_PATH)' '$(DESTDIR)$(LIBRARY_PATH)'/pkgconfig
	-if [ "$(SHARED_MODE)" = "1" ]; then \
		mkdir -p '$(DESTDIR)$(BINARY_PATH)'; \
		$(INSTALL) $(SHAREDLIB) '$(DESTDIR)$(BINARY_PATH)'; \
		$(INSTALL) $(IMPLIB) '$(DESTDIR)$(LIBRARY_PATH)'; \
	fi
	-$(INSTALL) zlib.h '$(DESTDIR)$(INCLUDE_PATH)'
	-$(INSTALL) zconf.h '$(DESTDIR)$(INCLUDE_PATH)'
	-$(INSTALL) $(STATICLIB) '$(DESTDIR)$(LIBRARY_PATH)'
	sed \
		-e 's|@prefix@|${prefix}|g' \
		-e 's|@exec_prefix@|${exec_prefix}|g' \
		-e 's|@libdir@|$(LIBRARY_PATH)|g' \
		-e 's|@sharedlibdir@|$(LIBRARY_PATH)|g' \
		-e 's|@includedir@|$(INCLUDE_PATH)|g' \
		-e 's|@VERSION@|'`sed -n -e '/VERSION "/s/.*"\(.*\)".*/\1/p' zlib.h`'|g' \
		zlib.pc.in > '$(DESTDIR)$(LIBRARY_PATH)'/pkgconfig/zlib.pc

uninstall:
	-if [ "$(SHARED_MODE)" = "1" ]; then \
		$(RM) '$(DESTDIR)$(BINARY_PATH)'/$(SHAREDLIB); \
		$(RM) '$(DESTDIR)$(LIBRARY_PATH)'/$(IMPLIB); \
	fi
	-$(RM) '$(DESTDIR)$(INCLUDE_PATH)'/zlib.h
	-$(RM) '$(DESTDIR)$(INCLUDE_PATH)'/zconf.h
	-$(RM) '$(DESTDIR)$(LIBRARY_PATH)'/$(STATICLIB)

clean:
	-$(RM) $(STATICLIB) *.o *.x *.s *.x.elf *.x.elf.2 foo.gz

adler32.o: zlib.h zconf.h
compress.o: zlib.h zconf.h
crc32.o: crc32.h zlib.h zconf.h
deflate.o: deflate.h zutil.h zlib.h zconf.h
gzclose.o: zlib.h zconf.h gzguts.h
gzlib.o: zlib.h zconf.h gzguts.h
gzread.o: zlib.h zconf.h gzguts.h
gzwrite.o: zlib.h zconf.h gzguts.h
inffast.o: zutil.h zlib.h zconf.h inftrees.h inflate.h inffast.h
inflate.o: zutil.h zlib.h zconf.h inftrees.h inflate.h inffast.h
infback.o: zutil.h zlib.h zconf.h inftrees.h inflate.h inffast.h
inftrees.o: zutil.h zlib.h zconf.h inftrees.h
trees.o: deflate.h zutil.h zlib.h zconf.h trees.h
uncompr.o: zlib.h zconf.h
zutil.o: zutil.h zlib.h zconf.h
