include ../../makefile.in

FeapClientHelper.class: FeapClientHelper.java
	$(JAVAC) FeapClientHelper.java

clean:
	rm -f *~

realclean: clean
	rm -f FeapClientHelper.class
	rm -f `dsbweb -list feapjsock.m`

web:
	dsbweb -mb feapjsock.m
