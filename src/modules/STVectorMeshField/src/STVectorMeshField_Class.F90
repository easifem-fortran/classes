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

MODULE STVectorMeshField_Class
USE GlobalData
USE BaSetype
USE FPL, ONLY: ParameterList_
USE ExceptionHandler_Class, ONLY: e
USE AbstractField_Class
USE AbstractMeshField_Class
USE Mesh_Class, ONLY: Mesh_
USE UserFunction_Class
IMPLICIT NONE
PRIVATE
CHARACTER(*), PARAMETER :: modName = "STVectorMeshField_Class"
CHARACTER(*), PARAMETER :: myprefix = "STVectorMeshField"
PUBLIC :: STVectorMeshFieldDeallocate
PUBLIC :: STVectorMeshField_
PUBLIC :: STVectorMeshFieldPointer_
PUBLIC :: SetSTVectorMeshFieldParam

!----------------------------------------------------------------------------
!                                                     STVectorMeshField_Class
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 20 Feb 2022
! summary: Scalar mesh field

TYPE, EXTENDS(AbstractVectorMeshField_) :: STVectorMeshField_
CONTAINS
  PRIVATE
  PROCEDURE, PUBLIC, PASS(obj) :: GetPrefix => obj_GetPrefix
  PROCEDURE, PUBLIC, PASS(obj) :: Initiate4 => obj_Initiate4
END TYPE STVectorMeshField_

!----------------------------------------------------------------------------
!
!----------------------------------------------------------------------------

TYPE :: STVectorMeshFieldPointer_
  CLASS(STVectorMeshField_), POINTER :: ptr => NULL()
END TYPE STVectorMeshFieldPointer_

!----------------------------------------------------------------------------
!                              SetAbstractMeshFieldParam@ConstructorMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 17 Feb 2022
! summary: This routine check the essential parameters in param.

INTERFACE
  MODULE SUBROUTINE SetSTVectorMeshFieldParam(param, name, &
    & fieldType, varType, engine, defineOn, spaceCompo, nns, nnt)
    TYPE(ParameterList_), INTENT(INOUT) :: param
    CHARACTER(*), INTENT(IN) :: name
    INTEGER(I4B), INTENT(IN) :: fieldType
    INTEGER(I4B), INTENT(IN) :: varType
    CHARACTER(*), INTENT(IN) :: engine
    INTEGER(I4B), INTENT(IN) :: defineOn
    !! Nodal, Quadrature
    INTEGER(I4B), INTENT(IN) :: spaceCompo
    INTEGER(I4B), INTENT(IN) :: nns
    INTEGER(I4B), INTENT(IN) :: nnt
    !! Number of node in space
  END SUBROUTINE SetSTVectorMeshFieldParam
END INTERFACE

!----------------------------------------------------------------------------
!                                             Initiate4@ConstructorMethods
!----------------------------------------------------------------------------

!> author: Vikas Sharma, Ph. D.
! date:  2023-12-05
! summary:  Initiate an instance Userfunction

INTERFACE
  MODULE SUBROUTINE obj_Initiate4(obj, mesh, func, name, engine, nnt)
    CLASS(STVectorMeshField_), INTENT(INOUT) :: obj
    !! AbstractMeshField
    TYPE(Mesh_), TARGET, INTENT(IN) :: mesh
    !! mesh
    CLASS(UserFunction_), INTENT(INOUT) :: func
    !! Abstract material
    CHARACTER(*), INTENT(IN) :: name
    !! name of the AbstractMeshField
    CHARACTER(*), INTENT(IN) :: engine
    !! engine of the AbstractMeshField
    INTEGER(I4B), OPTIONAL, INTENT(IN) :: nnt
    !! number of nodes in time
  END SUBROUTINE obj_Initiate4
END INTERFACE

!----------------------------------------------------------------------------
!                                             Deallocate@ConstructorMethods
!----------------------------------------------------------------------------

!> author: Vikas Sharma, Ph. D.
! date:  2023-09-12
! summary:  Deallocate the vector of NeumannBC_

INTERFACE STVectorMeshFieldDeallocate
  MODULE SUBROUTINE obj_Deallocate_Vector(obj)
    TYPE(STVectorMeshField_), ALLOCATABLE :: obj(:)
  END SUBROUTINE obj_Deallocate_Vector
END INTERFACE STVectorMeshFieldDeallocate

!----------------------------------------------------------------------------
!                                             Deallocate@ConstructorMethods
!----------------------------------------------------------------------------

!> author: Vikas Sharma, Ph. D.
! date:  2023-09-12
! summary:  Deallocate the vector of NeumannBC_

INTERFACE STVectorMeshFieldDeallocate
  MODULE SUBROUTINE obj_Deallocate_Ptr_Vector(obj)
    TYPE(STVectorMeshFieldPointer_), ALLOCATABLE :: obj(:)
  END SUBROUTINE obj_Deallocate_Ptr_Vector
END INTERFACE STVectorMeshFieldDeallocate

!----------------------------------------------------------------------------
!                                                              GetPrefix
!----------------------------------------------------------------------------

!> author: Vikas Sharma, Ph. D.
! date:  2023-12-04
! summary:  Get prefix

INTERFACE
  MODULE FUNCTION obj_GetPrefix(obj) RESULT(ans)
    CLASS(STVectorMeshField_), INTENT(IN) :: obj
    CHARACTER(:), ALLOCATABLE :: ans
  END FUNCTION obj_GetPrefix
END INTERFACE

END MODULE STVectorMeshField_Class
