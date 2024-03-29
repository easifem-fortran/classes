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

SUBMODULE(AbstractNodeField_Class) IOMethods
USE BaseMethod
USE HDF5File_Method
USE Mesh_Class
IMPLICIT NONE
CONTAINS

!----------------------------------------------------------------------------
!                                                                   Display
!----------------------------------------------------------------------------

MODULE PROCEDURE obj_Display
CALL AbstractFieldDisplay(obj=obj, msg=msg, unitNo=unitNo)
CALL Display(obj%tSize, "tSize: ", unitNo=unitNo)
CALL Display(obj%realVec, obj%dof, "realVec: ", unitNo=unitNo)
END PROCEDURE obj_Display

!----------------------------------------------------------------------------
!                                                                    Import
!----------------------------------------------------------------------------

MODULE PROCEDURE obj_Import
CHARACTER(*), PARAMETER :: myName = "obj_Import()"
TYPE(String) :: dsetname
LOGICAL(LGT) :: abool
TYPE(ParameterList_) :: param

#ifdef DEBUG_VER
CALL e%RaiseInformation(modName//'::'//myName//' - '// &
  & '[START] ')
#endif

CALL AbstractFieldImport( &
  & obj=obj, &
  & hdf5=hdf5, &
  & group=group, &
  & dom=dom, &
  & domains=domains)

dsetname = TRIM(group)//"/tSize"
abool = hdf5%pathExists(dsetname%chars())
IF (abool) THEN
  CALL hdf5%READ(dsetname=dsetname%chars(), vals=obj%tSize)
END IF

dsetname = TRIM(group)//"/dof"
abool = hdf5%pathExists(dsetname%chars())
IF (abool) THEN
  CALL ImportDOF(obj=obj%dof, hdf5=hdf5, group=dsetname%chars())
END IF

dsetname = TRIM(group)//"/realVec"
abool = hdf5%pathExists(dsetname%chars())
IF (abool) THEN
  CALL ImportRealVector(obj=obj%realvec, hdf5=hdf5, &
  & group=dsetname%chars())
END IF

#ifdef DEBUG_VER
CALL e%RaiseInformation(modName//'::'//myName//' - '// &
  & '[END] ')
#endif

END PROCEDURE obj_Import

!----------------------------------------------------------------------------
!                                                                    Export
!----------------------------------------------------------------------------

MODULE PROCEDURE obj_Export
CHARACTER(*), PARAMETER :: myName = "obj_Export()"
TYPE(String) :: strval, dsetname

#ifdef DEBUG_VER
CALL e%RaiseInformation(modName//'::'//myName//' - '// &
  & '[START] ')
#endif

CALL AbstractFieldExport(obj=obj, hdf5=hdf5, group=group)

! tSize
dsetname = TRIM(group)//"/tSize"
CALL hdf5%WRITE(dsetname=dsetname%chars(), vals=obj%tSize)

! dof
dsetname = TRIM(group)//"/dof"
CALL ExportDOF(obj=obj%dof, hdf5=hdf5, group=dsetname%chars())

! realVec
dsetname = TRIM(group)//"/realVec"
CALL ExportRealVector(obj=obj%realVec, hdf5=hdf5, &
  & group=dsetname%chars())

! info
#ifdef DEBUG_VER
CALL e%RaiseInformation(modName//'::'//myName//' - '// &
  & '[END] ')
#endif

END PROCEDURE obj_Export

SUBROUTINE ExportFieldToVTK(obj, vtk, nptrs, tPhysicalVars, dofNames,  &
           & spaceCompo, timeCompo)
  IMPLICIT NONE
  CLASS(AbstractNodeField_), INTENT(INOUT) :: obj
  TYPE(VTKFile_), INTENT(INOUT) :: vtk
  INTEGER(I4B), INTENT(IN) :: nptrs(:), spaceCompo(:), timeCompo(:)
  INTEGER(I4B), INTENT(IN) :: tPhysicalVars
  CHARACTER(1), INTENT(IN) :: dofNames(:)
  INTEGER(I4B) :: ivar, var_rank, var_vartype, itime
  REAL(DFP), ALLOCATABLE :: r1(:), r2(:, :), r3(:, :, :)
  TYPE(FEVariable_) :: fevar
  CHARACTER(*), PARAMETER :: myName = "ExportToVTK"
  CHARACTER(:), ALLOCATABLE :: name

  DO ivar = 1, tPhysicalVars
    CALL obj%GetFEVariable(globalNode=nptrs, VALUE=fevar, ivar=ivar)

    name = obj%name%raw//"_"//dofNames(ivar)
    var_rank = .RANK.fevar
    var_vartype = .vartype.fevar

    SELECT CASE (var_rank)
    CASE (Scalar)
      IF (var_vartype .EQ. Space) THEN
        r1 = Get(fevar, TypeFEVariableScalar, TypeFEVariableSpace)
        CALL vtk%WriteDataArray( &
          & name=String(name),  &
          & x=r1,  &
          & numberOfComponents=spaceCompo(ivar))
      END IF

      IF (var_vartype .EQ. SpaceTime) THEN
        r2 = Get(fevar, TypeFEVariableScalar, TypeFEVariableSpaceTime)
        DO itime = 1, timeCompo(ivar)
          CALL vtk%WriteDataArray( &
            & name=String(name//"_t"//tostring(itime)),  &
            & x=r2(itime, :),  &
            & numberOfComponents=spaceCompo(ivar))
        END DO
      END IF

    CASE (Vector)
      IF (var_vartype .EQ. Space) THEN
        r2 = Get(fevar, TypeFEVariableVector, TypeFEVariableSpace)
        CALL vtk%WriteDataArray( &
          & name=String(name),  &
          & x=r2,  &
          & numberOfComponents=spaceCompo(ivar))
      END IF

      IF (var_vartype .EQ. SpaceTime) THEN
        r3 = Get(fevar, TypeFEVariableVector, TypeFEVariableSpaceTime)
        DO itime = 1, timeCompo(ivar)
          CALL vtk%WriteDataArray( &
            & name=String(name//"_t"//tostring(itime)),  &
            & x=r3(:, :, itime),  &
            & numberOfComponents=spaceCompo(ivar))
        END DO
      END IF

    CASE DEFAULT
      CALL e%RaiseError(modName//'::'//myName//' - '// &
        & '[INTERNAL ERROR] :: No case found for fevar')
    END SELECT
    DEALLOCATE (name)
  END DO
  CALL DEALLOCATE (fevar)
  IF (ALLOCATED(r1)) DEALLOCATE (r1)
  IF (ALLOCATED(r2)) DEALLOCATE (r2)
  IF (ALLOCATED(r3)) DEALLOCATE (r3)

END SUBROUTINE ExportFieldToVTK

!----------------------------------------------------------------------------
!                                                             WriteData
!----------------------------------------------------------------------------

MODULE PROCEDURE obj_WriteData1_vtk
CHARACTER(*), PARAMETER :: myName = "obj_WriteData1_vtk()"
LOGICAL(LGT) :: isOK, isSingleDomain, isMultiDomain
TYPE(Domain_), POINTER :: dom
TYPE(Mesh_), POINTER :: meshPtr
INTEGER(I4B) :: imesh, tMesh, nsd, tPhysicalVars, tComponents, ivar, &
& tnodes, var_rank, var_vartype, itime
INTEGER(I4B), ALLOCATABLE :: nptrs(:), spaceCompo(:), timeCompo(:)
REAL(DFP), ALLOCATABLE :: r1(:), r2(:, :), r3(:, :, :), xij(:, :)
CHARACTER(1), ALLOCATABLE :: dofNames(:)
TYPE(FEVariable_) :: fevar

#ifdef DEBUG_VER
CALL e%RaiseInformation(modName//'::'//myName//' - '// &
  & '[START]')
#endif

NULLIFY (dom, meshPtr)

isOK = obj%isInitiated
IF (.NOT. isOK) THEN
  CALL e%RaiseError(modName//'::'//myName//' - '// &
    & '[INTERNAL ERROR] :: AbstractNodeField_::obj is not isInitiated.')
  RETURN
END IF

isOK = vtk%isOpen()
IF (.NOT. isOK) THEN
  CALL e%RaiseError(modName//'::'//myName//' - '// &
    & '[INTERNAL ERROR] :: VTKFile_::vtk is not open.')
  RETURN
END IF

isSingleDomain = ASSOCIATED(obj%domain)
isMultiDomain = ALLOCATED(obj%domains)
isOK = isSingleDomain .OR. isMultiDomain
IF (.NOT. isOK) THEN
  CALL e%RaiseError(modName//'::'//myName//' - '// &
    & '[INTERNAL ERROR] :: Either AbstractNodeField_::obj%domain, '// &
    & ' ot AbstractNodeField_::obj%domains not allocated.')
  RETURN
END IF

tPhysicalVars = obj%GetTotalPhysicalVars()
ALLOCATE (dofNames(tPhysicalVars), spaceCompo(tPhysicalVars),  &
  & timeCompo(tPhysicalVars))
CALL obj%GetPhysicalNames(dofNames)
spaceCompo = obj%GetSpaceCompo(tPhysicalVars)
timeCompo = obj%GetTimeCompo(tPhysicalVars)

IF (isSingleDomain) THEN
  dom => obj%domain
  nsd = dom%GetNSD()
  tMesh = dom%GetTotalMesh(dim=nsd)

  DO imesh = 1, tMesh
    meshptr => dom%GetMeshPointer(dim=nsd, entityNum=imesh)

    CALL dom%GetNodeCoord(nodeCoord=xij, dim=nsd, entityNum=imesh)

    CALL meshPtr%ExportToVTK(vtkfile=vtk, nodeCoord=xij,  &
      & openTag=.TRUE., content=.TRUE., closeTag=.FALSE.)

    CALL vtk%WriteDataArray(location=String('node'), action=String('open'))

    nptrs = meshPtr%GetNptrs()
    tnodes = meshPtr%GetTotalNodes()

    CALL ExportFieldToVTK(obj, vtk, nptrs, tPhysicalVars, dofNames,  &
    & spaceCompo, timeCompo)

    CALL vtk%WriteDataArray(location=String('node'), action=String('close'))

    CALL vtk%WritePiece()
  END DO

  IF (ALLOCATED(nptrs)) DEALLOCATE (nptrs)
  IF (ALLOCATED(xij)) DEALLOCATE (xij)
  IF (ALLOCATED(dofNames)) DEALLOCATE (dofNames)
  IF (ALLOCATED(spaceCompo)) DEALLOCATE (spaceCompo)
  IF (ALLOCATED(timeCompo)) DEALLOCATE (timeCompo)
  NULLIFY (meshPtr, dom)

END IF

#ifdef DEBUG_VER
CALL e%RaiseInformation(modName//'::'//myName//' - '// &
  & '[END]')
#endif
END PROCEDURE obj_WriteData1_vtk

!----------------------------------------------------------------------------
!                                                             WriteData
!----------------------------------------------------------------------------

MODULE PROCEDURE obj_WriteData2_vtk
CHARACTER(*), PARAMETER :: myName = "obj_WriteData2_vtk()"
LOGICAL(LGT) :: isOK, isSingleDomain, isMultiDomain
TYPE(Domain_), POINTER :: dom
TYPE(Mesh_), POINTER :: meshPtr
INTEGER(I4B) :: imesh, tMesh, nsd, ivar, &
& tnodes, var_rank, var_vartype, itime
INTEGER(I4B), ALLOCATABLE :: nptrs(:), tPhysicalVars(:)
TYPE(IntVector_), ALLOCATABLE :: spaceCompo(:), timeCompo(:)
REAL(DFP), ALLOCATABLE :: r1(:), r2(:, :), r3(:, :, :), xij(:, :)
CHARACTER(1), ALLOCATABLE :: dofNames(:), dofNames_sub(:)
TYPE(FEVariable_) :: fevar
INTEGER(I4B) :: tfield, iobj, tsize, aint
TYPE(DomainPointer_), ALLOCATABLE :: domains(:)
CLASS(AbstractNodeField_), POINTER :: obj0

tfield = SIZE(obj)
ALLOCATE (domains(tfield))
ALLOCATE (tPhysicalVars(tfield))
ALLOCATE (spaceCompo(tfield))
ALLOCATE (timeCompo(tfield))

#ifdef DEBUG_VER
CALL e%RaiseInformation(modName//'::'//myName//' - '// &
  & '[START]')
#endif

NULLIFY (dom, meshPtr, obj0)

isOK = vtk%isOpen()
IF (.NOT. isOK) THEN
  CALL e%RaiseError(modName//'::'//myName//' - '// &
    & '[INTERNAL ERROR] :: VTKFile_::vtk is not open.')
  RETURN
END IF

DO iobj = 1, tfield
  obj0 => obj(iobj)%ptr
  IF (.NOT. ASSOCIATED(obj0)) CYCLE

  isOK = obj0%isInitiated
  IF (.NOT. isOK) THEN
    CALL e%RaiseError(modName//'::'//myName//' - '// &
    & '[INTERNAL ERROR] :: AbstractNodeField_:: '// &
    & 'obj('//tostring(iobj)//') is not Initiated.')
    RETURN
  END IF

  isOK = ASSOCIATED(obj0%domain)
  IF (.NOT. isOK) THEN
    CALL e%RaiseError(modName//'::'//myName//' - '// &
      & '[INTERNAL ERROR] :: AbstractNodeField_::'// &
      & 'obj('//tostring(iobj)//')%domain is not associated')
    RETURN
  END IF

  IF (.NOT. ASSOCIATED(dom)) THEN
    dom => obj0%domain
  ELSE
    isOK = ASSOCIATED(dom, obj0%domain)
    IF (.NOT. isOK) THEN
      CALL e%RaiseError(modName//'::'//myName//' - '// &
        & '[INTERNAL ERROR] :: AbstractNodeField_ :: '//  &
        & 'associated domain should  be the same ')
    END IF
  END IF
END DO

nsd = dom%GetNSD()
tMesh = dom%GetTotalMesh(dim=nsd)

tsize = 0
DO iobj = 1, tfield
  obj0 => obj(iobj)%ptr
  IF (.NOT. ASSOCIATED(obj0)) THEN
    tPhysicalVars(iobj) = 0
    CALL Initiate(spaceCompo(iobj), 0)
    CALL Initiate(timeCompo(iobj), 0)

  ELSE
    tPhysicalVars(iobj) = obj0%GetTotalPhysicalVars()
    spaceCompo(iobj) = obj0%GetSpaceCompo(tPhysicalVars(iobj))
    timeCompo(iobj) = obj0%GetTimeCompo(tPhysicalVars(iobj))
  END IF

  tsize = tsize + tPhysicalVars(iobj)
END DO

ALLOCATE (dofNames(tsize))
tsize = 0
DO iobj = 1, tfield
  obj0 => obj(iobj)%ptr
  IF (.NOT. ASSOCIATED(obj0)) CYCLE

  ALLOCATE (dofNames_sub(tPhysicalVars(iobj)))
  CALL obj0%GetPhysicalNames(dofNames_sub)
  dofNames(tsize + 1:tsize + tPhysicalVars(iobj)) = dofNames_sub
  tsize = tsize + tPhysicalVars(iobj)
  DEALLOCATE (dofNames_sub)
END DO

DO imesh = 1, tMesh
  meshptr => dom%GetMeshPointer(dim=nsd, entityNum=imesh)

  CALL dom%GetNodeCoord(nodeCoord=xij, dim=nsd, entityNum=imesh)

  CALL meshPtr%ExportToVTK(vtkfile=vtk, nodeCoord=xij,  &
    & openTag=.TRUE., content=.TRUE., closeTag=.FALSE.)

  CALL vtk%WriteDataArray(location=String('node'), action=String('open'))

  nptrs = meshPtr%GetNptrs()
  tnodes = meshPtr%GetTotalNodes()

  tsize = 0
  DO iobj = 1, tfield
    obj0 => obj(iobj)%ptr
    IF (.NOT. ASSOCIATED(obj0)) CYCLE

    aint = tsize + tPhysicalVars(iobj)
    CALL ExportFieldToVTK(obj0, vtk, nptrs, tPhysicalVars(iobj),  &
        & dofNames(tsize + 1:aint), spaceCompo(iobj)%val, timeCompo(iobj)%val)
    tsize = aint

  END DO

  IF (ALLOCATED(nptrs)) DEALLOCATE (nptrs)
  IF (ALLOCATED(xij)) DEALLOCATE (xij)
  CALL vtk%WriteDataArray(location=String('node'), action=String('close'))
  CALL vtk%WritePiece()
END DO

DEALLOCATE (tPhysicalVars)
DEALLOCATE (dofNames)
DEALLOCATE (spaceCompo)
DEALLOCATE (timeCompo)
NULLIFY (meshPtr, dom, obj0)

#ifdef DEBUG_VER
CALL e%RaiseInformation(modName//'::'//myName//' - '// &
  & '[END]')
#endif

END PROCEDURE obj_WriteData2_vtk
!----------------------------------------------------------------------------
!
!----------------------------------------------------------------------------

END SUBMODULE IOMethods
