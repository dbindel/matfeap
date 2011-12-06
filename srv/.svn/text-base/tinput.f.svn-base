c     @T
c     \section{Adding synchronization on input}
c
c     We have our own version of the input routine [[tinput]],
c     which mediates most of the console input in FEAP.  Our version
c     calls [[feapsync]] to allow the client to sync up with the
c     server, then calls [[tinput2]], which is generated from the
c     ordinary [[tinput]] routine in FEAP.
c
c     @c
      logical function tinput(tx,mt,d,nn)

      include  'iofile.h'

      logical   tinput2
      integer   mt,nn,bnum
      character tx(*)*15
      real*8    d(*)

      save

      if(ior.lt.0) then
        bnum = 0
        call feapsync(bnum)
      end if
      tinput = tinput2(tx,mt,d,nn)

      end
