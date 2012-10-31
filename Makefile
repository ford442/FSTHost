### Generated by Winemaker
SRCDIR                = .
SUBDIRS               =
DLLS                  =
EXES                  = fsthost

LASH_EXISTS := $(shell if pkg-config --exists lash-1.0; then echo yes; else echo no; fi)

### Common settings

PKG_CONFIG_MODULES    := glib-2.0
PKG_CONFIG_MODULES    += gtk+-2.0
PKG_CONFIG_MODULES    += jack
PKG_CONFIG_MODULES    += libxml-2.0
ifeq ($(LASH_EXISTS),yes)
PKG_CONFIG_MODULES    += lash-1.0
endif

CEXTRA                := $(shell pkg-config --cflags $(PKG_CONFIG_MODULES)) 
CEXTRA                += -fPIC -m32 -g -Wno-multichar -O2 -frounding-math -fsignaling-nans -mfpmath=sse -msse2
ifneq (,$(findstring lash-1.0,$(PKG_CONFIG_MODULES)))
CEXTRA                += -DHAVE_LASH
endif
CXXEXTRA              = -mno-cygwin
RCEXTRA               =
INCLUDE_PATH          = -I. -I/usr/include -I/usr/include -I/usr/include/wine -I/usr/include/wine/windows -I/usr/local/include/wine -I/usr/local/include/wine/windows
DLL_PATH              =
LIBRARY_PATH          = -L/usr/lib/i386-linux-gnu/wine
LIBRARIES             := $(shell pkg-config --libs $(PKG_CONFIG_MODULES)) -L/usr/X11R6/lib -lpthread -lrt -lX11 -m32
DESTDIR               =
PREFIX                = /usr
LIB_INST_PATH         = $(PREFIX)/lib/i386-linux-gnu/wine
BIN_INST_PATH         = $(PREFIX)/bin

### fst.exe sources and settings
fsthost_exe_MODULE       = fsthost
fsthost_exe_C_SRCS       = audiomaster.c fst.c gtk.c jfst.c fxb.c fps.c vstwin.c cpuusage.c
fsthost_exe_CXX_SRCS     =
fsthost_exe_RC_SRCS      =
fsthost_exe_LDFLAGS      = -mwindows
fsthost_exe_DLL_PATH     =
fsthost_exe_DLLS         = 
fsthost_exe_LIBRARY_PATH =
fsthost_exe_LIBRARIES    = uuid

fsthost_exe_OBJS         = $(fsthost_exe_C_SRCS:.c=.o) \
			$(fsthost_exe_CXX_SRCS:.cpp=.o) \
			$(fsthost_exe_RC_SRCS:.rc=.res)

### Global source lists

C_SRCS                = $(fsthost_exe_C_SRCS)
CXX_SRCS              = $(fsthost_exe_CXX_SRCS)
RC_SRCS               = $(fsthost_exe_RC_SRCS)

### Tools

CC = gcc
CXX = g++
LINK = winegcc
RC = wrc
WINEBUILD = winebuild

### Generic targets

#all: hackheaders $(SUBDIRS) $(DLLS:%=%.so) $(EXES:%=%)
all: $(SUBDIRS) $(DLLS:%=%.so) $(EXES:%=%)

### Build rules

.PHONY: all clean dummy install

$(SUBDIRS): dummy
	@cd $@ && $(MAKE)

# Implicit rules

.SUFFIXES: .cpp .rc .res
DEFINCL = $(INCLUDE_PATH) $(DEFINES) $(OPTIONS)

.c.o:
	$(CC) -c $(CFLAGS) $(CEXTRA) $(DEFINCL) -o $@ $<

.cpp.o:
	$(CXX) -c $(CXXFLAGS) $(CXXEXTRA) $(DEFINCL) -o $@ $<

.cxx.o:
	$(CXX) -c $(CXXFLAGS) $(CXXEXTRA) $(DEFINCL) -o $@ $<

.rc.res:
	$(RC) $(RCFLAGS) $(RCEXTRA) $(DEFINCL) -fo$@ $<

# Rules for cleaning

CLEAN_FILES = *.dbg.c y.tab.c y.tab.h lex.yy.c core *.orig *.rej fsthost.exe* \\\#*\\\# *~ *% .\\\#*

clean:: $(SUBDIRS:%=%/__clean__) $(EXTRASUBDIRS:%=%/__clean__)
	$(RM) $(CLEAN_FILES) $(RC_SRCS:.rc=.res) $(C_SRCS:.c=.o) $(CXX_SRCS:.cpp=.o)
	$(RM) $(DLLS:%=%.dbg.o) $(DLLS:%=%.so)
	$(RM) $(EXES:%=%.dbg.o) $(EXES:%=%.so) $(EXES:%.exe=%)

install: $(fsthost_exe_MODULE)
	install -Dm 0644 fsthost.exe.so $(DESTDIR)$(LIB_INST_PATH)/fsthost.exe.so
	install -Dm 0755 fsthost $(DESTDIR)$(BIN_INST_PATH)/fsthost

$(SUBDIRS:%=%/__clean__): dummy
	cd `dirname $@` && $(MAKE) clean

$(EXTRASUBDIRS:%=%/__clean__): dummy
	-cd `dirname $@` && $(RM) $(CLEAN_FILES)

### Target specific build rules
DEFLIB = $(LIBRARY_PATH) $(LIBRARIES) $(DLL_PATH)

$(fsthost_exe_MODULE): $(fsthost_exe_OBJS)
	$(LINK) $(fsthost_exe_LDFLAGS) -o $@ $(fsthost_exe_OBJS) $(fsthost_exe_LIBRARY_PATH) $(DEFLIB) $(fsthost_exe_DLLS:%=-l%) $(fsthost_exe_LIBRARIES:%=-l%)
# Add support for WINE_RT
	sed -i -e '/^# determine the application directory/,/^esac/d' \
		-e 's/-n "$$appdir"/! -r "$$appname"/' \
		-e '3i \appdir="$(LIB_INST_PATH)"' \
		-e '3i \export WINE_RT=$${WINE_RT:-10}' \
		-e '3i \export WINE_SRV_RT=$${WINE_SRV_RT:-15}' $(fsthost_exe_MODULE).exe
# Cut extension from binary name
	mv $(fsthost_exe_MODULE).exe $(fsthost_exe_MODULE)
