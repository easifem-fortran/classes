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
! date: 2 May 2021
! summary: module for I/O defines the derived type for a Fortran File object.

MODULE TxtFile_Class
USE GlobalData
USE String_Class
USE BaseType
USE ExceptionHandler_Class, ONLY: e
USE FortranFile_Class
IMPLICIT NONE
PRIVATE
CHARACTER(*), PARAMETER :: modName = 'TxtFile_Class'
INTEGER(I4B), PARAMETER :: maxStrLen = 256
PUBLIC :: TxtFilePointer_
PUBLIC :: TxtFile_
PUBLIC :: TypeTxtFile
PUBLIC :: TxtFileInitiate
PUBLIC :: TxtFileDeallocate
PUBLIC :: TxtFileWrite

!----------------------------------------------------------------------------
!                                                                 TxtFile_
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 19 July, 2022
! summary: TxtFile is extension of FortranFile
!
!# Introduction
!
! TxtFile is an extension of the FortranFile.
! It stores data in ASCII format.

TYPE, EXTENDS(FortranFile_) :: TxtFile_
  PRIVATE
  LOGICAL(LGT) :: echostat = .FALSE.
  INTEGER(I4B) :: echounit = -1

CONTAINS
  PRIVATE

  ! CONSTRUCTOR:
  ! @ConstructorMethods
  PROCEDURE, PUBLIC, PASS(obj) :: Initiate => txt_initiate
  PROCEDURE, PUBLIC, PASS(obj) :: DEALLOCATE => txt_Deallocate
  FINAL :: txt_final

  ! GET:
  ! @EnquireMethods
  PROCEDURE, PUBLIC, PASS(obj) :: IsValidRecord => txt_IsValidRecord

  ! SET:
  ! @SetMethods
  PROCEDURE, PUBLIC, PASS(obj) :: SetEchoStat => txt_SetEchoStat
  PROCEDURE, PUBLIC, PASS(obj) :: SetEchoUnit => txt_SetEchoUnit

  ! GET:
  ! @GetMethods
  PROCEDURE, PUBLIC, PASS(obj) :: GetEchoStat => txt_GetEchoStat
  PROCEDURE, PUBLIC, PASS(obj) :: GetEchoUnit => txt_GetEchoUnit
  PROCEDURE, PUBLIC, PASS(obj) :: GetTotalRecords => txt_GetTotalRecords

  ! IO:
  ! @ReadMethods
  PROCEDURE, PUBLIC, PASS(obj) :: ReadLine => txt_read_Line
  !! Read strings and chars
  PROCEDURE, PUBLIC, PASS(obj) :: ReadLines => txt_read_Lines
  !! Read strings and chars
  PROCEDURE, PASS(obj) :: ReadChar => txt_read_Char
  !! scalars
  PROCEDURE, PASS(obj) :: ReadInt8 => txt_read_Int8
  PROCEDURE, PASS(obj) :: ReadInt16 => txt_read_Int16
  PROCEDURE, PASS(obj) :: ReadInt32 => txt_read_Int32
  PROCEDURE, PASS(obj) :: ReadInt64 => txt_read_Int64
  PROCEDURE, PASS(obj) :: ReadReal32 => txt_read_Real32
  PROCEDURE, PASS(obj) :: ReadReal64 => txt_read_Real64
  !! vectors
  PROCEDURE, PASS(obj) :: ReadVecInt8 => txt_read_vec_Int8
  PROCEDURE, PASS(obj) :: ReadVecInt16 => txt_read_vec_Int16
  PROCEDURE, PASS(obj) :: ReadVecInt32 => txt_read_vec_Int32
  PROCEDURE, PASS(obj) :: ReadVecInt64 => txt_read_vec_Int64
  PROCEDURE, PASS(obj) :: ReadIntVector => txt_read_IntVector
  PROCEDURE, PASS(obj) :: ReadVecIntVector => txt_read_vec_IntVector
  PROCEDURE, PASS(obj) :: ReadVecReal32 => txt_read_vec_Real32
  PROCEDURE, PASS(obj) :: ReadVecReal64 => txt_read_vec_Real64
  PROCEDURE, PASS(obj) :: ReadRealVector => txt_read_RealVector
  PROCEDURE, PASS(obj) :: ReadVecRealVector => txt_read_vec_RealVector
  !! matrix
  PROCEDURE, PASS(obj) :: ReadMatReal32 => txt_read_Mat_Real32
  PROCEDURE, PASS(obj) :: ReadMatReal64 => txt_read_Mat_Real64
  PROCEDURE, PASS(obj) :: ReadMatInt8 => txt_read_Mat_Int8
  PROCEDURE, PASS(obj) :: ReadMatInt16 => txt_read_Mat_Int16
  PROCEDURE, PASS(obj) :: ReadMatInt32 => txt_read_Mat_Int32
  PROCEDURE, PASS(obj) :: ReadMatInt64 => txt_read_Mat_Int64
  !! generic
  GENERIC, PUBLIC :: Read => &
    & ReadLine, ReadLines, ReadChar, &
    & ReadInt8, ReadInt16, ReadInt32, ReadInt64, &
    & ReadReal32, ReadReal64, &
    & ReadVecInt8, ReadVecInt16, ReadVecInt32, ReadVecInt64, &
    & ReadIntVector, ReadVecIntVector, &
    & ReadVecReal32, ReadVecReal64, &
    & ReadRealVector, ReadVecRealVector, &
    & ReadMatInt8, ReadMatInt16, ReadMatInt32, ReadMatInt64, &
    & ReadMatReal32, ReadMatReal64

  ! IO:
  ! @WriteMethods
  PROCEDURE, PUBLIC, PASS(obj) :: ConvertMarkdownToSource => &
    & txt_ConvertMarkDownToSource
  PROCEDURE, PUBLIC, PASS(obj) :: WriteBlank => txt_write_Blank
  PROCEDURE, PUBLIC, PASS(obj) :: nextRow => txt_Write_Blank
  PROCEDURE, PUBLIC, PASS(obj) :: WriteLine => txt_write_Line
  PROCEDURE, PUBLIC, PASS(obj) :: WriteLines => txt_write_Lines
  PROCEDURE, PASS(obj) :: WriteChar => txt_write_Char
  !! scalars
  PROCEDURE, PASS(obj) :: WriteInt8 => txt_write_Int8
  PROCEDURE, PASS(obj) :: WriteInt16 => txt_write_Int16
  PROCEDURE, PASS(obj) :: WriteInt32 => txt_write_Int32
  PROCEDURE, PASS(obj) :: WriteInt64 => txt_write_Int64
  PROCEDURE, PASS(obj) :: WriteReal32 => txt_write_Real32
  PROCEDURE, PASS(obj) :: WriteReal64 => txt_write_Real64
  !! vectors
  PROCEDURE, PASS(obj) :: WriteVecInt8 => txt_write_vec_Int8
  PROCEDURE, PASS(obj) :: WriteVecInt16 => txt_write_vec_Int16
  PROCEDURE, PASS(obj) :: WriteVecInt32 => txt_write_vec_Int32
  PROCEDURE, PASS(obj) :: WriteVecInt64 => txt_write_vec_Int64
  PROCEDURE, PASS(obj) :: WriteIntVector => txt_write_IntVector
  PROCEDURE, PASS(obj) :: WriteVecIntVector => txt_write_vec_IntVector
  PROCEDURE, PASS(obj) :: WriteVecReal32 => txt_write_vec_Real32
  PROCEDURE, PASS(obj) :: WriteVecReal64 => txt_write_vec_Real64
  PROCEDURE, PASS(obj) :: WriteRealVector => txt_write_RealVector
  PROCEDURE, PASS(obj) :: WriteVecRealVector => txt_write_vec_RealVector
  !! matrix
  PROCEDURE, PASS(obj) :: WriteMatReal32 => txt_write_Mat_Real32
  PROCEDURE, PASS(obj) :: WriteMatReal64 => txt_write_Mat_Real64
  PROCEDURE, PASS(obj) :: WriteMatInt8 => txt_write_Mat_Int8
  PROCEDURE, PASS(obj) :: WriteMatInt16 => txt_write_Mat_Int16
  PROCEDURE, PASS(obj) :: WriteMatInt32 => txt_write_Mat_Int32
  PROCEDURE, PASS(obj) :: WriteMatInt64 => txt_write_Mat_Int64
  !! generic
  GENERIC, PUBLIC :: Write => &
    & WriteBlank, &
    & WriteLine, WriteLines, WriteChar, &
    & WriteInt8, WriteInt16, WriteInt32, WriteInt64, &
    & WriteVecInt8, WriteVecInt16, WriteVecInt32, WriteVecInt64, &
    & WriteMatInt8, WriteMatInt16, WriteMatInt32, WriteMatInt64, &
    & WriteIntVector, WriteVecIntVector, &
    & WriteReal32, WriteReal64, &
    & WriteVecReal32, WriteVecReal64, &
    & WriteRealVector, WriteVecRealVector, &
    & WriteMatReal32, WriteMatReal64
END TYPE TxtFile_

TYPE(TxtFile_), PARAMETER :: TypeTxtFile = TxtFile_()

!----------------------------------------------------------------------------
!                                                             TxtFilePointer
!----------------------------------------------------------------------------

TYPE :: TxtFilePointer_
  CLASS(TxtFile_), POINTER :: ptr => NULL()
END TYPE

!----------------------------------------------------------------------------
!                                               Initiate@ConstructorMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 19 July 2022
! summary: Initiate the txt file

INTERFACE TxtFileInitiate
  MODULE SUBROUTINE txt_initiate(obj, filename, unit, status, access, form, &
    & position, action, pad, recl, comment, separator, delimiter)
    CLASS(TxtFile_), INTENT(INOUT) :: obj
    CHARACTER(*), INTENT(IN) :: filename
    INTEGER(I4B), OPTIONAL, INTENT(IN) :: unit
    !! User specified unit number, it should  not be `stdout, stdin, stderr`
    CHARACTER(*), OPTIONAL, INTENT(IN) :: status
    !! OLD, NEW, SCRATCH, REPLACE, UNKNOWN
    !! If UNKNOWN then we use REPLACE
    !! Default is REPLACE
    CHARACTER(*), OPTIONAL, INTENT(IN) :: access
    !! DIRECT, SEQUENTIAL, STREAM
    !! Default is SEQUENTIAL
    CHARACTER(*), OPTIONAL, INTENT(IN) :: form
    !! FORMATTED, UNFORMATTED
    !! Default is FORMATTED
    CHARACTER(*), OPTIONAL, INTENT(IN) :: position
    !! REWIND, APPEND, ASIS
    !! Default is ASIS
    CHARACTER(*), OPTIONAL, INTENT(IN) :: action
    !! READ, WRITE, READWRITE
    CHARACTER(*), OPTIONAL, INTENT(IN) :: pad
    !! YES, NO
    !! Default is YES
    INTEGER(I4B), OPTIONAL, INTENT(IN) :: recl
    CHARACTER(*), OPTIONAL, INTENT(IN) :: comment
    CHARACTER(*), OPTIONAL, INTENT(IN) :: separator
    CHARACTER(*), OPTIONAL, INTENT(IN) :: delimiter
  END SUBROUTINE txt_initiate
END INTERFACE TxtFileInitiate

!----------------------------------------------------------------------------
!                                              Deallocate@ConstructorMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 19 July 2022
! summary: Deallocate the data

INTERFACE TxtFileDeallocate
  MODULE SUBROUTINE txt_Deallocate(obj, Delete)
    CLASS(TxtFile_), INTENT(INOUT) :: obj
    LOGICAL(LGT), OPTIONAL, INTENT(IN) :: Delete
  END SUBROUTINE txt_Deallocate
END INTERFACE TxtFileDeallocate

!----------------------------------------------------------------------------
!                                                  Final@ConstructorMethods
!----------------------------------------------------------------------------

INTERFACE
  MODULE SUBROUTINE txt_final(obj)
    TYPE(TxtFile_), INTENT(INOUT) :: obj
  END SUBROUTINE txt_final
END INTERFACE

!----------------------------------------------------------------------------
!                                              isValidRecord@EnquireMethods
!----------------------------------------------------------------------------

INTERFACE
  MODULE FUNCTION txt_isValidRecord(obj, aline, ignoreComment, ignoreBlank, &
    & commentSymbol) RESULT(Ans)
    CLASS(TxtFile_), INTENT(IN) :: obj
    TYPE(String), INTENT(IN) :: aline
    LOGICAL(LGT), OPTIONAL, INTENT(IN) :: ignoreComment
    LOGICAL(LGT), OPTIONAL, INTENT(IN) :: ignoreBlank
    CHARACTER(1), OPTIONAL, INTENT(IN) :: commentSymbol
    LOGICAL(LGT) :: ans
  END FUNCTION txt_isValidRecord
END INTERFACE

!----------------------------------------------------------------------------
!                                                    SetEchoStat@SetMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 19 July 2022
! summary: Set the echo status

INTERFACE
  MODULE SUBROUTINE txt_setEchoStat(obj, bool)
    CLASS(TxtFile_), INTENT(INOUT) :: obj
    LOGICAL(LGT), INTENT(IN) :: bool
  END SUBROUTINE txt_setEchoStat
END INTERFACE

!----------------------------------------------------------------------------
!                                                     SetEchoUnit@SetMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 19 July 2022
! summary: Set the echo units

INTERFACE
  MODULE SUBROUTINE txt_setEchoUnit(obj, unitno)
    CLASS(TxtFile_), INTENT(INOUT) :: obj
    INTEGER(I4B), INTENT(IN) :: unitno
  END SUBROUTINE txt_setEchoUnit
END INTERFACE

!----------------------------------------------------------------------------
!                                                     GetEchoUnit@GetMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 19 July 2022
! summary: Get the echo units

INTERFACE
  MODULE PURE FUNCTION txt_getEchoUnit(obj) RESULT(ans)
    CLASS(TxtFile_), INTENT(IN) :: obj
    INTEGER(I4B) :: ans
  END FUNCTION txt_getEchoUnit
END INTERFACE

!----------------------------------------------------------------------------
!                                                getTotalRecords@GetMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 2021-11-09
! update: 2021-11-09
! summary: Returns the total number of records in a file
!
!
!# Introduction
!
! This function returns the total number of records in a file
! If `ignoreComment=.TRUE.`, then the comments are ignored
! If `ignoreComment` is true, then `commentSymbol` should be given

INTERFACE
  MODULE FUNCTION txt_getTotalRecords(obj, ignoreComment, ignoreBlank, &
    & commentSymbol) RESULT(Ans)
    CLASS(TxtFile_), INTENT(INOUT) :: obj
    LOGICAL(LGT), OPTIONAL, INTENT(IN) :: ignoreComment
    LOGICAL(LGT), OPTIONAL, INTENT(IN) :: ignoreBlank
    CHARACTER(1), OPTIONAL, INTENT(IN) :: commentSymbol
    INTEGER(I4B) :: ans
  END FUNCTION txt_getTotalRecords
END INTERFACE

!----------------------------------------------------------------------------
!                                                     GetEchoStat@GetMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 19 July 2022
! summary: Get the echo status

INTERFACE
  MODULE PURE FUNCTION txt_getEchoStat(obj) RESULT(ans)
    CLASS(TxtFile_), INTENT(IN) :: obj
    LOGICAL(LGT) :: ans
  END FUNCTION txt_getEchoStat
END INTERFACE

!----------------------------------------------------------------------------
!                                                       ReadLine@ReadMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 19 July 2022
! summary: Read a single line (record)

INTERFACE
  MODULE SUBROUTINE txt_read_Line(obj, val, iostat, iomsg, &
  & ignoreComment, ignoreBlank, commentSymbol, separator)
    CLASS(TxtFile_), INTENT(INOUT) :: obj
    TYPE(String), INTENT(OUT) :: val
    INTEGER(I4B), OPTIONAL, INTENT(OUT) :: iostat
    CHARACTER(*), OPTIONAL, INTENT(OUT) :: iomsg
    LOGICAL(LGT), OPTIONAL, INTENT(IN) :: ignoreComment
    LOGICAL(LGT), OPTIONAL, INTENT(IN) :: ignoreBlank
    CHARACTER(1), OPTIONAL, INTENT(IN) :: commentSymbol
    CHARACTER(*), OPTIONAL, INTENT(IN) :: separator
  END SUBROUTINE txt_read_Line
END INTERFACE

!----------------------------------------------------------------------------
!                                                       ReadLine@ReadMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 19 July 2022
! summary: Read a single line (record)

INTERFACE
  MODULE SUBROUTINE txt_read_Lines(obj, val, iostat, iomsg, &
  & ignoreComment, ignoreBlank, commentSymbol, separator)
    CLASS(TxtFile_), INTENT(INOUT) :: obj
    TYPE(String), ALLOCATABLE, INTENT(INOUT) :: val(:)
    INTEGER(I4B), OPTIONAL, INTENT(OUT) :: iostat
    CHARACTER(*), OPTIONAL, INTENT(OUT) :: iomsg
    LOGICAL(LGT), OPTIONAL, INTENT(IN) :: ignoreComment
    LOGICAL(LGT), OPTIONAL, INTENT(IN) :: ignoreBlank
    CHARACTER(1), OPTIONAL, INTENT(IN) :: commentSymbol
    CHARACTER(*), OPTIONAL, INTENT(IN) :: separator
  END SUBROUTINE txt_read_Lines
END INTERFACE

!----------------------------------------------------------------------------
!                                                       ReadLine@ReadMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 19 July 2022
! summary: Read a single line (record)

INTERFACE
  MODULE SUBROUTINE txt_read_Char(obj, val, iostat, iomsg, &
  & ignoreComment, ignoreBlank, commentSymbol, separator)
    CLASS(TxtFile_), INTENT(INOUT) :: obj
    CHARACTER(*), INTENT(OUT) :: val
    INTEGER(I4B), OPTIONAL, INTENT(OUT) :: iostat
    CHARACTER(*), OPTIONAL, INTENT(OUT) :: iomsg
    LOGICAL(LGT), OPTIONAL, INTENT(IN) :: ignoreComment
    LOGICAL(LGT), OPTIONAL, INTENT(IN) :: ignoreBlank
    CHARACTER(1), OPTIONAL, INTENT(IN) :: commentSymbol
    CHARACTER(*), OPTIONAL, INTENT(IN) :: separator
  END SUBROUTINE txt_read_Char
END INTERFACE

!----------------------------------------------------------------------------
!                                                           read@ReadMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 20 July 2022
! summary: Read a scalar integer

#define __SUBROUTINE_NAME__ txt_read_Int8
#define __DATA_TYPE__ INTEGER( Int8 )
#include "./ReadIntScalar.inc"
#undef __SUBROUTINE_NAME__
#undef __DATA_TYPE__

#define __SUBROUTINE_NAME__ txt_read_Int16
#define __DATA_TYPE__ INTEGER( Int16 )
#include "./ReadIntScalar.inc"
#undef __SUBROUTINE_NAME__
#undef __DATA_TYPE__

#define __SUBROUTINE_NAME__ txt_read_Int32
#define __DATA_TYPE__ INTEGER( Int32 )
#include "./ReadIntScalar.inc"
#undef __SUBROUTINE_NAME__
#undef __DATA_TYPE__

#define __SUBROUTINE_NAME__ txt_read_Int64
#define __DATA_TYPE__ INTEGER( Int64 )
#include "./ReadIntScalar.inc"
#undef __SUBROUTINE_NAME__
#undef __DATA_TYPE__

!----------------------------------------------------------------------------
!                                                          read@ReadMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 20 July 2022
! summary: Read a scalar real value

#define __SUBROUTINE_NAME__ txt_read_Real32
#define __DATA_TYPE__ REAL( Real32 )
#include "./ReadRealScalar.inc"
#undef __SUBROUTINE_NAME__
#undef __DATA_TYPE__

#define __SUBROUTINE_NAME__ txt_read_Real64
#define __DATA_TYPE__ REAL( Real64 )
#include "./ReadRealScalar.inc"
#undef __SUBROUTINE_NAME__
#undef __DATA_TYPE__

!----------------------------------------------------------------------------
!                                                           read@ReadMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 20 July 2022
! summary: Read an integer vector

#define __SUBROUTINE_NAME__ txt_read_vec_Int8
#define __DATA_TYPE__ INTEGER( Int8 )
#include "./ReadVector.inc"
#undef __SUBROUTINE_NAME__
#undef __DATA_TYPE__

#define __SUBROUTINE_NAME__ txt_read_vec_Int16
#define __DATA_TYPE__ INTEGER( Int16 )
#include "./ReadVector.inc"
#undef __SUBROUTINE_NAME__
#undef __DATA_TYPE__

#define __SUBROUTINE_NAME__ txt_read_vec_Int32
#define __DATA_TYPE__ INTEGER( Int32 )
#include "./ReadVector.inc"
#undef __SUBROUTINE_NAME__
#undef __DATA_TYPE__

#define __SUBROUTINE_NAME__ txt_read_vec_Int64
#define __DATA_TYPE__ INTEGER( Int64 )
#include "./ReadVector.inc"
#undef __SUBROUTINE_NAME__
#undef __DATA_TYPE__

!----------------------------------------------------------------------------
!                                                           read@ReadMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 20 July 2022
! summary: Read a intvector

#define __SUBROUTINE_NAME__ txt_read_IntVector
#define __DATA_TYPE__ TYPE( IntVector_ )
#include "./ReadRealScalar.inc"
#undef __SUBROUTINE_NAME__
#undef __DATA_TYPE__

!----------------------------------------------------------------------------
!                                                           read@ReadMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 20 July 2022
! summary: Read a vector of intvector

#define __SUBROUTINE_NAME__ txt_read_vec_IntVector
#define __DATA_TYPE__ TYPE( IntVector_ )
#include "./ReadVector.inc"
#undef __SUBROUTINE_NAME__
#undef __DATA_TYPE__

!----------------------------------------------------------------------------
!                                                          read@ReadMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 20 July 2022
! summary: Read a real value vector

#define __SUBROUTINE_NAME__ txt_read_vec_Real32
#define __DATA_TYPE__ REAL( Real32 )
#include "./ReadVector.inc"
#undef __SUBROUTINE_NAME__
#undef __DATA_TYPE__

#define __SUBROUTINE_NAME__ txt_read_vec_Real64
#define __DATA_TYPE__ REAL( Real64 )
#include "./ReadVector.inc"
#undef __SUBROUTINE_NAME__
#undef __DATA_TYPE__

!----------------------------------------------------------------------------
!                                                           read@ReadMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 20 July 2022
! summary: Read a realvector

#define __SUBROUTINE_NAME__ txt_read_RealVector
#define __DATA_TYPE__ TYPE( RealVector_ )
#include "./ReadRealScalar.inc"
#undef __SUBROUTINE_NAME__
#undef __DATA_TYPE__

!----------------------------------------------------------------------------
!                                                           read@ReadMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 20 July 2022
! summary: Read a vector of realvector

#define __SUBROUTINE_NAME__ txt_read_vec_RealVector
#define __DATA_TYPE__ TYPE( RealVector_ )
#include "./ReadVector.inc"
#undef __SUBROUTINE_NAME__
#undef __DATA_TYPE__

!----------------------------------------------------------------------------
!                                                           read@ReadMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 20 July 2022
! summary: Read an integer matrix

#define __SUBROUTINE_NAME__ txt_read_mat_Int8
#define __DATA_TYPE__ INTEGER( Int8 )
#include "./ReadMatrix.inc"
#undef __SUBROUTINE_NAME__
#undef __DATA_TYPE__

#define __SUBROUTINE_NAME__ txt_read_mat_Int16
#define __DATA_TYPE__ INTEGER( Int16 )
#include "./ReadMatrix.inc"
#undef __SUBROUTINE_NAME__
#undef __DATA_TYPE__

#define __SUBROUTINE_NAME__ txt_read_mat_Int32
#define __DATA_TYPE__ INTEGER( Int32 )
#include "./ReadMatrix.inc"
#undef __SUBROUTINE_NAME__
#undef __DATA_TYPE__

#define __SUBROUTINE_NAME__ txt_read_mat_Int64
#define __DATA_TYPE__ INTEGER( Int64 )
#include "./ReadMatrix.inc"
#undef __SUBROUTINE_NAME__
#undef __DATA_TYPE__

!> authors: Vikas Sharma, Ph. D.
! date: 20 July 2022
! summary: Read a real value vector

#define __SUBROUTINE_NAME__ txt_read_mat_Real32
#define __DATA_TYPE__ REAL( Real32 )
#include "./ReadMatrix.inc"
#undef __SUBROUTINE_NAME__
#undef __DATA_TYPE__

#define __SUBROUTINE_NAME__ txt_read_mat_Real64
#define __DATA_TYPE__ REAL( Real64 )
#include "./ReadMatrix.inc"
#undef __SUBROUTINE_NAME__
#undef __DATA_TYPE__

!----------------------------------------------------------------------------
!                                       ConvertMarkdownToSource@WriteMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 2021-11-07
! update: 2021-11-07
! summary: Reads a markdown file and converts it into the source file

INTERFACE
  MODULE SUBROUTINE txt_convertMarkdownToSource(obj, outfile, lang)
    CLASS(TxtFile_), INTENT(INOUT) :: obj
    TYPE(TxtFile_), INTENT(INOUT) :: outfile
    CHARACTER(*), OPTIONAL, INTENT(IN) :: lang
  END SUBROUTINE txt_convertMarkdownToSource
END INTERFACE

!----------------------------------------------------------------------------
!                                                       WriteLine@WriteMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 19 July 2022
! summary: Write a single line (record)

INTERFACE
  MODULE SUBROUTINE txt_write_Blank(obj)
    CLASS(TxtFile_), INTENT(INOUT) :: obj
    !! YES or NO
  END SUBROUTINE txt_write_Blank
END INTERFACE

!----------------------------------------------------------------------------
!                                                       WriteLine@WriteMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 19 July 2022
! summary: Write a single line (record)

INTERFACE
  MODULE SUBROUTINE txt_write_Line(obj, val, iostat, iomsg, advance)
    CLASS(TxtFile_), INTENT(INOUT) :: obj
    TYPE(String), INTENT(IN) :: val
    INTEGER(I4B), OPTIONAL, INTENT(OUT) :: iostat
    CHARACTER(*), OPTIONAL, INTENT(OUT) :: iomsg
    CHARACTER(*), OPTIONAL, INTENT(IN) :: advance
    !! YES or NO
  END SUBROUTINE txt_write_Line
END INTERFACE

INTERFACE TxtFileWrite
  MODULE PROCEDURE txt_write_Line
END INTERFACE TxtFileWrite

!----------------------------------------------------------------------------
!                                                       WriteLine@WriteMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 19 July 2022
! summary: Write a single line (record)

INTERFACE
  MODULE SUBROUTINE txt_write_Lines(obj, val, iostat, iomsg, advance)
    CLASS(TxtFile_), INTENT(INOUT) :: obj
    TYPE(String), INTENT(IN) :: val(:)
    INTEGER(I4B), OPTIONAL, INTENT(OUT) :: iostat
    CHARACTER(*), OPTIONAL, INTENT(OUT) :: iomsg
    CHARACTER(*), OPTIONAL, INTENT(IN) :: advance
    !! YES, NO
  END SUBROUTINE txt_write_Lines
END INTERFACE

INTERFACE TxtFileWrite
  MODULE PROCEDURE txt_write_Lines
END INTERFACE TxtFileWrite

!----------------------------------------------------------------------------
!                                                       WriteLine@WriteMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 19 July 2022
! summary: Write a single line (record)

INTERFACE
  MODULE SUBROUTINE txt_write_Char(obj, val, iostat, iomsg, &
    &  advance)
    CLASS(TxtFile_), INTENT(INOUT) :: obj
    CHARACTER(*), INTENT(IN) :: val
    INTEGER(I4B), OPTIONAL, INTENT(OUT) :: iostat
    CHARACTER(*), OPTIONAL, INTENT(OUT) :: iomsg
    CHARACTER(*), OPTIONAL, INTENT(IN) :: advance
    !! YES, NO
  END SUBROUTINE txt_write_Char
END INTERFACE

INTERFACE TxtFileWrite
  MODULE PROCEDURE txt_write_Char
END INTERFACE TxtFileWrite

!----------------------------------------------------------------------------
!                                                           Write@WriteMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 20 July 2022
! summary: Write an integer

#define __SUBROUTINE_NAME__ txt_write_Int8
#define __DATA_TYPE__ INTEGER( Int8 )
#include "./WriteScalar.inc"
#undef __SUBROUTINE_NAME__
#undef __DATA_TYPE__

#define __SUBROUTINE_NAME__ txt_write_Int16
#define __DATA_TYPE__ INTEGER( Int16 )
#include "./WriteScalar.inc"
#undef __SUBROUTINE_NAME__
#undef __DATA_TYPE__

#define __SUBROUTINE_NAME__ txt_write_Int32
#define __DATA_TYPE__ INTEGER( Int32 )
#include "./WriteScalar.inc"
#undef __SUBROUTINE_NAME__
#undef __DATA_TYPE__

#define __SUBROUTINE_NAME__ txt_write_Int64
#define __DATA_TYPE__ INTEGER( Int64 )
#include "./WriteScalar.inc"
#undef __SUBROUTINE_NAME__
#undef __DATA_TYPE__

INTERFACE TxtFileWrite
  MODULE PROCEDURE txt_write_Int8, txt_write_Int16, txt_write_Int32, &
    & txt_write_Int64
END INTERFACE TxtFileWrite

!----------------------------------------------------------------------------
!
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 20 July 2022
! summary: Write a real value

#define __SUBROUTINE_NAME__ txt_write_Real32
#define __DATA_TYPE__ REAL( Real32 )
#include "./WriteScalar.inc"
#undef __SUBROUTINE_NAME__
#undef __DATA_TYPE__

#define __SUBROUTINE_NAME__ txt_write_Real64
#define __DATA_TYPE__ REAL( Real64 )
#include "./WriteScalar.inc"
#undef __SUBROUTINE_NAME__
#undef __DATA_TYPE__

INTERFACE TxtFileWrite
  MODULE PROCEDURE txt_write_Real32, txt_write_Real64
END INTERFACE TxtFileWrite

!----------------------------------------------------------------------------
!                                                           Write@WriteMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 20 July 2022
! summary: Write an integer vector

#define __SUBROUTINE_NAME__ txt_write_vec_Int8
#define __DATA_TYPE__ INTEGER( Int8 )
#include "./WriteVector.inc"
#undef __SUBROUTINE_NAME__
#undef __DATA_TYPE__

#define __SUBROUTINE_NAME__ txt_write_vec_Int16
#define __DATA_TYPE__ INTEGER( Int16 )
#include "./WriteVector.inc"
#undef __SUBROUTINE_NAME__
#undef __DATA_TYPE__

#define __SUBROUTINE_NAME__ txt_write_vec_Int32
#define __DATA_TYPE__ INTEGER( Int32 )
#include "./WriteVector.inc"
#undef __SUBROUTINE_NAME__
#undef __DATA_TYPE__

#define __SUBROUTINE_NAME__ txt_write_vec_Int64
#define __DATA_TYPE__ INTEGER( Int64 )
#include "./WriteVector.inc"
#undef __SUBROUTINE_NAME__
#undef __DATA_TYPE__

INTERFACE TxtFileWrite
  MODULE PROCEDURE txt_write_vec_Int8, &
    & txt_write_vec_Int16, &
    & txt_write_vec_Int32, &
    & txt_write_vec_Int64
END INTERFACE TxtFileWrite

!----------------------------------------------------------------------------
!                                                         write@WriteMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 20 July 2022
! summary: Write a intvector

#define __SUBROUTINE_NAME__ txt_write_IntVector
#define __DATA_TYPE__ TYPE( IntVector_ )
#include "./WriteScalar.inc"
#undef __SUBROUTINE_NAME__
#undef __DATA_TYPE__

INTERFACE TxtFileWrite
  MODULE PROCEDURE txt_write_IntVector
END INTERFACE TxtFileWrite

!----------------------------------------------------------------------------
!                                                           read@ReadMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 20 July 2022
! summary: Write a vector of intvector

#define __SUBROUTINE_NAME__ txt_write_vec_IntVector
#define __DATA_TYPE__ TYPE( IntVector_ )
#include "./WriteVector.inc"
#undef __SUBROUTINE_NAME__
#undef __DATA_TYPE__

INTERFACE TxtFileWrite
  MODULE PROCEDURE txt_write_vec_IntVector
END INTERFACE TxtFileWrite

!----------------------------------------------------------------------------
!
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 20 July 2022
! summary: Write a real value vector

#define __SUBROUTINE_NAME__ txt_write_vec_Real32
#define __DATA_TYPE__ REAL( Real32 )
#include "./WriteVector.inc"
#undef __SUBROUTINE_NAME__
#undef __DATA_TYPE__

#define __SUBROUTINE_NAME__ txt_write_vec_Real64
#define __DATA_TYPE__ REAL( Real64 )
#include "./WriteVector.inc"
#undef __SUBROUTINE_NAME__
#undef __DATA_TYPE__

INTERFACE TxtFileWrite
  MODULE PROCEDURE txt_write_vec_Real32, txt_write_vec_Real64
END INTERFACE TxtFileWrite

!----------------------------------------------------------------------------
!                                                         write@WriteMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 20 July 2022
! summary: Write a RealVector

#define __SUBROUTINE_NAME__ txt_write_RealVector
#define __DATA_TYPE__ TYPE( RealVector_ )
#include "./WriteScalar.inc"
#undef __SUBROUTINE_NAME__
#undef __DATA_TYPE__

INTERFACE TxtFileWrite
  MODULE PROCEDURE txt_write_RealVector
END INTERFACE TxtFileWrite

!----------------------------------------------------------------------------
!                                                           read@ReadMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 20 July 2022
! summary: Write a vector of RealVector

#define __SUBROUTINE_NAME__ txt_write_vec_RealVector
#define __DATA_TYPE__ TYPE( RealVector_ )
#include "./WriteVector.inc"
#undef __SUBROUTINE_NAME__
#undef __DATA_TYPE__

INTERFACE TxtFileWrite
  MODULE PROCEDURE txt_write_vec_RealVector
END INTERFACE TxtFileWrite

!----------------------------------------------------------------------------
!                                                           Write@WriteMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 20 July 2022
! summary: Write an integer matrix

#define __SUBROUTINE_NAME__ txt_write_mat_Int8
#define __DATA_TYPE__ INTEGER( Int8 )
#include "./WriteMatrix.inc"
#undef __SUBROUTINE_NAME__
#undef __DATA_TYPE__

#define __SUBROUTINE_NAME__ txt_write_mat_Int16
#define __DATA_TYPE__ INTEGER( Int16 )
#include "./WriteMatrix.inc"
#undef __SUBROUTINE_NAME__
#undef __DATA_TYPE__

#define __SUBROUTINE_NAME__ txt_write_mat_Int32
#define __DATA_TYPE__ INTEGER( Int32 )
#include "./WriteMatrix.inc"
#undef __SUBROUTINE_NAME__
#undef __DATA_TYPE__

#define __SUBROUTINE_NAME__ txt_write_mat_Int64
#define __DATA_TYPE__ INTEGER( Int64 )
#include "./WriteMatrix.inc"
#undef __SUBROUTINE_NAME__
#undef __DATA_TYPE__

INTERFACE TxtFileWrite
  MODULE PROCEDURE txt_write_mat_Int8, &
    & txt_write_mat_Int16, &
    & txt_write_mat_Int32, &
    & txt_write_mat_Int64
END INTERFACE TxtFileWrite

!----------------------------------------------------------------------------
!
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 20 July 2022
! summary: Write a real value vector

#define __SUBROUTINE_NAME__ txt_write_mat_Real32
#define __DATA_TYPE__ REAL( Real32 )
#include "./WriteMatrix.inc"
#undef __SUBROUTINE_NAME__
#undef __DATA_TYPE__

#define __SUBROUTINE_NAME__ txt_write_mat_Real64
#define __DATA_TYPE__ REAL( Real64 )
#include "./WriteMatrix.inc"
#undef __SUBROUTINE_NAME__
#undef __DATA_TYPE__

INTERFACE TxtFileWrite
  MODULE PROCEDURE txt_write_mat_Real32, &
    & txt_write_mat_Real64
END INTERFACE TxtFileWrite

END MODULE TxtFile_Class
