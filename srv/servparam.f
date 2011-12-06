c     @T
c     \section{Parameter input}
c
c     The [[servparam]] routine writes directly into the FEAP common
c     block used for parameters.  This prevents us from dealing with
c     some of the peculiarities of [[pconst()]].
c
c     @c
      subroutine servparam(id1, id2, val)
c     @q

      implicit  none

      include 'conval.h'

      integer id1
      integer id2
      real*8 val

      vvv(id1,id2) = val

      end
