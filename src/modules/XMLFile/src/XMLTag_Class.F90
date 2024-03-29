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

MODULE XMLTag_Class
USE GlobalData
USE String_Class, ONLY: String
USE ExceptionHandler_Class, ONLY: e
IMPLICIT NONE
PRIVATE
CHARACTER(LEN=*), PARAMETER :: modName = "XMLTag_Class"
INTEGER(I4B), PUBLIC :: BAD_TAG = -1
  !! Module local constant for indicating a bad tag
INTEGER(I4B), PUBLIC :: START_TAG = 1
  !! Module local constant for indicating the start of a tag
INTEGER(I4B), PUBLIC :: END_TAG = 2
  !! Module local constant for indicating the end of a tag
INTEGER(I4B), PUBLIC :: EMPTY_ELEMENT_TAG = 3
  !! Module local constant for indicating an empty tag
INTEGER(I4B), PUBLIC :: COMMENT_TAG = 4
  !! Module local constant for indicating comment tag
INTEGER(I4B), PUBLIC :: PROCESSING_INST_TAG = 5
  !! Module local constant for indicating ??? tag
INTEGER(I4B), PUBLIC :: DECLARATION_TAG = 6
  !! Module local constant for indicating a declaration tag
  !! the declaration tag, is usually the first tag in the file.

!----------------------------------------------------------------------------
!                                                                  XMLTag_
!----------------------------------------------------------------------------

TYPE :: XMLTag_
  PRIVATE
  TYPE(String), PUBLIC :: name
    !!  name of tag
  TYPE(String), PUBLIC :: content
    !! Content
  TYPE(String), ALLOCATABLE :: attrNames(:)
    !! attribute names
  TYPE(String), ALLOCATABLE :: attrValues(:)
    !! attribute values
  INTEGER(I4B) :: tAttributes = 0
    !! Total number of attributes
  TYPE(XMLTag_), POINTER :: parent => NULL()
    !! parent tag
  TYPE(XMLTag_), POINTER :: children(:) => NULL()
    !! children tag
  INTEGER(I4B) :: indent = 0
    !! Indent
  LOGICAL(LGT) :: isSelfClosing = .FALSE.
CONTAINS
  PRIVATE
  PROCEDURE, PUBLIC, PASS(obj) :: Initiate => xmlTag_Initiate
  PROCEDURE, PUBLIC, PASS(obj) :: set => xmlTag_set
  PROCEDURE, PUBLIC, PASS(obj) :: Export => xmlTag_Export
  PROCEDURE, PUBLIC, PASS(obj) :: Deallocate => xmlTag_Deallocate
  FINAL :: xmlTag_Final
  PROCEDURE, PUBLIC, PASS(obj) :: isEmpty => xmlTag_isEmpty

  PROCEDURE, PUBLIC, PASS(obj) :: setName => xmlTag_setName

  PROCEDURE, PUBLIC, PASS(obj) :: hasParent => xmlTag_hasParent
  PROCEDURE, PUBLIC, PASS(obj) :: getParentPointer => &
    & xmlTag_getParentPointer
  PROCEDURE, PUBLIC, PASS(obj) :: setParent => xmlTag_setParent

  PROCEDURE, PUBLIC, PASS(obj) :: hasChildren => xmlTag_hasChildren
  PROCEDURE, PUBLIC, PASS(obj) :: getChildrenPointer => &
    & xmlTag_getChildrenPointer
  PROCEDURE, PUBLIC, PASS(obj) :: setChildren => xmlTag_setChildren

  PROCEDURE, PUBLIC, PASS(obj) :: getAttributes => xmlTag_getAttributes
  PROCEDURE, PUBLIC, PASS(obj) :: getAttributeValue => &
    & xmlTag_getAttributeValue
  PROCEDURE, PUBLIC, PASS(obj) :: setAttribute => xmlTag_setAttribute
  PROCEDURE, PUBLIC, PASS(obj) :: setAttributes => xmlTag_setAttributes

  PROCEDURE, PUBLIC, PASS(obj) :: setContent => xmlTag_setContent
  PROCEDURE, PUBLIC, PASS(obj) :: getContent => xmlTag_getContent
  PROCEDURE, PUBLIC, PASS(obj) :: Display => xmlTag_Display
  PROCEDURE, PUBLIC, PASS(obj) :: Write => xmlTag_Write
  PROCEDURE, PUBLIC, PASS(obj) :: Stringify => xmlTag_Stringify
  PROCEDURE, PUBLIC, PASS(obj) :: StartTag => xmlTag_StartTag
  PROCEDURE, PUBLIC, PASS(obj) :: EndTag => xmlTag_EndTag
  PROCEDURE, PUBLIC, PASS(obj) :: SelfClosingTag => xmlTag_SelfClosingTag
END TYPE XMLTag_

PUBLIC :: XMLTag_

TYPE :: XMLTagPointer_
  CLASS(XMLTag_), POINTER :: ptr => NULL()
END TYPE XMLTagPointer_

PUBLIC :: XMLTagPointer_

!----------------------------------------------------------------------------
!                                               Initiate@ConstructorMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 8 Sept 2021
! summary: This routine initializes an instance of XMLTag_ class
!
!# Introduction
! This routine initializes an instance of XMLTag_ class

INTERFACE
  MODULE RECURSIVE SUBROUTINE xmlTag_Initiate(obj, cachedFile, iTag, lines, &
    & tagStart, tagEnd)
    CLASS(XMLTag_), TARGET, INTENT(INOUT) :: obj
    !! xmlTag object
    CHARACTER(LEN=1), INTENT(IN) :: cachedFile(:)
    !! cached file, which will be used to construct the obj
    INTEGER(I4B), INTENT(IN) :: iTag(:, :)
    !! The starting and ending position of each tag
    INTEGER(I4B), INTENT(IN) :: lines(:)
    !! The position of line endings
    INTEGER(I4B), INTENT(IN) :: tagStart
    !! Starting position of tag
    INTEGER(I4B), INTENT(IN) :: tagEnd
    !! Ending position of tag
  END SUBROUTINE xmlTag_Initiate
END INTERFACE

!----------------------------------------------------------------------------
!                                                            Set@SetMethods
!----------------------------------------------------------------------------

INTERFACE
  MODULE SUBROUTINE xmlTag_set(obj, name, content, attrName, attrValue, &
    & attrNames, attrValues, parent, children, indent, isSelfClosing, &
    & isContentIndented)
    CLASS(XMLTag_), INTENT(INOUT) :: obj
    TYPE(String), OPTIONAL, INTENT(IN) :: name
    TYPE(String), OPTIONAL, INTENT(IN) :: content
    TYPE(String), OPTIONAL, INTENT(IN) :: attrName
    TYPE(String), OPTIONAL, INTENT(IN) :: attrValue
    TYPE(String), OPTIONAL, INTENT(IN) :: attrNames(:)
    TYPE(String), OPTIONAL, INTENT(IN) :: attrValues(:)
    TYPE(XMLTag_), OPTIONAL, TARGET, INTENT(INOUT) :: parent
    TYPE(XMLTag_), OPTIONAL, TARGET, INTENT(INOUT) :: children(:)
    INTEGER(I4B), OPTIONAL, INTENT(IN) :: indent
    LOGICAL(LGT), OPTIONAL, INTENT(IN) :: isSelfClosing
    LOGICAL(LGT), OPTIONAL, INTENT(IN) :: isContentIndented
  END SUBROUTINE xmlTag_set
END INTERFACE

!----------------------------------------------------------------------------
!                                         Deallocate@ConstructorMethods
!----------------------------------------------------------------------------

INTERFACE
  MODULE SUBROUTINE xmlTag_Deallocate(obj)
    CLASS(XMLTag_), INTENT(INOUT) :: obj
  END SUBROUTINE xmlTag_Deallocate
END INTERFACE

!----------------------------------------------------------------------------
!                                                 Final@ConstructorMethods
!----------------------------------------------------------------------------

INTERFACE
  MODULE SUBROUTINE xmlTag_Final(obj)
    TYPE(XMLTag_), INTENT(INOUT) :: obj
  END SUBROUTINE xmlTag_Final
END INTERFACE

!----------------------------------------------------------------------------
!                                                      getTagName@GetMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 4 Sept 2021
! summary: Get the name of an XML tag
!
!# Introduction
! Get the name of an XML tag.
! This routine is modified from the following library
! [https://github.com/CASL/Futility/blob/master/src/FileType_XML.F90](https://github.com/CASL/Futility/blob/master/src/FileType_XML.F90)
!

INTERFACE
  MODULE SUBROUTINE getTagName(chars, tagname, ierr)
    CHARACTER(LEN=1), INTENT(IN) :: chars(:)
    !! chars the full tag string
    TYPE(String), INTENT(INOUT) :: tagname
    !! String with Tag name
    INTEGER(I4B), INTENT(INOUT) :: ierr
    !! ierr return error code
    !!  0: Success
    !! -1: Bad value for chars
    !! -2: illegal first character for tag name
    !! -3: illegal character in tag name
    !! -4: tag name starts with "xml"
  END SUBROUTINE getTagName
END INTERFACE

!----------------------------------------------------------------------------
!                                          ConvertCharArrayToStr@GetMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 8 Sept 2021
! summary:         Converts a character array to a string
!

INTERFACE
  MODULE PURE SUBROUTINE ConvertCharArrayToStr(chars, strobj)
    CHARACTER(LEN=1), INTENT(IN) :: chars(:)
    TYPE(String), INTENT(INOUT) :: strobj
  END SUBROUTINE ConvertCharArrayToStr
END INTERFACE

PUBLIC :: ConvertCharArrayToStr

!----------------------------------------------------------------------------
!                                            parseTagAttributes@GetMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 8 Sept 2021
! summary: For a given XML element extract the tag information
!
!# Introduction
!
! This routine extracts the tag information from a given XML element
!
! - ierr is the error code, which has following meaning:
!   - 0: no errors
!   -1: the element string does not have start/end tags
!   -2: "==" was encountered
!   -3: bad attribute name
!   -4: bad attribute value

INTERFACE
  MODULE SUBROUTINE parseTagAttributes(chars, tAttributes, attrNames, &
    & attrValues, ierr)
    CHARACTER(LEN=*), INTENT(IN) :: chars
    !! the element string with start tag
    INTEGER(I4B), INTENT(OUT) :: tAttributes
    !! number of attributes in the tag
    TYPE(String), ALLOCATABLE, INTENT(INOUT) :: attrNames(:)
    !! names of the attributes
    TYPE(String), ALLOCATABLE, INTENT(INOUT) :: attrValues(:)
    !! values of the attributes
    INTEGER(I4B), INTENT(OUT) :: ierr
    !! error code
  END SUBROUTINE parseTagAttributes
END INTERFACE

PUBLIC :: parseTagAttributes

!----------------------------------------------------------------------------
!                                                getChildTagInfo@GetMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 8 Sept 2021
! summary: Determines the number of child elements fora  given XML element
!
!# Introduction
!
! This routine determines the number of child elements for a  given XML
! element

INTERFACE
  MODULE PURE SUBROUTINE getChildTagInfo(tagStart, tagEnd, iTag, tChild, &
    & childTags, ierr)
    INTEGER(I4B), INTENT(IN) :: tagStart
    !! The index of the first tag
    INTEGER(I4B), INTENT(IN) :: tagEnd
    !! The index of the last tag
    INTEGER(I4B), INTENT(IN) :: iTag(:, :)
    !! the XML tags for a given element
    INTEGER(I4B), INTENT(OUT) :: tChild
    !! The number of child elements
    INTEGER(I4B), ALLOCATABLE, INTENT(INOUT) :: childTags(:, :)
    !! The start/end indices of the tags of any children
    INTEGER(I4B), INTENT(OUT) :: ierr
  END SUBROUTINE getChildTagInfo
END INTERFACE

!----------------------------------------------------------------------------
!                                                            Write@IOMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 8 Sept 2021
! summary: This routine Writes an XML element object to a file

INTERFACE
  MODULE SUBROUTINE xmlTag_export(obj, unitNo, nindent)
    CLASS(XMLTag_), INTENT(IN) :: obj
    INTEGER(I4B), INTENT(IN) :: unitNo
    INTEGER(I4B), OPTIONAL, INTENT(IN) :: nindent
  END SUBROUTINE xmlTag_export
END INTERFACE

!----------------------------------------------------------------------------
!                                                        isEmpty@getMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 8 sept 2021
! summary: This routine returns true if the object is empty
!
!# Introduction
! This routine returns true if the object is empty.
! The xmltag is empty when there is no content and no children.

INTERFACE
  MODULE PURE FUNCTION xmlTag_isEmpty(obj) RESULT(Ans)
    CLASS(XMLTag_), INTENT(IN) :: obj
    LOGICAL(LGT) :: ans
  END FUNCTION xmlTag_isEmpty
END INTERFACE

!----------------------------------------------------------------------------
!                                                       hasParent@GetMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 8 sept 2021
! summary: This routine returns true if the xmltag has parent

INTERFACE
  MODULE PURE FUNCTION xmlTag_hasParent(obj) RESULT(Ans)
    CLASS(XMLTag_), INTENT(IN) :: obj
    LOGICAL(LGT) :: ans
  END FUNCTION xmlTag_hasParent
END INTERFACE

!----------------------------------------------------------------------------
!                                                getParentPointer@GetMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 8 sept 2021
! summary: This routine returns the pointer to the parent of xmlTag

INTERFACE
  MODULE FUNCTION xmlTag_getParentPointer(obj) RESULT(Ans)
    CLASS(XMLTag_), INTENT(INOUT) :: obj
    CLASS(XMLTag_), POINTER :: ans
  END FUNCTION xmlTag_getParentPointer
END INTERFACE

!----------------------------------------------------------------------------
!                                                       setParent@setMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 8 sept 2021
! summary: This routine sets the pointer to the parent of xmlTag

INTERFACE
  MODULE PURE SUBROUTINE xmlTag_setParent(obj, parent)
    CLASS(xmlTag_), INTENT(INOUT) :: obj
    CLASS(xmlTag_), TARGET, INTENT(INOUT) :: parent
  END SUBROUTINE xmlTag_setParent
END INTERFACE

!----------------------------------------------------------------------------
!                                                    hasChildren@getMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 8 sept 2021
! summary: This routine returns true if the xmltag has a child

INTERFACE
  MODULE PURE FUNCTION xmlTag_hasChildren(obj) RESULT(Ans)
    CLASS(xmlTag_), INTENT(IN) :: obj
    LOGICAL(LGT) :: ans
  END FUNCTION xmlTag_hasChildren
END INTERFACE

!----------------------------------------------------------------------------
!                                              getChildrenPointer@GetMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 8 Sept 2021
! summary: This routine returns the pointer to the children of xmltag

INTERFACE
  MODULE FUNCTION xmlTag_getChildrenPointer(obj) RESULT(Ans)
    CLASS(xmlTag_), INTENT(INOUT) :: obj
    CLASS(xmlTag_), POINTER :: ans(:)
  END FUNCTION xmlTag_getChildrenPointer
END INTERFACE

!----------------------------------------------------------------------------
!                                              getAttributes@GetMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 8 Sept 2021
! summary: Get a list of the attributes of an XML element

INTERFACE
  MODULE PURE SUBROUTINE xmlTag_getAttributes(obj, names, values)
    CLASS(xmlTag_), INTENT(IN) :: obj
    TYPE(String), ALLOCATABLE, INTENT(INOUT) :: names(:)
    TYPE(String), ALLOCATABLE, INTENT(INOUT) :: values(:)
  END SUBROUTINE xmlTag_getAttributes
END INTERFACE

!----------------------------------------------------------------------------
!                                              getAttributeValue@GetMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 8 Sept 2021
! summary: Get a list of the attributes of an XML element

INTERFACE
  MODULE PURE SUBROUTINE xmlTag_getAttributeValue(obj, name, value)
    CLASS(xmlTag_), INTENT(IN) :: obj
    TYPE(String), INTENT(IN) :: name
    TYPE(String), INTENT(INOUT) :: value
  END SUBROUTINE xmlTag_getAttributeValue
END INTERFACE

!----------------------------------------------------------------------------
!                                                      getContent@SetMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 8 Sept 2021
! summary:

INTERFACE
  MODULE PURE SUBROUTINE xmlTag_SetContent(obj, content, isContentIndented)
    CLASS(XMLTag_), INTENT(INOUT) :: obj
    TYPE(String), INTENT(IN) :: content
    LOGICAL(LGT), OPTIONAL, INTENT(IN) :: isContentIndented
  END SUBROUTINE xmlTag_SetContent
END INTERFACE

!----------------------------------------------------------------------------
!                                                   getContent@GetMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 8 Sept 2021
! summary:

INTERFACE
  MODULE PURE FUNCTION xmlTag_getContent(obj) RESULT(ans)
    CLASS(XMLTag_), INTENT(IN) :: obj
    TYPE(String) :: ans
  END FUNCTION xmlTag_getContent
END INTERFACE

!----------------------------------------------------------------------------
!                                                    setName@setMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 8 Sept 2021
! summary: This routine sets the name of xmltag

INTERFACE
  MODULE SUBROUTINE xmlTag_setName(obj, name)
    CLASS(XMLTag_), INTENT(INOUT) :: obj
    TYPE(String), INTENT(IN) :: name
  END SUBROUTINE xmlTag_setName
END INTERFACE

!----------------------------------------------------------------------------
!                                                     setChildren@setMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 8 Sept 2021
! summary: This routine set the children

INTERFACE
  MODULE SUBROUTINE xmlTag_setChildren(obj, children)
    CLASS(XMLTag_), TARGET, INTENT(INOUT) :: obj
    TYPE(XMLTag_), TARGET, INTENT(INOUT) :: children(:)
  END SUBROUTINE xmlTag_setChildren
END INTERFACE

!----------------------------------------------------------------------------
!                                                  setAttribute@setMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 8 Sept 2021
! summary: This routine sets the attribute name and value

INTERFACE
  MODULE SUBROUTINE xmlTag_setAttribute(obj, name, value)
    CLASS(XMLTag_), INTENT(INOUT) :: obj
    TYPE(String), INTENT(IN) :: name
    TYPE(String), INTENT(IN) :: value
  END SUBROUTINE xmlTag_setAttribute
END INTERFACE

!----------------------------------------------------------------------------
!                                                  setAttributes@setMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 8 Sept 2021
! summary: This routine sets the attribute name and value

INTERFACE
  MODULE SUBROUTINE xmlTag_setAttributes(obj, names, values)
    CLASS(XMLTag_), INTENT(INOUT) :: obj
    TYPE(String), INTENT(IN) :: names(:)
    TYPE(String), INTENT(IN) :: values(:)
  END SUBROUTINE xmlTag_setAttributes
END INTERFACE

!----------------------------------------------------------------------------
!                                                         Display@IOMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 8 Sept 2021
! summary: This routine displays the content of xmlTag

INTERFACE
  MODULE SUBROUTINE xmlTag_Display(obj, msg, unitNo)
    CLASS(XMLTag_), INTENT(IN) :: obj
    CHARACTER(LEN=*), INTENT(IN) :: msg
    INTEGER(I4B), OPTIONAL, INTENT(IN) :: unitNo
  END SUBROUTINE xmlTag_Display
END INTERFACE

!----------------------------------------------------------------------------
!                                                           Write@IOMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 13 Sept 2021
! summary: This routine writes the tag to a file

INTERFACE
  MODULE SUBROUTINE xmlTag_Write(obj, unitNo, isIndented, &
    & isContentIndented, onlyStart, onlyContent, onlyEnd, &
    & endRecord)
    CLASS(XMLTag_), INTENT(IN) :: obj
    INTEGER(I4B), INTENT(IN) :: unitNo
    LOGICAL(LGT), OPTIONAL, INTENT(IN) :: isIndented
    LOGICAL(LGT), OPTIONAL, INTENT(IN) :: isContentIndented
    LOGICAL(LGT), OPTIONAL, INTENT(IN) :: onlyStart
    LOGICAL(LGT), OPTIONAL, INTENT(IN) :: onlyContent
    LOGICAL(LGT), OPTIONAL, INTENT(IN) :: onlyEnd
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: endRecord
    !! Ending record
  END SUBROUTINE xmlTag_Write
END INTERFACE

!----------------------------------------------------------------------------
!                                                        StartTag@GetMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 13 Sept 2021
! summary:

INTERFACE
  MODULE PURE FUNCTION xmlTag_StartTag(obj, isIndented) RESULT(Ans)
    CLASS(XMLTag_), INTENT(IN) :: obj
    LOGICAL(LGT), OPTIONAL, INTENT(IN) :: isIndented
    CHARACTER(LEN=:), ALLOCATABLE :: ans
  END FUNCTION xmlTag_StartTag
END INTERFACE

!----------------------------------------------------------------------------
!                                                         EndTag@GetMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 13 Sept 2021
! summary:

INTERFACE
  MODULE PURE FUNCTION xmlTag_EndTag(obj, isIndented) RESULT(Ans)
    CLASS(XMLTag_), INTENT(IN) :: obj
    LOGICAL(LGT), OPTIONAL, INTENT(IN) :: isIndented
    CHARACTER(LEN=:), ALLOCATABLE :: ans
  END FUNCTION xmlTag_EndTag
END INTERFACE

!----------------------------------------------------------------------------
!                                                SelfClosingTag@GetMethods
!----------------------------------------------------------------------------

INTERFACE
  MODULE PURE FUNCTION xmlTag_SelfClosingTag(obj, isIndented) RESULT(Ans)
    CLASS(XMLTag_), INTENT(IN) :: obj
    LOGICAL(LGT), OPTIONAL, INTENT(IN) :: isIndented
    CHARACTER(LEN=:), ALLOCATABLE :: ans
  END FUNCTION xmlTag_SelfClosingTag
END INTERFACE

!----------------------------------------------------------------------------
!                                                       Stringify@GetMethods
!----------------------------------------------------------------------------

!> authors: Vikas Sharma, Ph. D.
! date: 13 Sept 2021
! summary: This routine stringify

INTERFACE
  MODULE PURE FUNCTION xmlTag_Stringify(obj, isIndented, &
    & isContentIndented, onlyStart, onlyContent, onlyEnd) RESULT(Ans)
    CLASS(XMLTag_), INTENT(IN) :: obj
    LOGICAL(LGT), OPTIONAL, INTENT(IN) :: isIndented
    LOGICAL(LGT), OPTIONAL, INTENT(IN) :: isContentIndented
    LOGICAL(LGT), OPTIONAL, INTENT(IN) :: onlyStart
    LOGICAL(LGT), OPTIONAL, INTENT(IN) :: onlyContent
    LOGICAL(LGT), OPTIONAL, INTENT(IN) :: onlyEnd
    CHARACTER(LEN=:), ALLOCATABLE :: ans
  END FUNCTION xmlTag_Stringify
END INTERFACE

!----------------------------------------------------------------------------
!
!----------------------------------------------------------------------------
END MODULE XMLTag_Class
