      subroutine cleannam(s)

      implicit  none

      integer i
      character s*128

      do i=1,128
        if ((ichar(s(i:i)).eq.13).or.(ichar(s(i:i)).eq.10)) then
          s(i:i) = ' '
        end if
      end do

      end
