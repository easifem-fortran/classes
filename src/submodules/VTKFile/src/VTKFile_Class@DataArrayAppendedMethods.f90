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

SUBMODULE( VTKFile_Class ) DataArrayAppendedMethods
USE BaseMethod
IMPLICIT NONE
CONTAINS


!----------------------------------------------------------------------------
!                                                           WriteDataArray
!----------------------------------------------------------------------------

MODULE PROCEDURE VTKFile_WriteDataArray_Appended
  CHARACTER( LEN = * ), PARAMETER :: myName="VTKFile_WriteDataArray_Appended"
  TYPE( String ) :: name, names( 1 ), values( 1 )
  INTEGER( I4B ) :: iostat, nByte, dataarray_dim
  CHARACTER( LEN=2 ) :: dataarray_type
  REAL( Real64 ),    ALLOCATABLE :: dataarray_R8P(:)
  REAL( Real32 ),    ALLOCATABLE :: dataarray_R4P(:)
#ifdef USE_Int64
  INTEGER( Int64 ), ALLOCATABLE :: dataarray_I8P(:)
#endif
  INTEGER( Int32 ), ALLOCATABLE :: dataarray_I4P(:)
  INTEGER( Int16 ), ALLOCATABLE :: dataarray_I2P(:)
  INTEGER( int8 ), ALLOCATABLE :: dataarray_I1P(:)
  !> main
  SELECT CASE( obj%DataFormat )
  CASE( VTK_APPENDED )
    name = "AppendedData"
    names( 1 ) = "encoding"
    values( 1 ) = '"' // TRIM(obj%encoding4Appended%chars()) // '"'
    CALL obj%WriteStartTag( name=name, attrNames=names, attrValues=values )
    WRITE(unit=obj%unitNo, fmt="(A)", iostat=iostat) '_'
    ENDFILE(unit=obj%scratch, iostat=iostat )
    REWIND(unit=obj%scratch, iostat=iostat )
    DO
      CALL read_dataarray_from_scratch
      IF( iostat .EQ. 0 ) CALL write_dataarray_on_xml
      IF( IS_IOSTAT_END( iostat ) ) EXIT
    END DO
    CLOSE( unit=obj%scratch, iostat=iostat )
    WRITE( unit=obj%unitNo, iostat=iostat ) CHAR_LF
    CALL obj%WriteEndTag( name=name )
  END SELECT

  CONTAINS
  !---------------------------------------------------------------------
  !
  !---------------------------------------------------------------------

  SUBROUTINE read_dataarray_from_scratch
    !< Read the current dataaray from scratch file.
    READ(unit=obj%scratch, iostat=iostat, end=10)nByte, dataarray_type, &
      & dataarray_dim
    !> select case
    SELECT CASE(dataarray_type)
    CASE('R8')
      IF( ALLOCATED( dataarray_R8P ) ) DEALLOCATE( dataarray_R8P )
      ALLOCATE( dataarray_R8P(1:dataarray_dim) )
      READ(unit=obj%scratch, iostat=iostat) dataarray_R8P

    CASE('R4')
      IF( ALLOCATED(dataarray_R4P) ) DEALLOCATE(dataarray_R4P)
      ALLOCATE( dataarray_R4P(1:dataarray_dim) )
      READ( unit=obj%scratch, iostat=iostat ) dataarray_R4P

#ifdef USE_Int64
    CASE( 'I8' )
      IF( ALLOCATED(dataarray_I8P) ) DEALLOCATE(dataarray_I8P)
      ALLOCATE( dataarray_I8P(1:dataarray_dim) )
      READ( unit=obj%scratch, iostat=iostat ) dataarray_I8P
#endif

    CASE('I4')
      IF( ALLOCATED(dataarray_I4P) ) DEALLOCATE(dataarray_I4P)
      ALLOCATE(dataarray_I4P(1:dataarray_dim))
      READ( unit=obj%scratch, iostat=iostat ) dataarray_I4P

    CASE('I2')
      IF( ALLOCATED(dataarray_I2P)) DEALLOCATE(dataarray_I2P)
      ALLOCATE(dataarray_I2P(1:dataarray_dim))
      READ( unit=obj%scratch, iostat=iostat )dataarray_I2P

    CASE('I1')
      IF( ALLOCATED(dataarray_I1P)) DEALLOCATE(dataarray_I1P)
      ALLOCATE(dataarray_I1P(1:dataarray_dim))
      READ( unit=obj%scratch, iostat=iostat ) dataarray_I1P

    CASE DEFAULT
      iostat = 1
      CALL e%raiseError(modName//'::'//myName// &
      & ' - Bad dataarray_type = ' // dataarray_type // &
        & ' bytes = ' // TRIM( str(nByte, .true.) ) // &
        & ' dataarray dimension = ' // TRIM( str(dataarray_dim, .true.)))

    END SELECT
    10 RETURN
  END SUBROUTINE read_dataarray_from_scratch

  !----------------------------------------------------------------------
  !
  !----------------------------------------------------------------------

  SUBROUTINE write_dataarray_on_xml
    !< Write the current dataaray on xml file.
    character(len=:), allocatable  :: content

    IF (obj%encoding4Appended .EQ. 'raw') THEN
      SELECT CASE( dataarray_type )
      CASE('R8')
        WRITE( unit=obj%unitNo, iostat=iostat )nByte, dataarray_R8P
        DEALLOCATE(dataarray_R8P)
      CASE('R4')
        WRITE(unit=obj%unitNo, iostat=iostat )nByte, dataarray_R4P
        DEALLOCATE(dataarray_R4P)
#ifdef USE_Int64
      CASE('I8')
        WRITE(unit=obj%unitNo, iostat=iostat )nByte, dataarray_I8P
        DEALLOCATE(dataarray_I8P)
#endif
      CASE('I4')
        WRITE(unit=obj%unitNo, iostat=iostat )nByte, dataarray_I4P
        DEALLOCATE(dataarray_I4P)
      CASE('I2')
        WRITE(unit=obj%unitNo, iostat=iostat )nByte, dataarray_I2P
        DEALLOCATE(dataarray_I2P)
      CASE('I1')
        WRITE(unit=obj%unitNo, iostat=iostat )nByte, dataarray_I1P
        DEALLOCATE(dataarray_I1P)
      END SELECT
    ELSE
      SELECT CASE(dataarray_type)
      CASE('R8')
        content = encodeVTKDataArray(x=dataarray_R8P, fmt="BINARY")
        WRITE(unit=obj%unitNo, iostat=iostat)content
      CASE('R4')
        content = encodeVTKDataArray(x=dataarray_R4P, fmt="BINARY")
        WRITE(unit=obj%unitNo, iostat=iostat)content
#ifdef USE_Int64
      CASE('I8')
        content = encodeVTKDataArray(x=dataarray_I8P, fmt="BINARY")
        WRITE(unit=obj%unitNo, iostat=iostat)content
#endif
      CASE('I4')
        content = encodeVTKDataArray(x=dataarray_I4P, fmt="BINARY")
        WRITE(unit=obj%unitNo, iostat=iostat)content
      CASE('I2')
        content = encodeVTKDataArray(x=dataarray_I2P, fmt="BINARY")
        WRITE(unit=obj%unitNo, iostat=iostat)content
      CASE('I1')
        content = encodeVTKDataArray(x=dataarray_I1P, fmt="BINARY")
        WRITE(unit=obj%unitNo, iostat=iostat)content
      END SELECT
    END IF
    END SUBROUTINE write_dataarray_on_xml
END PROCEDURE VTKFile_WriteDataArray_Appended

!----------------------------------------------------------------------------
!
!----------------------------------------------------------------------------

MODULE PROCEDURE VTKFile_WriteToScratch1
  CHARACTER( LEN = * ), PARAMETER :: myName="VTKFile_WriteToScratch1"
  INTEGER( I4B ) :: nn, iostat, n_byte
  nn = SIZE(x, dim=1)
#include "./VTKFile_WriteToScratch1_4.inc"
END PROCEDURE VTKFile_WriteToScratch1

!----------------------------------------------------------------------------
!
!----------------------------------------------------------------------------

MODULE PROCEDURE VTKFile_WriteToScratch2
  CHARACTER( LEN = * ), PARAMETER :: myName="VTKFile_WriteToScratch1"
  INTEGER( I4B ) :: nn, iostat, n_byte
  nn = SIZE( x, dim=1 ) * SIZE( x, dim=2 )
#include "./VTKFile_WriteToScratch1_4.inc"
END PROCEDURE VTKFile_WriteToScratch2
!----------------------------------------------------------------------------
!
!----------------------------------------------------------------------------

MODULE PROCEDURE VTKFile_WriteToScratch3
  CHARACTER( LEN = * ), PARAMETER :: myName="VTKFile_WriteToScratch1"
  INTEGER( I4B ) :: nn, iostat, n_byte
  nn = SIZE(x, dim=1)*SIZE(x, dim=2)*SIZE(x, dim=3)
#include "./VTKFile_WriteToScratch1_4.inc"
END PROCEDURE VTKFile_WriteToScratch3

!----------------------------------------------------------------------------
!
!----------------------------------------------------------------------------

MODULE PROCEDURE VTKFile_WriteToScratch4
  INTEGER( I4B ) :: nn, iostat, n_byte
  nn = SIZE(x, dim=1)*SIZE(x, dim=2)*SIZE(x, dim=3)*SIZE(x, dim=4)
#include "./VTKFile_WriteToScratch1_4.inc"
END PROCEDURE VTKFile_WriteToScratch4

!----------------------------------------------------------------------------
!
!----------------------------------------------------------------------------

MODULE PROCEDURE VTKFile_WriteToScratch5
  INTEGER( I4B ) :: n
  CALL obj%WriteToScratch( x=[(x(n), y(n), z(n), n=1, SIZE(x, dim=1))] )
END PROCEDURE VTKFile_WriteToScratch5
!----------------------------------------------------------------------------
!
!----------------------------------------------------------------------------

MODULE PROCEDURE VTKFile_WriteToScratch6
  INTEGER( I4B ) :: n
  CALL obj%WriteToScratch( x=[(x(n), y(n), z(n), n=1, SIZE(x, dim=1))] )
END PROCEDURE VTKFile_WriteToScratch6

!----------------------------------------------------------------------------
!
!----------------------------------------------------------------------------

#ifdef USE_Int64
MODULE PROCEDURE VTKFile_WriteToScratch7
  INTEGER( I4B ) :: n
  CALL obj%WriteToScratch( x=[(x(n), y(n), z(n), n=1, SIZE(x, dim=1))] )
END PROCEDURE VTKFile_WriteToScratch7
#endif

!----------------------------------------------------------------------------
!
!----------------------------------------------------------------------------

MODULE PROCEDURE VTKFile_WriteToScratch8
  INTEGER( I4B ) :: n
  CALL obj%WriteToScratch( x=[(x(n), y(n), z(n), n=1, SIZE(x, dim=1))] )
END PROCEDURE VTKFile_WriteToScratch8

!----------------------------------------------------------------------------
!
!----------------------------------------------------------------------------

MODULE PROCEDURE VTKFile_WriteToScratch9
  INTEGER( I4B ) :: n
  CALL obj%WriteToScratch( x=[(x(n), y(n), z(n), n=1, SIZE(x, dim=1))] )
END PROCEDURE VTKFile_WriteToScratch9

!----------------------------------------------------------------------------
!
!----------------------------------------------------------------------------

MODULE PROCEDURE VTKFile_WriteToScratch10
  INTEGER( I4B ) :: n
  CALL obj%WriteToScratch( x=[(x(n), y(n), z(n), n=1, SIZE(x, dim=1))] )
END PROCEDURE VTKFile_WriteToScratch10

!----------------------------------------------------------------------------
!
!----------------------------------------------------------------------------

MODULE PROCEDURE VTKFile_WriteToScratch11
  INTEGER( I4B ) :: n1, n2
  CALL obj%WriteToScratch(x=[((x(n1,n2), y(n1,n2), z(n1,n2), n1=1, &
    & size(x, dim=1)),n2=1,size(x, dim=2))])
END PROCEDURE VTKFile_WriteToScratch11

!----------------------------------------------------------------------------
!
!----------------------------------------------------------------------------

MODULE PROCEDURE VTKFile_WriteToScratch12
  INTEGER( I4B ) :: n1, n2
  CALL obj%WriteToScratch(x=[((x(n1,n2), y(n1,n2), z(n1,n2), n1=1, &
    & size(x, dim=1)),n2=1,size(x, dim=2))])
END PROCEDURE VTKFile_WriteToScratch12

!----------------------------------------------------------------------------
!
!----------------------------------------------------------------------------

#ifdef USE_Int64
MODULE PROCEDURE VTKFile_WriteToScratch13
  INTEGER( I4B ) :: n1, n2
  CALL obj%WriteToScratch(x=[((x(n1,n2), y(n1,n2), z(n1,n2), n1=1, &
    & size(x, dim=1)),n2=1,size(x, dim=2))])
END PROCEDURE VTKFile_WriteToScratch13
#endif

!----------------------------------------------------------------------------
!
!----------------------------------------------------------------------------

MODULE PROCEDURE VTKFile_WriteToScratch14
  INTEGER( I4B ) :: n1, n2
  CALL obj%WriteToScratch(x=[((x(n1,n2), y(n1,n2), z(n1,n2), n1=1, &
    & size(x, dim=1)),n2=1,size(x, dim=2))])
END PROCEDURE VTKFile_WriteToScratch14

!----------------------------------------------------------------------------
!
!----------------------------------------------------------------------------

MODULE PROCEDURE VTKFile_WriteToScratch15
  INTEGER( I4B ) :: n1, n2
  CALL obj%WriteToScratch(x=[((x(n1,n2), y(n1,n2), z(n1,n2), n1=1, &
    & size(x, dim=1)),n2=1,size(x, dim=2))])
END PROCEDURE VTKFile_WriteToScratch15

!----------------------------------------------------------------------------
!
!----------------------------------------------------------------------------

MODULE PROCEDURE VTKFile_WriteToScratch16
  INTEGER( I4B ) :: n1, n2
  CALL obj%WriteToScratch(x=[((x(n1,n2), y(n1,n2), z(n1,n2), n1=1, &
    & size(x, dim=1)),n2=1,size(x, dim=2))])
END PROCEDURE VTKFile_WriteToScratch16

!----------------------------------------------------------------------------
!
!----------------------------------------------------------------------------

MODULE PROCEDURE VTKFile_WriteToScratch17
  INTEGER( I4B ) :: n1, n2, n3
  CALL obj%WriteToScratch(x=[(((x(n1,n2,n3), y(n1,n2,n3), z(n1,n2,n3), &
    & n1=1,size(x, dim=1)),n2=1,size(x, dim=2)),n3=1,size(x, dim=3))])
END PROCEDURE VTKFile_WriteToScratch17

!----------------------------------------------------------------------------
!
!----------------------------------------------------------------------------

MODULE PROCEDURE VTKFile_WriteToScratch18
  INTEGER( I4B ) :: n1, n2, n3
  CALL obj%WriteToScratch(x=[(((x(n1,n2,n3), y(n1,n2,n3), z(n1,n2,n3), &
    & n1=1,size(x, dim=1)),n2=1,size(x, dim=2)),n3=1,size(x, dim=3))])
END PROCEDURE VTKFile_WriteToScratch18

!----------------------------------------------------------------------------
!
!----------------------------------------------------------------------------

#ifdef USE_Int64
MODULE PROCEDURE VTKFile_WriteToScratch19
  INTEGER( I4B ) :: n1, n2, n3
  CALL obj%WriteToScratch(x=[(((x(n1,n2,n3), y(n1,n2,n3), z(n1,n2,n3), &
    & n1=1,size(x, dim=1)),n2=1,size(x, dim=2)),n3=1,size(x, dim=3))])
END PROCEDURE VTKFile_WriteToScratch19
#endif

!----------------------------------------------------------------------------
!
!----------------------------------------------------------------------------

MODULE PROCEDURE VTKFile_WriteToScratch20
  INTEGER( I4B ) :: n1, n2, n3
  CALL obj%WriteToScratch(x=[(((x(n1,n2,n3), y(n1,n2,n3), z(n1,n2,n3), &
    & n1=1,size(x, dim=1)),n2=1,size(x, dim=2)),n3=1,size(x, dim=3))])
END PROCEDURE VTKFile_WriteToScratch20

!----------------------------------------------------------------------------
!
!----------------------------------------------------------------------------

MODULE PROCEDURE VTKFile_WriteToScratch21
  INTEGER( I4B ) :: n1, n2, n3
  CALL obj%WriteToScratch(x=[(((x(n1,n2,n3), y(n1,n2,n3), z(n1,n2,n3), &
    & n1=1,size(x, dim=1)),n2=1,size(x, dim=2)),n3=1,size(x, dim=3))])
END PROCEDURE VTKFile_WriteToScratch21

!----------------------------------------------------------------------------
!
!----------------------------------------------------------------------------

MODULE PROCEDURE VTKFile_WriteToScratch22
  INTEGER( I4B ) :: n1, n2, n3
  CALL obj%WriteToScratch(x=[(((x(n1,n2,n3), y(n1,n2,n3), z(n1,n2,n3), &
    & n1=1,size(x, dim=1)),n2=1,size(x, dim=2)),n3=1,size(x, dim=3))])
END PROCEDURE VTKFile_WriteToScratch22

END SUBMODULE DataArrayAppendedMethods