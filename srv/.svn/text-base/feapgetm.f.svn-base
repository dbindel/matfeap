c     @T
c     \section{Sending matrices}
c
c     The [[feapgetm(var)]] command fetches the named array from
c     FEAP's dynamic memory system using [[pgetd]].   If the array
c     is found, [[feapgetm]] calls [[feapsendint]] or [[feapsenddbl]]
c     in order to return the data to the client.  Otherwise, it prints
c     a ``Not found'' message.
c
c     There are two variants of this routine.  The code below works with
c     newer versions of FEAP (8.0+) in which the [[p_point.h]] header
c     declares an integer variable capable of storing a FEAP pointer.
c     The code in [[feapgetm7.f]] works with earlier versions of FEAP
c     in which pointers are always represented as 32-bit integers.
c
c     @c
      subroutine feapgetm(var)

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
          call fmsendint(mr(point), lengt)
        else
          call fmsenddbl(hr(point), lengt)
        endif
      else
        print *, 'Not found'
      endif

      end
