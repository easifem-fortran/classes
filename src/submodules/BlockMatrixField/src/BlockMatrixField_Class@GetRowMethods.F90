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

!> authors: Vikas Sharma, Ph. D.
! date: 16 July 2021
! summary: This module contains constructor method for [[MatrixField_]]

SUBMODULE(BlockMatrixField_Class) GetRowMethods
USE BaseMethod
IMPLICIT NONE
CONTAINS

!----------------------------------------------------------------------------
!                                                                     getRow
!----------------------------------------------------------------------------

MODULE PROCEDURE mField_getRow1
  CHARACTER( LEN = * ), PARAMETER :: myName="mField_getRow1"
  CALL e%raiseError(modName//'::'//myName// " - "// &
  & 'This routine is not callable for BlockMatrixField')
END PROCEDURE mField_getRow1

!----------------------------------------------------------------------------
!                                                                 getRow
!----------------------------------------------------------------------------

MODULE PROCEDURE mField_getRow2
  REAL( DFP ), POINTER :: realvec( : )
  !!
  !!
  !!
  IF( PRESENT( value ) ) &
    & CALL getRow( &
      & obj=obj%mat, &
      & nodenum=obj%domains(ivar)%ptr%getLocalNodeNumber( globalNode ), &
      & ivar=ivar, &
      & idof=idof, &
      & value=value, &
      & scale=scale, &
      & addContribution=addContribution )
  !!
  !!
  !!
  IF( PRESENT( nodeFieldVal ) ) THEN
    realvec => nodeFieldVal%getPointer( )
    CALL getRow( &
      & obj=obj%mat, &
      & nodenum=obj%domains(ivar)%ptr%getLocalNodeNumber( globalNode ), &
      & ivar=ivar, &
      & idof=idof, &
      & value=realvec, &
      & scale=scale, &
      & addContribution=addContribution )
  END IF
  !!
  NULLIFY( realvec )
  !!
END PROCEDURE mField_getRow2

!----------------------------------------------------------------------------
!                                                                 getRow
!----------------------------------------------------------------------------

MODULE PROCEDURE mField_getRow3
  REAL( DFP ), POINTER :: realvec( : )
  !!
  !!
  !!
  IF( PRESENT( value ) ) &
    & CALL getRow( &
      & obj=obj%mat, &
      & nodenum=obj%domains(ivar)%ptr%getLocalNodeNumber( globalNode ), &
      & ivar=ivar, &
      & spacecompo=spacecompo, &
      & timecompo=timecompo, &
      & value=value, &
      & scale=scale, &
      & addContribution=addContribution )
  !!
  !!
  !!
  IF( PRESENT( nodeFieldVal ) ) THEN
    realvec => nodeFieldVal%getPointer( )
    CALL getRow( &
      & obj=obj%mat, &
      & nodenum=obj%domains(ivar)%ptr%getLocalNodeNumber( globalNode ), &
      & ivar=ivar, &
      & spacecompo=spacecompo, &
      & timecompo=timecompo, &
      & value=realvec, &
      & scale=scale, &
      & addContribution=addContribution )
  END IF
  !!
  NULLIFY( realvec )
  !!
END PROCEDURE mField_getRow3

!----------------------------------------------------------------------------
!                                                                 getRow
!----------------------------------------------------------------------------

MODULE PROCEDURE mField_getRow4
  REAL( DFP ), POINTER :: realvec( : )
  !!
  !!
  !!
  IF( PRESENT( value ) ) THEN
    CALL getRow( &
      & obj=obj%mat, &
      & nodenum=obj%domains(ivar)%ptr%getLocalNodeNumber( globalNode ), &
      & ivar=ivar, &
      & spacecompo=spacecompo, &
      & timecompo=timecompo, &
      & value=value, &
      & scale=scale, &
      & addContribution=addContribution )
  END IF
  !!
  !!
  !!
  IF( PRESENT( nodeFieldVal ) ) THEN
    realvec => nodeFieldVal%getPointer( )
    CALL getRow( &
      & obj=obj%mat, &
      & nodenum=obj%domains(ivar)%ptr%getLocalNodeNumber( globalNode ), &
      & ivar=ivar, &
      & spacecompo=spacecompo, &
      & timecompo=timecompo, &
      & value=realvec, &
      & scale=scale, &
      & addContribution=addContribution )
  END IF
  !!
  NULLIFY( realvec )
  !!
END PROCEDURE mField_getRow4

!----------------------------------------------------------------------------
!                                                                 getRow
!----------------------------------------------------------------------------

MODULE PROCEDURE mField_getRow5
  REAL( DFP ), POINTER :: realvec( : )
  !!
  !!
  !!
  IF( PRESENT( value ) ) THEN
    CALL getRow( &
      & obj=obj%mat, &
      & nodenum=obj%domains(ivar)%ptr%getLocalNodeNumber( globalNode ), &
      & ivar=ivar, &
      & spacecompo=spacecompo, &
      & timecompo=timecompo, &
      & value=value, &
      & scale=scale, &
      & addContribution=addContribution )
  END IF
  !!
  !!
  !!
  IF( PRESENT( nodeFieldVal ) ) THEN
    realvec => nodeFieldVal%getPointer( )
    CALL getRow( &
      & obj=obj%mat, &
      & nodenum=obj%domains(ivar)%ptr%getLocalNodeNumber( globalNode ), &
      & ivar=ivar, &
      & spacecompo=spacecompo, &
      & timecompo=timecompo, &
      & value=realvec, &
      & scale=scale, &
      & addContribution=addContribution )
  END IF
  !!
  NULLIFY( realvec )
  !!
END PROCEDURE mField_getRow5

!----------------------------------------------------------------------------
!                                                                 getRow
!----------------------------------------------------------------------------

MODULE PROCEDURE mField_getRow6
  REAL( DFP ), POINTER :: realvec( : )
  !!
  !!
  !!
  IF( PRESENT( value ) ) THEN
    CALL getRow( &
      & obj=obj%mat, &
      & nodenum=obj%domains(ivar)%ptr%getLocalNodeNumber( globalNode ), &
      & ivar=ivar, &
      & spacecompo=spacecompo, &
      & timecompo=timecompo, &
      & value=value, &
      & scale=scale, &
      & addContribution=addContribution )
  END IF
  !!
  !!
  !!
  IF( PRESENT( nodeFieldVal ) ) THEN
    realvec => nodeFieldVal%getPointer( )
    CALL getRow( &
      & obj=obj%mat, &
      & nodenum=obj%domains(ivar)%ptr%getLocalNodeNumber( globalNode ), &
      & ivar=ivar, &
      & spacecompo=spacecompo, &
      & timecompo=timecompo, &
      & value=realvec, &
      & scale=scale, &
      & addContribution=addContribution )
  END IF
  !!
  NULLIFY( realvec )
  !!
END PROCEDURE mField_getRow6

!----------------------------------------------------------------------------
!                                                                 getRow
!----------------------------------------------------------------------------

MODULE PROCEDURE mField_getRow7
  REAL( DFP ), POINTER :: realvec( : )
  !!
  !!
  !!
  IF( PRESENT( value ) ) THEN
    CALL getRow( &
      & obj=obj%mat, &
      & nodenum=obj%domains(ivar)%ptr%getLocalNodeNumber( globalNode ), &
      & ivar=ivar, &
      & spacecompo=spacecompo, &
      & timecompo=timecompo, &
      & value=value, &
      & scale=scale, &
      & addContribution=addContribution )
  END IF
  !!
  !!
  !!
  IF( PRESENT( nodeFieldVal ) ) THEN
    realvec => nodeFieldVal%getPointer( )
    CALL getRow( &
      & obj=obj%mat, &
      & nodenum=obj%domains(ivar)%ptr%getLocalNodeNumber( globalNode ), &
      & ivar=ivar, &
      & spacecompo=spacecompo, &
      & timecompo=timecompo, &
      & value=realvec, &
      & scale=scale, &
      & addContribution=addContribution )
  END IF
  !!
  NULLIFY( realvec )
  !!
END PROCEDURE mField_getRow7

!----------------------------------------------------------------------------
!
!----------------------------------------------------------------------------

END SUBMODULE GetRowMethods