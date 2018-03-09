BINPREFIX = $(DESTDIR)/usr/bin
LIBPREFIX = $(DESTDIR)/usr/lib/frith

all: 
	echo

$(BINPREFIX) $(LIBPREFIX):
	mkdir -p $@

install: all $(BINPREFIX) $(LIBPREFIX)
	cp bin/frith $(BINPREFIX)/
	chmod 755 $(BINPREFIX)/frith
	cp frith-install.sh $(LIBPREFIX)/
	chmod 755 $(LIBPREFIX)/frith-install.sh

clean:
	echo
