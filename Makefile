### Generated by Winemaker ... and improved by Xj ;-)
CC                 := gcc
LINK               := winegcc
SRCDIR             := .
GTK                := 3
VUMETER            := 0
PKG_CONFIG_PATH32   = $(LIBDIR32)/pkgconfig
PKG_CONFIG_PATH64   =
PKGCP               =
LIBDIR              =
LBITS              != getconf LONG_BIT
LASH                = $(shell PKG_CONFIG_PATH=$(PKGCP) pkg-config --exists lash-1.0 && echo 1 || echo 0)
D_CEXTRA           :=
PKG_CONFIG_MODULES := jack libxml-2.0

# On 64 bit platform build also fsthost64
ifeq ($(LBITS), 64)
PLAT               := 32 64
else
PLAT               := 32
endif

# Modules / Features
ifneq ($(GTK),0)
D_CEXTRA           += -DHAVE_GTK
PKG_CONFIG_MODULES += gtk+-$(GTK).0
endif

ifneq ($(GTK),3)
override VUMETER   := 0
endif

ifeq ($(VUMETER),1)
D_CEXTRA           += -DVUMETER
endif

ifeq ($(MWW),1)
D_CEXTRA           += -DMOVING_WINDOWS_WORKAROUND
endif

ifeq ($(EE),1)
D_CEXTRA           += -DEMBEDDED_EDITOR
endif

ifeq ($(LASH),1)
PKG_CONFIG_MODULES += lash-1.0
D_CEXTRA           += -DHAVE_LASH
endif

# Shared GCC flags
CEXTRA              = $(shell PKG_CONFIG_PATH=$(PKGCP) pkg-config --cflags $(PKG_CONFIG_MODULES))
CEXTRA             += -g -O2 -Wall -fPIC -Wno-deprecated-declarations -Wno-multichar -march=native -mfpmath=sse
CEXTRA             += $(D_CEXTRA)

# Shared LDFlags
LDFLAGS             = $(shell PKG_CONFIG_PATH=$(PKGCP) pkg-config --libs $(PKG_CONFIG_MODULES))
LDFLAGS            += -lpthread -lX11 -mwindows
LDFLAGS            += -L$(LIBDIR_WINE)

# Shared include / install paths
INCLUDE_PATH       := -I. -I/usr/include -I/usr/include/wine -I/usr/include/wine/windows -I/usr/include/x86_64-linux-gnu
DESTDIR            :=
PREFIX             := /usr
MANDIR             := $(PREFIX)/man/man1
ICONDIR            := $(PREFIX)/share/icons/hicolor/32x32/apps
LIBDIR32           := $(PREFIX)/lib/i386-linux-gnu
LIBDIR64           := $(PREFIX)/lib/x86_64-linux-gnu
BINDIR             := $(PREFIX)/bin
LIBDIR_WINE       = $(LIBDIR)/wine

# Platform specific GCC flags
CEXTRA32           := -m32
CEXTRA64           := -m64 

# Platform specific LDFLAGS
LDFLAGS32          := -m32
LDFLAGS64          := -m64

### Global source lists
C_SRCS             := fsthost.c cpuusage.c proto.c
C_SRCS_DIRS        := jfst midifilter fst serv xmldb log

# LASH
ifeq ($(LASH),1)
C_SRCS_DIRS        += lash
endif

# GTK
ifneq ($(GTK),0)
C_SRCS_DIRS        += gtk
endif

C_SRCS             += $(wildcard $(C_SRCS_DIRS:=/*.c))

EXES               := $(PLAT:%=fsthost%) fsthost_list

# Variables for 32/64bit versions respectively
fsthost32: PKGCP    = $(PKG_CONFIG_PATH32)
fsthost64: PKGCP    = $(PKG_CONFIG_PATH64)

fsthost32: LDFLAGS += $(LDFLAGS32)
fsthost64: LDFLAGS += $(LDFLAGS64)

fsthost32: CEXTRA  += $(CEXTRA32)
fsthost64: CEXTRA  += $(CEXTRA64)

fsthost32: LIBDIR   = $(LIBDIR32)
fsthost64: LIBDIR   = $(LIBDIR64)

### Generic targets
all: $(EXES)

### Build rules
.PHONY: all clean dummy install

# Implicit rules
.SUFFIXES: _64.o _32.o
DEFINCL = $(INCLUDE_PATH) $(DEFINES) $(OPTIONS)

.c_64.o .c_32.o:
	$(CC) -c $(CFLAGS) $(CEXTRA) $(DEFINCL) -o $@ $<

# Rules for cleaning
ALL_OBJS = $(C_SRCS:.c=_*.o)
CLEAN_FILES = fsthost_menu.1 *.dbg.c y.tab.c y.tab.h lex.yy.c core *.orig *.rej fsthost.exe* \\\#*\\\# *~ *% .\\\#*
clean:
	$(RM) $(CLEAN_FILES) $(ALL_OBJS) $(EXES:=.dbg.o) $(EXES:=.so) $(EXES)

# Do not remove intermediate files
.SECONDARY: $(ALL_OBJS)

# Prepare manual
man:
	pod2man perl/fsthost_menu.pl fsthost_menu.1

# Rules for install
install-man: man
	install -Dm 0644 fsthost.1 $(DESTDIR)$(MANDIR)/fsthost.1
	install -Dm 0644 fsthost_menu.1 $(DESTDIR)$(MANDIR)/fsthost_menu.1

install-icon:
	install -Dm 0644 gtk/fsthost.xpm $(DESTDIR)$(ICONDIR)/fsthost.xpm

install-noarch:
	install -Dm 0755 perl/fsthost_menu.pl $(DESTDIR)$(BINDIR)/fsthost_menu
	install -Dm 0755 perl/fsthost_ctrl.pl $(DESTDIR)$(BINDIR)/fsthost_ctrl

fsthost32_install: fsthost32
	install -Dm 0644 $<.so $(DESTDIR)$(LIBDIR_WINE)/$<.so
	install -Dm 0755 $< $(DESTDIR)$(BINDIR)/$<

fsthost64_install: fsthost64
	install -Dm 0644 $<.so $(DESTDIR)$(LIBDIR_WINE)/$<.so
	install -Dm 0755 $< $(DESTDIR)$(BINDIR)/$<

fsthost_list_install: fsthost_list
	install -Dm 0755 $< $(DESTDIR)$(BINDIR)/$<

install: $(EXES:=_install) install-noarch install-man install-icon
	ln -fs fsthost32 $(DESTDIR)$(BINDIR)/fsthost

install32: fsthost32_install install-noarch install-man install-icon
	ln -fs fsthost32 $(DESTDIR)$(BINDIR)/fsthost

install64: fsthost64_install install-noarch install-man install-icon
	ln -fs fsthost64 $(DESTDIR)$(BINDIR)/fsthost

# Compile
fsthost_list: xmldb/list_$(LBITS).o
	gcc flist.c $< $(shell pkg-config --cflags --libs libxml-2.0) -O3 -g -I. -o $@

fsthost%: $(C_SRCS:.c=_%.o)
	$(LINK) -o $@ $^ $(LDFLAGS)
	mv $@.exe $@		# Fix script name
	mv $@.exe.so $@.so	# Fix library name

	# Script postprocessing
	sed -i -e 's|-n "$$appdir"|-r "$$appdir/$$appname"|' \
		-e 's|.exe.so|.so|' \
		-e '3i export WINEPATH="$(LIBDIR_WINE)"' \
		-e '3i export WINE_SRV_RT=$${WINE_SRV_RT:-15}' \
		-e '3i export WINE_RT=$${WINE_RT:-10}' \
		-e '3i export STAGING_RT_PRIORITY_SERVER=$${STAGING_RT_PRIORITY_SERVER:-15}' \
		-e '3i export STAGING_RT_PRIORITY_BASE=$${STAGING_RT_PRIORITY_BASE:-0}' \
		-e '3i export STAGING_SHARED_MEMORY=$${STAGING_SHARED_MEMORY:-1}' \
		-e '3i export L_ENABLE_PIPE_SYNC_FOR_APP="$@"' \
		-e '3i export L_RT_POLICY="$${L_RT_POLICY:-FF}"' \
		-e '3i export L_RT_PRIO=$${L_RT_PRIO:-10}' $@
