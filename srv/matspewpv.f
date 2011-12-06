c     @T
c     \section{FORTRAN sparse matrix output support}
c
c     The [[matspew]] command is based on the sparse matrix output
c     routine available at [[www.ce.berkeley.edu/~rlt/feap/umacr3.f]].
c     The [[matspew]] routine differs from the original routine
c     primarily in that it calls a function [[writeaij]] where the
c     original routine would write a coordinate triple to file.
c     The [[writeaij]] routine takes [[i]], [[j]], and [[Aij]],
c     but it also takes an additional argument that controls the precise
c     behavior of the routine -- if negative, it tells [[writeaij]]
c     to write binary or text data.  If the argument is non-negative,
c     [[writeaij]] writes no output, but increments the argument with
c     each call in order to compute the number of nonzeroes that would
c     be written.
c
c     The routine can output the following matrices:
c     \begin{itemize}
c       \item Tangent ([[tang]]) and unsymmetric tangent( [[utan]])
c       \item Consistent mass ([[mass]] or [[cmas]]), lumped mass
c          ([[lmas]]), or unsymmetric mass ([[umas]])
c       \item Consistent damping ([[damp]] or [[cdam]])
c          or unsymmetric damping ([[udam]])
c     \end{itemize}
c    
c     @c
      subroutine matspew(lct, cnt)
c     @q

c      * * F E A P * * A Finite Element Analysis Program

c....  Copyright (c) 1984-2003: Regents of the University of California
c                               All rights reserved

c-----[--.----+----.----+----.-----------------------------------------]
c      Purpose:  Output of arrays for use with Matlab sparse options.

c      Use:
c                Example:  Output of residual
c                     form
c                     output dr
c                Example:  Output of tangent
c                     tang,,-1
c                     output tang
c                Creates files with name 'dr' and 'tang'.
c                     Format: i  j  a(i,j)

c      Matlab use:
c                load dr
c                b = sparse(dr(:,1),dr(:,2),dr(:,3))
c                load tang
c                a = sparse(tang(:,1),tang(:,2),tang(:,3))
             
c      Inputs:
c         lct       - Command character parameters
c         cnt       - Count (if negative, do write)

c      Outputs:
c         To files with array name
c-----[--.----+----.----+----.-----------------------------------------]
      implicit   none

      include   'cdata.h'
      include   'compas.h'
      include   'iodata.h'
      include   'iofile.h'
c      include   'part0.h'
      include   'umac1.h'
      include   'pointer.h'
      include   'comblk.h'

      logical    pcomp
      character  lct*15,array*4
      integer    cnt

      save

c     Perform array outputs in Matlab sparse format

c       Get array name

        array = lct(1:4)

c       Tangent terms

        if(pcomp(array,'tang',4)) then
c          if(ittyp.eq.-1 .or. ittyp.eq.-2) then  ! Blocked or Sparse
c            if(max(abs(np(93)),abs(np(94)),abs(np(npart))).eq.0) then
c              go to 400
c            else
c              call ustang(neq,mr(np(93)),mr(np(94)),hr(np(npart)),cnt)
c            endif
c          elseif(ittyp.eq.-3) then               ! Profile
            if(max(abs(np(20+1)),abs(np(1))).eq.0) then
              go to 400
            else
              call uptang(neq,mr(np(20+1)),hr(np(1)),
     &                    hr(np(1)+neq), cnt)
c            endif
          endif
        elseif(pcomp(array,'utan',4)) then
c          if(ittyp.eq.-3) then               ! Profile
            if(max(abs(np(20+1)),abs(np(1)),
     &             abs(np(1+4))).eq.0) then
              go to 400
            else
              call uptang(neq,mr(np(20+1)),hr(np(1)),
     &                    hr(np(1+4)), cnt)
            endif
c          endif

c       Mass terms

        elseif(pcomp(array,'lmas',4)) then
          if(abs(np(1+12)).eq.0) then
            go to 400
          else
            call ulmass(neq,hr(np(1+12)), cnt)
          endif
        elseif(pcomp(array,'mass',4) .or. pcomp(array,'cmas',4)) then
          if(max(abs(np(90)),abs(np(91)),abs(np(1+8))).eq.0) then
            go to 400
          else
            call usmass(neq,mr(np(90)),mr(np(91)),hr(np(1+8)),2,cnt)
          endif
        elseif(pcomp(array,'umas',4)) then
          if(max(abs(np(90)),abs(np(91)),abs(np(1+8))).eq.0) then
            go to 400
          else
            call usmass(neq,mr(np(90)),mr(np(91)),hr(np(1+8)),3,cnt)
          endif

c       Damping terms

        elseif(pcomp(array,'damp',4) .or. pcomp(array,'cdam',4)) then
          if(max(abs(np(203)),abs(np(204)),abs(np(1+16))).eq.0) then
            go to 400
          else
            call usmass(neq,mr(np(203)),mr(np(204)),hr(np(1+16)),2,
     &                  cnt)
          endif
        elseif(pcomp(array,'udam',4)) then
          if(max(abs(np(203)),abs(np(204)),abs(np(1+16))).eq.0) then
            go to 400
          else
            call usmass(neq,mr(np(203)),mr(np(204)),hr(np(1+16)),3,
     &                  cnt)
          endif

c       Residual terms

        elseif(pcomp(array,'dr  ',2) .or. pcomp(array,'form',4)) then
          if(abs(np(26)).eq.0) then
            go to 400
          else
            call urform(neq,hr(np(26)),cnt)
          endif
        endif
      
      return

c     Error

400   write(iow,4000) array
c      write(ilg,4000) array
      if(ior.lt.0) then
        write(*,4000) array
      endif

c     format

4000  format(' *ERROR* Array ',a,' can not be output -- missing data'/)

      end

      subroutine uptang(neq,jp,ad, al, cnt)

c-----[--+---------+---------+---------+---------+---------+---------+-]
c     Purpose: Output of profile stored tangent

c     Inputs:
c        neq    - Number of equations
c        jp(*)  - Column pointers
c        ad(*)  - Diagonal and upper part of array
c        al(*)  - Lower part of array
c        cnt    - If positive, compute count rather than writing
c-----[--+---------+---------+---------+---------+---------+---------+-]
      implicit   none

      include   'iodata.h'

      integer    ii,i,j, neq,jp(*), cnt
      real*8     ad(*), al(*)

c     Output diagonal entries

      do i = 1,neq
        if(ad(i).ne.0.0d0) then
          call writeaij( i,i, ad(i), cnt )
        endif
      end do ! i

c     Output last entry if zero (helps Matlab size array)

      if(ad(neq).eq.0.0d0) then
        call writeaij( neq, neq, ad(neq), cnt )
      endif

c     Output off-diagonal entries

      do j = 2,neq
        ii = j - jp(j) + jp(j-1)
        do i = jp(j-1)+1,jp(j)
          if(ad(neq+i).ne.0.0d0) then
            call writeaij( ii,j,ad(neq+i), cnt )
          endif
          if(al(i).ne.0.0d0) then
            call writeaij( j,ii,al(i), cnt )
          endif
          ii = ii + 1
        end do ! i
      end do ! j

      end

      subroutine ustang(neq,ir,jc,ad, cnt)

c-----[--+---------+---------+---------+---------+---------+---------+-]
c     Purpose: Output of symmetric sparse stored tangent

c     Inputs:
c        neq    - Number of equations
c        ir(*)  - Row pointers
c        jc(*)  - Entries in each row
c        ad(*)  - Diagonal and upper part of array
c        cnt    - If positive, compute count rather than writing
c-----[--+---------+---------+---------+---------+---------+---------+-]
      implicit   none

      include   'iodata.h'

      integer    i1,i,j, neq,ir(*),jc(*), cnt
      real*8     ad(*)

      i1 = 1
      do i = 1,neq
        do j = i1,ir(i)
          if(ad(j).ne.0.0d0) then
            call writeaij( i,jc(j),ad(j), cnt )
            if(i.ne.jc(j)) then
              call writeaij( jc(j),i,ad(j), cnt )
            endif
          endif
        end do ! j
        i1 = ir(i) + 1
      end do ! i

      end

      subroutine ulmass(neq,ad,cnt)

c-----[--+---------+---------+---------+---------+---------+---------+-]
c     Purpose: Output of diagonal (lumped) mass

c     Inputs:
c        neq    - Number of equations
c        ad(*)  - Diagonal entries of mass
c        cnt    - If positive, compute count rather than writing
c-----[--+---------+---------+---------+---------+---------+---------+-]
      implicit   none

      include   'iodata.h'

      integer    i, neq, cnt
      real*8     ad(*)

      do i = 1,neq
        if(ad(i).ne.0.0d0) then
          call writeaij( i,i,ad(i), cnt )
        endif
      end do ! i

c     Output last entry if zero (helps Matlab size array)

      if(ad(neq).eq.0.0d0) then
        call writeaij( neq, neq, ad(neq), cnt )
      endif
        
      end

      subroutine usmass(neq,ir,jc,ad,isw, cnt)

c-----[--+---------+---------+---------+---------+---------+---------+-]
c     Purpose: Output of consistent mass/damping array (sparse)

c     Inputs:
c        neq    - Number of equations
c        ir(*)  - Row pointers
c        jc(*)  - Entries in each row
c        ad(*)  - Diagonal and upper part of array
c        isw    - Switch: 1 = diagonal; 2 = symmetric; 3 = unsymmetric
c        cnt    - If positive, compute count rather than writing
c-----[--+---------+---------+---------+---------+---------+---------+-]
      implicit   none

      include   'iodata.h'

      integer    isw,i1,i,j, neq,ir(*),jc(*), cnt
      real*8     ad(*)

c     Output diagonal entries

      do i = 1,neq
        if(ad(i).ne.0.0d0) then
          call writeaij( i,i,ad(i), cnt )
        endif
      end do ! i

c     Output the last element if it is zero (for Matlab dimensioning)

      if(ad(neq).eq.0.0d0) then
        call writeaij( neq,neq,ad(neq), cnt )
      endif

c     Output off-diagonal entries
        
      if(isw.ge.2) then
        i1 = 1
        do i = 1,neq
          do j = i1,ir(i)
            if(ad(j+neq).ne.0.0d0) then
              call writeaij( jc(j),i,ad(j+neq), cnt )
              if(isw.eq.2) then
                call writeaij( i,jc(j),ad(j+neq), cnt )
              endif
            endif
            if(isw.eq.3 .and. ad(j+neq+ir(neq)).ne.0.0d0) then
              if(i.ne.jc(j)) then
                call writeaij( i,jc(j),ad(j+neq+ir(neq)), cnt )
              endif
            endif
          end do ! j
          i1 = ir(i) + 1
        end do ! i
      endif

      end

      subroutine urform(neq,dr, cnt)

c-----[--+---------+---------+---------+---------+---------+---------+-]
c     Purpose: Output of residual vector

c     Inputs:
c        neq    - Number of equations
c        dr(*)  - Vector entries
c        cnt    - If positive, compute count rather than writing
c-----[--+---------+---------+---------+---------+---------+---------+-]
      implicit   none

      include   'iodata.h'

      integer    i,neq,cnt
      real*8     dr(*)

      do i = 1,neq
        if(dr(i).ne.0.0d0) then
          call writeaij( i, 1, dr(i), cnt )
        endif
      end do !

c     Output last entry if zero (helps Matlab size array)

      if(dr(neq).eq.0.0d0) then
        call writeaij( neq, 1, dr(neq), cnt )
      endif

      end
