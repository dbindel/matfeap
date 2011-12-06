include makefile.in

server: dsbweb
	(cd srv; make)

jclient: dsbweb
	(cd mlab; make jclient)

cclient: dsbweb
	(cd mlab; make cclient)

web: dsbweb
	(cd mlab; make web)
	(cd doc; make web)

dsbweb:
	$(CC) -o dsbweb util/dsbweb.c

run:
	srv/feaps

clean:
	rm -f feapname fort.16 [LMO]block* *~
	(cd srv; make clean)
	(cd mlab; make clean)
	(cd example; make clean)
	(cd doc; make clean)

distclean: clean
	rm -f dsbweb
	(cd srv; make realclean)

realclean: clean
	(cd srv; make realclean)
	(cd mlab; make realclean)
	(cd doc; make realclean)
