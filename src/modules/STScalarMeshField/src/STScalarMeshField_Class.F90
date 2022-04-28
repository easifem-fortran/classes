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

MODULE STScalarMeshField_Class
USE GlobalData
USE BaseType
USE FPL, ONLY: ParameterList_
USE Mesh_Class, ONLY: Mesh_
USE ExceptionHandler_Class, ONLY: ExceptionHandler_
USE AbstractField_Class
USE AbstractMeshField_Class
IMPLICIT NONE
PRIVATE
CHARACTER( LEN = * ), PARAMETER :: modName = "STScalarMeshField_Class"
TYPE( ExceptionHandler_ ) :: e

!----------------------------------------------------------------------------
!                                                     STScalarMeshField_Class
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 20 Feb 2022
! summary: Scalar mesh field

TYPE, EXTENDS( AbstractMeshField_ ) :: STScalarMeshField_
  CONTAINS
  PRIVATE
  PROCEDURE, PUBLIC, PASS( obj ) :: addSurrogate => aField_addSurrogate
    !! check essential parameters
  PROCEDURE, PUBLIC, PASS( obj ) :: checkEssentialParam => &
    & aField_checkEssentialParam
    !! check essential parameters
  PROCEDURE, PASS( obj ) :: Initiate1 => aField_Initiate1
    !! Initiate the field by reading param and a given mesh
END TYPE STScalarMeshField_

PUBLIC :: STScalarMeshField_

!----------------------------------------------------------------------------
!
!----------------------------------------------------------------------------

TYPE :: STScalarMeshFieldPointer_
  CLASS( STScalarMeshField_ ), POINTER :: ptr => NULL()
END TYPE STScalarMeshFieldPointer_

PUBLIC :: STScalarMeshFieldPointer_

!----------------------------------------------------------------------------
!                              setAbstractMeshFieldParam@ConstructorMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 17 Feb 2022
! summary: This routine check the essential parameters in param.

INTERFACE
MODULE SUBROUTINE setSTScalarMeshFieldParam( param, name, &
  & fieldType, engine, defineOn, nns, nnt )
  TYPE( ParameterList_ ), INTENT( INOUT ) :: param
  CHARACTER( LEN = * ), INTENT( IN ) :: name
  INTEGER( I4B ), INTENT( IN ) :: fieldType
  CHARACTER( LEN = * ), INTENT( IN ) :: engine
  INTEGER( I4B ), INTENT( IN ) :: defineOn
  !! Nodal, Quadrature
  INTEGER( I4B ), INTENT( IN ) :: nns
  !! Number of node in space
  INTEGER( I4B ), INTENT( IN ) :: nnt
  !! Number of node in time
END SUBROUTINE setSTScalarMeshFieldParam
END INTERFACE

PUBLIC :: setSTScalarMeshFieldParam

!----------------------------------------------------------------------------
!                                            addSurrogate@ConstructorMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 17 Feb 2022
! summary: This routine check the essential parameters in param.

INTERFACE
MODULE SUBROUTINE aField_addSurrogate( obj, UserObj )
  CLASS( STScalarMeshField_ ), INTENT( INOUT ) :: obj
  TYPE( ExceptionHandler_ ), INTENT( IN ) :: UserObj
END SUBROUTINE aField_addSurrogate
END INTERFACE

!----------------------------------------------------------------------------
!                                     checkEssentialParam@ConstructorMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 17 Feb 2022
! summary: This routine check the essential parameters in param.

INTERFACE
MODULE SUBROUTINE aField_checkEssentialParam( obj, param )
  CLASS( STScalarMeshField_ ), INTENT( IN ) :: obj
  TYPE( ParameterList_ ), INTENT( IN ) :: param
END SUBROUTINE aField_checkEssentialParam
END INTERFACE

!----------------------------------------------------------------------------
!                                               Initiate@ConstructorMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 17 Feb 2022
! summary: Initiate the field by reading param and given domain

INTERFACE
MODULE SUBROUTINE aField_Initiate1( obj, param, mesh )
  CLASS( STScalarMeshField_ ), INTENT( INOUT ) :: obj
  TYPE( ParameterList_ ), INTENT( IN ) :: param
  TYPE( Mesh_ ), TARGET, INTENT( IN ) :: mesh
END SUBROUTINE aField_Initiate1
END INTERFACE

END MODULE STScalarMeshField_Class