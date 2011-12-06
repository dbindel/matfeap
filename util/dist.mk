all: dist

# === Version information ===

VERS=0.8
MATFEAP=matfeap-$(VERS)

include makefile.in
include Makefile

# === Tar / distribution targets ===

SRC=\
	Makefile README INSTALL NEWS matfeap_init.m makefile.in.ex \
	example/Makefile example/I* example/*.m \
	mlab/Makefile mlab/*.m mlab/web/*.m \
	mlab/jsock/Makefile \
	mlab/jsock/*.java mlab/jsock/*.class mlab/jsock/*.m \
	mlab/csock/Makefile mlab/csock/*.m mlab/csock/*.mw \
	mlab/csock/*.h mlab/csock/*.c \
	srv/makefile srv/feapu srv/feapu-vg srv/*f srv/*.c \
	doc/Makefile doc/*.tex doc/*.pdf

matfeap.pdf: doc/matfeap.tex
	(cd doc; make matfeap.pdf; cp matfeap.pdf ..)

dist: tgz

tgz: $(MATFEAP).tar.gz

$(MATFEAP).tar.gz: clean doc/matfeap.pdf README INSTALL
	ls $(SRC) | sed s:^:$(MATFEAP)/: >MANIFEST
	(ln -s `pwd` ../$(MATFEAP))
	(cd ..; tar -czvf $(MATFEAP).tar.gz `cat $(MATFEAP)/MANIFEST`)
	(cd ..; rm $(MATFEAP))

webby: dist
	cp ../$(MATFEAP).tar.gz  ~/work/webby/content/sw/matfeap
	cp doc/matfeap.pdf       ~/work/webby/content/sw/matfeap
	cp doc/matfeap-notes.pdf ~/work/webby/content/sw/matfeap

