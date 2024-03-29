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

!> authors: Vikas Sharma, Ph. D.
! date: 2023-03-15
! summary: This module defines LIS library based linear solver

MODULE LisLinSolver_Class
USE GlobalData
USE BaseType
USE FPL, ONLY: ParameterList_
USE ExceptionHandler_Class, ONLY: e
USE AbstractLinSolver_Class
USE LinSolver_Class
IMPLICIT NONE
PRIVATE

CHARACTER(*), PARAMETER :: modName = "LisLinsolver_Class"

!----------------------------------------------------------------------------
!                                                               LinSolver_
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 2023-03-15
! summary: Lis library based linear solver

TYPE, EXTENDS(LinSolver_) :: LisLinSolver_
  LIS_VECTOR :: lis_rhs = 0
  LIS_VECTOR :: lis_sol = 0
  LIS_VECTOR :: lis_res = 0
  LIS_MATRIX :: lis_Amat = 0
  LIS_PRECON :: lis_precon = 0
  LIS_SOLVER :: lis_solver = 0
CONTAINS
  PRIVATE
  PROCEDURE, PUBLIC, PASS(obj) :: checkEssentialParam => &
    & ls_checkEssentialParam
    !! Check essential parameters
  PROCEDURE, PUBLIC, PASS(obj) :: Initiate => ls_Initiate
    !! Initiate object
  PROCEDURE, PUBLIC, PASS(obj) :: Set => ls_Set
    !! Set the matrix and preconditioning matrix
  PROCEDURE, PUBLIC, PASS(obj) :: Solve => ls_solve
    !! Solve the system of linear equation
  PROCEDURE, PUBLIC, NOPASS :: &
     & getLinSolverCodeFromName => ls_getLinSolverCodeFromName
  PROCEDURE, PUBLIC, NOPASS :: &
     & getLinSolverNameFromCode => ls_getLinSolverNameFromCode
  PROCEDURE, PUBLIC, PASS(obj) :: DEALLOCATE => ls_Deallocate
    !! Deallocate Data
END TYPE LisLinSolver_

PUBLIC :: LisLinSolver_

!----------------------------------------------------------------------------
!                                                             TypeLinSolver
!----------------------------------------------------------------------------

TYPE(LisLinSolver_), PUBLIC, PARAMETER :: &
  & TypeLisLinSolver = LisLinSolver_()

TYPE :: LisLinSolverPointer_
  CLASS(LisLinSolver_), POINTER :: Ptr => NULL()
END TYPE LisLinSolverPointer_

PUBLIC :: LisLinSolverPointer_

!----------------------------------------------------------------------------
!                                                                   Initiate
!----------------------------------------------------------------------------

ABSTRACT INTERFACE
  SUBROUTINE ls_init(obj, SolverName, MaxIter, Tol, diagScale, ipar, fpar)
    IMPORT :: LinSolver_, DFP, I4B
    CLASS(Linsolver_), INTENT(INOUT) :: obj
    REAL(DFP), INTENT(IN) :: Tol
    INTEGER(I4B), INTENT(IN) :: MaxIter
    INTEGER(I4B), INTENT(IN) :: SolverName
    INTEGER(I4B), OPTIONAL, INTENT(IN) :: ipar(:)
    INTEGER(I4B), OPTIONAL, INTENT(IN) :: diagScale
    REAL(DFP), OPTIONAL, INTENT(IN) :: fpar(:)
  END SUBROUTINE ls_init
END INTERFACE

!----------------------------------------------------------------------------
!                                                            setPrecondioning
!----------------------------------------------------------------------------

ABSTRACT INTERFACE
  SUBROUTINE ls_set_precon(obj, precondtype, ipar, fpar)
    IMPORT :: LinSolver_, DFP, I4B
    CLASS(LinSolver_), INTENT(INOUT) :: obj
    INTEGER(I4B), INTENT(IN) :: precondtype
    INTEGER(I4B), OPTIONAL, INTENT(IN) :: ipar(:)
    REAL(DFP), OPTIONAL, INTENT(IN) :: fpar(:)
  END SUBROUTINE ls_set_precon
END INTERFACE

!----------------------------------------------------------------------------
!                                                                setSparsity
!----------------------------------------------------------------------------

ABSTRACT INTERFACE
  SUBROUTINE ls_set_sparsity(From, To)
    IMPORT :: LinSolver_, SparseMatrix_
    CLASS(LinSolver_), INTENT(INOUT) :: To
    TYPE(SparseMatrix_), INTENT(IN), TARGET :: From
  END SUBROUTINE ls_set_sparsity
END INTERFACE

!----------------------------------------------------------------------------
!                                                        setDirichletBCNodes
!----------------------------------------------------------------------------

ABSTRACT INTERFACE
  SUBROUTINE ls_set_dbc_1(obj, Nptrs, dofs)
    IMPORT :: LinSolver_, I4B
    CLASS(LinSolver_), INTENT(INOUT) :: obj
    INTEGER(I4B), INTENT(IN) :: Nptrs(:), dofs(:)
  END SUBROUTINE ls_set_dbc_1
END INTERFACE

ABSTRACT INTERFACE
  SUBROUTINE ls_set_dbc_2(obj, Nptrs, dofs)
    IMPORT :: LinSolver_, IntVector_, I4B
    CLASS(LinSolver_), INTENT(INOUT) :: obj
    TYPE(IntVector_), INTENT(IN) :: Nptrs(:)
    INTEGER(I4B), INTENT(IN) :: dofs(:)
  END SUBROUTINE ls_set_dbc_2
END INTERFACE

!----------------------------------------------------------------------------
!                                                                    Convert
!----------------------------------------------------------------------------

ABSTRACT INTERFACE
  SUBROUTINE ls_set_matrix(From, To)
    IMPORT :: LinSolver_, SparseMatrix_
    CLASS(LinSolver_), INTENT(INOUT) :: To
    TYPE(SparseMatrix_), INTENT(IN), TARGET :: From
  END SUBROUTINE ls_set_matrix
END INTERFACE

!----------------------------------------------------------------------------
!                                                                       Solve
!----------------------------------------------------------------------------

! sol contains the initial guess
ABSTRACT INTERFACE
  SUBROUTINE ls_solve(obj, sol, rhs)
    IMPORT :: LinSolver_, DFP
    CLASS(LinSolver_), INTENT(INOUT) :: obj
    REAL(DFP), INTENT(INOUT) :: sol(:)
    REAL(DFP), INTENT(INOUT) :: rhs(:)
  END SUBROUTINE ls_solve
END INTERFACE

!----------------------------------------------------------------------------
!                                                                    Display
!----------------------------------------------------------------------------

ABSTRACT INTERFACE
  SUBROUTINE ls_display(obj, msg, unitno)
    IMPORT :: LinSolver_, I4B
    CLASS(LinSolver_), INTENT(IN) :: obj
    CHARACTER(LEN=*), INTENT(IN) :: msg
    INTEGER(I4B), OPTIONAL, INTENT(IN) :: Unitno
  END SUBROUTINE ls_display
END INTERFACE

!----------------------------------------------------------------------------
!                                                          WriteResidueHisory
!----------------------------------------------------------------------------

ABSTRACT INTERFACE
  SUBROUTINE ls_w_res(obj, path, prefix, fmt, iter)
    IMPORT :: LinSolver_, I4B
    CLASS(LinSolver_), INTENT(IN) :: obj
    CHARACTER(LEN=*), INTENT(IN) :: path, prefix, fmt
    INTEGER(I4B), INTENT(IN), OPTIONAL :: iter
  END SUBROUTINE ls_w_res
END INTERFACE

!----------------------------------------------------------------------------
!                                                             Deallocate
!----------------------------------------------------------------------------

ABSTRACT INTERFACE
  SUBROUTINE ls_deallocate(obj)
    IMPORT :: LinSolver_
    CLASS(LinSolver_), INTENT(INOUT) :: obj
  END SUBROUTINE ls_deallocate
END INTERFACE

!-----------------------------------------------------------------------------
!                                                           Initiate@Methods
!-----------------------------------------------------------------------------

INTERFACE
!! Initiate [[sparsekit_]]

!> authors: Dr. Vikas Sharma
!
! This subroutine initiate the [[sparsekit_]] object
!
! - It sets the name of the solver
! - It sets the parameters related to the solver
!
! If name of the solver is `lis_gmres`, `lis_fgmres`, `lis_dqgmres`,
! or `lis_om` then `ipar(1)` denotes the number of restarts required in
! these algorithms. Default value is set to 20.

  MODULE SUBROUTINE skit_initiate(obj, SolverName, MaxIter, Tol, &
    & diagScale, ipar, fpar)
    CLASS(LinSolver_), INTENT(INOUT) :: obj
    REAL(DFP), INTENT(IN) :: Tol
    INTEGER(I4B), INTENT(IN) :: MaxIter
    INTEGER(I4B), INTENT(IN) :: SolverName
    INTEGER(I4B), OPTIONAL, INTENT(IN) :: ipar(:)
    INTEGER(I4B), OPTIONAL, INTENT(IN) :: diagScale
    REAL(DFP), OPTIONAL, INTENT(IN) :: fpar(:)
  END SUBROUTINE skit_initiate
END INTERFACE

!> Generic subroutine to initiate [[sparsekit_]]
INTERFACE Initiate
  MODULE PROCEDURE skit_initiate
END INTERFACE Initiate

PUBLIC :: Initiate

!----------------------------------------------------------------------------
!                                                  setPrecondioning@Methods
!----------------------------------------------------------------------------

INTERFACE
!! Set preconditioners in [[sparsekit_]]

!> authors: Dr. Vikas Sharma
!
! This subroutine set the preconditioner required to solve system of
! linear equations by using the
!
! - For `precondType=p_ilut` `ipar( 1 )` denotes number of fills and `fpar(1)`
! denotes the dropping tolerance
! - For `p_ilutp`:
!   - `ipar(1)` number of fills default is 10
!   - `ipar(2)` mbloc, default is size of problem
!   - `fpar(1)` drop tolerance, default is 1.0E-4
!   - `fpar(2)` permutation tolerance, default is 0.5
! - For `p_ilud`
!   - `fpar(1)` denotes drop tolerance
!   - `fpar(2)` denotes value of alpha
! - For `p_iludp`
!   - `ipar(1)` denotes mbloc
!   - `fpar(1)` denotes drop tolerance
!   - `fpar(2)` denotes value of alpha
!   - `fpar(3)` denotes permutation tolerance

  MODULE SUBROUTINE skit_setprecond(obj, precondtype, ipar, fpar)
    CLASS(LinSolver_), INTENT(INOUT) :: obj
    INTEGER(I4B), INTENT(IN) :: precondtype
    INTEGER(I4B), OPTIONAL, INTENT(IN) :: ipar(:)
    REAL(DFP), OPTIONAL, INTENT(IN) :: fpar(:)
  END SUBROUTINE skit_setprecond
END INTERFACE

!----------------------------------------------------------------------------
!                                                      setSparsity@Methods
!----------------------------------------------------------------------------

INTERFACE
!! Set sparsity pattern in [[sparsekit_]]

!> authors: Dr. Vikas Sharma
!
! This subroutine set the sparsity pattern in [[sparsekit_]]

  MODULE SUBROUTINE skit_set_sparsity(From, To)
    CLASS(LinSolver_), INTENT(INOUT) :: To
    TYPE(SparseMatrix_), INTENT(IN), TARGET :: From
  END SUBROUTINE skit_set_sparsity
END INTERFACE

!----------------------------------------------------------------------------
!                                              setDirichletBCNodes@Methods
!----------------------------------------------------------------------------

INTERFACE
!! set Dirichlet boundary condition information

!> authors: Dr. Vikas Sharma
!
! This subroutine set the Dirichlet boundary condition in the linear solver
! In this case all DOFs have the same dirichlet nodes pointers
! `Nptrs` denotes the dirichlet node numbers
! `storageFMT` can be `DOF_FMT` or `Nodes_FMT`

  MODULE SUBROUTINE skit_setDBC_1(obj, Nptrs, dofs)
    CLASS(LinSolver_), INTENT(INOUT) :: obj
    INTEGER(I4B), INTENT(IN) :: Nptrs(:)
    INTEGER(I4B), INTENT(IN) :: dofs(:)
  END SUBROUTINE skit_setDBC_1
END INTERFACE

INTERFACE
!! set Dirichlet boundary condition information

  MODULE SUBROUTINE skit_setDBC_2(obj, Nptrs, dofs)
    CLASS(LinSolver_), INTENT(INOUT) :: obj
    TYPE(IntVector_), INTENT(IN) :: Nptrs(:)
    INTEGER(I4B), INTENT(IN) :: dofs(:)
  END SUBROUTINE skit_setDBC_2
END INTERFACE

!----------------------------------------------------------------------------
!                                                          Convert@Methods
!----------------------------------------------------------------------------

INTERFACE
!! set Matrix
  MODULE SUBROUTINE skit_setmatrix(From, To)
    CLASS(LinSolver_), INTENT(INOUT) :: To
    TYPE(SparseMatrix_), INTENT(IN), TARGET :: From
  END SUBROUTINE skit_setmatrix
END INTERFACE

!----------------------------------------------------------------------------
!                                                             Solve@Methods
!----------------------------------------------------------------------------

! sol contains the initial guess
INTERFACE
  MODULE SUBROUTINE skit_solve(obj, sol, rhs)
    CLASS(LinSolver_), INTENT(INOUT) :: obj
    REAL(DFP), INTENT(INOUT) :: sol(:)
    REAL(DFP), INTENT(INOUT) :: rhs(:)
  END SUBROUTINE skit_solve
END INTERFACE

!----------------------------------------------------------------------------
!                                                          Display@Sparsekit
!----------------------------------------------------------------------------

INTERFACE
  MODULE SUBROUTINE skit_display(obj, msg, unitno)
    CLASS(LinSolver_), INTENT(IN) :: obj
    CHARACTER(LEN=*), INTENT(IN) :: msg
    INTEGER(I4B), OPTIONAL, INTENT(IN) :: Unitno
  END SUBROUTINE skit_display
END INTERFACE

INTERFACE Display
  MODULE PROCEDURE skit_display
END INTERFACE Display

PUBLIC :: Display

!----------------------------------------------------------------------------
!                                                WriteResidueHisory@Sparsekit
!----------------------------------------------------------------------------

INTERFACE
  MODULE SUBROUTINE skit_write_res_his(obj, path, prefix, fmt, iter)
    CLASS(LinSolver_), INTENT(IN) :: obj
    CHARACTER(LEN=*), INTENT(IN) :: path, prefix, fmt
    INTEGER(I4B), INTENT(IN), OPTIONAL :: iter
  END SUBROUTINE skit_write_res_his
END INTERFACE

!----------------------------------------------------------------------------
!                                                   Deallocate@Sparsekit
!----------------------------------------------------------------------------

INTERFACE
  MODULE SUBROUTINE skit_Deallocate(obj)
    CLASS(LinSolver_), INTENT(INOUT) :: obj
  END SUBROUTINE skit_Deallocate
END INTERFACE

INTERFACE DEALLOCATE
  MODULE PROCEDURE skit_Deallocate
END INTERFACE DEALLOCATE

PUBLIC :: DEALLOCATE

!----------------------------------------------------------------------------
!                                                        Initiate@Sparsekitt
!----------------------------------------------------------------------------

!<--- tInit : denotes the diagonal scaling 0-> no; 1->Right; 2-> symm
!<--- ipar( 1 ) : contains ell or restart or irestart
!<--- fpar( 1 ) : contains value of omega
INTERFACE
  MODULE SUBROUTINE lis_initiate(obj, SolverName, MaxIter, Tol, &
    & diagScale, ipar, fpar)
    CLASS(LIS_), INTENT(INOUT) :: obj
    REAL(DFP), INTENT(IN) :: Tol
    INTEGER(I4B), INTENT(IN) :: MaxIter, SolverName
    INTEGER(I4B), OPTIONAL, INTENT(IN) :: ipar(:), diagScale
    REAL(DFP), OPTIONAL, INTENT(IN) :: fpar(:)
  END SUBROUTINE lis_initiate
END INTERFACE

INTERFACE Initiate
  MODULE PROCEDURE lis_initiate
END INTERFACE Initiate

!----------------------------------------------------------------------------
!                                                 setPreconditioning@Methods
!----------------------------------------------------------------------------

INTERFACE
  MODULE SUBROUTINE lis_setprecond(obj, precondtype, ipar, fpar)
    CLASS(LIS_), INTENT(INOUT) :: obj
    INTEGER(I4B), INTENT(IN) :: precondtype
    INTEGER(I4B), OPTIONAL, INTENT(IN) :: ipar(:)
    REAL(DFP), OPTIONAL, INTENT(IN) :: fpar(:)
  END SUBROUTINE lis_setprecond
END INTERFACE

!----------------------------------------------------------------------------
!                                                        setSparsity@Methods
!----------------------------------------------------------------------------

!<--- allocate obj % A, obj % IA, obj % JA
!<--- set size of obj % lis_rhs, lis_sol, lis_mat
!<--- set all values of lis_rhs and lis_sol to zero
!<--- set csr
INTERFACE
  MODULE SUBROUTINE lis_set_sparsity(From, To)
    CLASS(LIS_), INTENT(INOUT) :: To
    TYPE(SparseMatrix_), INTENT(IN), TARGET :: From
  END SUBROUTINE lis_set_sparsity
END INTERFACE

!----------------------------------------------------------------------------
!                                                setDirichletBCNodes@Methods
!----------------------------------------------------------------------------

!<--- initiate dbcNptrs, dbcJA, dbcIndx, dbcIA
INTERFACE
  MODULE SUBROUTINE lis_setDBC_1(obj, Nptrs, dofs)
    CLASS(LIS_), INTENT(INOUT) :: obj
    INTEGER(I4B), INTENT(IN) :: Nptrs(:)
    INTEGER(I4B), INTENT(IN) :: dofs(:)
  END SUBROUTINE lis_setDBC_1
END INTERFACE

INTERFACE
  MODULE SUBROUTINE lis_setDBC_2(obj, Nptrs, dofs)
    CLASS(LIS_), INTENT(INOUT) :: obj
    TYPE(IntVector_), INTENT(IN) :: Nptrs(:)
    INTEGER(I4B), INTENT(IN) :: dofs(:)
  END SUBROUTINE lis_setDBC_2
END INTERFACE

!----------------------------------------------------------------------------
!                                                            Convert@Methods
!----------------------------------------------------------------------------

INTERFACE
  MODULE SUBROUTINE lis_setmatrix(From, To)
    CLASS(LIS_), INTENT(INOUT) :: To
    TYPE(SparseMatrix_), INTENT(IN), TARGET :: From
  END SUBROUTINE lis_setmatrix
END INTERFACE

!----------------------------------------------------------------------------
!                                                              Solve@Methods
!----------------------------------------------------------------------------

! sol contains the initial guess
INTERFACE
  MODULE SUBROUTINE lis_solve_1(obj, sol, rhs)
    CLASS(LIS_), INTENT(INOUT) :: obj
    REAL(DFP), INTENT(INOUT) :: sol(:)
    REAL(DFP), INTENT(INOUT) :: rhs(:)
  END SUBROUTINE lis_solve_1
END INTERFACE

!----------------------------------------------------------------------------
!                                                            Display@Methods
!----------------------------------------------------------------------------

INTERFACE
  MODULE SUBROUTINE lis_display(obj, msg, unitno)
    CLASS(LIS_), INTENT(IN) :: obj
    CHARACTER(LEN=*), INTENT(IN) :: msg
    INTEGER(I4B), OPTIONAL, INTENT(IN) :: unitno
  END SUBROUTINE lis_display
END INTERFACE

INTERFACE Display
  MODULE PROCEDURE lis_display
END INTERFACE Display

!----------------------------------------------------------------------------
!                                                WriteResidueHistory@Methods
!----------------------------------------------------------------------------

INTERFACE
  MODULE SUBROUTINE lis_write_res_his(obj, path, prefix, fmt, iter)
    CLASS(LIS_), INTENT(IN) :: obj
    CHARACTER(LEN=*), INTENT(IN) :: path, prefix, fmt
    INTEGER(I4B), INTENT(IN), OPTIONAL :: iter
  END SUBROUTINE lis_write_res_his
END INTERFACE

!----------------------------------------------------------------------------
!                                                      Deallocate@Methods
!----------------------------------------------------------------------------

INTERFACE
  MODULE SUBROUTINE lis_Deallocate(obj)
    CLASS(LIS_), INTENT(INOUT) :: obj
  END SUBROUTINE lis_Deallocate
END INTERFACE

INTERFACE DEALLOCATE
  MODULE PROCEDURE lis_Deallocate
END INTERFACE DEALLOCATE

END MODULE LisLinSolver_Class
