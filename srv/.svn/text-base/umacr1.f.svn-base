c     @T
c     \section{The FEAP dispatch macro}
c
c     The FEAP user macro [[serv]] plays two roles.  If called with
c     a positive integer argument (e.g. [[serv,,1]]), FEAP will call
c     [[feapsync]] to output a string that the MATLAB client can
c     use for synchronization.  Otherwise, FEAP will call the [[feapsrv]]
c     dispatcher routine, which allows the MATLAB client to access most of
c     the MATFEAP-specific functionality available.
c
c     @c
      subroutine umacr1(lct,ctl,prt)

c      * * F E A P * * A Finite Element Analysis Program

c....  Copyright (c) 1984-2006: Regents of the University of California
c                               All rights reserved

c-----[--.----+----.----+----.-----------------------------------------]
c     Modification log                                Date (dd/mm/year)
c       Original version                                    01/11/2006
c-----[--.----+----.----+----.-----------------------------------------]
c      Purpose:  User interface for adding solution command language
c                instructions.

c      Inputs:
c         lct       - Command character parameters
c         ctl(3)    - Command numerical parameters
c         prt       - Flag, output if true

c      Outputs:
c         N.B.  Users are responsible for command actions.  See
c               programmers manual for example.
c-----[--.----+----.----+----.-----------------------------------------]
      implicit  none

      include  'iofile.h'
      include  'umac1.h'

      logical   pcomp,prt
      character lct*15
      real*8    ctl(3)
      integer   ival

      save

c     Set command word

      if(pcomp(uct,'mac1',4)) then      ! Usual    form
        uct = 'serv'                    ! Specify 'name'
      elseif(urest.eq.1) then           ! Read  restart data

      elseif(urest.eq.2) then           ! Write restart data

      else                              ! Perform user operation
        ival = ctl(1)
        if(ival.gt.0) then
          call feapsync(ival)
        else
          call feapsrv()
        endif
      endif

      end
