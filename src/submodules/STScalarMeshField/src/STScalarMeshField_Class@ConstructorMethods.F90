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

SUBMODULE(STScalarMeshField_Class) ConstructorMethods
USE BaseMethod
IMPLICIT NONE
CONTAINS

!----------------------------------------------------------------------------
!
!----------------------------------------------------------------------------

MODULE PROCEDURE SetSTScalarMeshFieldParam
INTEGER(I4B) :: s(2), n

IF (fieldType .EQ. FIELD_TYPE_CONSTANT) THEN
  s = 1; n = 1
ELSE
  s = [nns, nnt]; n = 2
END IF

IF (varType .EQ. Time) THEN
  CALL SetAbstractMeshFieldParam( &
    & param=param, &
    & prefix="STScalarMeshField", &
    & name=name, &
    & fieldType=fieldType, &
    & varType=varType, &
    & engine=engine, &
    & defineOn=defineOn, &
    & rank=Scalar, &
    & s=s(n:n))
  RETURN
END IF

CALL SetAbstractMeshFieldParam( &
  & param=param, &
  & prefix="STScalarMeshField", &
  & name=name, &
  & fieldType=fieldType, &
  & varType=varType, &
  & engine=engine, &
  & defineOn=defineOn, &
  & rank=Scalar, &
  & s=s(1:n))

END PROCEDURE SetSTScalarMeshFieldParam

!----------------------------------------------------------------------------
!                                                                   Initiate
!----------------------------------------------------------------------------

MODULE PROCEDURE obj_Initiate4
CHARACTER(*), PARAMETER :: myName = "obj_Initiate4()"
LOGICAL(LGT) :: isok
INTEGER(I4B) :: returnType, argType, nns, varType, fieldType
TYPE(ParameterList_) :: param
CLASS(ReferenceElement_), POINTER :: refelem

#ifdef DEBUG_VER
CALL e%RaiseInformation(modName//'::'//myName//' - '// &
  & '[START] ')
#endif DEBUG_VER

refelem => NULL()
refelem => mesh%GetRefElemPointer()
isok = ASSOCIATED(refelem)
IF (.NOT. isok) THEN
  CALL e%RaiseError(modName//'::'//myName//' - '// &
    & '[INTERNAL ERROR] :: refelem pointer not found.')
  RETURN
END IF
nns = (.NNE.refelem)

returnType = func%GetReturnType()
argType = func%GetArgType()

isok = returnType .EQ. Scalar
IF (.NOT. isok) THEN
  CALL e%RaiseError(modName//'::'//myName//' - '// &
    & '[INTERNAL ERROR] :: returnType should be Scalar.')
  RETURN
END IF

fieldType = TypeField%normal
varType = argType
IF (argType .EQ. Constant) THEN
  fieldType = TypeField%constant
  varType = Constant
END IF

isok = PRESENT(nnt)
IF (.NOT. isok) THEN
  CALL e%RaiseError(modName//'::'//myName//' - '// &
    & '[INTERNAL ERROR] :: NNT should be present when varType'//  &
    & ' in userFunction is Time or SpaceTime.')
  RETURN
END IF

CALL param%Initiate()

CALL SetSTScalarMeshFieldParam(param=param, name=name,  &
  & fieldType=fieldType, varType=varType, engine=engine, &
  & defineOn=Nodal, nns=nns, nnt=nnt)

CALL obj%Initiate(param=param, mesh=mesh)

CALL param%DEALLOCATE()

NULLIFY (refelem)

#ifdef DEBUG_VER
CALL e%RaiseInformation(modName//'::'//myName//' - '// &
  & '[END] ')
#endif DEBUG_VER

END PROCEDURE obj_Initiate4

!----------------------------------------------------------------------------
!                                                             Deallocate
!----------------------------------------------------------------------------

MODULE PROCEDURE aField_Deallocate_Vector
INTEGER(I4B) :: ii
IF (ALLOCATED(obj)) THEN
  DO ii = 1, SIZE(obj)
    CALL obj(ii)%DEALLOCATE()
  END DO
  DEALLOCATE (obj)
END IF
END PROCEDURE aField_Deallocate_Vector

!----------------------------------------------------------------------------
!                                                             Deallocate
!----------------------------------------------------------------------------

MODULE PROCEDURE aField_Deallocate_Ptr_Vector
INTEGER(I4B) :: ii
IF (ALLOCATED(obj)) THEN
  DO ii = 1, SIZE(obj)
    IF (ASSOCIATED(obj(ii)%ptr)) THEN
      CALL obj(ii)%ptr%DEALLOCATE()
      obj(ii)%ptr => NULL()
    END IF
  END DO
  DEALLOCATE (obj)
END IF
END PROCEDURE aField_Deallocate_Ptr_Vector

!----------------------------------------------------------------------------
!                                                                 GetPrefix
!----------------------------------------------------------------------------

MODULE PROCEDURE obj_GetPrefix
ans = myprefix
END PROCEDURE obj_GetPrefix

!----------------------------------------------------------------------------
!
!----------------------------------------------------------------------------

END SUBMODULE ConstructorMethods
