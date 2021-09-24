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

SUBMODULE (DirichletBC_Class) IOMethods
USE BaseMethod
IMPLICIT NONE
CONTAINS

!----------------------------------------------------------------------------
!
!----------------------------------------------------------------------------

MODULE PROCEDURE dbc_Import
  CHARACTER( LEN = * ), PARAMETER :: myName="dbc_Import"
  TYPE( String ) :: dsetname, strval
  INTEGER( I4B ) :: ierr
  REAL( DFP ) :: real0
  REAL( DFP ), ALLOCATABLE :: real1( : ), real2( :, : )
  !> check
  IF( obj%isInitiated ) THEN
    CALL e%raiseError(modName//'::'//myName// " - "// &
    & 'The object is already initiated, deallocate first!')
  END IF
  obj%isInitiated = .TRUE.
  obj%dom => dom
  !> print info
  CALL e%raiseInformation( modName//"::"//myName//" - "// &
    & "IMPORTING DIRICHLET BOUNDARY CONDITION" )
  !> check
  IF( .NOT. hdf5%isOpen() ) THEN
    CALL e%raiseError(modName//'::'//myName// &
    & 'HDF5 file is not opened')
  END IF
  !> check
  IF( .NOT. hdf5%isRead() ) THEN
    CALL e%raiseError(modName//'::'//myName// &
    & 'HDF5 file does not have read permission')
  END IF
  ! READ name
  dsetname=TRIM(group)//"/name"
  IF( .NOT. hdf5%pathExists(TRIM(dsetname%chars()))) THEN
    CALL e%raiseError(modName//'::'//myName// " - "// &
    & 'The dataset name should be present')
  ELSE
    CALL hdf5%read(dsetname=TRIM(dsetname%chars()), &
      & vals=obj%name)
  END IF
  ! READ idof
  dsetname=TRIM(group)//"/idof"
  IF( .NOT. hdf5%pathExists(TRIM(dsetname%chars()))) THEN
    CALL e%raiseError(modName//'::'//myName// " - "// &
    & 'The dataset idof should be present')
  ELSE
    CALL hdf5%read(dsetname=TRIM(dsetname%chars()), &
      & vals=obj%idof)
  END IF
  ! READ nodalValueType
  dsetname=TRIM(group)//"/nodalValueType"
  IF( .NOT. hdf5%pathExists(TRIM(dsetname%chars()))) THEN
    CALL e%raiseError(modName//'::'//myName// " - "// &
    & 'The dataset nodalValueType should be present')
  ELSE
    CALL hdf5%read(dsetname=TRIM(dsetname%chars()), &
      & vals=strval)
  END IF
  SELECT CASE( TRIM( strval%chars() ) )
  CASE( "CONSTANT" )
    obj%nodalValueType = Constant
  CASE( "SPACE" )
    obj%nodalValueType = Space
  CASE( "TIME" )
    obj%nodalValueType = Time
  CASE( "SPACETIME" )
    obj%nodalValueType = SpaceTime
  END SELECT
  ! READ useFunction
  dsetname=TRIM(group)//"/useFunction"
  IF( .NOT. hdf5%pathExists(TRIM(dsetname%chars()))) THEN
    CALL e%raiseError(modName//'::'//myName// " - "// &
    & 'The dataset useFunction should be present')
  ELSE
    CALL hdf5%read(dsetname=TRIM(dsetname%chars()), &
      & vals=obj%useFunction)
  END IF
  ! READ Boundary
  dsetname=TRIM(group)//"/Boundary"
  IF( .NOT. hdf5%pathExists(TRIM(dsetname%chars()))) THEN
    CALL e%raiseError(modName//'::'//myName// " - "// &
    & 'The dataset Boundary, which is a group, should be present')
  ELSE
    CALL obj%boundary%import( hdf5=hdf5, group=TRIM(dsetname%chars()))
  END IF
  ! Read nodalValue
  IF( .NOT. obj%UseFunction ) THEN
    dsetname=TRIM(group)//"/NodalValue"
    IF( .NOT. hdf5%pathExists(TRIM(dsetname%chars()))) THEN
      CALL e%raiseError(modName//'::'//myName// " - "// &
      & 'The dataset NodalValue should be present')
    END IF
    SELECT CASE( obj%nodalValueType )
    CASE( Constant )
      CALL hdf5%read(dsetname=TRIM(dsetname%chars()), &
      & vals=real0)
      CALL Reallocate( obj%NodalValue, 1, 1 )
      obj%NodalValue = real0
    CASE( Space, Time )
      CALL hdf5%read(dsetname=TRIM(dsetname%chars()), &
        & vals=real1)
      CALL Reallocate( obj%nodalValue, SIZE( real1), 1 )
      obj%NodalValue( :, 1 ) = real1
    CASE( SpaceTime )
      CALL hdf5%read(dsetname=TRIM(dsetname%chars()), &
      & vals=real2)
      obj%NodalValue = real2
    END SELECT
  END IF

  IF( ALLOCATED( real1 ) ) DEALLOCATE( real1 )
  IF( ALLOCATED( real2 ) ) DEALLOCATE( real2 )
END PROCEDURE dbc_Import

!----------------------------------------------------------------------------
!
!----------------------------------------------------------------------------

MODULE PROCEDURE dbc_Export
  CHARACTER( LEN = * ), PARAMETER :: myName="dbc_Export"
  TYPE( String ) :: dsetname, strval
  INTEGER( I4B ) :: ierr
  REAL( DFP ) :: real0
  REAL( DFP ), ALLOCATABLE :: real1( : ), real2( :, : )
  !> check
  IF( .NOT. obj%isInitiated ) THEN
    CALL e%raiseError(modName//'::'//myName// " - "// &
    & 'The object is not initiated, initiate it first!')
  END IF
  !> print info
  CALL e%raiseInformation( modName//"::"//myName//" - "// &
    & "EXPORTING DIRICHLET BOUNDARY CONDITION" )
  !> check
  IF( .NOT. hdf5%isOpen() ) THEN
    CALL e%raiseError(modName//'::'//myName// &
    & 'HDF5 file is not opened')
  END IF
  !> check
  IF( .NOT. hdf5%isWrite() ) THEN
    CALL e%raiseError(modName//'::'//myName// &
    & 'HDF5 file does not have write permission')
  END IF
  ! WRITE name
  dsetname=TRIM(group)//"/name"
  CALL hdf5%write(dsetname=TRIM(dsetname%chars()), &
    & vals=obj%name)
  ! WRITE idof
  dsetname=TRIM(group)//"/idof"
  CALL hdf5%write(dsetname=TRIM(dsetname%chars()), &
    & vals=obj%idof)
  ! WRITE nodalValueType
  dsetname=TRIM(group)//"/nodalValueType"
  SELECT CASE( obj%nodalValueType )
  CASE( Constant )
    strval = "CONSTANT"
  CASE( Space )
    strval = "SPACE"
  CASE( Time )
    strval = "TIME"
  CASE( SpaceTime )
    strval = "SPACETIME"
  END SELECT
  CALL hdf5%write(dsetname=TRIM(dsetname%chars()), &
    & vals=strval)
  ! WRITE useFunction
  dsetname=TRIM(group)//"/useFunction"
  CALL hdf5%write(dsetname=TRIM(dsetname%chars()), &
    & vals=obj%useFunction)
  ! WRITE Boundary
  dsetname=TRIM(group)//"/Boundary"
  CALL obj%boundary%export( hdf5=hdf5, group=TRIM(dsetname%chars()))
  ! Read nodalValue
  IF( .NOT. obj%UseFunction ) THEN
    dsetname=TRIM(group)//"/NodalValue"
    IF( .NOT. ALLOCATED( obj%NodalValue ) ) THEN
      CALL e%raiseError(modName//'::'//myName// &
      & 'NodalValue is not allocated, it seems NodalValue is not set')
    END IF
    SELECT CASE( obj%nodalValueType )
    CASE( Constant )
      real0 = obj%NodalValue(1,1)
      CALL hdf5%write(dsetname=TRIM(dsetname%chars()), &
        & vals=real0)
    CASE( Space, Time )
      real1 = obj%NodalValue(:,1)
      CALL hdf5%write(dsetname=TRIM(dsetname%chars()), &
        & vals=real1)
    CASE( SpaceTime )
      real2 = obj%NodalValue
      CALL hdf5%write(dsetname=TRIM(dsetname%chars()), &
        & vals=real2)
    END SELECT
  END IF
  IF( ALLOCATED( real1 ) ) DEALLOCATE( real1 )
  IF( ALLOCATED( real2 ) ) DEALLOCATE( real2 )
END PROCEDURE dbc_Export

!----------------------------------------------------------------------------
!
!----------------------------------------------------------------------------

MODULE PROCEDURE dbc_Display
  TYPE( String ) :: strval
  REAL( DFP ) :: real0
  REAL( DFP ), ALLOCATABLE :: real1( : ), real2( :, : )

  !> check
  IF( .NOT. obj%isInitiated ) THEN
    CALL Display( "DirichletBC is not initiated, nothing to display", &
      & unitNo=unitNo )
  END IF
  CALL Display( "# name : "// TRIM(obj%name%chars()), unitNo=unitNo )
  CALL Display( obj%idof, "# idof : ", unitNo=unitNo )
  SELECT CASE( obj%nodalValueType )
  CASE( Constant )
    strval = "CONSTANT"
  CASE( Space )
    strval = "SPACE"
  CASE( Time )
    strval = "TIME"
  CASE( SpaceTime )
    strval = "SPACETIME"
  END SELECT
  CALL Display("# nodalValueType : "// TRIM(strval%chars()), unitNo=unitNo)
  CALL Display( obj%useFunction, "# useFunction : ", unitNo=unitNo )
  CALL obj%Boundary%Display( msg="Boundary : ", unitNo=unitNo )
  IF( .NOT. obj%UseFunction ) THEN
    IF( .NOT. ALLOCATED( obj%NodalValue ) ) THEN
      CALL Display( "# NodalValue : NOT ALLOCATED", unitNo=unitNo )
    ELSE
      SELECT CASE( obj%nodalValueType )
      CASE( Constant )
        real0 = obj%NodalValue(1,1)
        CALL Display( real0, "# NodalValue : ", unitNo=unitNo )
      CASE( Space, Time )
        real1 = obj%NodalValue(:,1)
        CALL Display( real1, "# NodalValue : ", unitNo=unitNo, orient="col" )
      CASE( SpaceTime )
        real2 = obj%NodalValue(:,:)
        CALL Display( real2, "# NodalValue : ", unitNo=unitNo )
      END SELECT
    END IF
  END IF
  IF( ALLOCATED( real1 ) ) DEALLOCATE( real1 )
  IF( ALLOCATED( real2 ) ) DEALLOCATE( real2 )
END PROCEDURE dbc_Display

END SUBMODULE IOMethods