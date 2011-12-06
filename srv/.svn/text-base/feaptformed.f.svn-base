c     @T
c     \section{Clearing the solution flag}
c
c     The FEAP common block flag [[fl(8)]] is used to keep track of
c     whether or not the residual has been formed since the last [[solv]]
c     call.  If it has already been formed, there's no reason to form it
c     again.  But when we do a calculation on MATLAB and directly write
c     to the FEAP vectors containing the current state, whatever residual
c     might be in FEAP's memory is invalidated.  We therefore use 
c     [[feaptformed]] to clear the value of [[fl(8)]] so that FEAP
c     will know when such an event has happened.
c
c     @c
      subroutine feaptformed()

      implicit  none

      include  'fdata.h'

      save

      fl(8) = .false.

      end
