# Makefile for Virtual Jaguar
#
# by James Hammons
# (C) 2011 Underground Software
#
# Note that we control the version information here--uncomment only one set of
# echo's from the "prepare" recipe. :-)
#

FIND = find

# Gah
OSTYPE := $(shell uname -a)

# Should catch both 'darwin' and 'darwin7.0'
ifeq "$(findstring Darwin,$(OSTYPE))" "Darwin"
QMAKE_EXTRA := -spec macx-g++
endif

# Eh?
CFLAGS ?= ""
CPPFLAGS ?= ""
CXXFLAGS ?= ""
LDFLAGS ?= ""

QMAKE_EXTRA += "QMAKE_CFLAGS_RELEASE=$(CFLAGS)"
QMAKE_EXTRA += "QMAKE_CXXFLAGS_RELEASE=$(CXXFLAGS)"
QMAKE_EXTRA += "QMAKE_LFLAGS_RELEASE=$(LDFLAGS)"

QMAKE_EXTRA += "QMAKE_CFLAGS_DEBUG=$(CFLAGS)"
QMAKE_EXTRA += "QMAKE_CXXFLAGS_DEBUG=$(CXXFLAGS)"
QMAKE_EXTRA += "QMAKE_LFLAGS_DEBUG=$(LDFLAGS)"


all: prepare virtualjaguar
	@echo -e "\033[01;33m***\033[00;32m Success!\033[00m"

obj:
	@mkdir obj

prepare: obj
	@echo -e "\033[01;33m***\033[00;32m Preparing to compile Virtual Jaguar...\033[00m"
#	@echo "#define VJ_RELEASE_VERSION \"v2.1.0\"" > src/version.h
#	@echo "#define VJ_RELEASE_SUBVERSION \"Final\"" >> src/version.h
	@echo "#define VJ_RELEASE_VERSION \"SVN `svn info | grep -i revision`\"" > src/version.h
	@echo "#define VJ_RELEASE_SUBVERSION \"2.1.0 Prerelease\"" >> src/version.h

virtualjaguar: sources libs makefile-qt
	@echo -e "\033[01;33m***\033[00;32m Making Virtual Jaguar GUI...\033[00m"
	$(MAKE) -f makefile-qt

makefile-qt: virtualjaguar.pro
	@echo -e "\033[01;33m***\033[00;32m Creating Qt makefile...\033[00m"
	qmake $(QMAKE_EXTRA) virtualjaguar.pro -o makefile-qt

#libs: obj/libmusashi.a obj/libjaguarcore.a
libs: obj/libm68k.a obj/libjaguarcore.a
	@echo -e "\033[01;33m***\033[00;32m Libraries successfully made.\033[00m"

obj/libm68k.a: src/m68000/Makefile sources
	@echo -e "\033[01;33m***\033[00;32m Making Customized UAE 68K Core...\033[00m"
#	@$(MAKE) -C src/m68000
	@$(MAKE) -C src/m68000 CFLAGS="$(CFLAGS)"
	@cp src/m68000/obj/libm68k.a obj/

obj/libmusashi.a: musashi.mak sources
	@echo -e "\033[01;33m***\033[00;32m Making Musashi...\033[00m"
	$(MAKE) -f musashi.mak

obj/libjaguarcore.a: jaguarcore.mak sources
	@echo -e "\033[01;33m***\033[00;32m Making Virtual Jaguar core...\033[00m"
#	$(MAKE) -f jaguarcore.mak
	$(MAKE) -f jaguarcore.mak CFLAGS="$(CFLAGS)" CXXFLAGS="$(CXXFLAGS)"

sources: src/*.h src/*.cpp src/*.c src/m68000/*.c src/m68000/*.h

clean:
	@echo -ne "\033[01;33m***\033[00;32m Cleaning out the garbage...\033[00m"
	@-rm -rf ./obj
	@-rm -rf ./src/m68000/obj
	@-rm -rf makefile-qt
	@-rm -rf virtualjaguar
	@-$(FIND) . -name "*~" -exec rm -f {} \;
	@echo "done!"

statistics:
	@echo -n "Lines in source files: "
	@-$(FIND) ./src -name "*.cpp" | xargs cat | wc -l
	@echo -n "Lines in header files: "
	@-$(FIND) ./src -name "*.h" | xargs cat | wc -l

dist:	clean
