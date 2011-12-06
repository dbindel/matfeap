all: matfeap.pdf matfeap-notes.pdf

matfeap.pdf: matfeap.tex
	pdflatex matfeap.tex

matfeap-notes.pdf: matfeap-notes.tex
	pdflatex matfeap-notes.tex
	pdflatex matfeap-notes.tex

force:
	pdflatex matfeap-notes.tex
	pdflatex matfeap.tex

web:
	dsbweb -o feapsock.tex ../srv/feapsock.c
	dsbweb -o feapsrv.tex  ../srv/feapsrv.c
	dsbweb -o feapfort.tex \
		../srv/tinput.f \
		../srv/feapget.f \
		../srv/feapgetm.f \
		../srv/feapsetm.f \
		../srv/matspew.f \
		../srv/feaptformed.f \
		../srv/umacr1.f \
		../srv/makefile
	dsbweb -o feapmlab.tex -m \
		../mlab/jsock/feapjsock.m \
		../mlab/csock/feapcsock.mw \
		../mlab/web/feaps.m \
		../mlab/feapstart.m \
		../mlab/web/feapuser.m \
		../mlab/web/feapgetset.m \
		../mlab/web/feaputil.m 
	dsbweb -o feapinit.tex \
		../matfeap_init.m
	dsbweb -o feapex1.tex \
		../example/solve1.m

clean:
	rm -f *.aux *.idx *.log *.toc *~

realclean: clean
	rm -f feap*.tex matfeap.pdf matfeap-notes.pdf
