DPKG_DEST = ~/build
PREFIX = $(DPKG_DEST)/frith

BINPREFIX = $(PREFIX)/usr/bin
LIBPREFIX = $(PREFIX)/var/lib/frith
SKEL = $(LIBPREFIX)/skel

all: 
	echo

$(BINPREFIX) $(LIBPREFIX) $(SKEL):
	sudo mkdir -p $@

install: all $(BINPREFIX) $(LIBPREFIX) $(SKEL)
	sudo cp bin/frith $(BINPREFIX)/
	sudo chmod 755 $(BINPREFIX)/frith
	sudo cp -R skel/* $(SKEL)/
	sudo chmod 600 $(SKEL)/live-additional-software.conf $(SKEL)/persistence.conf

clean:
	echo

deb: install
	vi DEBIAN/control
	sudo cp -R DEBIAN $(PREFIX)/
	sudo dpkg-deb --build $(PREFIX) $(DPKG_DEST)

deb-clean: clean
	sudo rm -rf $(BINPREFIX)/frith $(SKEL)

