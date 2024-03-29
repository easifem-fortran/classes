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

SUBMODULE(AbstractMeshField_Class) AddMethods
USE BaseMethod
IMPLICIT NONE
CONTAINS

!----------------------------------------------------------------------------
!                                                                       Add
!----------------------------------------------------------------------------

MODULE PROCEDURE obj_Add
  !!
INTEGER(I4B) :: iel
  !!
IF (obj%fieldType .EQ. FIELD_TYPE_CONSTANT) THEN
  obj%val(:, 1) = obj%val(:, 1) + scale * fevar%val(:)
ELSE
  IF (PRESENT(globalElement)) THEN
    iel = obj%mesh%getLocalElemNumber(globalElement)
    obj%val(:, iel) = obj%val(:, iel) + scale * fevar%val(:)
  ELSE
    DO iel = 1, obj%mesh%getTotalElements()
      obj%val(:, iel) = obj%val(:, iel) + scale * fevar%val(:)
    END DO
  END IF
END IF
  !!
END PROCEDURE obj_Add

!----------------------------------------------------------------------------
!
!----------------------------------------------------------------------------

END SUBMODULE AddMethods
