include makefile.in

server:
	(cd srv; make)

jclient:
	(cd mlab; make jclient)

cclient:
	(cd mlab; make cclient)

web:
	(cd mlab; make web)
	(cd doc; make web)

run:
	srv/feaps

clean:
	rm -f feapname fort.16 [LMO]block* *~
	(cd srv; make clean)
	(cd mlab; make clean)
	(cd example; make clean)
	(cd doc; make clean)

distclean: clean
	(cd srv; make realclean)

realclean: clean
	(cd srv; make realclean)
	(cd mlab; make realclean)
	(cd doc; make realclean)
