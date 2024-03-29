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

SUBMODULE(mshPhysicalNames_Class) Methods
USE BaseMethod
IMPLICIT NONE
CONTAINS

!----------------------------------------------------------------------------
!                                                                      Final
!----------------------------------------------------------------------------

MODULE PROCEDURE pn_final
CALL obj%DEALLOCATE()
END PROCEDURE pn_final

!----------------------------------------------------------------------------
!                                                             Deallocate
!----------------------------------------------------------------------------

MODULE PROCEDURE pn_Deallocate
IF (ALLOCATED(obj%NSD)) DEALLOCATE (obj%NSD)
IF (ALLOCATED(obj%Tag)) DEALLOCATE (obj%Tag)
IF (ALLOCATED(obj%numElements)) DEALLOCATE (obj%numElements)
IF (ALLOCATED(obj%numNodes)) DEALLOCATE (obj%numNodes)
IF (ALLOCATED(obj%Entities)) DEALLOCATE (obj%Entities)
IF (ALLOCATED(obj%PhysicalName)) DEALLOCATE (obj%PhysicalName)
obj%isInitiated = .FALSE.
END PROCEDURE pn_Deallocate

!----------------------------------------------------------------------------
!                                                          GotoTag
!----------------------------------------------------------------------------

MODULE PROCEDURE pn_GotoTag
! Define internal variables
INTEGER(I4B) :: IOSTAT, Reopen, unitNo
CHARACTER(100) :: Dummy
CHARACTER(*), PARAMETER :: myName = "pn_GotoTag"
LOGICAL(LGT) :: isNotOpen, isNotRead

! Find $PhysicalNames

#ifdef DEBUG_VER
CALL e%raiseInformation(modName//'::'//myName//' - '// &
  & '[START] GotoTag()')
#endif

isNotOpen = .NOT. mshFile%isOpen()
isNotRead = .NOT. mshFile%isRead()

IF (isNotOpen .OR. isNotRead) THEN

  CALL e%raiseError(modName//'::'//myName//' - '// &
    & '[INTERNAL ERROR] :: mshFile is either not opened or does not have read access!')
  error = -1
  RETURN

END IF

Reopen = 0
error = 0

#ifndef Darwin_SYSTEM
  CALL mshFile%REWIND()
#endif

DO
  unitNo = mshFile%getUnitNo()
  READ (unitNo, "(A)", IOSTAT=IOSTAT) Dummy
  IF (IS_IOSTAT_END(IOSTAT)) THEN
    CALL mshFile%setEOFStat(.TRUE.)

#ifdef Darwin_SYSTEM
    CALL mshFile%CLOSE()
    CALL mshFile%OPEN()
#endif

    Reopen = Reopen + 1

  END IF
  IF (IOSTAT .GT. 0 .OR. Reopen .GT. 1) THEN
    error = -2
    EXIT
  ELSE IF (TRIM(Dummy) .EQ. '$PhysicalNames') THEN
    EXIT
  END IF
END DO

#ifdef DEBUG_VER
CALL e%raiseInformation(modName//'::'//myName//' - '// &
  & '[END] GotoTag()')
#endif
END PROCEDURE pn_GotoTag

!----------------------------------------------------------------------------
!                                                               ReadFromFile
!----------------------------------------------------------------------------

MODULE PROCEDURE pn_Read
! Define internal variables
INTEGER(I4B) :: IOSTAT, tp, k, unitNo
CHARACTER(maxStrLen) :: dummystr
CHARACTER(*), PARAMETER :: myName = "pn_Read"

#ifdef DEBUG_VER
CALL e%RaiseInformation(modName //'::'//myName// ' - '// &
  & '[START] Read()')
#endif

! Go to $PhysicalNames
CALL obj%GotoTag(mshFile, error)

IF (error .EQ. 0) THEN

  CALL obj%DEALLOCATE()
  obj%isInitiated = .TRUE.
  unitNo = mshFile%getUnitNo()
  READ (UnitNo, *) tp
  ALLOCATE ( &
    & obj%numElements(tp), &
    & obj%numNodes(tp), &
    & obj%NSD(tp), &
    & obj%Tag(tp), &
    & obj%PhysicalName(tp), &
    & obj%Entities(tp))
  obj%numElements = 0
  obj%numNodes = 0
  DO k = 1, tp
    READ (UnitNo, *, IOSTAT=IOSTAT) obj%NSD(k), &
      & obj%Tag(k), dummystr
    obj%PhysicalName(k) = String(dummystr)
    dummystr = ""
  END DO
ELSE
  obj%isInitiated = .FALSE.
  CALL obj%DEALLOCATE()
END IF

#ifdef DEBUG_VER
CALL e%RaiseInformation(modName //'::'//myName// ' - '// &
  & '[END] Read()')
#endif
END PROCEDURE pn_Read

!----------------------------------------------------------------------------
!                                                               WriteToFile
!----------------------------------------------------------------------------

MODULE PROCEDURE pn_Write
INTEGER(I4B) :: k, tp, iostat
INTEGER(I4B) :: unitNo
CHARACTER(1024) :: iomsg
CHARACTER(*), PARAMETER :: myName = "fmt_Write"

IF (obj%isInitiated) THEN

  unitNo = afile%getUnitNo()
  IF (ALLOCATED(obj%NSD)) THEN
    tp = SIZE(obj%NSD)
  ELSEIF (ALLOCATED(obj%tag)) THEN
    tp = SIZE(obj%tag)
  ELSE
    tp = 0
  END IF

  WRITE (unitNo, "( A )", iomsg=iomsg, iostat=iostat) &
   & "$PhysicalNames"
  IF (iostat .NE. 0) THEN
    CALL e%raiseError(modName//'::'//myName//' - '// &
    & 'Error occured in writing format msg = '//TRIM(iomsg))
  END IF

  WRITE (unitNo, "( A )", iomsg=iomsg, iostat=iostat) &
  & tostring(tp)

  IF (iostat .NE. 0) THEN
    CALL e%raiseError(modName//'::'//myName//' - '// &
    & 'Error occured in writing format msg = '//TRIM(iomsg))
  END IF
  DO k = 1, tp
    WRITE (unitNo, "( A )", iomsg=iomsg, iostat=iostat) &
      & TRIM(str(obj%NSD(k), .TRUE.)) &
      & //" " &
      & //TRIM(str(obj%Tag(k), .TRUE.)) &
      & //' "' &
      & //TRIM(obj%PhysicalName(k))//'"'
  END DO

  IF (iostat .NE. 0) THEN
    CALL e%raiseError(modName//'::'//myName//' - '// &
    & 'Error occured in writing format msg = '//TRIM(iomsg))
  END IF
  WRITE (unitNo, "( A )", iomsg=iomsg, iostat=iostat) &
    & "$EndPhysicalNames"

  IF (iostat .NE. 0) THEN
    CALL e%raiseError(modName//'::'//myName//' - '// &
    & 'Error occured in writing format msg = '//TRIM(iomsg))
  END IF
END IF

END PROCEDURE pn_Write

!----------------------------------------------------------------------------
!                                                                    Display
!----------------------------------------------------------------------------

MODULE PROCEDURE pn_Display
! Define internal variables
INTEGER(I4B) :: I, tSize, j
TYPE(String) :: Str1, Str2
! set unit number
IF (obj%isInitiated) THEN
  IF (PRESENT(UnitNo)) THEN
    I = UnitNo
  ELSE
    I = stdout
  END IF
  ! print message
  IF (LEN_TRIM(Msg) .NE. 0) THEN
    WRITE (I, "(A)") TRIM(Msg)
  END IF
  ! get total size info
  tSize = SIZE(obj%NSD)
  IF (tSize .NE. 0) THEN
    ! write header in markdown
    CALL BlankLines(UnitNo=I, NOL=1)
    WRITE (I, "(A)") "| Sr.No. |  NSD  | Physical Tag | Physical Name |&
      & NumElem | NumNodes |"
    WRITE (I, "(A)") "| :---   | :---: | :---:        | :---:          | &
      & :---: | ---: |"
    ! Write entries one by one
    DO j = 1, tSize
      Str2 = Str1%Join([ &
        & String("| "//TRIM(Str(j, .TRUE.))), &
        & String(Str(obj%NSD(j), .TRUE.)), &
        & String(Str(obj%Tag(j), .TRUE.)), &
        & TRIM(obj%PhysicalName(j)), &
        & String(Str(obj%numElements(j), .TRUE.)), &
        & String(Str(obj%numNodes(j), .TRUE.))], " | ")
      WRITE (I, "(A)") TRIM(Str2)//" | "
    END DO
    !
    IF (ALLOCATED(obj%Entities)) THEN
      CALL BlankLines(UnitNo=I, NOL=1)
      WRITE (I, "(A)") "Physical Tag to Entities Tag"
      WRITE (I, "(A)") "| Physical Tag | PhysicalName | Entities Tag |"
      WRITE (I, "(A)") "| :--- | :---: | ---: |"
      DO j = 1, SIZE(obj%Entities)
        tSize = SIZE(obj%Entities(j))
        WRITE (I, "( A, I4, A, "//TRIM(Str(tSize, .FALSE.)) &
          & //"(I4,',')"//", A )") &
          & "| ", obj%Tag(j), &
          & "| "//TRIM(obj%PhysicalName(j))//" | ", &
          & obj%Entities(j)%Val, " |"
      END DO
    END IF
  END IF
END IF
END PROCEDURE pn_Display

!----------------------------------------------------------------------------
!                                                                       Size
!----------------------------------------------------------------------------

MODULE PROCEDURE pn_getTotalPhysicalEntities
INTEGER(I4B) :: ii
!> main
IF (.NOT. PRESENT(dim)) THEN
  IF (ALLOCATED(obj%NSD)) THEN
    ans = SIZE(obj%NSD)
  ELSE
    ans = 0
  END IF
ELSE
  ans = 0
  DO ii = 1, SIZE(dim)
    SELECT CASE (DIM(ii))
    CASE (0)
      ans = ans + getTotalPhysicalPoints(obj)
    CASE (1)
      ans = ans + getTotalPhysicalCurves(obj)
    CASE (2)
      ans = ans + getTotalPhysicalSurfaces(obj)
    CASE (3)
      ans = ans + getTotalPhysicalVolumes(obj)
    END SELECT
  END DO
END IF
END PROCEDURE pn_getTotalPhysicalEntities

!----------------------------------------------------------------------------
!                                                    getTotalPhysicalPoints
!----------------------------------------------------------------------------

MODULE PROCEDURE getTotalPhysicalPoints
IF (ALLOCATED(obj%NSD)) THEN
  ans = COUNT(obj%NSD .EQ. 0)
ELSE
  ans = 0
END IF
END PROCEDURE getTotalPhysicalPoints

!----------------------------------------------------------------------------
!                                                     getTotalPhysicalCurves
!----------------------------------------------------------------------------

MODULE PROCEDURE getTotalPhysicalCurves
IF (ALLOCATED(obj%NSD)) THEN
  ans = COUNT(obj%NSD .EQ. 1)
ELSE
  ans = 0
END IF
END PROCEDURE getTotalPhysicalCurves

!----------------------------------------------------------------------------
!                                                  getTotalPhysicalSurfaces
!----------------------------------------------------------------------------

MODULE PROCEDURE getTotalPhysicalSurfaces
IF (ALLOCATED(obj%NSD)) THEN
  ans = COUNT(obj%NSD .EQ. 2)
ELSE
  ans = 0
END IF
END PROCEDURE getTotalPhysicalSurfaces

!----------------------------------------------------------------------------
!                                                    getTotalPhysicalVolumes
!----------------------------------------------------------------------------

MODULE PROCEDURE getTotalPhysicalVolumes
IF (ALLOCATED(obj%NSD)) THEN
  ans = COUNT(obj%NSD .EQ. 3)
ELSE
  ans = 0
END IF
END PROCEDURE getTotalPhysicalVolumes

!----------------------------------------------------------------------------
!                                                                 getIndex
!----------------------------------------------------------------------------

MODULE PROCEDURE pn_getIndex_a
! Define internal variables
INTEGER(I4B) :: j

ans = 0
IF (ALLOCATED(obj%NSD)) THEN
  DO j = 1, SIZE(obj%NSD)
    IF (obj%PhysicalName(j) .EQ. Name) THEN
      ans = j
      EXIT
    END IF
  END DO
END IF

END PROCEDURE pn_getIndex_a

!----------------------------------------------------------------------------
!                                                                 getIndex
!----------------------------------------------------------------------------

MODULE PROCEDURE pn_getIndex_b
! Define internal variables
INTEGER(I4B) :: i

ans = 0
IF (ALLOCATED(obj%NSD)) THEN
  DO i = 1, SIZE(Name)
    ans(i) = pn_getIndex_a(obj, Name(i))
  END DO
END IF
END PROCEDURE pn_getIndex_b

!----------------------------------------------------------------------------
!                                                                 getIndex
!----------------------------------------------------------------------------

MODULE PROCEDURE pn_getIndex_c
! Define internal variables
INTEGER(I4B) :: k
ans = 0
DO k = 1, SIZE(obj%NSD)
  IF (obj%NSD(k) .EQ. dim .AND. obj%Tag(k) .EQ. Tag) THEN
    ans = k
  END IF
END DO
END PROCEDURE pn_getIndex_c

!----------------------------------------------------------------------------
!                                                                 getIndex
!----------------------------------------------------------------------------

MODULE PROCEDURE pn_getIndex_d
! Define internal variables
INTEGER(I4B) :: tPoints, k, i

tPoints = obj%getTotalPhysicalEntities([dim])

IF (tPoints .NE. 0) THEN
  ALLOCATE (ans(tPoints))
  i = 0
  DO k = 1, SIZE(obj%NSD)
    IF (obj%NSD(k) .EQ. dim) THEN
      i = i + 1
      ans(i) = k
    END IF
  END DO
ELSE
  ALLOCATE (ans(0))
END IF
END PROCEDURE pn_getIndex_d

!----------------------------------------------------------------------------
!                                                                 getIndex
!----------------------------------------------------------------------------

MODULE PROCEDURE pn_getIndex_e
INTEGER(I4B) :: i
ans = 0_I4B
DO i = 1, SIZE(tag)
  ans(i) = pn_getIndex_c(obj=obj, dim=dim, tag=tag(i))
END DO
END PROCEDURE pn_getIndex_e

!----------------------------------------------------------------------------
!                                                          getPhysicalNames
!----------------------------------------------------------------------------

MODULE PROCEDURE pn_getPhysicalNames
INTEGER(I4B) :: ii
IF (PRESENT(dim)) THEN
  SELECT CASE (dim)
  CASE (0)
    ans = getPhysicalPointNames(obj)
  CASE (1)
    ans = getPhysicalCurveNames(obj)
  CASE (2)
    ans = getPhysicalSurfaceNames(obj)
  CASE (3)
    ans = getPhysicalVolumeNames(obj)
  END SELECT
ELSE
  ALLOCATE (ans(SIZE(obj%physicalName)))
  DO ii = 1, SIZE(obj%physicalName)
    ans(ii) = TRIM(obj%physicalName(ii))
  END DO
END IF
END PROCEDURE pn_getPhysicalNames

!----------------------------------------------------------------------------
!                                                          PhysicalPointNames
!----------------------------------------------------------------------------

MODULE PROCEDURE getPhysicalPointNames
INTEGER(I4B) :: tPoints, i, k
!> main
tPoints = getTotalPhysicalPoints(obj)
ALLOCATE (ans(tPoints))
IF (tPoints .NE. 0) THEN
  i = 0; 
  DO k = 1, SIZE(obj%NSD)
    IF (obj%NSD(k) .EQ. 0) THEN
      i = i + 1
      ans(i) = TRIM(obj%PhysicalName(k))
    END IF
  END DO
END IF
END PROCEDURE getPhysicalPointNames

!----------------------------------------------------------------------------
!                                                          PhysicalCurveNames
!----------------------------------------------------------------------------

MODULE PROCEDURE getPhysicalCurveNames
INTEGER(I4B) :: tLines, i, k
!> main
tLines = getTotalPhysicalCurves(obj)
ALLOCATE (ans(tLines))
IF (tLines .NE. 0) THEN
  i = 0; 
  DO k = 1, SIZE(obj%NSD)
    IF (obj%NSD(k) .EQ. 1) THEN
      i = i + 1
      ans(i) = TRIM(obj%PhysicalName(k))
    END IF
  END DO
END IF
END PROCEDURE getPhysicalCurveNames

!----------------------------------------------------------------------------
!                                                       PhysicalSurfaceNames
!----------------------------------------------------------------------------

MODULE PROCEDURE getPhysicalSurfaceNames
! Define internal variables
INTEGER(I4B) :: tSurfaces, i, k
!> main
tSurfaces = getTotalPhysicalSurfaces(obj)
ALLOCATE (ans(tSurfaces))
IF (tSurfaces .NE. 0) THEN
  i = 0; 
  DO k = 1, SIZE(obj%NSD)
    IF (obj%NSD(k) .EQ. 2) THEN
      i = i + 1
      ans(i) = TRIM(obj%PhysicalName(k))
    END IF
  END DO
END IF
END PROCEDURE getPhysicalSurfaceNames

!----------------------------------------------------------------------------
!                                                       PhysicalVolumeNames
!----------------------------------------------------------------------------

MODULE PROCEDURE getPhysicalVolumeNames
! Define internal variables
INTEGER(I4B) :: tVolumes, i, k

tVolumes = getTotalPhysicalVolumes(obj)
ALLOCATE (ans(tVolumes))

IF (tVolumes .NE. 0) THEN
  i = 0; 
  DO k = 1, SIZE(obj%NSD)
    IF (obj%NSD(k) .EQ. 3) THEN
      i = i + 1
      ans(i) = TRIM(obj%PhysicalName(k))
    END IF
  END DO
END IF
END PROCEDURE getPhysicalVolumeNames

!----------------------------------------------------------------------------
!                                                            getPhysicalTags
!----------------------------------------------------------------------------

MODULE PROCEDURE pn_getPhysicalTags
IF (PRESENT(dim)) THEN
  SELECT CASE (dim)
  CASE (0)
    ans = getPhysicalPointTags(obj)
  CASE (1)
    ans = getPhysicalCurveTags(obj)
  CASE (2)
    ans = getPhysicalSurfaceTags(obj)
  CASE (3)
    ans = getPhysicalVolumeTags(obj)
  END SELECT
ELSE
  ans = obj%Tag
END IF
END PROCEDURE pn_getPhysicalTags

!----------------------------------------------------------------------------
!                                                      getPhysicalPointTags
!----------------------------------------------------------------------------

MODULE PROCEDURE getPhysicalPointTags
! Define internal variables
INTEGER(I4B) :: tSize, i, k
INTEGER(I4B), PARAMETER :: dim = 0

tSize = getTotalPhysicalPoints(obj)
ALLOCATE (ans(tSize))

IF (tSize .NE. 0) THEN
  i = 0; 
  DO k = 1, SIZE(obj%NSD)
    IF (obj%NSD(k) .EQ. dim) THEN
      i = i + 1
      ans(i) = obj%Tag(k)
    END IF
  END DO
END IF
END PROCEDURE getPhysicalPointTags

!----------------------------------------------------------------------------
!                                                       getPhysicalCurveTag
!----------------------------------------------------------------------------

MODULE PROCEDURE getPhysicalCurveTags
! Define internal variables
INTEGER(I4B) :: tSize, i, k
INTEGER(I4B), PARAMETER :: dim = 1

tSize = getTotalPhysicalCurves(obj)
ALLOCATE (ans(tSize))

IF (tSize .NE. 0) THEN
  i = 0; 
  DO k = 1, SIZE(obj%NSD)
    IF (obj%NSD(k) .EQ. dim) THEN
      i = i + 1
      ans(i) = obj%Tag(k)
    END IF
  END DO
END IF
END PROCEDURE getPhysicalCurveTags

!----------------------------------------------------------------------------
!                                                      getPhysicalSurfaceTag
!----------------------------------------------------------------------------

MODULE PROCEDURE getPhysicalSurfaceTags
! Define internal variables
INTEGER(I4B) :: tSize, i, k
INTEGER(I4B), PARAMETER :: dim = 2

tSize = getTotalPhysicalSurfaces(obj)
ALLOCATE (ans(tSize))

IF (tSize .NE. 0) THEN
  i = 0; 
  DO k = 1, SIZE(obj%NSD)
    IF (obj%NSD(k) .EQ. dim) THEN
      i = i + 1
      ans(i) = obj%Tag(k)
    END IF
  END DO
END IF
END PROCEDURE getPhysicalSurfaceTags

!----------------------------------------------------------------------------
!                                                       getPhysicalVolumeTag
!----------------------------------------------------------------------------

MODULE PROCEDURE getPhysicalVolumeTags
! Define internal variables
INTEGER(I4B) :: tSize, i, k
INTEGER(I4B), PARAMETER :: dim = 3

tSize = getTotalPhysicalVolumes(obj)
ALLOCATE (ans(tSize))

IF (tSize .NE. 0) THEN
  i = 0; 
  DO k = 1, SIZE(obj%NSD)
    IF (obj%NSD(k) .EQ. dim) THEN
      i = i + 1
      ans(i) = obj%Tag(k)
    END IF
  END DO
END IF
END PROCEDURE getPhysicalVolumeTags

!----------------------------------------------------------------------------
!                                                                 WhoAmI
!----------------------------------------------------------------------------

MODULE PROCEDURE pn_WhoAmI
! Define internal variables
INTEGER(I4B) :: NSD
NSD = obj%NSD(I)
SELECT CASE (NSD)
CASE (0)
  ans = "PhysicalPoint"
CASE (1)
  ans = "PhysicalCurve"
CASE (2)
  ans = "PhysicalSurface"
CASE (3)
  ans = "PhysicalVolume"
END SELECT
END PROCEDURE pn_WhoAmI

!----------------------------------------------------------------------------
!                                                            OutputFileName
!----------------------------------------------------------------------------

MODULE PROCEDURE pn_OutputFileName
TYPE(String) :: path, filename, ext

CALL mshFile%getFileParts(path, filename, ext)
ans = &
  &    TRIM(path) &
  & //TRIM(filename) &
  & //"_" &
  & //TRIM(obj%WhoAmI(indx)) &
  & //"_" &
  & //TRIM(obj%PhysicalName(indx)) &
  & //TRIM(ext)
END PROCEDURE pn_OutputFileName

!----------------------------------------------------------------------------
!                                                            AppendEntities
!----------------------------------------------------------------------------

MODULE PROCEDURE pn_AppendEntities
CALL APPEND(obj%Entities(indx), EntityTag)
END PROCEDURE pn_AppendEntities

!----------------------------------------------------------------------------
!                                                           IncNumElements
!----------------------------------------------------------------------------

MODULE PROCEDURE pn_IncNumElements
INTEGER(I4B) :: incr0

incr0 = input(option=incr, default=1)
obj%numElements(indx) = obj%numElements(indx) + incr0
END PROCEDURE pn_IncNumElements

!----------------------------------------------------------------------------
!                                                               getEntities
!----------------------------------------------------------------------------

MODULE PROCEDURE pn_getEntities
Ans = get(obj%Entities(indx), TypeIntI4B)
END PROCEDURE pn_getEntities

!----------------------------------------------------------------------------
!                                                           IncNumNodes
!----------------------------------------------------------------------------

MODULE PROCEDURE pn_IncNumNodes
INTEGER(I4B) :: incr0

incr0 = input(option=incr, default=1)
obj%numNodes(indx) = obj%numNodes(indx) + incr0
END PROCEDURE pn_IncNumNodes

!----------------------------------------------------------------------------
!                                                                 getNSD
!----------------------------------------------------------------------------

MODULE PROCEDURE pn_getNSD
ans = obj%NSD
END PROCEDURE pn_getNSD

!----------------------------------------------------------------------------
!                                                            getNumElements
!----------------------------------------------------------------------------

MODULE PROCEDURE pn_getNumElements
ans = obj%numElements
END PROCEDURE pn_getNumElements

!----------------------------------------------------------------------------
!                                                               getNumNodes
!----------------------------------------------------------------------------

MODULE PROCEDURE pn_getNumNodes
ans = obj%numNodes
END PROCEDURE pn_getNumNodes

!----------------------------------------------------------------------------
!                                                               setNumNodes
!----------------------------------------------------------------------------

MODULE PROCEDURE pn_setNumNodes
obj%numNodes(indx) = numNode
END PROCEDURE pn_setNumNodes

!----------------------------------------------------------------------------
!
!----------------------------------------------------------------------------

END SUBMODULE Methods
