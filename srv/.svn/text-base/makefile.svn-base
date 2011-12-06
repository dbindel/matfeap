include ../makefile.in
include $(FEAPHOME)/makefile.in

PLSTOP = $(FEAPHOME)/unix/plstop.f
VER7 = feapgetm7.o feapsetm7.o
VER8 = feapgetm.o feapsetm.o
OBJECTS = feap.o feapsrv.o \
	servparam.o filnam.o cleannam.o plstop.o umacr1.o \
	feapget$(MFEAPPV).o $(MFEAPVER) matspew$(MFEAPPV).o \
	feaptformed.o tinput.o tinput2.o \
	$(MY_OBJECTS)

all: feaps feapp

feaps: $(OBJECTS) feapsock.o
	$(FF) -o feaps $(OBJECTS) feapsock.o $(ARFEAP) $(LDOPTIONS)

feapp: $(OBJECTS) feappipe.o
	$(FF) -o feapp $(OBJECTS) feappipe.o $(ARFEAP) $(LDOPTIONS)

.f.o:
	$(FF) -c $(FFOPTFLAG) -I$(FINCLUDE) $*.f -o $*.o

.c.o:
	$(CC) -c $(CCOPTFLAG)  $*.c -o $*.o

clean:
	rm -f *.o *~ fort.16 filnam.f feap.f plstop.f tinput2.f

realclean: clean
	rm -f feapp feaps 

check:
	echo $(FINCLUDE)

#################################################################
#@T
# \section{Generated files}
#
# We mostly augment FEAP by adding new files, but there are a few minor
# changes that we have to make to the existing files as well.  Because
# MATFEAP is supposed to work with different versions of FEAP, and because
# some of the files we need to modify vary between FEAP versions, we
# automatically rewrite the FEAP sources with scripts, rather than trying
# to come up with a one or more modified routine that will be compatible with
# all the relevant versions.
#
# The most obvious change is to the FEAP front-end routine.  We add calls
# to [[feapserver]] (to start the socket server) and to [[feapsrv]]
# (so that the user can set parameters, change directories, etc. before
# entering filenames and processing the input file.
#
#@c

feap.f: $(FEAPMAIN)
	$(AWK) ' \
	/call pstart/ { \
	  print "      call feapserver()"; \
	  print "      call feapsrv()" } \
	{ print }' $(FEAPMAIN) > feap.f

#@T
# FEAP calls the [[plstop]] routine to close files, clear memory, and
# otherwise clean up before exiting.  It causes problems on some systems
# to close the socket connection before FEAP finishes writing whatever
# it will to the standard output, so we add a synchronization call at
# the very end of [[plstop]], just before the true exit.
#
#@c
plstop.f: $(PLSTOP)
	$(AWK) ' \
	/^[ ]*stop/ { print "      call feapsync(1)" } \
	{ print }' $(PLSTOP) > plstop.f

#@T
# The [[filnam]] routine, which reads in file names from the standard
# input, requires four modifications:
# \begin{enumerate}
# \item  We need to make sure that
#   [[filnam]] doesn't decide to use the default file names saved in the
#   [[feapname]] file (which is what the ordinary FEAP routine does).
#   So we strategically insert the statement [[lfil = .false.]] (indicating
#   that there's no [[feapname]] to read) immediately before where FEAP
#   tests [[lfil]].  
# \item   We add initialization routines for the
#   various filename variables, fixing a bug in FEAP that would otherwise
#   cause the program to go into a tailspin if we tried to quit rather than
#   entering filenames.  
# \item  We make a call to [[cleannam]] to turn any
#   carriage returns and line feeds received by FEAP into ordinary spaces
#   (it's unclear to me why these characters show up when I send the data
#   over a socket and not over the terminal, but it seems that they do).
# \item   We add a call to [[feapsync]] before each
#   read, so that the client will know when it's supposed to provide input.
# \end{enumerate}
#
#@c
filnam.f:
	$(AWK) ' \
	/if\(lfil\) then/          { print "      lfil = .false."; init = 1 } \
	init == 1 && /^      else/ { init = 2 } \
	init == 2 && /^[ ]*p/      { print; sub(/ p/, " f") } \
	init == 2 && /^[ ]*end/    { init = 0 } \
	/^[0-9 \t]*read/           { print "      call feapsync(0)" } \
	/.not.pcomp\(filein/       { print "      call cleannam(filein)" }  \
	{ print }' $(FEAPHOME)/program/filnam.f > filnam.f

#@T
# The [[tinput]] routine mediates most (though not all) of 
# FEAP's standard input.  Prior to version 8.0, [[tinput]] was in the
# program subdirectory.  Since 8.0, there has been a special UNIX version
# of [[tinput]] that uses a [[select]] loop to keep X11 plots up to
# date while waiting for user input at the console.  We just need to
# find the version that's appropriate, copy it to the local directory,
# and rename it to [[tinput2]].  We have our own version of [[tinput]]
# that will call [[tinput2]] and then call [[feapsync]] to allow
# the client to synchronize with the server.
#@c
tinput2.f: 
	if grep "function tinput" $(FEAPHOME)/program/*.f > /dev/null ; \
		then cp $(FEAPHOME)/program/tinput.f tinput0.f ; \
		else cp $(FEAPHOME)/unix/tinput.f tinput0.f ; \
		fi
	$(AWK) '{ gsub(/tinput/, "tinput2"); print }' tinput0.f > tinput2.f
	rm tinput0.f

