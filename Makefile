BINPREFIX = $(DESTDIR)/usr/bin
LIBPREFIX = $(DESTDIR)/usr/lib/frith

all:
	echo

$(BINPREFIX) $(LIBPREFIX):
	mkdir -p $@

install: all $(BINPREFIX) $(LIBPREFIX)
	cp bin/frith $(BINPREFIX)/
	chmod 755 $(BINPREFIX)/frith

clean:
	echo
