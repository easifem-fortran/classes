! This program is a part of EASIFEM library
! Copyright (C) 2020-2021  Vikas Sharma, Ph.D
!
! This program is free software: you can redistribute it and/or modify
! it under the terms of the GNU General Public License as published by
! the Free Software Foundation, either version 3 of the License, or
! (at your option) any later version.
!
! This program is distributed in the hope that it will be useful,
! but WITHOUT ANY WARRANTY; without even the implied warranty of
! MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
! GNU General Public License for more details.
!
! You should have received a copy of the GNU General Public License
! along with this program.  If not, see <https: //www.gnu.org/licenses/>
!

SELECT CASE( TRIM(fmt) )
  CASE( "ASCII" )
  DO j=1, jj
    DO i=1, ii
      ans = ans // str(n=x(i, j)) &
        & // ' ' // str(n=y(i, j)) &
        & // ' ' // str(n=z(i, j))
    END DO
  END DO
  !>
  CASE( "BINARY" )
    CALL PACK_DATA( &
      & a1=[ INT(nbyte, I4B) ], &
      & a2=[((x(i,j), y(i,j), z(i,j), i=1, ii), j=1, jj)], packed=xp )
    CALL B64_ENCODE( n=xp, code=ans )
END SELECT