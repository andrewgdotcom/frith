BINPREFIX = $(DESTDIR)/usr/bin

all: 
	echo

$(BINPREFIX):
	mkdir -p $@

install: all $(BINPREFIX)
	cp bin/frith $(BINPREFIX)/
	chmod 755 $(BINPREFIX)/frith

clean:
	echo
