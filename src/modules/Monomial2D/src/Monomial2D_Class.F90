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

MODULE Monomial2D_Class
USE String_Class, ONLY: String
USE GlobalData
USE AbstractFunction_Class
USE AbstractBasis_Class
USE Monomial1D_Class
IMPLICIT NONE
PRIVATE
CHARACTER(LEN=*), PARAMETER :: modName = "Monomial2D_Class"

!----------------------------------------------------------------------------
!                                                                Monomial2D_
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 14 May 2022
! summary: Monomial2D class is defined

TYPE, EXTENDS(AbstractBasis2D_) :: Monomial2D_
  PRIVATE
  INTEGER(I4B) :: n1 = -1_I4B
  INTEGER(I4B) :: n2 = -1_I4B
CONTAINS
    !!
    !! @ConstructorMethods
    !!
  PROCEDURE, PASS(obj) :: Initiate1 => func_Initiate1
  PROCEDURE, PASS(obj) :: Initiate2 => func_Initiate2
  GENERIC, PUBLIC :: Initiate => Initiate1, Initiate2
  PROCEDURE, PUBLIC, PASS(obj) :: Deallocate => func_Deallocate
  FINAL :: func_Final
    !!
    !! @GetMethods
    !!
  PROCEDURE, PUBLIC, PASS(obj) :: EvalScalar => func_Eval
  PROCEDURE, PUBLIC, PASS(obj) :: EvalGradient => func_EvalGradient
  PROCEDURE, PUBLIC, PASS(obj) :: Grad => func_Grad
  GENERIC, PUBLIC :: OPERATOR(.Grad.) => Grad
  PROCEDURE, PUBLIC, PASS(obj) :: GetStringForUID => &
    & func_GetStringForUID
  PROCEDURE, PUBLIC, PASS(obj) :: GetDisplayString =>  &
    & func_GetDisplayString
  PROCEDURE, PUBLIC, PASS(obj) :: GetDegree => func_GetDegree
  PROCEDURE, PUBLIC, PASS(obj) :: GetCoeff => func_GetCoeff
    !!
    !! @DisplayMethods
    !!
  PROCEDURE, PUBLIC, PASS(obj) :: Display => func_Display
    !!
    !! @OperatorMethods
    !!
    !! OPERATOR(*)
    !!
  PROCEDURE, PUBLIC, PASS(obj1) :: MultiplicationObjObj => &
    & func_Multiplication_obj_obj
  GENERIC, PUBLIC :: OPERATOR(*) => MultiplicationObjObj
    !!
    !! @AssignmentMethods
    !!
  PROCEDURE, PUBLIC, PASS(obj) :: AssignObjObj => func_AssignObjObj
  GENERIC, PUBLIC :: ASSIGNMENT(=) => AssignObjObj
    !!
    !! @BasisMethods
    !!
END TYPE Monomial2D_

PUBLIC :: Monomial2D_

!----------------------------------------------------------------------------
!                                                         Monomial2DPointer_
!----------------------------------------------------------------------------

TYPE :: Monomial2DPointer_
  CLASS(Monomial2D_), POINTER :: ptr => NULL()
END TYPE Monomial2DPointer_

PUBLIC :: Monomial2DPointer_

!----------------------------------------------------------------------------
!                                                Initiate@ConstructorMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 14 May 2022
! summary: Construct function for Monomial2D

INTERFACE
  MODULE ELEMENTAL SUBROUTINE func_Initiate1(obj, n1, n2, varname1, varname2)
    CLASS(Monomial2D_), INTENT(INOUT) :: obj
    !! monomial2d = $x^{n1} y^{n2}$
    INTEGER(I4B), INTENT(IN) :: n1
    !! power of variable 1
    INTEGER(I4B), INTENT(IN) :: n2
    !! power for variable 2
    CHARACTER(LEN=*), INTENT(IN) :: varname1
    !! varname of variable 1
    CHARACTER(LEN=*), INTENT(IN) :: varname2
    !! varname of variable 2
  END SUBROUTINE func_Initiate1
END INTERFACE

!----------------------------------------------------------------------------
!                                             Initiate@ConstructorMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 14 May 2022
! summary: Constructor function the Monomial2D

INTERFACE
  MODULE ELEMENTAL SUBROUTINE func_Initiate2(obj, f1, f2)
    CLASS(Monomial2D_), INTENT(INOUT) :: obj
    !! ans = f1*f2
    CLASS(Monomial1D_), INTENT(IN) :: f1
    !! monomial for first variable
    CLASS(Monomial1D_), INTENT(IN) :: f2
    !! monomial for second variable
  END SUBROUTINE func_Initiate2
END INTERFACE

!----------------------------------------------------------------------------
!                                             Monomial2D@ConstructorMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 14 May 2022
! summary: Construct function for Monomial2D

INTERFACE
  MODULE ELEMENTAL FUNCTION func_Monomial2D1(n1, n2, varname1, varname2) &
    & RESULT(ans)
    INTEGER(I4B), INTENT(IN) :: n1
    !! power of variable 1
    INTEGER(I4B), INTENT(IN) :: n2
    !! power for variable 2
    CHARACTER(LEN=*), INTENT(IN) :: varname1
    !! varname of variable 1
    CHARACTER(LEN=*), INTENT(IN) :: varname2
    !! varname of variable 2
    TYPE(Monomial2D_) :: ans
    !! monomial2d = $x^{n1} y^{n2}$
  END FUNCTION func_Monomial2D1
END INTERFACE

INTERFACE Monomial2D
  MODULE PROCEDURE func_Monomial2D1
END INTERFACE Monomial2D

PUBLIC :: Monomial2D

!----------------------------------------------------------------------------
!                                             Monomial2D@ConstructorMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 14 May 2022
! summary: Constructor function the Monomial2D

INTERFACE
  MODULE ELEMENTAL FUNCTION func_Monomial2D2(f1, f2) RESULT(ans)
    CLASS(Monomial1D_), INTENT(IN) :: f1
    !! monomial for first variable
    CLASS(Monomial1D_), INTENT(IN) :: f2
    !! monomial for second variable
    TYPE(Monomial2D_) :: ans
    !! ans = f1*f2
  END FUNCTION func_Monomial2D2
END INTERFACE

INTERFACE Monomial2D
  MODULE PROCEDURE func_Monomial2D2
END INTERFACE Monomial2D

!----------------------------------------------------------------------------
!                                     Monomial2D_Pointer@ConstructorMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 14 May 2022
! summary: Construct function to return a pointer to the Monomial2D

INTERFACE
  MODULE FUNCTION func_Monomial2D_Pointer1(n1, n2, varname1, varname2) &
    & RESULT(ans)
    INTEGER(I4B), INTENT(IN) :: n1
    !! power of variable 1
    INTEGER(I4B), INTENT(IN) :: n2
    !! power of variable 2
    CHARACTER(LEN=*), INTENT(IN) :: varname1
    !! varname of variable 1
    CHARACTER(LEN=*), INTENT(IN) :: varname2
    !! varname of variable 2
    CLASS(Monomial2D_), POINTER :: ans
    !! returned 2D monomial
  END FUNCTION func_Monomial2D_Pointer1
END INTERFACE

INTERFACE Monomial2D_Pointer
  MODULE PROCEDURE func_Monomial2D_Pointer1
END INTERFACE Monomial2D_Pointer

PUBLIC :: Monomial2D_Pointer

!----------------------------------------------------------------------------
!                                      Monomial2D_Pointer@ConstructorMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 14 May 2022
! summary: Construct function to return a pointer to the Monomial2D

INTERFACE
  MODULE FUNCTION func_Monomial2D_Pointer2(f1, f2) RESULT(ans)
    CLASS(Monomial1D_), INTENT(IN) :: f1
    CLASS(Monomial1D_), INTENT(IN) :: f2
    CLASS(Monomial2D_), POINTER :: ans
  END FUNCTION func_Monomial2D_Pointer2
END INTERFACE

INTERFACE Monomial2D_Pointer
  MODULE PROCEDURE func_Monomial2D_Pointer2
END INTERFACE Monomial2D_Pointer

!----------------------------------------------------------------------------
!                                             Deallocate@ConstructorMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 14 May 2022
! summary: Deallocate the object

INTERFACE
  MODULE SUBROUTINE func_Deallocate(obj)
    CLASS(Monomial2D_), INTENT(INOUT) :: obj
  END SUBROUTINE func_Deallocate
END INTERFACE

INTERFACE Monomial2DDeallocate
  MODULE PROCEDURE func_Deallocate
END INTERFACE Monomial2DDeallocate

PUBLIC :: Monomial2DDeallocate

INTERFACE
  MODULE SUBROUTINE func_Final(obj)
    TYPE(Monomial2D_), INTENT(INOUT) :: obj
  END SUBROUTINE func_Final
END INTERFACE

!----------------------------------------------------------------------------
!                                                            Eval@GetMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 14 May 2022
! summary: Evaluate the function

INTERFACE
  MODULE ELEMENTAL FUNCTION func_eval(obj, x, y) RESULT(ans)
    CLASS(Monomial2D_), INTENT(IN) :: obj
    REAL(DFP), INTENT(IN) :: x, y
    REAL(DFP) :: ans
  END FUNCTION func_eval
END INTERFACE

!----------------------------------------------------------------------------
!                                                   EvalGradient@GetMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 14 May 2022
! summary: Evaluate the function

INTERFACE
  MODULE ELEMENTAL FUNCTION func_EvalGradient(obj, x, y, dim) RESULT(ans)
    CLASS(Monomial2D_), INTENT(IN) :: obj
    REAL(DFP), INTENT(IN) :: x
    REAL(DFP), INTENT(IN) :: y
    INTEGER(I4B), INTENT(IN) :: dim
    REAL(DFP) :: ans
  END FUNCTION func_EvalGradient
END INTERFACE

!----------------------------------------------------------------------------
!                                                            Grad@GetMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 14 May 2022
! summary: Evaluate the function

INTERFACE
  MODULE ELEMENTAL FUNCTION func_Grad(obj, dim) RESULT(ans)
    CLASS(Monomial2D_), INTENT(IN) :: obj
    INTEGER(I4B), INTENT(IN) :: dim
    TYPE(Monomial2D_) :: ans
  END FUNCTION func_Grad
END INTERFACE

!----------------------------------------------------------------------------
!                                                            Grad@GetMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 14 May 2022
! summary: Evaluate the gradient of function df/dx

INTERFACE
  MODULE ELEMENTAL FUNCTION func_GetStringForUID(obj) RESULT(ans)
    CLASS(Monomial2D_), INTENT(IN) :: obj
    TYPE(String) :: ans
  END FUNCTION func_GetStringForUID
END INTERFACE

!----------------------------------------------------------------------------
!                                                 GetStringForUID@GetMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 14 May 2022
! summary: Get the display string

INTERFACE
  MODULE ELEMENTAL FUNCTION func_GetDisplayString(obj) RESULT(ans)
    CLASS(Monomial2D_), INTENT(IN) :: obj
    TYPE(String) :: ans
  END FUNCTION func_GetDisplayString
END INTERFACE

!----------------------------------------------------------------------------
!                                                       GetDegree@GetMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 14 May 2022
! summary: Evaluate the gradient of function df/dx

INTERFACE
  MODULE PURE FUNCTION func_GetDegree(obj) RESULT(ans)
    CLASS(Monomial2D_), INTENT(IN) :: obj
    INTEGER(I4B) :: ans(2)
  END FUNCTION func_GetDegree
END INTERFACE

!----------------------------------------------------------------------------
!                                                       GetDegree@GetMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 14 May 2022
! summary: Get the coefficient

INTERFACE
  MODULE ELEMENTAL FUNCTION func_GetCoeff(obj) RESULT(ans)
    CLASS(Monomial2D_), INTENT(IN) :: obj
    REAL(DFP) :: ans
  END FUNCTION func_GetCoeff
END INTERFACE

!----------------------------------------------------------------------------
!                                                          Display@IOMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 14 May 2022
! summary: Display the content of Monomial2D

INTERFACE
  MODULE SUBROUTINE func_Display(obj, msg, unitno)
    CLASS(Monomial2D_), INTENT(IN) :: obj
    CHARACTER(LEN=*), INTENT(IN) :: msg
    INTEGER(I4B), OPTIONAL, INTENT(IN) :: unitno
  END SUBROUTINE func_Display
END INTERFACE

!----------------------------------------------------------------------------
!                                             Multiplication@OperatorMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 14 May 2022
! summary: Multiplication two Monomial1D

INTERFACE
  MODULE ELEMENTAL FUNCTION func_Multiplication_obj_obj(obj1, obj2) &
    & RESULT(ans)
    CLASS(Monomial2D_), INTENT(IN) :: obj1
    CLASS(Monomial2D_), INTENT(IN) :: obj2
    TYPE(Monomial2D_) :: ans
  END FUNCTION func_Multiplication_obj_obj
END INTERFACE

!----------------------------------------------------------------------------
!
!----------------------------------------------------------------------------

INTERFACE
  MODULE PURE SUBROUTINE func_AssignObjObj(obj, obj2)
    CLASS(Monomial2D_), INTENT(INOUT) :: obj
    CLASS(Monomial2D_), INTENT(IN) :: obj2
  END SUBROUTINE func_AssignObjObj
END INTERFACE

!----------------------------------------------------------------------------
!                                                      Assign@AssignMethods
!----------------------------------------------------------------------------

INTERFACE
  MODULE PURE SUBROUTINE func_AssignObjVecObjVec(obj, obj2)
    CLASS(Monomial2D_), ALLOCATABLE, INTENT(INOUT) :: obj(:)
    CLASS(Monomial2D_), INTENT(IN) :: obj2(:)
  END SUBROUTINE func_AssignObjVecObjVec
END INTERFACE

INTERFACE ASSIGNMENT(=)
  MODULE PROCEDURE func_AssignObjVecObjVec
END INTERFACE ASSIGNMENT(=)

PUBLIC :: ASSIGNMENT(=)

!----------------------------------------------------------------------------
!                                                   Monomials2D@BasisMethods
!----------------------------------------------------------------------------

!> author: Vikas Sharma, Ph. D.
! date: 13 Aug 2022
! summary: Returns monomial basis for lagrange polynomials

INTERFACE
  MODULE FUNCTION func_Monomials2D(order, varname1, varname2, elemType) &
    & RESULT(ans)
    INTEGER(I4B), INTENT(IN) :: order
    !! order
    CHARACTER(LEN=*), INTENT(IN) :: varname1
    !! "x"
    CHARACTER(LEN=*), INTENT(IN) :: varname2
    !! "y"
    INTEGER(I4B), INTENT(IN) :: elemType
    !! "P", "Triangle" then monomial for triangle
    !! "Q", "Quadrangle" then monomials for quadrangle
    TYPE(Monomial2D_), ALLOCATABLE :: ans(:)
    !! Monomials in 2D
  END FUNCTION func_Monomials2D
END INTERFACE

INTERFACE Monomials2D
  MODULE PROCEDURE func_Monomials2D
END INTERFACE Monomials2D

PUBLIC :: Monomials2D

!----------------------------------------------------------------------------
!
!----------------------------------------------------------------------------

END MODULE Monomial2D_Class
