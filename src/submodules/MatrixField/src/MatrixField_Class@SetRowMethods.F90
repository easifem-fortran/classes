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

SUBMODULE(MatrixField_Class) SetRowMethods
USE BaseMethod
IMPLICIT NONE
CONTAINS

!----------------------------------------------------------------------------
!                                                                    SetRow
!----------------------------------------------------------------------------

MODULE PROCEDURE obj_SetRow1
REAL(DFP), POINTER :: realvec(:)
CHARACTER(*), PARAMETER :: myName = "obj_SetRow1"

IF (PRESENT(scalarVal)) THEN
  IF (obj%isRectangle) THEN
    CALL SetRow( &
    & obj=obj%mat, &
    & nodenum=obj%domains(1)%ptr%getLocalNodeNumber(globalNode), &
    & idof=idof, &
    & VALUE=scalarVal)
  ELSE
    CALL SetRow( &
    & obj=obj%mat, &
    & nodenum=obj%domain%getLocalNodeNumber(globalNode), &
    & idof=idof, &
    & VALUE=scalarVal)
  END IF
END IF

IF (PRESENT(vecVal)) THEN
  IF (obj%isRectangle) THEN
    CALL SetRow( &
    & obj=obj%mat, &
    & nodenum=obj%domains(1)%ptr%getLocalNodeNumber(globalNode), &
    & idof=idof, &
    & VALUE=vecVal)
  ELSE
    CALL SetRow( &
    & obj=obj%mat, &
    & nodenum=obj%domain%getLocalNodeNumber(globalNode), &
    & idof=idof, &
    & VALUE=vecVal)
  END IF
END IF

IF (PRESENT(nodeFieldVal)) THEN
  IF (obj%isRectangle) THEN
    realvec => nodeFieldVal%getPointer()
    CALL SetRow( &
    & obj=obj%mat, &
    & nodenum=obj%domains(1)%ptr%getLocalNodeNumber(globalNode), &
    & idof=idof, &
    & VALUE=realvec)
  ELSE
    realvec => nodeFieldVal%getPointer()
    CALL SetRow( &
    & obj=obj%mat, &
    & nodenum=obj%domain%getLocalNodeNumber(globalNode), &
    & idof=idof, &
    & VALUE=realvec)
  END IF
END IF

realvec => NULL()
END PROCEDURE obj_SetRow1

!----------------------------------------------------------------------------
!                                                                 SetRow
!----------------------------------------------------------------------------

MODULE PROCEDURE obj_SetRow2
REAL(DFP), POINTER :: realvec(:)
CHARACTER(*), PARAMETER :: myName = "obj_SetRow2"

IF (PRESENT(scalarVal)) THEN
  IF (obj%isRectangle) THEN
    CALL SetRow( &
    & obj=obj%mat, &
    & nodenum=obj%domains(1)%ptr%getLocalNodeNumber(globalNode), &
    & ivar=ivar, &
    & idof=idof, &
    & VALUE=scalarVal)
  ELSE
    CALL SetRow( &
    & obj=obj%mat, &
    & nodenum=obj%domain%getLocalNodeNumber(globalNode), &
    & ivar=ivar, &
    & idof=idof, &
    & VALUE=scalarVal)
  END IF
END IF

IF (PRESENT(vecVal)) THEN
  IF (obj%isRectangle) THEN
    CALL SetRow( &
    & obj=obj%mat, &
    & nodenum=obj%domains(1)%ptr%getLocalNodeNumber(globalNode), &
    & ivar=ivar, &
    & idof=idof, &
    & VALUE=vecVal)
  ELSE
    CALL SetRow( &
    & obj=obj%mat, &
    & nodenum=obj%domain%getLocalNodeNumber(globalNode), &
    & ivar=ivar, &
    & idof=idof, &
    & VALUE=vecVal)
  END IF
END IF

IF (PRESENT(nodeFieldVal)) THEN
  IF (obj%isRectangle) THEN
    realvec => nodeFieldVal%getPointer()
    CALL SetRow( &
    & obj=obj%mat, &
    & nodenum=obj%domains(1)%ptr%getLocalNodeNumber(globalNode), &
    & ivar=ivar, &
    & idof=idof, &
    & VALUE=realvec)
  ELSE
    realvec => nodeFieldVal%getPointer()
    CALL SetRow( &
    & obj=obj%mat, &
    & nodenum=obj%domain%getLocalNodeNumber(globalNode), &
    & ivar=ivar, &
    & idof=idof, &
    & VALUE=realvec)
  END IF
END IF

realvec => NULL()
END PROCEDURE obj_SetRow2

!----------------------------------------------------------------------------
!                                                                 SetRow
!----------------------------------------------------------------------------

MODULE PROCEDURE obj_SetRow3
REAL(DFP), POINTER :: realvec(:)
CHARACTER(*), PARAMETER :: myName = "obj_SetRow3"

IF (PRESENT(scalarVal)) THEN
  IF (obj%isRectangle) THEN
    CALL SetRow( &
    & obj=obj%mat, &
    & nodenum=obj%domains(1)%ptr%getLocalNodeNumber(globalNode), &
    & ivar=ivar, &
    & spacecompo=spacecompo, &
    & timecompo=timecompo, &
    & VALUE=scalarVal)
  ELSE
    CALL SetRow( &
     & obj=obj%mat, &
     & nodenum=obj%domain%getLocalNodeNumber(globalNode), &
     & ivar=ivar, &
     & spacecompo=spacecompo, &
     & timecompo=timecompo, &
     & VALUE=scalarVal)
  END IF
END IF

IF (PRESENT(vecVal)) THEN
  IF (obj%isRectangle) THEN
    CALL SetRow( &
      & obj=obj%mat, &
      & nodenum=obj%domains(1)%ptr%getLocalNodeNumber(globalNode), &
      & ivar=ivar, &
      & spacecompo=spacecompo, &
      & timecompo=timecompo, &
      & VALUE=vecVal)
  ELSE
    CALL SetRow( &
      & obj=obj%mat, &
      & nodenum=obj%domain%getLocalNodeNumber(globalNode), &
      & ivar=ivar, &
      & spacecompo=spacecompo, &
      & timecompo=timecompo, &
      & VALUE=vecVal)
  END IF
END IF

IF (PRESENT(nodeFieldVal)) THEN
  IF (obj%isRectangle) THEN
    realvec => nodeFieldVal%getPointer()
    CALL SetRow( &
      & obj=obj%mat, &
      & nodenum=obj%domains(1)%ptr%getLocalNodeNumber(globalNode), &
      & ivar=ivar, &
      & spacecompo=spacecompo, &
      & timecompo=timecompo, &
      & VALUE=realvec)
  ELSE
    realvec => nodeFieldVal%getPointer()
    CALL SetRow( &
      & obj=obj%mat, &
      & nodenum=obj%domain%getLocalNodeNumber(globalNode), &
      & ivar=ivar, &
      & spacecompo=spacecompo, &
      & timecompo=timecompo, &
      & VALUE=realvec)
  END IF
END IF

realvec => NULL()
END PROCEDURE obj_SetRow3

!----------------------------------------------------------------------------
!                                                                    SetRow
!----------------------------------------------------------------------------

MODULE PROCEDURE obj_SetRow4
REAL(DFP), POINTER :: realvec(:)
CHARACTER(*), PARAMETER :: myName = "obj_SetRow4"

IF (PRESENT(scalarVal)) THEN
  IF (obj%isRectangle) THEN
    CALL SetRow( &
      & obj=obj%mat, &
      & nodenum=obj%domains(1)%ptr%getLocalNodeNumber(globalNode), &
      & ivar=ivar, &
      & spacecompo=spacecompo, &
      & timecompo=timecompo, &
      & VALUE=scalarVal)
  ELSE
    CALL SetRow( &
      & obj=obj%mat, &
      & nodenum=obj%domain%getLocalNodeNumber(globalNode), &
      & ivar=ivar, &
      & spacecompo=spacecompo, &
      & timecompo=timecompo, &
      & VALUE=scalarVal)
  END IF
END IF

IF (PRESENT(vecVal)) THEN
  IF (obj%isRectangle) THEN
    CALL SetRow( &
      & obj=obj%mat, &
      & nodenum=obj%domains(1)%ptr%getLocalNodeNumber(globalNode), &
      & ivar=ivar, &
      & spacecompo=spacecompo, &
      & timecompo=timecompo, &
      & VALUE=vecVal)
  ELSE
    CALL SetRow( &
      & obj=obj%mat, &
      & nodenum=obj%domain%getLocalNodeNumber(globalNode), &
      & ivar=ivar, &
      & spacecompo=spacecompo, &
      & timecompo=timecompo, &
      & VALUE=vecVal)
  END IF
END IF

IF (PRESENT(nodeFieldVal)) THEN
  IF (obj%isRectangle) THEN
    realvec => nodeFieldVal%getPointer()
    CALL SetRow( &
      & obj=obj%mat, &
      & nodenum=obj%domains(1)%ptr%getLocalNodeNumber(globalNode), &
      & ivar=ivar, &
      & spacecompo=spacecompo, &
      & timecompo=timecompo, &
      & VALUE=realvec)
  ELSE
    realvec => nodeFieldVal%getPointer()
    CALL SetRow( &
      & obj=obj%mat, &
      & nodenum=obj%domain%getLocalNodeNumber(globalNode), &
      & ivar=ivar, &
      & spacecompo=spacecompo, &
      & timecompo=timecompo, &
      & VALUE=realvec)
  END IF
END IF

realvec => NULL()
END PROCEDURE obj_SetRow4

!----------------------------------------------------------------------------
!                                                                    SetRow
!----------------------------------------------------------------------------

MODULE PROCEDURE obj_SetRow5
REAL(DFP), POINTER :: realvec(:)
CHARACTER(*), PARAMETER :: myName = "obj_SetRow5"

IF (PRESENT(scalarVal)) THEN
  IF (obj%isRectangle) THEN
    CALL SetRow( &
      & obj=obj%mat, &
      & nodenum=obj%domains(1)%ptr%getLocalNodeNumber(globalNode), &
      & ivar=ivar, &
      & spacecompo=spacecompo, &
      & timecompo=timecompo, &
      & VALUE=scalarVal)
  ELSE
    CALL SetRow( &
      & obj=obj%mat, &
      & nodenum=obj%domain%getLocalNodeNumber(globalNode), &
      & ivar=ivar, &
      & spacecompo=spacecompo, &
      & timecompo=timecompo, &
      & VALUE=scalarVal)
  END IF
END IF

IF (PRESENT(vecVal)) THEN
  IF (obj%isRectangle) THEN
    CALL SetRow( &
      & obj=obj%mat, &
      & nodenum=obj%domains(1)%ptr%getLocalNodeNumber(globalNode), &
      & ivar=ivar, &
      & spacecompo=spacecompo, &
      & timecompo=timecompo, &
      & VALUE=vecVal)
  ELSE
    CALL SetRow( &
      & obj=obj%mat, &
      & nodenum=obj%domain%getLocalNodeNumber(globalNode), &
      & ivar=ivar, &
      & spacecompo=spacecompo, &
      & timecompo=timecompo, &
      & VALUE=vecVal)
  END IF
END IF

IF (PRESENT(nodeFieldVal)) THEN
  IF (obj%isRectangle) THEN
    realvec => nodeFieldVal%getPointer()
    CALL SetRow( &
      & obj=obj%mat, &
      & nodenum=obj%domains(1)%ptr%getLocalNodeNumber(globalNode), &
      & ivar=ivar, &
      & spacecompo=spacecompo, &
      & timecompo=timecompo, &
      & VALUE=realvec)
  ELSE
    realvec => nodeFieldVal%getPointer()
    CALL SetRow( &
      & obj=obj%mat, &
      & nodenum=obj%domain%getLocalNodeNumber(globalNode), &
      & ivar=ivar, &
      & spacecompo=spacecompo, &
      & timecompo=timecompo, &
      & VALUE=realvec)
  END IF
END IF

realvec => NULL()
END PROCEDURE obj_SetRow5

!----------------------------------------------------------------------------
!                                                                    SetRow
!----------------------------------------------------------------------------

MODULE PROCEDURE obj_SetRow6
REAL(DFP), POINTER :: realvec(:)
CHARACTER(*), PARAMETER :: myName = "obj_SetRow6"

IF (PRESENT(scalarVal)) THEN
  IF (obj%isRectangle) THEN
    CALL SetRow( &
      & obj=obj%mat, &
      & nodenum=obj%domains(1)%ptr%getLocalNodeNumber(globalNode), &
      & ivar=ivar, &
      & spacecompo=spacecompo, &
      & timecompo=timecompo, &
      & VALUE=scalarVal)
  ELSE
    CALL SetRow( &
      & obj=obj%mat, &
      & nodenum=obj%domain%getLocalNodeNumber(globalNode), &
      & ivar=ivar, &
      & spacecompo=spacecompo, &
      & timecompo=timecompo, &
      & VALUE=scalarVal)
  END IF
END IF

IF (PRESENT(vecVal)) THEN
  IF (obj%isRectangle) THEN
    CALL SetRow( &
      & obj=obj%mat, &
      & nodenum=obj%domains(1)%ptr%getLocalNodeNumber(globalNode), &
      & ivar=ivar, &
      & spacecompo=spacecompo, &
      & timecompo=timecompo, &
      & VALUE=vecVal)
  ELSE
    CALL SetRow( &
      & obj=obj%mat, &
      & nodenum=obj%domain%getLocalNodeNumber(globalNode), &
      & ivar=ivar, &
      & spacecompo=spacecompo, &
      & timecompo=timecompo, &
      & VALUE=vecVal)
  END IF
END IF

IF (PRESENT(nodeFieldVal)) THEN
  IF (obj%isRectangle) THEN
    realvec => nodeFieldVal%getPointer()
    CALL SetRow( &
      & obj=obj%mat, &
      & nodenum=obj%domains(1)%ptr%getLocalNodeNumber(globalNode), &
      & ivar=ivar, &
      & spacecompo=spacecompo, &
      & timecompo=timecompo, &
      & VALUE=realvec)
  ELSE
    realvec => nodeFieldVal%getPointer()
    CALL SetRow( &
      & obj=obj%mat, &
      & nodenum=obj%domain%getLocalNodeNumber(globalNode), &
      & ivar=ivar, &
      & spacecompo=spacecompo, &
      & timecompo=timecompo, &
      & VALUE=realvec)
  END IF
END IF

realvec => NULL()
END PROCEDURE obj_SetRow6

!----------------------------------------------------------------------------
!                                                                    SetRow
!----------------------------------------------------------------------------

MODULE PROCEDURE obj_SetRow7
REAL(DFP), POINTER :: realvec(:)
CHARACTER(*), PARAMETER :: myName = "obj_SetRow7"

IF (PRESENT(scalarVal)) THEN
  IF (obj%isRectangle) THEN
    CALL SetRow( &
      & obj=obj%mat, &
      & nodenum=obj%domains(1)%ptr%getLocalNodeNumber(globalNode), &
      & ivar=ivar, &
      & spacecompo=spacecompo, &
      & timecompo=timecompo, &
      & VALUE=scalarVal)
  ELSE
    CALL SetRow( &
      & obj=obj%mat, &
      & nodenum=obj%domain%getLocalNodeNumber(globalNode), &
      & ivar=ivar, &
      & spacecompo=spacecompo, &
      & timecompo=timecompo, &
      & VALUE=scalarVal)
  END IF
END IF

IF (PRESENT(vecVal)) THEN
  IF (obj%isRectangle) THEN
    CALL SetRow( &
      & obj=obj%mat, &
      & nodenum=obj%domains(1)%ptr%getLocalNodeNumber(globalNode), &
      & ivar=ivar, &
      & spacecompo=spacecompo, &
      & timecompo=timecompo, &
      & VALUE=vecVal)
  ELSE
    CALL SetRow( &
      & obj=obj%mat, &
      & nodenum=obj%domain%getLocalNodeNumber(globalNode), &
      & ivar=ivar, &
      & spacecompo=spacecompo, &
      & timecompo=timecompo, &
      & VALUE=vecVal)
  END IF
END IF

IF (PRESENT(nodeFieldVal)) THEN
  IF (obj%isRectangle) THEN
    realvec => nodeFieldVal%getPointer()
    CALL SetRow( &
      & obj=obj%mat, &
      & nodenum=obj%domains(1)%ptr%getLocalNodeNumber(globalNode), &
      & ivar=ivar, &
      & spacecompo=spacecompo, &
      & timecompo=timecompo, &
      & VALUE=realvec)
  ELSE
    realvec => nodeFieldVal%getPointer()
    CALL SetRow( &
      & obj=obj%mat, &
      & nodenum=obj%domain%getLocalNodeNumber(globalNode), &
      & ivar=ivar, &
      & spacecompo=spacecompo, &
      & timecompo=timecompo, &
      & VALUE=realvec)
  END IF
END IF

realvec => NULL()
END PROCEDURE obj_SetRow7

!----------------------------------------------------------------------------
!
!----------------------------------------------------------------------------

END SUBMODULE SetRowMethods
