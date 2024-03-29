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

SUBMODULE(VTKPlot_Class) ScatterMethods
USE BaseMethod
IMPLICIT NONE
CONTAINS

!----------------------------------------------------------------------------
!                                                                 Scatter3D
!----------------------------------------------------------------------------

MODULE PROCEDURE plot_scatter3D_1
!
CHARACTER(*), PARAMETER :: myName = "plot_scatter3D_1"
INTEGER(I4B) :: nPoints
TYPE(VTKFile_) :: aVTKfile
REAL(DFP), ALLOCATABLE :: temp(:)

! check
IF ((SIZE(x) .NE. SIZE(y)) .OR. &
  & (SIZE(y) .NE. SIZE(z)) .OR. &
  & (SIZE(z) .NE. SIZE(x))) THEN
  CALL e%raiseError(modName//'::'//myName//' - '// &
    & 'Size of x, y, and z should be the same.')
END IF

nPoints = SIZE(x)

CALL aVTKfile%InitiateVTKFile( &
  & filename=filename, &
  & mode="NEW", &
  & DataFormat=VTK_ASCII, &
  & DataStructureType=VTK_PolyData)

CALL aVTKfile%WritePiece(nPoints=nPoints, &
  & nVerts=0_I4B, &
  & nLines=0_I4B, &
  & nStrips=0_I4B, &
  & nPolys=0_I4B)

CALL aVTKfile%WritePoints(x=x, y=y, z=z)

CALL aVTKfile%WriteDataArray(&
  & location=String("node"), &
  & action=String("open"))

temp = zeros(nPoints, 1.0_DFP)
CALL aVTKfile%WriteDataArray(&
  & name=String(TRIM(label)), &
  & x=temp, &
  & y=temp, &
  & z=z)

CALL aVTKfile%WriteDataArray(&
  & location=String("node"), &
  & action=String("close"))

CALL aVTKfile%WritePiece()

CALL aVTKfile%DEALLOCATE()

IF (ALLOCATED(temp)) DEALLOCATE (temp)
END PROCEDURE plot_scatter3D_1

!----------------------------------------------------------------------------
!                                                                 Scatter3D
!----------------------------------------------------------------------------

MODULE PROCEDURE plot_scatter3D_2

CHARACTER(*), PARAMETER :: myName = "plot_scatter3D_2"
INTEGER(I4B) :: nPoints, ii, ndata
TYPE(VTKFile_) :: aVTKfile
TYPE(String) :: labelstr
REAL(DFP), ALLOCATABLE :: temp(:)

! check
IF ((SIZE(x) .NE. SIZE(y)) .OR. &
  & (SIZE(y) .NE. SIZE(z, 1)) .OR. &
  & (SIZE(z, 1) .NE. SIZE(x))) THEN
  CALL e%raiseError(modName//'::'//myName//' - '// &
    & 'Size of x, y, and z should be the same.')
END IF

nPoints = SIZE(x)
ndata = SIZE(z, 2)
CALL aVTKfile%InitiateVTKFile( &
  & filename=filename, &
  & mode="NEW", &
  & DataFormat=VTK_BINARY, &
  & DataStructureType=VTK_PolyData)

CALL aVTKfile%WritePiece(nPoints=nPoints, &
  & nVerts=0_I4B, &
  & nLines=0_I4B, &
  & nStrips=0_I4B, &
  & nPolys=0_I4B)

CALL aVTKfile%WritePoints(x=x, y=y, z=z(:, 1))

CALL aVTKfile%WriteDataArray(&
  & location=String("node"), &
  & action=String("open"))

temp = zeros(nPoints, 1.0_DFP)
DO ii = 1, ndata

  labelstr = TRIM(label)//tostring(ii)
  ! CALL aVTKfile%WriteDataArray(&
  !   & name=labelstr, &
  !   & x=temp, &
  !   & y=temp, &
  !   & z=z(:, ii))

  CALL aVTKfile%WriteDataArray(name=labelstr, x=z(:, ii))

END DO

CALL aVTKfile%WriteDataArray(&
  & location=String("node"), &
  & action=String("close"))

CALL aVTKfile%WritePiece()
CALL aVTKfile%DEALLOCATE()
IF (ALLOCATED(temp)) DEALLOCATE (temp)
END PROCEDURE plot_scatter3D_2

!----------------------------------------------------------------------------
!
!----------------------------------------------------------------------------

MODULE PROCEDURE plot_scatter3D_3
REAL(DFP) :: z(SIZE(x))
z = Zeros(SIZE(x), 1.0_DFP)
CALL obj%Scatter3D(x=x, y=y, z=z, label=label, filename=filename)
END PROCEDURE plot_scatter3D_3

!----------------------------------------------------------------------------
!
!----------------------------------------------------------------------------

MODULE PROCEDURE plot_scatter3D_4
CHARACTER(*), PARAMETER :: myName = "plot_scatter3D_4"
INTEGER(I4B) :: nPoints, ii, ndata
TYPE(VTKFile_) :: aVTKfile
TYPE(String) :: labelstr

! check
IF ((SIZE(x) .NE. SIZE(y)) .OR. &
  & (SIZE(y) .NE. SIZE(z)) .OR. &
  & (SIZE(z) .NE. SIZE(x))) THEN
  CALL e%raiseError(modName//'::'//myName//' - '// &
    & 'Size of x, y, and z should be the same.')
END IF

! check
IF (SIZE(w, 1) .NE. SIZE(x)) THEN
  CALL e%raiseError(modName//'::'//myName//' - '// &
    & 'Size of x, y, z, and size(w,1) should be the same.')
END IF

nPoints = SIZE(x)
ndata = SIZE(w, 2)

CALL aVTKfile%InitiateVTKFile( &
  & filename=filename, &
  & mode="NEW", &
  & DataFormat=VTK_BINARY, &
  & DataStructureType=VTK_PolyData)

CALL aVTKfile%WritePiece(nPoints=nPoints, &
  & nVerts=0_I4B, &
  & nLines=0_I4B, &
  & nStrips=0_I4B, &
  & nPolys=0_I4B)

CALL aVTKfile%WritePoints(x=x, y=y, z=z)

CALL aVTKfile%WriteDataArray(&
  & location=String("node"), &
  & action=String("open"))

DO ii = 1, ndata
  labelstr = TRIM(label)//tostring(ii)
  CALL aVTKfile%WriteDataArray(name=labelstr, x=w(:, ii))
END DO

CALL aVTKfile%WriteDataArray(&
  & location=String("node"), &
  & action=String("close"))

CALL aVTKfile%WritePiece()
CALL aVTKfile%DEALLOCATE()
END PROCEDURE plot_scatter3D_4

END SUBMODULE ScatterMethods
