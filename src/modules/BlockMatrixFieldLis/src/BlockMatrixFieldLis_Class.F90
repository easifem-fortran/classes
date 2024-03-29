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

MODULE BlockMatrixFieldLis_Class
USE GlobalData
USE BaseType
USE FPL, ONLY: ParameterList_
USE FPL_Method
USE HDF5File_Class
USE ExceptionHandler_Class, ONLY: e
USE AbstractField_Class
USE AbstractNodeField_Class
USE AbstractMatrixField_Class
USE BlockMatrixField_Class
USE Domain_Class
IMPLICIT NONE
PRIVATE
CHARACTER(*), PARAMETER :: modName = "BlockMatrixFieldLis_Class"
CHARACTER(*), PARAMETER :: myPrefix = "BlockMatrixField"
PUBLIC :: BlockMatrixFieldLis_
PUBLIC :: TypeBlockMatrixFieldLis

!----------------------------------------------------------------------------
!                                                          BlockMatrixField_
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 15 July 2021
! summary: This is native implementation of finite element tangent matrices.

TYPE, EXTENDS(BlockMatrixField_) :: BlockMatrixFieldLis_
  INTEGER(I4B), ALLOCATABLE :: lis_ia(:)
  INTEGER(I4B), ALLOCATABLE :: lis_ja(:)
CONTAINS
  PRIVATE
  PROCEDURE, PUBLIC, PASS(obj) :: Initiate1 => mField_Initiate1
  !! Initiate from the parameter list
  PROCEDURE, PUBLIC, PASS(obj) :: Initiate2 => mField_Initiate2
  !! Initiate by copy
  PROCEDURE, PUBLIC, PASS(obj) :: Initiate3 => mField_Initiate3
  !! Initiate for block matrices
  PROCEDURE, PUBLIC, PASS(obj) :: DEALLOCATE => mField_Deallocate
  FINAL :: mField_Final
  !! Finalizer
  PROCEDURE, PUBLIC, PASS(obj) :: Display => mField_Display
  !! Display the field
  PROCEDURE, PUBLIC, PASS(obj) :: IMPORT => mField_Import
  !! Import from hdf5 file
  PROCEDURE, PUBLIC, PASS(obj) :: Export => mField_Export
  !! export matrix field in hdf5file_
  PROCEDURE, PASS(obj) :: Matvec2 => mField_Matvec2
  !! Matrix vector multiplication
END TYPE BlockMatrixFieldLis_

TYPE(BlockMatrixFieldLis_), PARAMETER :: TypeBlockMatrixFieldLis = &
  & BlockMatrixFieldLis_(domains=NULL())

!----------------------------------------------------------------------------
!                                                   Final@ConstructorMethods
!----------------------------------------------------------------------------

INTERFACE
  MODULE SUBROUTINE mField_Final(obj)
    TYPE(BlockMatrixFieldLis_), INTENT(INOUT) :: obj
  END SUBROUTINE mField_Final
END INTERFACE

!----------------------------------------------------------------------------
!                                               Initiate@ConstructorMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 16 July 2021
! summary: This routine initiates the Matrix Field
!
!# Introduction
!
! This routine initiates an instance of [[BlockMatrixField_]].
! The options/arguments to initiate the matrix field are
! contained inside param, which is an instance of [[ParameterList_]].
! In addition, [[Domain_]] `dom` is target to the pointer
! [[AbstractField_:domain]] and [[AbstractField_::domains]]
!
! - `param` contains both essential and optional parameters which are used in
! constructing the matrix field
! - `dom` is a pointer to a domain
!
! ESSENTIAL PARAMETERS are
!
! - `name` This is name of field (char)
! - `matrixProp`, UNSYM, SYM (char)
!
! OPTIONAL PARAMETERS
!
! - `spaceCompo`, INT, default is 1
! - `timeCompo`, INT, default is 1
! - `fieldType`, INT, default is FIELD_TYPE_NORMAL

INTERFACE
  MODULE SUBROUTINE mField_Initiate1(obj, param, dom)
    CLASS(BlockMatrixFieldLis_), INTENT(INOUT) :: obj
    TYPE(ParameterList_), INTENT(IN) :: param
    TYPE(Domain_), TARGET, INTENT(IN) :: dom
  END SUBROUTINE mField_Initiate1
END INTERFACE

!----------------------------------------------------------------------------
!                                                Initiate@ConstructorMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 2023-03-30
! summary: This routine initiates the Matrix Field
!
!# Introduction
!
! This routine initiates the `obj` by copying contents
! from `obj2`, an instance of chid class of [[AbstractField_]].
! In this way, we try to minimize the computation effort.
!
!@todo
! At present, the routine works for `copyFull=.TRUE., copyStructure=.TRUE.,
! usePointer=.TRUE.`, which equivalent to the default behavior.
! Add functionality for other options too.
!@endtodo

INTERFACE
  MODULE SUBROUTINE mField_Initiate2(obj, obj2, copyFull, copyStructure, &
    & usePointer)
    CLASS(BlockMatrixFieldLis_), INTENT(INOUT) :: obj
    CLASS(AbstractField_), INTENT(INOUT) :: obj2
    !! It should be an instance of MatrixField_
    LOGICAL(LGT), OPTIONAL, INTENT(IN) :: copyFull
    LOGICAL(LGT), OPTIONAL, INTENT(IN) :: copyStructure
    LOGICAL(LGT), OPTIONAL, INTENT(IN) :: usePointer
  END SUBROUTINE mField_Initiate2
END INTERFACE
!----------------------------------------------------------------------------
!                                                Initiate@ConstructorMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 16 July 2021
! summary: This routine initiates the Matrix Field

INTERFACE
  MODULE SUBROUTINE mField_Initiate3(obj, param, dom)
    CLASS(BlockMatrixFieldLis_), INTENT(INOUT) :: obj
    TYPE(ParameterList_), INTENT(IN) :: param
    TYPE(DomainPointer_), TARGET, INTENT(IN) :: dom(:)
  END SUBROUTINE mField_Initiate3
END INTERFACE

!----------------------------------------------------------------------------
!                                              Deallocate@ConstructorMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 2023-03-30
! summary: This routine deallocates the data stored inside the matrix

INTERFACE
  MODULE SUBROUTINE mField_Deallocate(obj)
    CLASS(BlockMatrixFieldLis_), INTENT(INOUT) :: obj
  END SUBROUTINE mField_Deallocate
END INTERFACE

!----------------------------------------------------------------------------
!                                                          Display@IOMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 2023-03-30
! summary: This routine displays the content

INTERFACE
  MODULE SUBROUTINE mField_Display(obj, msg, unitNo)
    CLASS(BlockMatrixFieldLis_), INTENT(INOUT) :: obj
    CHARACTER(*), INTENT(IN) :: msg
    INTEGER(I4B), OPTIONAL, INTENT(IN) :: unitNo
  END SUBROUTINE mField_Display
END INTERFACE

!----------------------------------------------------------------------------
!                                                            Export@IOMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 2023-03-30
! summary: This routine Exports the content of matrixfield_ to hdf5 file

INTERFACE
  MODULE SUBROUTINE mField_Export(obj, hdf5, group)
    CLASS(BlockMatrixFieldLis_), INTENT(INOUT) :: obj
    TYPE(HDF5File_), INTENT(INOUT) :: hdf5
    CHARACTER(*), INTENT(IN) :: group
  END SUBROUTINE mField_Export
END INTERFACE

!----------------------------------------------------------------------------
!                                                           Import@IOMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 2023-03-31
! summary: This routine Imports the content of matrix field from hdf5file

INTERFACE
  MODULE SUBROUTINE mField_Import(obj, hdf5, group, dom, domains)
    CLASS(BlockMatrixFieldLis_), INTENT(INOUT) :: obj
    TYPE(HDF5File_), INTENT(INOUT) :: hdf5
    CHARACTER(*), INTENT(IN) :: group
    TYPE(Domain_), TARGET, OPTIONAL, INTENT(IN) :: dom
    TYPE(DomainPointer_), TARGET, OPTIONAL, INTENT(IN) :: domains(:)
  END SUBROUTINE mField_Import
END INTERFACE

!----------------------------------------------------------------------------
!                                                     Matvec@MatVecMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 18 July 2021
! summary: This routine returns the maxtrix vector multiplication
!
!# Introduction
!
! This routine returns the matrix vector multiplication. Here, input vector
! is an instance of AbstractNodeField.
! The output vector is also an instance of AbstractNodeField.
! It should be noted that the output vector should be allocated
! outside and it should have same length as the input vector.

INTERFACE
  MODULE SUBROUTINE mField_Matvec2(obj, x, y, isTranspose, &
    & addContribution, scale)
    CLASS(BlockMatrixFieldLis_), INTENT(IN) :: obj
    CLASS(AbstractNodeField_), INTENT(IN) :: x
    !! Input vector in y=Ax
    CLASS(AbstractNodeField_), INTENT(INOUT) :: y
    !! Output vector y=Ax
    LOGICAL(LGT), OPTIONAL, INTENT(IN) :: isTranspose
    LOGICAL(LGT), OPTIONAL, INTENT(IN) :: addContribution
    REAL(DFP), OPTIONAL, INTENT(IN) :: scale
  END SUBROUTINE mField_Matvec2
END INTERFACE

END MODULE BlockMatrixFieldLis_Class
