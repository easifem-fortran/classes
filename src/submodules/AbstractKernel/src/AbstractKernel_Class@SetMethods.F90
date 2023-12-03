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

SUBMODULE(AbstractKernel_Class) SetMethods
USE BaseMethod
IMPLICIT NONE
CONTAINS

!----------------------------------------------------------------------------
!                                                                       Set
!----------------------------------------------------------------------------

MODULE PROCEDURE obj_Set
CHARACTER(*), PARAMETER :: myName = "obj_Set"
CALL e%RaiseError(modName//'::'//myName//' - '// &
  & '[WIP ERROR] :: This routine has not been implemented yet')
END PROCEDURE obj_Set

!----------------------------------------------------------------------------
!                                                         SetCurrentTimeStep
!----------------------------------------------------------------------------

MODULE PROCEDURE obj_SetCurrentTimeStep
obj%currentTimeStep = its
END PROCEDURE obj_SetCurrentTimeStep

!----------------------------------------------------------------------------
!                                                       SetIterationNumber
!----------------------------------------------------------------------------

MODULE PROCEDURE obj_SetIterationNumber
obj%iterData%iterationNumber = iter
END PROCEDURE obj_SetIterationNumber

!----------------------------------------------------------------------------
!                                                              SetMeshData
!----------------------------------------------------------------------------

MODULE PROCEDURE obj_SetMeshData
CHARACTER(*), PARAMETER :: myName = "obj_SetMeshData"
#ifdef DEBUG_VER
CALL e%RaiseInformation(modName//'::'//myName//' - '// &
  & '[START] ')
#endif DEBUG_VER

IF (ASSOCIATED(obj%dom)) THEN
  CALL obj%dom%InitiateNodeToElements()
  CALL obj%dom%InitiateNodeToNodes()
  CALL obj%dom%InitiateFacetElements()
ELSE
  CALL e%RaiseError(modName//'::'//myName//' - '// &
    & '[POINTER ERROR] :: AbstractKernel_::obj%dom is not associated.')
  RETURN
END IF

IF (ALLOCATED(obj%domains)) THEN
  CALL e%RaiseError(modName//'::'//myName//' - '// &
    & '[WIP] :: AbstractKernel_::obj%domains  case todo.')
  RETURN
END IF
! TODO: Implement SetMeshData when isCommonDomain is false.

#ifdef DEBUG_VER
CALL e%RaiseInformation(modName//'::'//myName//' - '// &
  & '[END] ')
#endif DEBUG_VER

END PROCEDURE obj_SetMeshData

!----------------------------------------------------------------------------
!                                                         SetFiniteElements
!----------------------------------------------------------------------------

MODULE PROCEDURE obj_SetFiniteElements
CHARACTER(*), PARAMETER :: myName = "kernel_SetFiniteElements"
INTEGER(I4B), ALLOCATABLE :: order(:), elemType(:)
INTEGER(I4B) :: tsize, ii, nsd
LOGICAL(LGT) :: problem

#ifdef DEBUG_VER
CALL e%RaiseInformation(modName//'::'//myName//' - '// &
  & '[START] ')
#endif DEBUG_VER

nsd = obj%nsd
tsize = obj%dom%getTotalMesh(dim=nsd)
CALL Reallocate(elemType, tsize)
CALL Reallocate(order, tsize)
elemType = obj%dom%GetElemType(dim=nsd)
order = obj%dom%GetOrder(dim=nsd)

problem = (ALLOCATED(obj%cellFE) .OR. ALLOCATED(obj%linCellFE))
IF (problem) THEN
  CALL e%RaiseError(modName//'::'//myName//' - '// &
    & '[CONFIG ERROR] :: AbstractKernel_::obj%cellFE or obj%linCellFE '//  &
    & 'already allocated.')
  RETURN
END IF

ALLOCATE (obj%cellFE(tsize), obj%linCellFE(tsize))

DO ii = 1, tsize
  ALLOCATE (FiniteElement_ :: obj%cellFE(ii)%ptr)
  ALLOCATE (FiniteElement_ :: obj%linCellFE(ii)%ptr)

  CALL obj%cellFE(ii)%ptr%InitiateLagrangeFE( &
    & nsd=nsd,  &
    & elemType=elemType(ii),  &
    & order=order(ii),  &
    & baseContinuity=obj%baseContinuityForSpace%chars(),  &
    & baseInterpolation=obj%baseInterpolationForSpace%chars(),  &
    & ipType=obj%ipTypeForSpace,  &
    & basisType=obj%basisTypeForSpace,  &
    & alpha=obj%alphaForSpace,  &
    & beta=obj%betaForSpace,  &
    & lambda=obj%lambdaForSpace)

  CALL obj%linCellFE(ii)%ptr%InitiateLagrangeFE( &
    & nsd=nsd,  &
    & elemType=elemType(ii),  &
    & order=1_I4B,  &
    & baseContinuity=obj%baseContinuityForSpace%chars(),  &
    & baseInterpolation=obj%baseInterpolationForSpace%chars(),  &
    & ipType=obj%ipTypeForSpace,  &
    & basisType=obj%basisTypeForSpace,  &
    & alpha=obj%alphaForSpace,  &
    & beta=obj%betaForSpace,  &
    & lambda=obj%lambdaForSpace)
END DO

CALL obj%SetQuadPointsInSpace()
CALL obj%SetLocalElemShapeDataInSpace()

IF (nsd .GE. 2) THEN
  elemType = obj%dom%GetElemType(dim=nsd - 1)
  order = obj%dom%GetOrder(dim=nsd - 1)
  tsize = SIZE(elemType)

  IF (ALLOCATED(obj%facetFE) .OR. ALLOCATED(obj%linFacetFE)) THEN
    CALL e%RaiseError(modName//'::'//myName//' - '// &
    & '[CONFIG ERROR] :: AbstractKernel_::obj%facetFE or obj%linFacetFE '//  &
      & 'already allocated.')
  END IF

  ALLOCATE (obj%facetFE(tsize), obj%linFacetFE(tsize))

  DO ii = 1, tsize

    ALLOCATE (FiniteElement_ :: obj%facetFE(ii)%ptr)
    ALLOCATE (FiniteElement_ :: obj%linFacetFE(ii)%ptr)

    CALL obj%facetFE(ii)%ptr%InitiateLagrangeFE( &
      & nsd=nsd,  &
      & elemType=elemType(ii),  &
      & order=order(ii),  &
      & baseContinuity=obj%baseContinuityForSpace%chars(),  &
      & baseInterpolation=obj%baseInterpolationForSpace%chars(),  &
      & ipType=obj%ipTypeForSpace,  &
      & basisType=obj%basisTypeForSpace,  &
      & alpha=obj%alphaForSpace,  &
      & beta=obj%betaForSpace,  &
      & lambda=obj%lambdaForSpace)

    CALL obj%linFacetFE(ii)%ptr%InitiateLagrangeFE( &
      & nsd=nsd,  &
      & elemType=elemType(ii),  &
      & order=1_I4B,  &
      & baseContinuity=obj%baseContinuityForSpace%chars(),  &
      & baseInterpolation=obj%baseInterpolationForSpace%chars(),  &
      & ipType=obj%ipTypeForSpace,  &
      & basisType=obj%basisTypeForSpace,  &
      & alpha=obj%alphaForSpace,  &
      & beta=obj%betaForSpace,  &
      & lambda=obj%lambdaForSpace)

  END DO
END IF

IF (nsd .GE. 3) THEN
  elemType = obj%dom%GetElemType(dim=nsd - 2)
  order = obj%dom%GetOrder(dim=nsd - 2)
  tsize = SIZE(elemType)

  IF (ALLOCATED(obj%edgeFE) .OR. ALLOCATED(obj%linEdgeFE)) THEN
    CALL e%RaiseError(modName//'::'//myName//' - '// &
      & '[CONFIG ERROR] :: AbstractKernel_::obj%edgeFE or obj%linEdgeFE '//  &
      & 'already allocated.')
  END IF

  ! CALL DEALLOCATE (obj%edgeFE)
  ALLOCATE (obj%edgeFE(tsize), obj%linEdgeFE(tsize))

  DO ii = 1, tsize
    ALLOCATE (FiniteElement_ :: obj%edgeFE(ii)%ptr)
    ALLOCATE (FiniteElement_ :: obj%linEdgeFE(ii)%ptr)

    CALL obj%edgeFE(ii)%ptr%InitiateLagrangeFE( &
      & nsd=nsd,  &
      & elemType=elemType(ii),  &
      & order=order(ii),  &
      & baseContinuity=obj%baseContinuityForSpace%chars(),  &
      & baseInterpolation=obj%baseInterpolationForSpace%chars(),  &
      & ipType=obj%ipTypeForSpace,  &
      & basisType=obj%basisTypeForSpace,  &
      & alpha=obj%alphaForSpace,  &
      & beta=obj%betaForSpace,  &
      & lambda=obj%lambdaForSpace)

    CALL obj%linEdgeFE(ii)%ptr%InitiateLagrangeFE( &
      & nsd=nsd,  &
      & elemType=elemType(ii),  &
      & order=1_I4B,  &
      & baseContinuity=obj%baseContinuityForSpace%chars(),  &
      & baseInterpolation=obj%baseInterpolationForSpace%chars(),  &
      & ipType=obj%ipTypeForSpace,  &
      & basisType=obj%basisTypeForSpace,  &
      & alpha=obj%alphaForSpace,  &
      & beta=obj%betaForSpace,  &
      & lambda=obj%lambdaForSpace)
  END DO

END IF

IF (obj%nnt .GT. 1_I4B) THEN
  CALL obj%timeFE%InitiateLagrangeFE( &
    & nsd=nsd,  &
    & elemType=Line2,  &
    & order=obj%nnt - 1_I4B,  &
    & baseContinuity=obj%baseContinuityForTime%chars(),  &
    & baseInterpolation=obj%baseInterpolationForTime%chars(),  &
    & ipType=obj%ipTypeForTime,  &
    & basisType=obj%basisTypeForTime,  &
    & alpha=obj%alphaForTime,  &
    & beta=obj%betaForTime,  &
    & lambda=obj%lambdaForTime)

  CALL obj%linTimeFE%InitiateLagrangeFE( &
    & nsd=nsd,  &
    & elemType=Line2,  &
    & order=1_I4B,  &
    & baseContinuity=obj%baseContinuityForTime%chars(),  &
    & baseInterpolation=obj%baseInterpolationForTime%chars(),  &
    & ipType=obj%ipTypeForTime,  &
    & basisType=obj%basisTypeForTime,  &
    & alpha=obj%alphaForTime,  &
    & beta=obj%betaForTime,  &
    & lambda=obj%lambdaForTime)

  CALL obj%SetQuadPointsInTime()
  CALL obj%SetLocalElemShapeDataInTime()
END IF

IF (ALLOCATED(elemType)) DEALLOCATE (elemType)
IF (ALLOCATED(order)) DEALLOCATE (order)

#ifdef DEBUG_VER
CALL e%RaiseInformation(modName//'::'//myName//' - '// &
  & '[END] ')
#endif DEBUG_VER

END PROCEDURE obj_SetFiniteElements

!----------------------------------------------------------------------------
!                                                     SetQuadPointsInSpace
!----------------------------------------------------------------------------

MODULE PROCEDURE obj_SetQuadPointsInSpace
CHARACTER(*), PARAMETER :: myName = "obj_SetQuadPointsInSpace"
INTEGER(I4B) :: ii, tCell, order
CLASS(FiniteElement_), POINTER :: fe

#ifdef DEBUG_VER
CALL e%RaiseInformation(modName//'::'//myName//' - '// &
  & '[START] ')
#endif DEBUG_VER

IF (.NOT. ALLOCATED(obj%cellFE)) THEN
  CALL e%RaiseError(modName//'::'//myName//' - '// &
    & '[INTERNAL ERROR] AbstractKernel_::obj%cellFE not allocated')
END IF

tCell = SIZE(obj%cellFE)
fe => NULL()

IF (.NOT. ALLOCATED(obj%quadratureForSpace)) THEN
  ALLOCATE (obj%quadratureForSpace(tCell))
END IF

DO ii = 1, tCell
  fe => obj%cellFE(ii)%ptr
  CALL fe%GetParam(order=order)
  order = order * 2
  CALL fe%GetQuadraturePoints( &
    & quad=obj%quadratureForSpace(ii), &
    & quadratureType=[obj%quadTypeForSpace],  &
    & order=[order],  &
    & alpha=[obj%alphaForSpace],  &
    & beta=[obj%betaForSpace],  &
    & lambda=[obj%lambdaForSpace])
END DO

NULLIFY (fe)

#ifdef DEBUG_VER
CALL e%RaiseInformation(modName//'::'//myName//' - '// &
  & '[END] ')
#endif DEBUG_VER

END PROCEDURE obj_SetQuadPointsInSpace

!----------------------------------------------------------------------------
!                                                     SetQuadPointsInTime
!----------------------------------------------------------------------------

MODULE PROCEDURE obj_SetQuadPointsInTime
CHARACTER(*), PARAMETER :: myName = "obj_SetQuadPointsInTime"
INTEGER(I4B) :: order

#ifdef DEBUG_VER
CALL e%RaiseInformation(modName//'::'//myName//' - '// &
  & '[START]')
#endif

IF (obj%nnt .GT. 1) THEN
  CALL obj%timeFE%GetParam(order=order)
  order = order * 2
  CALL obj%timeFE%GetQuadraturePoints( &
    & quad=obj%quadratureForTime, &
    & quadratureType=[obj%quadTypeForTime],  &
    & order=[order],  &
    & alpha=[obj%alphaForTime],  &
    & beta=[obj%betaForTime],  &
    & lambda=[obj%lambdaForTime])
END IF

#ifdef DEBUG_VER
CALL e%RaiseInformation(modName//'::'//myName//' - '// &
  & '[END]')
#endif
END PROCEDURE obj_SetQuadPointsInTime

!----------------------------------------------------------------------------
!                                               SetLocalElemShapeDataInSpace
!----------------------------------------------------------------------------

! This routine Sets the local shape data in space (linSpaceElemSD and
! spaceElemSD) for the mesh.
! The quadrature points should be initiated before calling this routine.
MODULE PROCEDURE obj_SetLocalElemShapeDataInSpace
CHARACTER(*), PARAMETER :: myName = "obj_SetLocalElemShapeDataInSpace()"
INTEGER(I4B) :: ii, tCell
CLASS(FiniteElement_), POINTER :: fe

#ifdef DEBUG_VER
CALL e%RaiseInformation(modName//'::'//myName//' - '// &
  & '[START]')
#endif

IF (.NOT. ALLOCATED(obj%cellFE)) THEN
  CALL e%RaiseError(modName//'::'//myName//' - '// &
  & '[CONFIG ERROR] AbstractKernel_::obj%cellFE not allocated')
END IF

IF (.NOT. ALLOCATED(obj%quadratureForSpace)) THEN
  CALL e%RaiseError(modName//'::'//myName//' - '// &
  & '[CONFIG ERROR] AbstractKernel_::obj%quadratureForSpace not allocated')
END IF

tCell = SIZE(obj%cellFE)
fe => NULL()

IF (ALLOCATED(obj%spaceElemSD)) THEN
  CALL e%RaiseError(modName//'::'//myName//' - '// &
  & '[CONFIG ERROR] AbstractKernel_::obj%spaceElemSD already allocated')
END IF

IF (ALLOCATED(obj%linSpaceElemSD)) THEN
  CALL e%RaiseError(modName//'::'//myName//' - '// &
  & '[CONFIG ERROR] AbstractKernel_::obj%linSpaceElemSD already allocated')
END IF

ALLOCATE (obj%spaceElemSD(tCell), obj%linSpaceElemSD(tCell))

DO ii = 1, tCell
  fe => obj%cellFE(ii)%ptr
  CALL fe%GetLocalElemShapeData( &
    & quad=obj%quadratureForSpace(ii), &
    & elemsd=obj%spaceElemSD(ii))

  fe => obj%linCellFE(ii)%ptr
  CALL fe%GetLocalElemShapeData( &
    & quad=obj%quadratureForSpace(ii), &
    & elemsd=obj%linSpaceElemSD(ii))
END DO

NULLIFY (fe)

#ifdef DEBUG_VER
CALL e%RaiseInformation(modName//'::'//myName//' - '// &
  & '[END]')
#endif

END PROCEDURE obj_SetLocalElemShapeDataInSpace

!----------------------------------------------------------------------------
!                                               SetLocalElemShapeDataInTime
!----------------------------------------------------------------------------

! This routine Sets the local shape data in time (linTimeElemSD and
! timeElemSD) for the mesh.
! The quadrature points should be initiated before calling this routine.
MODULE PROCEDURE obj_SetLocalElemShapeDataInTime
CHARACTER(*), PARAMETER :: myName = "obj_SetLocalElemShapeDataInTime()"

#ifdef DEBUG_VER
CALL e%RaiseInformation(modName//'::'//myName//' - '// &
  & '[START]')
#endif

CALL obj%timeFE%GetLocalElemShapeData( &
  & quad=obj%quadratureForTime, &
  & elemsd=obj%timeElemSD)

CALL obj%linTimeFE%GetLocalElemShapeData( &
  & quad=obj%quadratureForTime, &
  & elemsd=obj%linTimeElemSD)

#ifdef DEBUG_VER
CALL e%RaiseInformation(modName//'::'//myName//' - '// &
  & '[END]')
#endif
END PROCEDURE obj_SetLocalElemShapeDataInTime

!----------------------------------------------------------------------------
!                                             SetGlobalElemShapeDataInSpace
!----------------------------------------------------------------------------

MODULE PROCEDURE obj_SetGlobalElemShapeDataInSpace
CHARACTER(*), PARAMETER :: myName = " obj_SetGlobalElemShapeDataInSpace()"
CALL e%RaiseError(modName//'::'//myName//' - '// &
  & '[WIP ERROR] :: This routine has not been implemented yet.')
END PROCEDURE obj_SetGlobalElemShapeDataInSpace

!----------------------------------------------------------------------------
!                                              SetGlobalElemShapeDataInTime
!----------------------------------------------------------------------------

MODULE PROCEDURE obj_SetGlobalElemShapeDataInTime
CHARACTER(*), PARAMETER :: myName = " obj_SetGlobalElemShapeDataInTime()"
CALL e%RaiseError(modName//'::'//myName//' - '// &
  & '[WIP ERROR] :: This routine has not been implemented yet.')
END PROCEDURE obj_SetGlobalElemShapeDataInTime

!----------------------------------------------------------------------------
!                                                    SetFacetFiniteElements
!----------------------------------------------------------------------------

MODULE PROCEDURE obj_SetFacetFiniteElements
CHARACTER(*), PARAMETER :: myName = "obj_SetFacetFiniteElements()"
CALL e%RaiseWarning(modName//'::'//myName//' - '// &
  & '[WIP WARNING] :: This routine has been implemented yet.')
END PROCEDURE obj_SetFacetFiniteElements

!----------------------------------------------------------------------------
!
!----------------------------------------------------------------------------

END SUBMODULE SetMethods