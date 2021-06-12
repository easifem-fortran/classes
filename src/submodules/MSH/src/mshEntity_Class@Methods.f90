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

SUBMODULE( mshEntity_Class ) Methods
USE BaseMethod
IMPLICIT NONE

CONTAINS

!----------------------------------------------------------------------------
!                                                                 Final
!----------------------------------------------------------------------------

MODULE PROCEDURE ent_Final
  CALL obj%DeallocateData()
END PROCEDURE ent_Final

!----------------------------------------------------------------------------
!                                                             DeallocateData
!----------------------------------------------------------------------------

MODULE PROCEDURE ent_deallocatedata
  obj%uid = 0
  obj%xiDim = 0
  obj%elemType = 0
  obj%minX = 0.0
  obj%minY = 0.0
  obj%minZ = 0.0
  obj%maxX = 0.0
  obj%maxY = 0.0
  obj%maxZ = 0.0
  obj%x = 0.0
  obj%y = 0.0
  obj%z = 0.0
  IF( ALLOCATED( obj%physicalTag ) ) DEALLOCATE( obj%physicalTag )
  IF( ALLOCATED( obj%nodeNumber ) ) DEALLOCATE( obj%nodeNumber )
  IF( ALLOCATED( obj%ElemNumber ) ) DEALLOCATE( obj%ElemNumber )
  IF( ALLOCATED( obj%Nptrs ) ) DEALLOCATE( obj%Nptrs )
  IF( ALLOCATED( obj%BoundingEntity ) ) DEALLOCATE( obj%BoundingEntity )
  IF( ALLOCATED( obj%NodeCoord ) ) DEALLOCATE( obj%NodeCoord )
END PROCEDURE ent_deallocatedata

!----------------------------------------------------------------------------
!                                                               gotoEntities
!----------------------------------------------------------------------------

MODULE PROCEDURE ent_GotoTag
  ! Define internal variables
  INTEGER( I4B ) :: IOSTAT, Reopen, unitNo
  CHARACTER( LEN = 100 ) :: Dummy
  CHARACTER( LEN = * ), PARAMETER :: myName = "pn_GotoTag"
  !
  ! Find $meshFormat

  IF( .NOT. mshFile%isOpen() .OR. .NOT. mshFile%isRead() ) THEN
    CALL mshFile%e%raiseError(modName//'::'//myName//' - '// &
      & 'mshFile is either not opened or does not have read access!')
    error = -1
  ELSE
    Reopen = 0
    error = 0
    DO
      unitNo = mshFile%getUnitNo()
      READ( unitNo, "(A)", IOSTAT = IOSTAT ) Dummy
      IF( mshFile%isEOF() ) THEN
        CALL mshFile%Rewind()
        Reopen = Reopen + 1
      END IF
      IF( IOSTAT .GT. 0 .OR. Reopen .GT. 1 ) THEN
        CALL mshFile%e%raiseError(modName//'::'//myName//' - '// &
        & 'Could not find $Entities !')
        error = -2
        EXIT
      ELSE IF( TRIM( Dummy ) .EQ. '$Entities' ) THEN
        EXIT
      END IF
    END DO
  END IF
END PROCEDURE ent_GotoTag

!----------------------------------------------------------------------------
!                                                           Write
!----------------------------------------------------------------------------

MODULE PROCEDURE ent_Write
END PROCEDURE ent_Write

!----------------------------------------------------------------------------
!                                                                 Display
!----------------------------------------------------------------------------

MODULE PROCEDURE ent_display
  INTEGER( I4B ) :: I, j
  TYPE( String ) :: Str1

  I = Input( Default=stdout, Option=UnitNo )
  IF( LEN_TRIM( Msg ) .NE. 0 ) THEN
    WRITE( I, "(A)" ) TRIM( Msg )
  END IF

  CALL BlankLines( UnitNo = I, NOL = 1 )
  WRITE( I, "(A)" ) "| Property | Value |"
  WRITE( I, "(A)" ) "| :---     | ---:  |"
  WRITE( I, "(A, I4, A )" ) " | Tag | ", obj%UiD, " | "
  SELECT CASE( obj%XiDim )
  CASE( 0 )
    WRITE( I, "(A)" ) " | Type |  Point | "
    WRITE( I, "(A, 3(G13.6, ','), A)" ) " | X, Y, Z | ", obj%X, &
      & obj%Y, obj%Z, " | "
  CASE( 1 )
    WRITE( I, "(A)" ) " | Type |  Curve | "
    WRITE( I, "(A, 3(G13.6, ','), A)" ) " | minX, minY, minZ | ", &
      & obj%minX, obj%minY, obj%minZ, " | "
    WRITE( I, "(A, 3(G13.6, ','), A)" ) " | maxX, maxY, maxZ | ", &
      & obj%maxX, obj%maxY, obj%maxZ, " | "
    Str1 = String( Str( SIZE( obj%BoundingEntity ), .true. ) )
    WRITE( I, "(A, "//TRIM( Str1 )//"(I4, ','), A)" ) &
      & "| Bounding Points |", obj%BoundingEntity, " |"
  CASE( 2 )
    WRITE( I, "(A)" ) " | Type |  Surface | "
    WRITE( I, "(A, 3(G13.6, ','), A)" ) " | minX, minY, minZ | ", &
      & obj%minX, obj%minY, obj%minZ, " | "
    WRITE( I, "(A, 3(G13.6, ','), A)" ) " | maxX, maxY, maxZ | ", &
      & obj%maxX, obj%maxY, obj%maxZ, " | "
    Str1 = String( Str( SIZE( obj%BoundingEntity ), .true. ) )
    WRITE( I, "(A, "//TRIM( Str1 )//"(I4, ','), A)" ) &
      & "| Bounding Curves |", obj%BoundingEntity, " |"
  CASE( 3 )
    WRITE( I, "(A)" ) " | Type |  Volume | "
    WRITE( I, "(A, 3(G13.6, ','), A)" ) " | minX, minY, minZ | ", &
      & obj%minX, obj%minY, obj%minZ, " | "
    WRITE( I, "(A, 3(G13.6, ','), A)" ) " | maxX, maxY, maxZ | ", &
      & obj%maxX, obj%maxY, obj%maxZ, " | "
    Str1 = String( Str( SIZE( obj%BoundingEntity ), .true. ) )
    WRITE( I, "(A, "//TRIM( Str1 )//"(I4, ','), A)" ) &
      & "| Bounding Surfaces |", obj%BoundingEntity, " |"
  END SELECT
  ! Physical Tag
  IF( ALLOCATED( obj%physicalTag ) ) THEN
    Str1 = String( Str( SIZE( obj%physicalTag ), .true. ) )
    WRITE( I, "(A, "//TRIM( Str1 )//"(I4, ','), A)" ) &
      & "| Physical Tag |", obj%physicalTag, " | "
  END IF
  ! Nodes
  IF( ALLOCATED( obj%nodeNumber ) ) THEN
    WRITE( I, "(A, I4)" ) "| Total Nodes |", SIZE( obj%nodeNumber )
    WRITE( I, "(A)" ) "| Node Number | Coordinates |"
    DO j = 1, SIZE( obj%nodeNumber )
      WRITE( I, "(A, I4, A, 3(G13.6, ','), A)" ) &
      & "| ", obj%nodeNumber( j ), " | ", obj%NodeCoord( 1:3, j), " |"
    END DO
  END IF
  ! Elements
  IF( ALLOCATED( obj%ElemNumber ) ) THEN
    WRITE( I, "(A, I4)" ) "| Total Elements |", SIZE( obj%ElemNumber )
    WRITE( I, "(A)" ) "| Element Number | Connectivity |"
    Str1 = String( Str( SIZE( obj%Nptrs, 1 ), .true. ) )
    DO j = 1, SIZE( obj%ElemNumber )
      WRITE( I, "(A, I4, A, "//TRIM(Str1)//"(G13.6, ','), A)" ) &
      & "| ", obj%ElemNumber( j ), " | ", obj%Nptrs( 1:, j), " |"
    END DO
  END IF
END PROCEDURE ent_display

!----------------------------------------------------------------------------
!                                                                 Read
!----------------------------------------------------------------------------

MODULE PROCEDURE ent_Read
  SELECT CASE( dim )
  CASE( 0 )
    CALL ReadPointEntity( obj, mshFile, readTag, error )
  CASE( 1 )
    CALL ReadCurveEntity( obj, mshFile, readTag, error )
  CASE( 2 )
    CALL ReadSurfaceEntity( obj, mshFile, readTag, error )
  CASE( 3 )
    CALL ReadVolumeEntity( obj, mshFile, readTag, error )
  END SELECT
END PROCEDURE ent_Read

!----------------------------------------------------------------------------
!                                                           ReadPointEntity
!----------------------------------------------------------------------------

MODULE PROCEDURE ReadPointEntity
  ! Define internal variables
  INTEGER( I4B ) :: dummyierr
  INTEGER( I4B ) :: Intvec( 100 ), n, i

  ! go to tag
  IF( ReadTag ) THEN
    CALL obj%GotoTag( mshFile, error )
  ELSE
    error = 0
  END IF

  IF( error .EQ. 0 ) THEN
    obj%XiDim = 0
    READ( mshFile%getUnitNo(), * ) obj%Uid, obj%X, obj%Y, obj%Z, &
      & n, (Intvec(i), i=1,n)

    IF( ALLOCATED( obj%physicalTag ) ) DEALLOCATE( obj%physicalTag )

    IF( n .NE. 0 ) THEN
      ALLOCATE( obj%physicalTag( n ) )
      obj%physicalTag( 1 : n ) = Intvec( 1 : n )
    END IF
  END IF
END PROCEDURE ReadPointEntity

!----------------------------------------------------------------------------
!                                                           ReadCurveEntity
!----------------------------------------------------------------------------

MODULE PROCEDURE ReadCurveEntity
  INTEGER( I4B ) :: Intvec1( 100 ), n, i, m, Intvec2( 100 )

  IF( ReadTag ) THEN
    CALL obj%GotoTag( mshFile, error )
  ELSE
    error = 0
  END IF

  IF( error .EQ. 0 ) THEN
    obj%XiDim = 1
    READ( mshFile%getUnitNo(), * ) &
      & obj%Uid, obj%minX, obj%minY, obj%minZ, &
      & obj%maxX, obj%maxY, obj%maxZ, &
      & n, (Intvec1(i), i=1,n), &
      & m, (Intvec2(i), i=1,m)
    !
    IF( ALLOCATED( obj%physicalTag ) ) DEALLOCATE( obj%physicalTag )
    IF( ALLOCATED( obj%BoundingEntity ) ) DEALLOCATE( obj%BoundingEntity )
    !
    IF( n .NE. 0 ) THEN
      ALLOCATE( obj%physicalTag( n ) )
      obj%physicalTag( 1 : n ) = Intvec1( 1 : n )
    END IF
    IF( m .NE. 0 ) THEN
      ALLOCATE( obj%BoundingEntity( m ) )
      obj%BoundingEntity( 1 : m ) = Intvec2( 1 : m )
    END IF
  END IF
END PROCEDURE ReadCurveEntity

!----------------------------------------------------------------------------
!                                                          ReadSurfaceEntity
!----------------------------------------------------------------------------

MODULE PROCEDURE ReadSurfaceEntity
  ! Define internal variables
  INTEGER( I4B ), ALLOCATABLE :: Intvec1( : ), Intvec2( : )
  INTEGER( I4B ) :: n, i, m
  TYPE( String ) :: aline
  TYPE( String ), ALLOCATABLE :: entries( : )
  !
  IF( ReadTag ) THEN
    CALL obj%GotoTag( mshFile, error )
  ELSE
    error = 0
  END IF

  IF( error .EQ. 0 ) THEN
    obj%XiDim = 2
    CALL aline%read_line( unit = mshFile%getUnitno() )
    CALL aline%split(tokens=entries, sep=' ')
    obj%Uid = entries( 1 )%to_number( kind = I4B )

    obj%minX = entries( 2 )%to_number( kind = DFP )
    obj%minY = entries( 3 )%to_number( kind = DFP )
    obj%minZ = entries( 4 )%to_number( kind = DFP )

    obj%maxX = entries( 5 )%to_number( kind = DFP )
    obj%maxY = entries( 6 )%to_number( kind = DFP )
    obj%maxZ = entries( 7 )%to_number( kind = DFP )

    n = entries( 8 )%to_number( kind = I4B )
    IF( n .NE. 0 ) THEN
      ALLOCATE( IntVec1( n ) )
      DO i = 1, n
        IntVec1( i ) = entries( 8 + i )%to_number( kind = I4B )
      END DO
    ENDIF
    !! check total length here
    m = entries( 9 + n )%to_number( kind = I4B )
    IF( m .NE. 0 ) THEN
      ALLOCATE( IntVec2( m ) )
      DO i = 1, m
        IntVec2( i ) = entries( 9 + n + i )%to_number( kind = I4B )
      END DO
    ENDIF

    IF( ALLOCATED( obj%physicalTag ) ) DEALLOCATE( obj%physicalTag )
    IF( ALLOCATED( obj%BoundingEntity ) ) DEALLOCATE( obj%BoundingEntity )

    IF( n .NE. 0 ) THEN
      ALLOCATE( obj%physicalTag( n ) )
      obj%physicalTag( 1 : n ) = Intvec1( 1 : n )
    END IF

    IF( m .NE. 0 ) THEN
      ALLOCATE( obj%BoundingEntity( m ) )
      obj%BoundingEntity( 1 : m ) = Intvec2( 1 : m )
    END IF
  END IF

  IF( ALLOCATED( IntVec1 ) ) DEALLOCATE( IntVec1 )
  IF( ALLOCATED( IntVec2 ) ) DEALLOCATE( IntVec2 )
  IF( ALLOCATED( entries ) ) DEALLOCATe( entries )
END PROCEDURE ReadSurfaceEntity

!----------------------------------------------------------------------------
!                                                           ReadVolumeEntity
!----------------------------------------------------------------------------

MODULE PROCEDURE ReadVolumeEntity
  ! Define internal variables
  INTEGER( I4B ), ALLOCATABLE :: Intvec1( : ), Intvec2( : )
  INTEGER( I4B ) :: n, i, m
  TYPE( String ) :: aline
  TYPE( String ), ALLOCATABLE :: entries( : )

  IF( ReadTag ) THEN
    CALL obj%GotoTag( mshFile, error )
  ELSE
    error = 0
  END IF
  !
  IF( error .EQ. 0 ) THEN
    obj%XiDim = 3

    CALL aline%read_line( unit = mshFile%getUnitno() )
    CALL aline%split(tokens=entries, sep=' ')
    obj%Uid = entries( 1 )%to_number( kind = I4B )

    obj%minX = entries( 2 )%to_number( kind = DFP )
    obj%minY = entries( 3 )%to_number( kind = DFP )
    obj%minZ = entries( 4 )%to_number( kind = DFP )

    obj%maxX = entries( 5 )%to_number( kind = DFP )
    obj%maxY = entries( 6 )%to_number( kind = DFP )
    obj%maxZ = entries( 7 )%to_number( kind = DFP )

    n = entries( 8 )%to_number( kind = I4B )
    IF( n .NE. 0 ) THEN
      ALLOCATE( IntVec1( n ) )
      DO i = 1, n
        IntVec1( i ) = entries( 8 + i )%to_number( kind = I4B )
      END DO
    ENDIF
    !! check total length here
    m = entries( 9 + n )%to_number( kind = I4B )
    IF( m .NE. 0 ) THEN
      ALLOCATE( IntVec2( m ) )
      DO i = 1, m
        IntVec2( i ) = entries( 9 + n + i )%to_number( kind = I4B )
      END DO
    ENDIF

    IF( ALLOCATED( obj%physicalTag ) ) DEALLOCATE( obj%physicalTag )
    IF( ALLOCATED( obj%BoundingEntity ) ) DEALLOCATE( obj%BoundingEntity )
    !
    IF( n .NE. 0 ) THEN
      ALLOCATE( obj%physicalTag( n ) )
      obj%physicalTag( 1 : n ) = Intvec1( 1 : n )
    END IF
    !
    IF( m .NE. 0 ) THEN
      ALLOCATE( obj%BoundingEntity( m ) )
      obj%BoundingEntity( 1 : m ) = Intvec2( 1 : m )
    END IF
  END IF

  IF( ALLOCATED( IntVec1 ) ) DEALLOCATE( IntVec1 )
  IF( ALLOCATED( IntVec2 ) ) DEALLOCATE( IntVec2 )
  IF( ALLOCATED( entries ) ) DEALLOCATe( Entries )

END PROCEDURE ReadVolumeEntity

!----------------------------------------------------------------------------
!                                                                 getIndex
!----------------------------------------------------------------------------

MODULE PROCEDURE ent_getIndex
  ! Define internal variables
  INTEGER( I4B ) :: j, tSize
  ans = 0
  tSize = SIZE( mshEntities )
  DO j = 1, tSize
    IF( mshEntities( j )%UiD .EQ. UiD ) THEN
      ans = j
      EXIT
    END IF
  END DO
END PROCEDURE ent_getIndex

!----------------------------------------------------------------------------
!                                                      getTotalPhysicalTags
!----------------------------------------------------------------------------

MODULE PROCEDURE ent_getTotalPhysicalTags
  IF( ALLOCATED( obj%physicalTag ) ) THEN
    ans = SIZE( obj%physicalTag )
  ELSE
    ans = 0
  END IF
END PROCEDURE ent_getTotalPhysicalTags

!----------------------------------------------------------------------------
!                                                      getTotalBoundingTags
!----------------------------------------------------------------------------

MODULE PROCEDURE ent_getTotalBoundingTags
  IF( ALLOCATED( obj%BoundingEntity ) ) THEN
    ans = SIZE( obj%BoundingEntity )
  ELSE
    ans = 0
  END IF
END PROCEDURE ent_getTotalBoundingTags

!----------------------------------------------------------------------------
!                                                           getTotalElements
!----------------------------------------------------------------------------

MODULE PROCEDURE ent_getTotalElements
  IF( ALLOCATED( obj%ElemNumber ) ) THEN
    ans = SIZE( obj%ElemNumber )
  ELSE
    ans = 0
  END IF
END PROCEDURE ent_getTotalElements

!----------------------------------------------------------------------------
!                                                           getPhysicalTag
!----------------------------------------------------------------------------

MODULE PROCEDURE ent_getPhysicalTag
  IF( ALLOCATED( obj%physicalTag ) ) THEN
    ans = obj%physicalTag
  ELSE
    ALLOCATE( ans( 0 ) )
  END IF
END PROCEDURE ent_getPhysicalTag

!----------------------------------------------------------------------------
!                                                            setNodeNumber
!----------------------------------------------------------------------------

MODULE PROCEDURE ent_setNodeNumber
  obj%nodeNumber = NodeNumber
END PROCEDURE ent_setNodeNumber

!----------------------------------------------------------------------------
!                                                              setNodeCoord
!----------------------------------------------------------------------------

MODULE PROCEDURE ent_setNodeCoord
  obj%NodeCoord = NodeCoord
END PROCEDURE ent_setNodeCoord

!----------------------------------------------------------------------------
!                                                                setElemType
!----------------------------------------------------------------------------

MODULE PROCEDURE ent_setElemType
  obj%ElemType = ElemType
END PROCEDURE ent_setElemType

!----------------------------------------------------------------------------
!                                                             setElemNumber
!----------------------------------------------------------------------------

MODULE PROCEDURE ent_setElemNumber
  obj%ElemNumber = ElemNumber
END PROCEDURE ent_setElemNumber

!----------------------------------------------------------------------------
!                                                                 setNptrs
!----------------------------------------------------------------------------

MODULE PROCEDURE ent_setNptrs
  obj%Nptrs = Nptrs
END PROCEDURE ent_setNptrs

!----------------------------------------------------------------------------
!                                                                 getUid
!----------------------------------------------------------------------------

MODULE PROCEDURE ent_getUid
  ans = obj%Uid
END PROCEDURE ent_getUid

!----------------------------------------------------------------------------
!                                                                 getXiDim
!----------------------------------------------------------------------------

MODULE PROCEDURE ent_getXiDim
  ans = obj%XiDim
END PROCEDURE ent_getXiDim

!----------------------------------------------------------------------------
!                                                                 getElemType
!----------------------------------------------------------------------------

MODULE PROCEDURE ent_getElemType
  ans = obj%ElemType
END PROCEDURE ent_getElemType

!----------------------------------------------------------------------------
!                                                                 getMinX
!----------------------------------------------------------------------------

MODULE PROCEDURE ent_getMinX
  ans = obj%MinX
END PROCEDURE ent_getMinX

!----------------------------------------------------------------------------
!                                                                 getMinY
!----------------------------------------------------------------------------

MODULE PROCEDURE ent_getMinY
  ans = obj%MinY
END PROCEDURE ent_getMinY

!----------------------------------------------------------------------------
!                                                                 getMinZ
!----------------------------------------------------------------------------

MODULE PROCEDURE ent_getMinZ
  ans = obj%MinZ
END PROCEDURE ent_getMinZ

!----------------------------------------------------------------------------
!                                                                 getMaxX
!----------------------------------------------------------------------------

MODULE PROCEDURE ent_getMaxX
  ans = obj%MaxX
END PROCEDURE ent_getMaxX

!----------------------------------------------------------------------------
!                                                                 getMaxY
!----------------------------------------------------------------------------

MODULE PROCEDURE ent_getMaxY
  ans = obj%MaxY
END PROCEDURE ent_getMaxY

!----------------------------------------------------------------------------
!                                                                 getMaxZ
!----------------------------------------------------------------------------

MODULE PROCEDURE ent_getMaxZ
  ans = obj%MaxZ
END PROCEDURE ent_getMaxZ

!----------------------------------------------------------------------------
!                                                                 getX
!----------------------------------------------------------------------------

MODULE PROCEDURE ent_getX
  ans = obj%X
END PROCEDURE ent_getX

!----------------------------------------------------------------------------
!                                                                 getY
!----------------------------------------------------------------------------

MODULE PROCEDURE ent_getY
  ans = obj%Y
END PROCEDURE ent_getY

!----------------------------------------------------------------------------
!                                                                 getZ
!----------------------------------------------------------------------------

MODULE PROCEDURE ent_getZ
  ans = obj%Z
END PROCEDURE ent_getZ

!----------------------------------------------------------------------------
!                                                               getNodeCoord
!----------------------------------------------------------------------------

MODULE PROCEDURE ent_getNodeCoord
  IF( ALLOCATED( obj%NodeCoord ) ) THEN
    ans = obj%NodeCoord
  ELSE
    ALLOCATE( ans( 0, 0 ) )
  END IF
END PROCEDURE ent_getNodeCoord

!----------------------------------------------------------------------------
!                                                            getNodeNumber
!----------------------------------------------------------------------------

MODULE PROCEDURE ent_getNodeNumber
  IF( ALLOCATED( obj%NodeNumber ) ) THEN
    ans = Obj%NodeNumber
  ELSE
    ALLOCATE( ans(0) )
  END IF
END PROCEDURE ent_getNodeNumber

!----------------------------------------------------------------------------
!                                                            getElemNumber
!----------------------------------------------------------------------------

MODULE PROCEDURE ent_getElemNumber
  IF( ALLOCATED( obj%ElemNumber ) ) THEN
    ans = Obj%ElemNumber
  ELSE
    ALLOCATE( ans(0) )
  END IF
END PROCEDURE ent_getElemNumber

!----------------------------------------------------------------------------
!                                                            getBoundingEntity
!----------------------------------------------------------------------------

MODULE PROCEDURE ent_getBoundingEntity
  IF( ALLOCATED( obj%boundingEntity ) ) THEN
    ans = Obj%boundingEntity
  ELSE
    ALLOCATE( ans(0) )
  END IF
END PROCEDURE ent_getBoundingEntity

!----------------------------------------------------------------------------
!                                                                 getNptrs
!----------------------------------------------------------------------------

MODULE PROCEDURE ent_getNptrs_a
  Ans = obj%Nptrs( :, elemNum )
END PROCEDURE ent_getNptrs_a

!----------------------------------------------------------------------------
!                                                                 getNptrs
!----------------------------------------------------------------------------

MODULE PROCEDURE ent_getNptrs_b
  IF( ALLOCATED( obj%Nptrs ) ) THEN
    ans = Obj%Nptrs
  ELSE
    ALLOCATE( ans(0,0) )
  END IF
END PROCEDURE ent_getNptrs_b

END SUBMODULE Methods