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

SUBMODULE(mshElements_Class) Methods
USE BaseMethod
IMPLICIT NONE
CONTAINS

!----------------------------------------------------------------------------
!                                                                 Final
!----------------------------------------------------------------------------

MODULE PROCEDURE el_Final
CALL obj%DEALLOCATE()
END PROCEDURE el_Final

!----------------------------------------------------------------------------
!                                                             Deallocate
!----------------------------------------------------------------------------

MODULE PROCEDURE el_Deallocate
obj%numElements = 0
obj%numEntityBlocks = 0
obj%minElementTag = 0
obj%maxElementTag = 0
obj%isSparse = .FALSE.
END PROCEDURE el_Deallocate

!----------------------------------------------------------------------------
!                                                                 GotoTag
!----------------------------------------------------------------------------

MODULE PROCEDURE el_GotoTag
! Define internal variables
INTEGER(I4B) :: IOSTAT, Reopen, unitNo
CHARACTER(100) :: Dummy
CHARACTER(*), PARAMETER :: myName = "el_GotoTag"
LOGICAL(LGT) :: isNotOpen, isNotRead

#ifdef DEBUG_VER
CALL e%RaiseInformation(modName//'::'//myName//' - '// &
  & '[START] GotoTag()')
#endif

isNotOpen = .NOT. mshFile%isOpen()
isNotRead = .NOT. mshFile%isRead()

IF (isNotOpen .OR. isNotRead) THEN
  CALL e%raiseError(modName//'::'//myName//' - '// &
    & '[INTERNAL ERROR] :: mshFile is either not opened '// &
      & 'or does not have read access!')
  error = -1
  RETURN
END IF

Reopen = 0; error = 0

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
    CALL e%raiseError(modName//'::'//myName//' - '// &
    & '[INTERNAL ERROR] :: Could not find $Elements !')
    error = -2
    EXIT
  ELSE IF (TRIM(Dummy) .EQ. '$Elements') THEN
    EXIT
  END IF

END DO

#ifdef DEBUG_VER
CALL e%RaiseInformation(modName//'::'//myName//' - '// &
  & '[END] GotoTag()')
#endif
END PROCEDURE el_GotoTag

!----------------------------------------------------------------------------
!                                                                     Read
!----------------------------------------------------------------------------

MODULE PROCEDURE el_Read
CHARACTER(*), PARAMETER :: myName = "el_Read()"

#ifdef DEBUG_VER
CALL e%RaiseInformation(modName//'::'//myName//' - '// &
  & '[START] el_Read()')
#endif

CALL obj%GotoTag(mshFile, error)
IF (error .NE. 0) THEN
  CALL e%RaiseError(modName //'::'//myName// ' - '// &
    & '[INTERNAL ERROR] :: some error occured while finding the tag.')
END IF

IF (mshFormat%getMajorVersion() .GT. 2) THEN
  READ (mshFile%getUnitNo(), *) obj%numEntityBlocks, obj%numElements, &
    & obj%minElementTag, obj%maxElementTag
  IF ((obj%maxElementTag - obj%minElementTag) &
    & .EQ. (obj%numElements - 1)) THEN
    obj%isSparse = .FALSE.
  ELSE
    obj%isSparse = .TRUE.
  END IF
ELSE
  READ (mshFile%getUnitNo(), *) obj%numElements
END IF

#ifdef DEBUG_VER
CALL e%RaiseInformation(modName//'::'//myName//' - '// &
  & '[END] el_Read()')
#endif

END PROCEDURE el_Read

!----------------------------------------------------------------------------
!                                                                 WriteToFile
!----------------------------------------------------------------------------

MODULE PROCEDURE el_Write

TYPE(String) :: astr
INTEGER(I4B) :: unitNo

unitNo = afile%getUnitNo()

astr = tostring(obj%numEntityBlocks)//" "// &
  & tostring(obj%numElements)//" "// &
  & tostring(obj%minElementTag)//" "// &
  & tostring(obj%maxElementTag)

WRITE (unitNo, "(A)") astr%chars()
END PROCEDURE el_Write

!----------------------------------------------------------------------------
!                                                                    Display
!----------------------------------------------------------------------------

MODULE PROCEDURE el_Display
! Define internal variables
INTEGER(I4B) :: I
IF (PRESENT(UnitNo)) THEN
  I = UnitNo
ELSE
  I = stdout
END IF
!
IF (LEN_TRIM(Msg) .NE. 0) THEN
  WRITE (I, "(A)") TRIM(Msg)
END IF
!
CALL BlankLines(UnitNo=I, NOL=1)
WRITE (I, "(A)") "| Property | Value |"
WRITE (I, "(A)") "| :----    | ---:  |"
WRITE (I, "(A, I4, A)") "| Total Elements    | ", obj%NumElements, " | "
WRITE (I, "(A, I4, A)") "| Total Entities | ", obj%NumEntityBlocks, &
  & " | "
WRITE (I, "(A, I4, A)") "| Min Element Tag   | ", obj%minElementTag, &
  & " | "
WRITE (I, "(A, I4, A)") "| Max Element Tag   | ", obj%maxElementTag, &
  & " | "
WRITE (I, "(A, G5.2, A)") "| isSparse       | ", obj%isSparse, &
  & " | "
END PROCEDURE el_Display

!----------------------------------------------------------------------------
!                                                              TotalElements
!----------------------------------------------------------------------------

MODULE PROCEDURE el_getNumElements
ans = obj%numElements
END PROCEDURE el_getNumElements

!----------------------------------------------------------------------------
!                                                          getNumEntityBlock
!----------------------------------------------------------------------------

MODULE PROCEDURE el_getNumEntityBlocks
ans = obj%NumEntityBlocks
END PROCEDURE el_getNumEntityBlocks

!----------------------------------------------------------------------------
!                                                          getMinElementTag
!----------------------------------------------------------------------------

MODULE PROCEDURE el_getMinElementTag
ans = obj%minElementTag
END PROCEDURE el_getMinElementTag

!----------------------------------------------------------------------------
!                                                          getMaxElementTag
!----------------------------------------------------------------------------

MODULE PROCEDURE el_getMaxElementTag
ans = obj%maxElementTag
END PROCEDURE el_getMaxElementTag

!----------------------------------------------------------------------------
!
!----------------------------------------------------------------------------

END SUBMODULE Methods
