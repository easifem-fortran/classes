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

SUBMODULE(DomainConnectivity_Class) CellMethods
USE BaseMethod
IMPLICIT NONE
CONTAINS

!----------------------------------------------------------------------------
!
!----------------------------------------------------------------------------

MODULE PROCEDURE dc_initiateCellToCellData1
CHARACTER(*), PARAMETER :: myName = "dc_initiateCellToCellData1"
CLASS(Mesh_), POINTER :: mesh1 => NULL()
! mesh1 in domain1 (low order mesh)
CLASS(Mesh_), POINTER :: mesh2 => NULL()
! mesh2 in domain2 (high order mesh)
CLASS(ReferenceElement_), POINTER :: refelem1 => NULL()
! reference element in mesh1
CLASS(ReferenceElement_), POINTER :: refelem2 => NULL()
! refelem in mesh2
INTEGER(I4B) :: ii, jj, nsd, order1, order2, iel1, iel2
! some counters and indices
INTEGER(I4B), ALLOCATABLE :: nptrs1(:)
! node number in mesh1
INTEGER(I4B), ALLOCATABLE :: nptrs2(:), nptrs(:)
! node number in mesh2
INTEGER(I4B), ALLOCATABLE :: elem2(:)
! element numbers in mesh2
INTEGER(I4B), POINTER :: nodeToNode(:)
!> main
!> check
IF (.NOT. obj%isNodeToNode) &
  & CALL e%raiseError(modName//"::"//myName//" - "// &
  & 'NodeToNode data is not initiated!')
!> check
IF (obj%isCellToCell) THEN
  CALL e%raiseWarning(modName//"::"//myName//" - "// &
    & "It seems, obj%cellToCell data is already initiated")
END IF
!> get mesh pointer
mesh1 => domain1%GetMeshPointer(dim=dim1, entityNum=entityNum1)
mesh2 => domain2%GetMeshPointer(dim=dim2, entityNum=entityNum2)
! TODO
! is it possible to have bounds of obj%cellToCell from
! mesh1%minElemNum to mesh1%maxElemNum, it will save the space
CALL Reallocate(obj%cellToCell, mesh1%maxElemNum)
CALL Reallocate(obj%cellToCellExtraData, 2, mesh1%maxElemNum)
obj%isCellToCell = .TRUE.
!
!
!
refelem1 => mesh1%getRefElemPointer()
refelem2 => mesh2%getRefElemPointer()
!
!
!
IF (ElementTopology(refelem1) .NE. ElementTopology(refelem2)) &
    & CALL e%raiseError(modName//"::"//myName//" - "// &
    & 'Topology of mesh element is not the same.')
!
!
!
order1 = elementOrder(refelem1)
order2 = elementOrder(refelem2)
!>
! NOTE
! The size of nptrs1 and nptrs2 are the same.
! When order1 > order2, some of the entries in nptrs2
! will be zero. In this case size(nptrs2) .gt. size(nptrs)
!
! when order1 < order2, then size(nptrs) .gt. size(nptrs2)
! in this case we should use (nptrs2 .in nptrs)
!
nodeToNode => obj%getNodeToNodePointer()
IF (order1 .GE. order2) THEN
  DO iel1 = mesh1%minElemNum, mesh1%maxElemNum
    IF (.NOT. mesh1%isElementPresent(globalElement=iel1)) CYCLE
    nptrs1 = mesh1%getConnectivity(globalElement=iel1)
    nptrs2 = nodeToNode(nptrs1)
    !> Now we get the list of all elements in mesh2 which are
    ! connected/contains node number in nptrs2
    elem2 = mesh2%getNodeToElements(GlobalNode=nptrs2)
    !> now we are ready to search iel2 in elem2 which
    ! contains all nptrs2
    DO ii = 1, SIZE(elem2)
      iel2 = elem2(ii)
      nptrs = mesh2%getConnectivity(globalElement=iel2)
      IF (nptrs.in.nptrs2) THEN
        obj%cellToCell(iel1) = iel2
        obj%cellToCellExtraData(1, iel1) = dim2
        obj%cellToCellExtraData(2, iel1) = entityNum2
        EXIT
      END IF
    END DO
  END DO
ELSE
  DO iel1 = mesh1%minElemNum, mesh1%maxElemNum
    IF (.NOT. mesh1%isElementPresent(globalElement=iel1)) CYCLE
    nptrs1 = mesh1%getConnectivity(globalElement=iel1)
    nptrs2 = nodeToNode(nptrs1)
    !> Now we get the list of all elements in mesh2 which are
    ! connected/contains node number in nptrs2
    elem2 = mesh2%getNodeToElements(GlobalNode=nptrs2)
    !> now we are ready to search iel2 in elem2 which
    ! contains all nptrs2
    DO ii = 1, SIZE(elem2)
      iel2 = elem2(ii)
      nptrs = mesh2%getConnectivity(globalElement=iel2)
      IF (nptrs2.in.nptrs) THEN
        obj%cellToCell(iel1) = iel2
        obj%cellToCellExtraData(1, iel1) = dim2
        obj%cellToCellExtraData(2, iel1) = entityNum2
        EXIT
      END IF
    END DO
  END DO
END IF
!> cleanup
NULLIFY (mesh1, mesh2, refelem1, refelem2)
IF (ALLOCATED(nptrs1)) DEALLOCATE (nptrs1)
IF (ALLOCATED(nptrs2)) DEALLOCATE (nptrs2)
IF (ALLOCATED(nptrs)) DEALLOCATE (nptrs)
IF (ALLOCATED(elem2)) DEALLOCATE (elem2)
END PROCEDURE dc_initiateCellToCellData1

!----------------------------------------------------------------------------
!
!----------------------------------------------------------------------------

MODULE PROCEDURE dc_InitiateCellToCellData2
CHARACTER(*), PARAMETER :: myName = "dc_InitiateCellToCellData2"
CLASS(Mesh_), POINTER :: mesh1 => NULL()
! mesh1 in domain1 (low order mesh)
CLASS(Mesh_), POINTER :: mesh2 => NULL()
! mesh2 in domain2 (high order mesh)
CLASS(ReferenceElement_), POINTER :: refelem1 => NULL()
! reference element in mesh1
CLASS(ReferenceElement_), POINTER :: refelem2 => NULL()
! refelem in mesh2
INTEGER(I4B) :: ii, jj, nsd, order1, order2, iel1, iel2, dimEntity(2)
! some counters and indices
INTEGER(I4B), ALLOCATABLE :: nptrs1(:)
! node number in mesh1
INTEGER(I4B), ALLOCATABLE :: nptrs2(:), nptrs(:)
! node number in mesh2
INTEGER(I4B), ALLOCATABLE :: elem2(:)
! element numbers in mesh2
INTEGER(I4B), POINTER :: nodeToNode(:)
!
! main
!
!
! check
!
IF (.NOT. domain1%isInitiated) &
  & CALL e%raiseError(modName//"::"//myName//" - "// &
  & "Domain-1 is not initiated, first initiate")
!
! check
!
IF (.NOT. domain2%isInitiated) &
  & CALL e%raiseError(modName//"::"//myName//" - "// &
  & "Domain-2 is not initiated, first initiate")
!
! check
!
IF (.NOT. obj%isNodeToNode) &
    & CALL e%raiseError(modName//"::"//myName//" - "// &
    & 'NodeToNode data is not initiated!')
!
! check
!
IF (obj%isCellToCell) &
  & CALL e%raiseWarning(modName//"::"//myName//" - "// &
  & "It seems, obj%cellToCell data is already initiated")
!
! TODO is it possible to have bounds of obj%cellToCell from
!      domain1%minElemNum to domain1%maxElemNum,
!      it will save the space
!
CALL Reallocate(obj%cellToCell, domain1%maxElemNum)
CALL Reallocate(obj%cellToCellExtraData, 2, domain1%maxElemNum)
obj%isCellToCell = .TRUE.
nsd = domain1%getNSD()
!
!
!
nodeToNode => obj%getNodeToNodePointer()
!
! get mesh pointer
!
DO iel1 = domain1%minElemNum, domain1%maxElemNum
  !
  IF (.NOT. domain1%isElementPresent(globalElement=iel1)) CYCLE
  !
  mesh1 => domain1%GetMeshPointer(globalElement=iel1)
  refelem1 => mesh1%getRefElemPointer()
  !
  ! If the mesh is made of point elements then skip it
  !
  IF (refelem1%xidimension .EQ. 0) CYCLE
  !
  ! NOTE if the reference element is not a cell then
  !      skip it. We want to consider only the
  !      cells, i.e xidim == dim
  !
  ! Commented: IF (refelem1%xidimension .NE. nsd) CYCLE
  !
  order1 = elementOrder(refelem1)
  nptrs1 = mesh1%getConnectivity(globalElement=iel1)
  nptrs2 = nodeToNode(nptrs1)
  !
  ! Now we get the list of all elements in domain2
  ! which are connected/contains node number in nptrs2
  !
  ! NOTE some of these elements in elem2 may not be cell
  !      elements, i.e. xidim .ne. nsd
  !      we should skip such elements.
  !
  elem2 = domain2%getNodeToElements(GlobalNode=nptrs2)
  !
  ! now we are ready to search iel2 in elem2 which
  ! contains all nptrs2
  !
  DO ii = 1, SIZE(elem2)
    iel2 = elem2(ii)
    dimEntity = domain2%GetDimEntityNum(globalElement=iel2)
    mesh2 => domain2%GetMeshPointer( &
      & dim=dimEntity(1), &
      & entityNum=dimEntity(2))
    refelem2 => mesh2%getRefElemPointer()
    !
    ! skip if refelem2%xidim .ne. refelem1%xidim
    !
    IF (refelem2%xidimension .NE. refelem1%xidimension) CYCLE
    IF (ElementTopology(refelem1) .NE. ElementTopology(refelem2)) CYCLE
    !
    order2 = elementOrder(refelem2)
    nptrs = mesh2%getConnectivity(globalElement=iel2)
    !
    IF (order1 .GE. order2) THEN
      IF (nptrs.in.nptrs2) THEN
        obj%cellToCell(iel1) = iel2
        obj%cellToCellExtraData(:, iel1) = dimEntity
        EXIT
      END IF
    ELSE
      IF (nptrs2.in.nptrs) THEN
        obj%cellToCell(iel1) = iel2
        obj%cellToCellExtraData(:, iel1) = dimEntity
        EXIT
      END IF
    END IF
  END DO
END DO
! cleanup
NULLIFY (mesh1, mesh2, refelem1, refelem2)
IF (ALLOCATED(nptrs1)) DEALLOCATE (nptrs1)
IF (ALLOCATED(nptrs2)) DEALLOCATE (nptrs2)
IF (ALLOCATED(nptrs)) DEALLOCATE (nptrs)
IF (ALLOCATED(elem2)) DEALLOCATE (elem2)
END PROCEDURE dc_InitiateCellToCellData2

!----------------------------------------------------------------------------
!                                                      getCellToCellPointer
!----------------------------------------------------------------------------

MODULE PROCEDURE dc_getCellToCellPointer
ans => obj%cellTocell
END PROCEDURE dc_getCellToCellPointer

!----------------------------------------------------------------------------
!                                                            getDimEntityNum
!----------------------------------------------------------------------------

MODULE PROCEDURE dc_getDimEntityNum
ans = obj%cellToCellExtraData(1:2, globalElement)
END PROCEDURE dc_getDimEntityNum

END SUBMODULE CellMethods
