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

SUBMODULE(AbstractKernel_Class) AssembleTanmatMethods
! USE BaseMethod
IMPLICIT NONE
CONTAINS

!----------------------------------------------------------------------------
!                                                            AssembleTanmat
!----------------------------------------------------------------------------

MODULE PROCEDURE obj_AssembleTanmat
CHARACTER(*), PARAMETER :: myName = "obj_AssembleTanmat()"
CALL e%raiseError(modName//'::'//myName//" - "// &
& '[IMPLEMENTATION ERROR] :: the routine should be implemented by subclass')
END PROCEDURE obj_AssembleTanmat

!----------------------------------------------------------------------------
!                                                            AssembleMassMat
!----------------------------------------------------------------------------

MODULE PROCEDURE obj_AssembleMassMat
CHARACTER(*), PARAMETER :: myName = "obj_AssembleMassMat()"
LOGICAL(LGT) :: isok
TYPE(CPUTime_) :: TypeCPUTime

IF (obj%showTime) CALL TypeCPUTime%SetStartTime()

#ifdef DEBUG_VER
CALL e%RaiseInformation(modName//'::'//myName//' - '// &
  & '[START] ')
#endif DEBUG_VER

isok = ASSOCIATED(obj%massMat)
IF (.NOT. isok) THEN
  CALL e%RaiseError(modName//'::'//myName//' - '// &
    & '[INTERNAL ERROR] :: AbstractKernel_::obj%massMat is NOT '//  &
    & ' ASSOCIATED.')
  RETURN
END IF

CALL KernelAssembleMassMatrix(mat=obj%massMat, massDensity=obj%massDensity, &
  & dom=obj%dom, cellFE=obj%cellFE, geoCellFE=obj%geoCellFE,  &
  & spaceElemSD=obj%spaceElemSD, geoSpaceElemSD=obj%geoSpaceElemSD,  &
  & problemType=obj%problemType, reset=.TRUE.)

#ifdef DEBUG_VER
CALL e%RaiseInformation(modName//'::'//myName//' - '// &
  & '[END] ')
#endif DEBUG_VER

IF (obj%showTime) THEN
  CALL TypeCPUTime%SetEndTime()
  CALL obj%showTimeFile%WRITE(val=TypeCPUTime%GetStringForKernelLog( &
  & currentTime=obj%currentTime, currentTimeStep=obj%currentTimeStep, &
  & methodName=myName))
END IF
END PROCEDURE obj_AssembleMassMat

!----------------------------------------------------------------------------
!                                                       AssembleStiffnessMat
!----------------------------------------------------------------------------

MODULE PROCEDURE obj_AssembleStiffnessMat
CHARACTER(*), PARAMETER :: myName = "obj_AssembleStiffnessMat()"
TYPE(CPUTime_) :: TypeCPUTime

IF (obj%showTime) CALL TypeCPUTime%SetStartTime()

#ifdef DEBUG_VER
CALL e%RaiseInformation(modName//'::'//myName//' - '// &
  & '[START] ')
#endif DEBUG_VER

IF (obj%isIsotropic) THEN
  CALL KernelAssembleStiffnessMatrix(mat=obj%stiffnessMat,  &
    & youngsModulus=obj%youngsModulus, shearModulus=obj%shearModulus, dom=obj%dom,  &
    & cellFE=obj%cellFE, geoCellFE=obj%geoCellFE,  &
    & spaceElemSD=obj%spaceElemSD, geoSpaceElemSD=obj%geoSpaceElemSD,  &
    & reset=.TRUE.)

ELSE

  CALL KernelAssembleStiffnessMatrix(mat=obj%stiffnessMat,  &
    & Cijkl=obj%Cijkl, dom=obj%dom, cellFE=obj%cellFE,  &
    & geoCellFE=obj%geoCellFE, spaceElemSD=obj%spaceElemSD,  &
    & geoSpaceElemSD=obj%geoSpaceElemSD, reset=.TRUE.)
END IF

#ifdef DEBUG_VER
CALL e%RaiseInformation(modName//'::'//myName//' - '// &
  & '[END] ')
#endif DEBUG_VER

IF (obj%showTime) THEN
  CALL TypeCPUTime%SetEndTime()
  CALL obj%showTimeFile%WRITE(val=TypeCPUTime%GetStringForKernelLog( &
  & currentTime=obj%currentTime, currentTimeStep=obj%currentTimeStep, &
  & methodName=myName))
END IF
END PROCEDURE obj_AssembleStiffnessMat

!----------------------------------------------------------------------------
!                                                       AssembleDiffusionMat
!----------------------------------------------------------------------------

MODULE PROCEDURE obj_AssembleDiffusionMat
CHARACTER(*), PARAMETER :: myName = "obj_AssembleDiffusionMat()"
TYPE(CPUTime_) :: TypeCPUTime

IF (obj%showTime) CALL TypeCPUTime%SetStartTime()

#ifdef DEBUG_VER
CALL e%RaiseInformation(modName//'::'//myName//' - '// &
  & '[START] ')
#endif DEBUG_VER

! NOTE: this is for isotropic one
CALL KernelAssembleDiffusionMatrix(mat=obj%diffusionMat,  &
  & coefficient=obj%scalarCoefficient, dom=obj%dom,  &
  & cellFE=obj%cellFE, geoCellFE=obj%geoCellFE,  &
  & spaceElemSD=obj%spaceElemSD, geoSpaceElemSD=obj%geoSpaceElemSD,  &
  & reset=.TRUE.)

#ifdef DEBUG_VER
CALL e%RaiseInformation(modName//'::'//myName//' - '// &
  & '[END] ')
#endif DEBUG_VER

IF (obj%showTime) THEN
  CALL TypeCPUTime%SetEndTime()
  CALL obj%showTimeFile%WRITE(val=TypeCPUTime%GetStringForKernelLog( &
  & currentTime=obj%currentTime, currentTimeStep=obj%currentTimeStep, &
  & methodName=myName))
END IF
END PROCEDURE obj_AssembleDiffusionMat

!----------------------------------------------------------------------------
!                                                     AssembleDampingMatrix
!----------------------------------------------------------------------------

MODULE PROCEDURE obj_AssembleDampingMat
CHARACTER(*), PARAMETER :: myName = "obj_AssembleDampingMat()"
TYPE(CPUTime_) :: TypeCPUTime

IF (obj%showTime) CALL TypeCPUTime%SetStartTime()

#ifdef DEBUG_VER
CALL e%RaiseInformation(modName//'::'//myName//' - '// &
  & '[START] ')
#endif DEBUG_VER

IF (obj%isIsotropic) THEN
  CALL KernelAssembleDampingMatrix(mat=obj%dampingMat,  &
    & youngsModulus=obj%youngsModulus,  &
    & shearModulus=obj%shearModulus,  &
    & massDensity=obj%massDensity,  &
    & dampCoeff_alpha=obj%dampCoeff_alpha,  &
    & dampCoeff_beta=obj%dampCoeff_beta,  &
    & dom=obj%dom,  &
    & cellFE=obj%cellFE,  &
    & geoCellFE=obj%geoCellFE,  &
    & spaceElemSD=obj%spaceElemSD,  &
    & geoSpaceElemSD=obj%geoSpaceElemSD,  &
    & reset=.TRUE.)
END IF

IF (.NOT. obj%isIsotropic) THEN

  CALL KernelAssembleDampingMatrix( &
    & mat=obj%dampingMat,  &
    & Cijkl=obj%Cijkl,  &
    & massDensity=obj%massDensity,  &
    & dampCoeff_alpha=obj%dampCoeff_alpha,  &
    & dampCoeff_beta=obj%dampCoeff_beta,  &
    & dom=obj%dom,  &
    & cellFE=obj%cellFE,  &
    & geoCellFE=obj%geoCellFE,  &
    & spaceElemSD=obj%spaceElemSD,  &
    & geoSpaceElemSD=obj%geoSpaceElemSD,  &
    & reset=.TRUE.)

END IF

#ifdef DEBUG_VER
CALL e%RaiseInformation(modName//'::'//myName//' - '// &
  & '[END] ')
#endif DEBUG_VER

IF (obj%showTime) THEN
  CALL TypeCPUTime%SetEndTime()
  CALL obj%showTimeFile%WRITE(val=TypeCPUTime%GetStringForKernelLog( &
  & currentTime=obj%currentTime, currentTimeStep=obj%currentTimeStep, &
  & methodName=myName))
END IF

END PROCEDURE obj_AssembleDampingMat

!----------------------------------------------------------------------------
!                                                     AssembleNitscheMatrix
!----------------------------------------------------------------------------

MODULE PROCEDURE obj_AssembleNitscheMat
CHARACTER(*), PARAMETER :: myName = "obj_AssembleNitscheMat()"
CALL e%RaiseError(modName//'::'//myName//' - '// &
  & '[WIP ERROR] :: This module has not been implemented yet')
! TODO: Implement obj_AssembleNitscheMat
END PROCEDURE obj_AssembleNitscheMat

END SUBMODULE AssembleTanmatMethods
