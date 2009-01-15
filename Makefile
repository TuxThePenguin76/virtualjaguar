#
# Unified Makefile for Virtual Jaguar GCC/SDL Portable Jaguar Emulator
#
# by James L. Hammons
#
# This software is licensed under the GPL v2 or any later version. Set the
# file GPL.TXT for details. ;-)
#

# NOTE: zlib and OpenGL libs are a dependency, but are not checked for.
#       same goes for libcdio

# Figure out which system we're compiling for, and set the appropriate variables

ifeq "$(OSTYPE)" "msys"							# Win32

SYSTYPE    = __GCCWIN32__
EXESUFFIX  = .exe
GLLIB      = -lopengl32
ICON       = obj/icon.o
SDLLIBTYPE = --libs
MSG        = Win32 on MinGW

else
#ifeq "$(OSTYPE)" "darwin"
ifeq "darwin" "$(findstring darwin,$(OSTYPE))"	# Should catch both 'darwin' and 'darwin7.0'

SYSTYPE    = __GCCUNIX__ -D_OSX_
EXESUFFIX  =
GLLIB      =
ICON       =
SDLLIBTYPE = --static-libs
MSG        = Mac OS X

else											# *nix

SYSTYPE    = __GCCUNIX__
EXESUFFIX  =
GLLIB      = -lGL
ICON       =
SDLLIBTYPE = --libs
MSG        = generic Unix/Linux

endif
endif

CC         = gcc
LD         = gcc
TARGET     = vj

# Note that we use optimization level 2 instead of 3--3 doesn't seem to gain much over 2
CFLAGS   = -MMD -Wall -Wno-switch -O2 -D$(SYSTYPE) -ffast-math -fomit-frame-pointer `sdl-config --cflags`
CPPFLAGS = -MMD -Wall -Wno-switch -Wno-non-virtual-dtor -O2 -D$(SYSTYPE) \
		-DHAVE_LIB_CDIO -ffast-math -fomit-frame-pointer `sdl-config --cflags` -g
#		-fomit-frame-pointer `sdl-config --cflags` -g
#		-fomit-frame-pointer `sdl-config --cflags` -DLOG_UNMAPPED_MEMORY_ACCESSES

LDFLAGS =

LIBS = -L/usr/local/lib -L/usr/lib `sdl-config $(SDLLIBTYPE)` -lstdc++ -lz $(GLLIB) -lcdio
# Comment out the above and uncomment below if you don't have libcdio.
# Also, remove the "-DHAVE_LIB_CDIO" from CPPFLAGS above.
#LIBS = -L/usr/local/lib -L/usr/lib `sdl-config $(SDLLIBTYPE)` -lstdc++ -lz $(GLLIB)

INCS = -I. -I./src -I./src/gui -I/usr/local/include -I/usr/include

OBJS = \
	obj/m68kcpu.o       \
	obj/m68kops.o       \
	obj/m68kopac.o      \
	obj/m68kopdm.o      \
	obj/m68kopnz.o      \
	obj/m68kdasm.o      \
\
	obj/button.o        \
	obj/element.o       \
	obj/filelist.o      \
	obj/gui.o           \
	obj/guimisc.o       \
	obj/image.o         \
	obj/listbox.o       \
	obj/menu.o          \
	obj/pushbutton.o    \
	obj/slideswitch.o   \
	obj/text.o          \
	obj/textedit.o      \
	obj/window.o        \
\
	obj/blitter.o       \
	obj/cdrom.o         \
	obj/cdintf.o        \
	obj/crc32.o         \
	obj/dac.o           \
	obj/dsp.o           \
	obj/eeprom.o        \
	obj/event.o         \
	obj/file.o          \
	obj/gpu.o           \
	obj/jagdasm.o       \
	obj/jaguar.o        \
	obj/jerry.o         \
	obj/joystick.o      \
	obj/log.o           \
	obj/memory.o        \
	obj/objectp.o       \
	obj/sdlemu_config.o \
	obj/sdlemu_opengl.o \
	obj/settings.o      \
	obj/state.o         \
	obj/tom.o           \
	obj/unzip.o         \
	obj/video.o         \
	obj/vj.o            \
	$(ICON)

all: checkenv message obj $(TARGET)$(EXESUFFIX)
	@echo
	@echo -e "\033[01;33m***\033[00;32m Looks like it compiled OK... Give it a whirl!\033[00m"

# Check the compilation environment, barf if not appropriate

checkenv:
	@echo
	@echo -en "\033[01;33m***\033[00;32m Checking compilation environment... \033[00m"
ifeq "" "$(shell which sdl-config)"
	@echo
	@echo
	@echo -e "\033[01;33mIt seems that you don't have the SDL development libraries installed. If you"
	@echo -e "have installed them, make sure that the sdl-config file is somewhere in your"
	@echo -e "path and is executable.\033[00m"
	@echo
#Is there a better way to break out of the makefile?
	@breaky
else
	@echo -e "\033[01;37mOK\033[00m"
endif
# !!! NOTE !!! Need to put a check here for libcdio, GL, zlib

message:
	@echo
	@echo -e "\033[01;33m***\033[00;32m Building Virtual Jaguar for $(MSG)...\033[00m"
	@echo

clean:
	@echo -en "\033[01;33m***\033[00;32m Cleaning out the garbage...\033[00m"
	@rm -rf obj
	@rm -f ./$(TARGET)$(EXESUFFIX)
	@echo -e "\033[01;37mdone!\033[00m"

obj:
	@mkdir obj

# This is only done for Win32 at the moment...

ifneq "" "$(ICON)"
$(ICON): res/$(TARGET).rc res/$(TARGET).ico
	@echo -e "\033[01;33m***\033[00;32m Processing icon...\033[00m"
	@windres -i res/$(TARGET).rc -o $(ICON) --include-dir=./res
endif

obj/%.o: src/%.c
	@echo -e "\033[01;33m***\033[00;32m Compiling $<...\033[00m"
	@$(CC) $(CFLAGS) $(INCS) -c $< -o $@

obj/%.o: src/%.cpp
	@echo -e "\033[01;33m***\033[00;32m Compiling $<...\033[00m"
	@$(CC) $(CPPFLAGS) $(INCS) -c $< -o $@

obj/%.o: src/gui/%.cpp
	@echo -e "\033[01;33m***\033[00;32m Compiling $<...\033[00m"
	@$(CC) $(CPPFLAGS) $(INCS) -c $< -o $@

$(TARGET)$(EXESUFFIX): $(OBJS)
	@echo -e "\033[01;33m***\033[00;32m Linking it all together...\033[00m"
	@$(LD) $(LDFLAGS) -o $@ $(OBJS) $(LIBS)
#	strip --strip-all vj$(EXESUFFIX)
#	upx -9 vj$(EXESUFFIX)

# Pull in dependencies autogenerated by gcc's -MMD switch
# The "-" in front is there just in case they haven't been created yet

-include obj/*.d

#
# Musashi specific stuffola
#

#obj/m68k%.o: obj/m68k%.c obj/m68kops.h
#	$(CC) $(CFLAGS) -Iobj -c src/m68k%.c -o obj/m68k%.o

#obj/m68k%.o: obj/m68k%.c obj/m68kmake$(EXESUFFIX)
#	$(CC) $(CFLAGS) -Iobj -c src/m68k%.c -o obj/m68k%.o

#see if you can collapse all this crap into one or two lines...
#NOTE: The above doesn't work for some reason...

obj/m68kcpu.o: obj/m68kops.h src/m68k.h src/m68kconf.h
	@echo -e "\033[01;33m***\033[00;32m Compiling m68kcpu.c...\033[00m"
	@$(CC) $(CFLAGS) -Iobj -c src/m68kcpu.c -o obj/m68kcpu.o

obj/m68kops.o: obj/m68kmake$(EXESUFFIX) obj/m68kops.h obj/m68kops.c src/m68k.h src/m68kconf.h
	@echo -e "\033[01;33m***\033[00;32m Compiling m68kops.c...\033[00m"
	@$(CC) $(CFLAGS) -Isrc -c obj/m68kops.c -o obj/m68kops.o

obj/m68kopac.o: obj/m68kmake$(EXESUFFIX) obj/m68kops.h obj/m68kopac.c src/m68k.h src/m68kconf.h
	@echo -e "\033[01;33m***\033[00;32m Compiling m68kopac.c...\033[00m"
	@$(CC) $(CFLAGS) -Isrc -c obj/m68kopac.c -o obj/m68kopac.o

obj/m68kopdm.o: obj/m68kmake$(EXESUFFIX) obj/m68kops.h obj/m68kopdm.c src/m68k.h src/m68kconf.h
	@echo -e "\033[01;33m***\033[00;32m Compiling m68kopdm.c...\033[00m"
	@$(CC) $(CFLAGS) -Isrc -c obj/m68kopdm.c -o obj/m68kopdm.o

obj/m68kopnz.o: obj/m68kmake$(EXESUFFIX) obj/m68kops.h obj/m68kopnz.c src/m68k.h src/m68kconf.h
	@echo -e "\033[01;33m***\033[00;32m Compiling m68kopnz.c...\033[00m"
	@$(CC) $(CFLAGS) -Isrc -c obj/m68kopnz.c -o obj/m68kopnz.o

obj/m68kdasm.o: src/m68kdasm.c src/m68k.h src/m68kconf.h
	@echo -e "\033[01;33m***\033[00;32m Compiling m68kdasm.c...\033[00m"
	@$(CC) $(CFLAGS) -Isrc -c src/m68kdasm.c -o obj/m68kdasm.o

obj/m68kops.h: obj/m68kmake$(EXESUFFIX)
	@obj/m68kmake obj src/m68k_in.c

obj/m68kmake$(EXESUFFIX): src/m68kmake.c src/m68k_in.c
	@echo -e "\033[01;33m***\033[00;32m Preparing to make the Musashi core...\033[00m"
	@$(CC) $(WARNINGS) src/m68kmake.c -o obj/m68kmake$(EXESUFFIX)
