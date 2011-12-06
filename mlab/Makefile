include ../makefile.in
.PHONY: web

jclient:
	(cd jsock; make)

cclient:
	(cd csock; make)

clean:
	rm -f fort.16 *~ web/*~
	(cd jsock; make clean)
	(cd csock; make clean)

realclean: clean
	rm -f `dsbweb -list web/feapgetset.m web/feapuser.m \
		web/feaputil.m web/feaps.m`
	(cd jsock; make realclean)
	(cd csock; make realclean)

web:
	dsbweb -mb web/feapgetset.m web/feapuser.m web/feaputil.m web/feaps.m
	(cd csock; make web)
	(cd jsock; make web)
