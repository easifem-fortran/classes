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

!> author: Vikas Sharma, Ph. D.
! date: 9 Aug 2022
! summary: Reference element for tetrahedron is implemented

MODULE RefTetrahedron_Class
USE GlobalData
USE Topology_Class
USE AbstractRefElement_Class
USE ExceptionHandler_Class, ONLY: e
IMPLICIT NONE
PRIVATE
CHARACTER(*), PARAMETER :: modName = "RefTetrahedron_Class"
PUBLIC :: RefTetrahedron_
PUBLIC :: RefTetrahedronPointer_

!----------------------------------------------------------------------------
!                                                   RefTetrahedron_
!----------------------------------------------------------------------------

!> author: Vikas Sharma, Ph. D.
! date: 9 Aug 2022
! summary:         RefTetrahedron class is defined
!
!{!pages/docs-api/RefTetrahedron/RefTetrahedron_.md!}

TYPE, EXTENDS(AbstractRefElement_) :: RefTetrahedron_
CONTAINS
  PROCEDURE, PUBLIC, PASS(obj) :: GetName => refelem_GetName
  !! Return the name of the element
  PROCEDURE, PUBLIC, PASS(obj) :: GetFacetElements => &
    & refelem_GetFacetElements
  !! Returns the facet elements
  PROCEDURE, PUBLIC, PASS(obj) :: RefCoord => refelem_RefCoord
  !! returns coordiantes of linear reference elements
END TYPE RefTetrahedron_

!----------------------------------------------------------------------------
!                                            RefTetrahedronPointer_
!----------------------------------------------------------------------------

TYPE :: RefTetrahedronPointer_
  CLASS(RefTetrahedron_), POINTER :: ptr => NULL()
END TYPE RefTetrahedronPointer_

!----------------------------------------------------------------------------
!                                                         RefCoord@Methods
!----------------------------------------------------------------------------

!> author: Vikas Sharma, Ph. D.
! date: 2023-08-09
! summary: Return the reference coordiante of linear element

INTERFACE
 MODULE FUNCTION refelem_RefCoord(obj, baseInterpolation, baseContinuity)  &
    & RESULT(ans)
    CLASS(RefTetrahedron_), INTENT(IN) :: obj
    CHARACTER(*), INTENT(IN) :: baseInterpolation
    CHARACTER(*), INTENT(IN) :: baseContinuity
    REAL(DFP), ALLOCATABLE :: ans(:, :)
  END FUNCTION refelem_RefCoord
END INTERFACE

!----------------------------------------------------------------------------
!                                                           GetName@Methods
!----------------------------------------------------------------------------

!> author: Vikas Sharma, Ph. D.
! date: 25 July 2022
! summary: Returns the name of the element

INTERFACE
  MODULE PURE FUNCTION refelem_GetName(obj) RESULT(ans)
    CLASS(RefTetrahedron_), INTENT(IN) :: obj
    INTEGER(I4B) :: ans
  END FUNCTION refelem_GetName
END INTERFACE

!----------------------------------------------------------------------------
!                                                   GetFacetElements@Methods
!----------------------------------------------------------------------------

!> author: Vikas Sharma, Ph. D.
! date: 16 June 2021
! summary: This routine returns the facet elements
!
!# Introduction
!
! Returns the facet elements.

INTERFACE
  MODULE SUBROUTINE refelem_GetFacetElements(obj, ans)
    CLASS(RefTetrahedron_), INTENT(IN) :: obj
    TYPE(AbstractRefElementPointer_), ALLOCATABLE :: ans(:)
  END SUBROUTINE refelem_GetFacetElements
END INTERFACE

!----------------------------------------------------------------------------
!
!----------------------------------------------------------------------------

END MODULE RefTetrahedron_Class
