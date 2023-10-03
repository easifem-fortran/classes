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

MODULE MixedFiniteElement_Class
USE GlobalData
USE AbstractRefElement_Class
USE AbstractFE_Class
USE FiniteElement_Class, ONLY: FiniteElementPointer_
USE FPL, ONLY: ParameterList_
USE Domain_Class, ONLY: Domain_, DomainPointer_
IMPLICIT NONE
PRIVATE
PUBLIC :: MixedFiniteElement_
PUBLIC :: MixedFiniteElementPointer_
PUBLIC :: SetMixedFiniteElementParam
PUBLIC :: DEALLOCATE
PUBLIC :: Initiate
CHARACTER(*), PARAMETER :: modName = "MixedFiniteElement_Class"
CHARACTER(*), PARAMETER :: myprefix = "MixedFiniteElement"

!----------------------------------------------------------------------------
!                                                        AbstractRefElement_
!----------------------------------------------------------------------------

!> author: Vikas Sharma, Ph. D.
! date: 2023-08-13
! summary: Finite element class
!
!{!pages/docs-api/MixedFiniteElement/MixedFiniteElement_.md!}

TYPE, EXTENDS(AbstractFE_) :: MixedFiniteElement_
  TYPE(FiniteElementPointer_), ALLOCATABLE :: fe(:)
CONTAINS
  PRIVATE
  PROCEDURE, PUBLIC, PASS(obj) :: Initiate => fe_Initiate
  !! Constructor method for AbstractFE element
  PROCEDURE, PUBLIC, PASS(obj) :: DEALLOCATE => fe_Deallocate
  !! Deallocate data stored in Mixed finite element
  !! This method can be overloaded by Subclass of this abstract class.
  PROCEDURE, PUBLIC, PASS(obj) :: CheckEssentialParam => &
    & fe_CheckEssentialParam
END TYPE MixedFiniteElement_

!----------------------------------------------------------------------------
!                                                      FiniteElementPointer_
!----------------------------------------------------------------------------

TYPE :: MixedFiniteElementPointer_
  CLASS(MixedFiniteElement_), POINTER :: ptr => NULL()
END TYPE MixedFiniteElementPointer_

!----------------------------------------------------------------------------
!                                               CheckEssentialParam@Methods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 2023-08-11
! summary: This routine Check the essential parameters in param.

INTERFACE
  MODULE SUBROUTINE fe_CheckEssentialParam(obj, param)
    CLASS(MixedFiniteElement_), INTENT(IN) :: obj
    TYPE(ParameterList_), INTENT(IN) :: param
  END SUBROUTINE fe_CheckEssentialParam
END INTERFACE

!----------------------------------------------------------------------------
!                                                Initiate@ConstructorMethods
!----------------------------------------------------------------------------

!> author: Vikas Sharma, Ph. D.
! date: 2023-10-02
! summary: Initiates an instance of the finite element

INTERFACE
  MODULE SUBROUTINE fe_Initiate(obj, param)
    CLASS(MixedFiniteElement_), INTENT(INOUT) :: obj
    TYPE(ParameterList_), INTENT(IN) :: param
  END SUBROUTINE fe_Initiate
END INTERFACE

!----------------------------------------------------------------------------
!                                                Initiate@ConstructorMethods
!----------------------------------------------------------------------------

!> author: Vikas Sharma, Ph. D.
! date: 2023-10-02
! summary: Initiates an instance of the finite element

INTERFACE DEALLOCATE
  MODULE SUBROUTINE fe_Deallocate(obj)
    CLASS(MixedFiniteElement_), INTENT(INOUT) :: obj
  END SUBROUTINE fe_Deallocate
END INTERFACE DEALLOCATE

!----------------------------------------------------------------------------
!                                                         Deallocate@Methods
!----------------------------------------------------------------------------

!> author: Vikas Sharma, Ph. D.
! date: 2023-09-25
! summary:  Deallocate a vector of FiniteElement

INTERFACE DEALLOCATE
  MODULE SUBROUTINE Deallocate_Vector(obj)
    TYPE(MixedFiniteElement_), ALLOCATABLE :: obj(:)
  END SUBROUTINE Deallocate_Vector
END INTERFACE DEALLOCATE

!----------------------------------------------------------------------------
!                                                         Deallocate@Methods
!----------------------------------------------------------------------------

!> author: Vikas Sharma, Ph. D.
! date:  2023-09-09
! summary:  Deallocate the vector of NeumannBC_

INTERFACE DEALLOCATE
  MODULE SUBROUTINE Deallocate_Ptr_Vector(obj)
    TYPE(MixedFiniteElementPointer_), ALLOCATABLE :: obj(:)
  END SUBROUTINE Deallocate_Ptr_Vector
END INTERFACE DEALLOCATE

!----------------------------------------------------------------------------
!                                                SetAbstractFEParam@Methods
!----------------------------------------------------------------------------

!> author: Vikas Sharma, Ph. D.
! date:  2023-08-11
! summary:  Sets the parameters for initiating abstract finite element

INTERFACE
  MODULE SUBROUTINE SetMixedFiniteElementParam( &
    & param, &
    & tFiniteElements, & 
    & iFiniteElement, &
    & nsd, &
    & elemType, &
    & baseContinuity, &
    & baseInterpolation, &
    & ipType, &
    & basisType, &
    & alpha, &
    & beta, &
    & lambda, &
    & order,  &
    & anisoOrder,  &
    & edgeOrder,  &
    & faceOrder,  &
    & cellOrder)
    TYPE(ParameterList_), INTENT(INOUT) :: param
    INTEGER(I4B), INTENT(IN) :: tFiniteElements
      !! Total number of finite elements
    INTEGER( I4B ), INTENT( IN ) :: iFiniteElement
      !! Finite element number
    INTEGER(I4B), INTENT(IN) :: nsd
      !! Number of spatial dimension
    INTEGER(I4B), INTENT(IN) :: elemType
      !! Type of finite element
      !! Line, Triangle, Quadrangle, Tetrahedron, Prism, Pyramid,
      !! Hexahedron
    CHARACTER(*), INTENT(IN) :: baseContinuity
      !! Continuity or Conformity of basis function.
      !! This parameter is used to determine the nodal coordinates of
      !! reference element, when xij is not present.
      !! If xij is present then this parameter is ignored
      !! H1* (default), HDiv, HCurl, DG
    CHARACTER(*), INTENT(IN) :: baseInterpolation
      !! Basis function family used for interpolation.
      !! This parameter is used to determine the nodal coordinates of
      !! reference element, when xij is not present.
      !! If xij is present then this parameter is ignored
      !! LagrangeInterpolation, LagrangePolynomial
      !! SerendipityInterpolation, SerendipityPolynomial
      !! HierarchyInterpolation, HierarchyPolynomial
      !! OrthogonalInterpolation, OrthogonalPolynomial
      !! HermitInterpolation, HermitPolynomial
    INTEGER(I4B), OPTIONAL, INTENT(IN) :: ipType
      !! Interpolation point type, It is required when
      !! baseInterpol is LagrangePolynomial
    INTEGER(I4B), OPTIONAL, INTENT(IN) :: basisType(:)
      !! Basis type: Legendre, Lobatto, Ultraspherical,
      !! Jacobi, Monomial
    REAL(DFP), OPTIONAL, INTENT(IN) :: alpha(:)
      !! Jacobi parameter
    REAL(DFP), OPTIONAL, INTENT(IN) :: beta(:)
      !! Jacobi parameter
    REAL(DFP), OPTIONAL, INTENT(IN) :: lambda(:)
      !! Ultraspherical parameters
    INTEGER(I4B), OPTIONAL, INTENT(IN) :: order
      !! Isotropic Order of finite element
    INTEGER(I4B), OPTIONAL, INTENT(IN) :: anisoOrder(:)
    !! Anisotropic order, order in x, y, and z directions
    INTEGER(I4B), OPTIONAL, INTENT(IN) :: edgeOrder(:)
      !! Order of approximation along edges
    INTEGER(I4B), OPTIONAL, INTENT(IN) :: faceOrder(:)
      !! Order of approximation along face
    INTEGER(I4B), OPTIONAL, INTENT(IN) :: cellOrder(:)
      !! Order of approximation along cell
  END SUBROUTINE SetMixedFiniteElementParam
END INTERFACE

!----------------------------------------------------------------------------
!                                                                 Initiate
!----------------------------------------------------------------------------

!> author: Vikas Sharma, Ph. D.
! date:  2023-09-22
! summary:  Initiate vector of FiniteElement pointers

INTERFACE Initiate
  MODULE SUBROUTINE fe_Initiate1(obj, param, dom)
    TYPE(MixedFiniteElementPointer_), ALLOCATABLE, INTENT(INOUT) :: obj(:)
    TYPE(ParameterList_), INTENT(IN) :: param
    CLASS(Domain_), INTENT(IN) :: dom
  END SUBROUTINE fe_Initiate1
END INTERFACE Initiate

!----------------------------------------------------------------------------
!                                                                 Initiate
!----------------------------------------------------------------------------

!> author: Vikas Sharma, Ph. D.
! date:  2023-09-22
! summary:  Initiate vector of FiniteElement pointers

INTERFACE Initiate
  MODULE SUBROUTINE fe_Initiate2(obj, param, dom)
    TYPE(MixedFiniteElementPointer_), ALLOCATABLE, INTENT(INOUT) :: obj(:)
    TYPE(ParameterList_), INTENT(IN) :: param
    CLASS(DomainPointer_), INTENT(IN) :: dom(:)
  END SUBROUTINE fe_Initiate2
END INTERFACE Initiate

END MODULE MixedFiniteElement_Class