c     @T
c     \section{Getting and setting scalars}
c
c     The [[feapget]] routine either reads a common block variable from
c     the standard input or writes a common block variable to the 
c     standard output, depending on whether the mode is [[r]] or [[w]].
c     If no such variable is available, the routine doesn't do anything.
c     The data is always sent in text format.
c
c     NOTE:  The FORTRAN [[read]] statement is not very smart, so if
c     the client tries to write a double value into an integer variable,
c     the FORTRAN I/O library is likely to complain and abort the program.
c
c     @c
      subroutine feapget(var, mode)
c     @q

      implicit  none

      include  'allotd.h'
      include  'allotn.h'
c      include  'auto2.h'
      include  'cdata.h'
      include  'codat.h'
      include  'comblk.h'
      include  'comfil.h'
      include  'conval.h'
      include  'counts.h'
      include  'eltran.h'
      include  'endata.h'
      include  'evdata.h'
      include  'fdata.h'
      include  'hdata.h'
      include  'hlpdat.h'
      include  'iodata.h'
      include  'iofile.h'
      include  'machnc.h'
      include  'pathn.h'
      include  'pdatps.h'
      include  'plflag.h'
      include  'pointer.h'
      include  'prmptd.h'
      include  'psize.h'
      include  'rdat1.h'
      include  'rdata.h'
      include  'sdata.h'
      include  'setups.h'
      include  'tdata.h'
      include  'vdata.h'
      include  'x11f.h'

      character var*8
      character mode*1
      logical pcomp

      save

      if (pcomp(mode,'r',1)) then
c        if (pcomp(var,'autcnv ',7)) write(*,*), autcnv
        if (pcomp(var,'dt ',3))     write(*,*), dt
        if (pcomp(var,'ior ',4))    write(*,*), ior
        if (pcomp(var,'iow ', 4))   write(*,*), iow
        if (pcomp(var,'ipr ', 4))   write(*,*), ipr
        if (pcomp(var,'mf ', 3))    write(*,*), mf
        if (pcomp(var,'mq ', 3))    write(*,*), mq
c        if (pcomp(var,'nadd ', 5))  write(*,*), nadd
        if (pcomp(var,'ndf ', 4))   write(*,*), ndf
c        if (pcomp(var,'ndl ', 4))   write(*,*), ndl
        if (pcomp(var,'ndm ', 4))   write(*,*), ndm
        if (pcomp(var,'nen ', 4))   write(*,*), nen
        if (pcomp(var,'neq ', 4))   write(*,*), neq
        if (pcomp(var,'nh1 ', 4))   write(*,*), nh1
        if (pcomp(var,'nh2 ', 4))   write(*,*), nh2
        if (pcomp(var,'nh3 ', 4))   write(*,*), nh3
        if (pcomp(var,'nneq ', 5))  write(*,*), nneq
c        if (pcomp(var,'nnlm ', 5))  write(*,*), nnlm
        if (pcomp(var,'nst ', 4))   write(*,*), nst
        if (pcomp(var,'numel ',6))  write(*,*), numel
        if (pcomp(var,'nummat ',7)) write(*,*), nummat
        if (pcomp(var,'numnp ',5))  write(*,*), numnp
        if (pcomp(var,'solver ',7)) write(*,*), solver
      else
c        if (pcomp(var,'autcnv ',7)) read(*,*), autcnv
        if (pcomp(var,'dt ',3))     read(*,*), dt
        if (pcomp(var,'ior ',4))    read(*,*), ior
        if (pcomp(var,'iow ', 4))   read(*,*), iow
        if (pcomp(var,'ipr ', 4))   read(*,*), ipr
        if (pcomp(var,'mf ', 3))    read(*,*), mf
        if (pcomp(var,'mq ', 3))    read(*,*), mq
c        if (pcomp(var,'nadd ', 5))  read(*,*), nadd
        if (pcomp(var,'ndf ', 4))   read(*,*), ndf
c        if (pcomp(var,'ndl ', 4))   read(*,*), ndl
        if (pcomp(var,'ndm ', 4))   read(*,*), ndm
        if (pcomp(var,'nen ', 4))   read(*,*), nen
        if (pcomp(var,'neq ', 4))   read(*,*), neq
        if (pcomp(var,'nh1 ', 4))   read(*,*), nh1
        if (pcomp(var,'nh2 ', 4))   read(*,*), nh2
        if (pcomp(var,'nh3 ', 4))   read(*,*), nh3
        if (pcomp(var,'nneq ', 5))  read(*,*), nneq
c        if (pcomp(var,'nnlm ', 5))  read(*,*), nnlm
        if (pcomp(var,'nst ', 4))   read(*,*), nst
        if (pcomp(var,'numel ',6))  read(*,*), numel
        if (pcomp(var,'nummat ',7)) read(*,*), nummat
        if (pcomp(var,'numnp ',5))  read(*,*), numnp
        if (pcomp(var,'solver ',7)) read(*,*), solver
      endif

      end
