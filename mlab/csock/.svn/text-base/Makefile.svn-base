include ../../makefile.in

mex: csockmex.c matsock.c matsock.h
	$(MEX) csockmex.c matsock.c

clean:
	rm -f *~ csockmex.mex*

realclean: clean
	rm -f csockmex.c *.m

csockmex.c: 
	mwrap -mb -mex csockmex -c csockmex.c feapcsock.mw

web:
	mwrap -mb -mex csockmex -c csockmex.c feapcsock.mw
