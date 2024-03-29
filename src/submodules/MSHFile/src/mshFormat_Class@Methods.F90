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

SUBMODULE(mshFormat_Class) Methods
USE BaseMethod
IMPLICIT NONE
CONTAINS

!----------------------------------------------------------------------------
!                                                                 Display
!----------------------------------------------------------------------------

MODULE PROCEDURE fmt_display
INTEGER(I4B) :: I
I = Input(Option=unitNo, Default=stdout)
IF (LEN_TRIM(Msg) .NE. 0) THEN
  WRITE (I, "(A)") TRIM(Msg)
END IF
WRITE (I, "(A)") TRIM(obj%meshFormat)
END PROCEDURE fmt_display

!----------------------------------------------------------------------------
!                                                                 getVersion
!----------------------------------------------------------------------------

MODULE PROCEDURE fmt_getVersion
Ans = obj%version
END PROCEDURE fmt_getVersion

!----------------------------------------------------------------------------
!                                                            getMajorVersion
!----------------------------------------------------------------------------

MODULE PROCEDURE fmt_getMajorVersion
Ans = obj%majorVersion
END PROCEDURE fmt_getMajorVersion

!----------------------------------------------------------------------------
!                                                            getMinorVersion
!----------------------------------------------------------------------------

MODULE PROCEDURE fmt_getMinorVersion
Ans = obj%minorVersion
END PROCEDURE fmt_getMinorVersion

!----------------------------------------------------------------------------
!                                                                getFileType
!----------------------------------------------------------------------------

MODULE PROCEDURE fmt_getFileType
Ans = obj%fileType
END PROCEDURE fmt_getFileType

!----------------------------------------------------------------------------
!                                                                getDataSize
!----------------------------------------------------------------------------

MODULE PROCEDURE fmt_getDataSize
Ans = obj%dataSize
END PROCEDURE fmt_getDataSize

!----------------------------------------------------------------------------
!                                                             getMeshFormat
!----------------------------------------------------------------------------

MODULE PROCEDURE fmt_getMeshFormat
Ans = obj%meshFormat
END PROCEDURE fmt_getMeshFormat

!----------------------------------------------------------------------------
!                                                              ReadFromFile
!----------------------------------------------------------------------------

MODULE PROCEDURE fmt_Read
INTEGER(I4B) :: unitNo
CHARACTER(*), PARAMETER :: myName = "fmt_Read"

CALL obj%GotoTag(mshFile, error)
IF (error .EQ. 0) THEN
  unitNo = mshFile%getUnitNo()
  READ (unitNo, *) obj%version, obj%fileType, obj%dataSize
  obj%majorVersion = INT(obj%version)
  obj%minorVersion = INT(10 * (obj%version - obj%majorVersion))

  obj%meshFormat = tostring(obj%version) &
    & //" "// &
    & TRIM(INT2STR(obj%fileType))//" " &
    & //TRIM(INT2STR(obj%dataSize))

  ! obj%meshFormat = TRIM(str(obj%majorVersion, .TRUE.))//"."  &
  !   & //TRIM(str(obj%minorVersion, .TRUE.))//" "// &
  !   & TRIM(INT2STR(obj%fileType))//" " &
  !   & //TRIM(INT2STR(obj%dataSize))

  IF (obj%fileType .EQ. 1) THEN
    obj%isASCII = .FALSE.
  ELSE
    obj%isASCII = .TRUE.
  END IF

ELSE
  CALL e%raiseError(modName//'::'//myName//' - '// &
    & '[INTERNAL ERROR] :: Could not read mesh format from mshFile !')
END IF
END PROCEDURE fmt_Read

!----------------------------------------------------------------------------
!                                                               WriteToFile
!----------------------------------------------------------------------------

MODULE PROCEDURE fmt_Write
! Define internal variables
INTEGER(I4B) :: unitNo
INTEGER(I4B) :: iostat
CHARACTER(1024) :: iomsg
CHARACTER(*), PARAMETER :: myName = "fmt_Write"

unitNo = afile%getUnitNo()

WRITE (unitNo, "( A )", iomsg=iomsg, iostat=iostat) "$MeshFormat"

IF (iostat .NE. 0) THEN
  CALL e%raiseError(modName//'::'//myName//' - '// &
  & 'Error occured in writing format msg = '//TRIM(iomsg))
END IF

WRITE (unitNo, "( A )", iomsg=iomsg, iostat=iostat) TRIM(obj%meshFormat)

IF (iostat .NE. 0) THEN
  CALL e%raiseError(modName//'::'//myName//' - '// &
  & 'Error occured in writing format msg = '//TRIM(iomsg))
END IF

WRITE (unitNo, "( A )", iomsg=iomsg, iostat=iostat) "$EndMeshFormat"

IF (iostat .NE. 0) THEN
  CALL e%raiseError(modName//'::'//myName//' - '// &
  & 'Error occured in writing format msg = '//TRIM(iomsg))
END IF

END PROCEDURE fmt_Write

!----------------------------------------------------------------------------
!                                                                   GotoTag
!----------------------------------------------------------------------------

MODULE PROCEDURE fmt_GotoTag
! Define internal variables
INTEGER(I4B) :: IOSTAT, Reopen, unitNo
CHARACTER(100) :: Dummy
CHARACTER(*), PARAMETER :: myName = "fmt_GotoTag"
LOGICAL(LGT) :: isNotOpen, isNotRead
! Find $meshFormat

#ifdef DEBUG_VER
CALL e%RaiseInformation(modName//'::'//myName//' - '// &
  & '[START] GotoTag()')
#endif

isNotOpen = .NOT. mshFile%isOpen()
isNotRead = .NOT. mshFile%isRead()

IF (isNotOpen .OR. isNotRead) THEN

  CALL e%raiseError(modName//'::'//myName//' - '// &
    & '[INTERNAL ERROR] :: mshFile is either not opened or '//  &
    & 'does not have read access!')
  error = -1

ELSE

  Reopen = 0
  error = 0

#ifndef Darwin_SYSTEM
  CALL mshFile%REWIND()
#endif

  DO
    unitNo = mshFile%GetUnitNo()
    READ (unitNo, "(A)", IOSTAT=IOSTAT) Dummy
    IF (IS_IOSTAT_END(IOSTAT)) THEN
      CALL mshFile%SetEOFStat(.TRUE.)

#ifdef Darwin_SYSTEM
    CALL mshFile%Close()
    CALL mshFile%Open()
#endif

      Reopen = Reopen + 1
    END IF
    IF (IOSTAT .GT. 0 .OR. Reopen .GT. 1) THEN
      CALL e%RaiseError(modName//'::'//myName//' - '// &
        & '[INTERNAL ERROR] :: Could not find $MeshFormat!')
      error = -2
      EXIT
    ELSE IF (TRIM(Dummy) .EQ. '$MeshFormat') THEN
      EXIT
    END IF
  END DO
END IF

#ifdef DEBUG_VER
CALL e%RaiseInformation(modName//'::'//myName//' - '// &
  & '[END] GotoTag()')
#endif

END PROCEDURE fmt_GotoTag

!----------------------------------------------------------------------------
!                                                             Deallocate
!----------------------------------------------------------------------------

MODULE PROCEDURE fmt_Finalize
SELECT TYPE (obj)
TYPE IS (mshFormat_)
  obj = TypemshFormat
END SELECT
END PROCEDURE fmt_Finalize

END SUBMODULE Methods
