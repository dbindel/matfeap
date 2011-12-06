c     @T
c     \section{Receiving matrices}
c
c     The [[feapsetm]] command is exactly analogous to [[feapgetm]],
c     except that it receives data from the client using [[feaprecvint]]
c     and [[feaprecvdbl]] where [[feapgetm]] sends data. 
c
c     @c
      subroutine feapsetm(var)
c     @q

      implicit  none

      include 'comblk.h'
      include 'pointer.h'
      include 'p_point.h'

      character var*(*)
      logical flag
      integer lengt, prec

      save

      call pgetd( var, point, lengt, prec, flag )
      if(flag) then
        if(prec.eq.1) then
          call fmrecvint(mr(point), lengt)
        else
          call fmrecvdbl(hr(point), lengt)
        endif
      else
        print *, 'Not found'
      endif

      end
