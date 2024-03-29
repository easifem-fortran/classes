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

SUBMODULE(AbstractMaterial_Class) IOMethods
USE BaseMethod
USE fhash, ONLY: fhash_tbl_t, key => fhash_key, fhash_iter_t, fhash_key_t
USE TomlUtility
USE tomlf, ONLY:  &
  & toml_serialize,  &
  & toml_array, &
  & toml_get => get_value, &
  & toml_len => len, &
  & toml_stat
IMPLICIT NONE
CONTAINS

!----------------------------------------------------------------------------
!
!----------------------------------------------------------------------------

MODULE PROCEDURE obj_Display
INTEGER(I4B) :: tsize, ii
LOGICAL(LGT) :: matalloc, isOK
TYPE(fhash_iter_t) :: iter
CLASS(fhash_key_t), ALLOCATABLE :: ikey
CLASS(*), ALLOCATABLE :: idata

CALL Display(msg, unitNo=unitNo)
CALL Display(obj%isInit, "isInitiated : ", unitNo=unitNo)
IF (.NOT. obj%isInit) RETURN

CALL Display("name : "//obj%name%chars(), unitNo=unitNo)
CALL Display(obj%tProperties, "total Properties: ", unitNo=unitNo)
CALL BlankLines(unitNo=unitNo, nol=1)

iter = fhash_iter_t(obj%tbl)

DO WHILE (iter%next(ikey, idata))

  SELECT TYPE (d => idata)
  TYPE IS (INTEGER)
    CALL Display('property ('//tostring(d)//'): '//ikey%to_string(),  &
      & unitNo=unitNo)
  END SELECT

END DO

CALL BlankLines(unitNo=unitNo, nol=1)

matalloc = ALLOCATED(obj%matProps)

CALL Display(matalloc, "matProps ALLOCATED: ", unitNo=unitNo)

IF (matalloc) THEN
  tsize = SIZE(obj%matProps)

  DO ii = 1, tsize
    isOK = ASSOCIATED(obj%matProps(ii)%ptr)
    IF (isOK) THEN
      CALL BlankLines(unitNo=unitNo, nol=1)
      CALL obj%matProps(ii)%ptr%Display("material Properties("//  &
        & tostring(ii)//"):", unitNo=unitNo)
      CALL EqualLine(unitNo=unitNo)
    END IF
  END DO

END IF

END PROCEDURE obj_Display

!----------------------------------------------------------------------------
!                                                                    Export
!----------------------------------------------------------------------------

MODULE PROCEDURE obj_Export
CHARACTER(*), PARAMETER :: myName = "obj_Export()"
TYPE(String) :: dsetname

#ifdef DEBUG_VER
CALL e%RaiseInformation(modName//'::'//myName//' - '// &
  & '[START] Export()')
#endif

CALL e%RaiseError(modName//'::'//myName//' - '// &
  & '[WIP ERROR]')

! check
IF (.NOT. obj%isInit) THEN
  CALL e%RaiseError(modName//'::'//myName//" - "// &
    & '[INTERNAL ERROR] :: The instance of AbstractMaterial_'//  &
    & CHAR_LF//'or its child-class is not '//&
    & CHAR_LF//'initiated, initiate it first.')
END IF

! check
IF (.NOT. hdf5%isOpen()) THEN
  CALL e%RaiseError(modName//'::'//myName//" - "// &
  & '[INTERNAL ERROR] :: HDF5 file is not opened')
END IF

! check
IF (.NOT. hdf5%isWrite()) THEN
  CALL e%RaiseError(modName//'::'//myName//" - "// &
  & '[INTERNAL ERROR] :: HDF5 file does not have write permission')
END IF

! name
dsetname = TRIM(group)//"/name"
CALL hdf5%WRITE(dsetname=dsetname%chars(), vals=obj%name)

#ifdef DEBUG_VER
CALL e%RaiseInformation(modName//'::'//myName//' - '// &
  & '[END] Export()')
#endif
END PROCEDURE obj_Export

!----------------------------------------------------------------------------
!                                                                 Import
!----------------------------------------------------------------------------

MODULE PROCEDURE obj_Import
CHARACTER(*), PARAMETER :: myName = "obj_Import()"
TYPE(String) :: dsetname

#ifdef DEBUG_VER
CALL e%RaiseInformation(modName//'::'//myName//' - '// &
  & '[START] Import()')
#endif

CALL e%RaiseError(modName//'::'//myName//' - '// &
  & '[WIP ERROR]')

! check
IF (obj%isInit) THEN
  CALL e%RaiseError(modName//'::'//myName//" - "// &
  & '[CONFIG ERROR] :: Instance of AbstractMaterial_ or'//  &
  & CHAR_LF//' its child is already initiated, Deallocate it first!')
END IF

! check
IF (.NOT. hdf5%isOpen()) THEN
  CALL e%RaiseError(modName//'::'//myName//" - "// &
    & '[INTERNAL ERROR] :: HDF5 file is not opened')
END IF

! check
IF (.NOT. hdf5%isRead()) THEN
  CALL e%RaiseError(modName//'::'//myName//" - "// &
  & '[INTERNAL ERROR] :: HDF5 file does not have read permission')
END IF

obj%isInit = .TRUE.

! name
dsetname = TRIM(group)//"/name"
CALL hdf5%READ(dsetname=dsetname%chars(), vals=obj%name)

#ifdef DEBUG_VER
CALL e%RaiseInformation(modName//'::'//myName//' - '// &
  & '[END] Import()')
#endif

END PROCEDURE obj_Import

!----------------------------------------------------------------------------
!
!----------------------------------------------------------------------------

MODULE PROCEDURE obj_ImportFromToml_table
CHARACTER(*), PARAMETER :: myName = "obj_ImportFromToml_table"
INTEGER(I4B) :: origin, stat
LOGICAL(LGT) :: isOK
TYPE(ParameterList_) :: param
CHARACTER(:), ALLOCATABLE :: name
CLASS(UserFunction_), POINTER :: afunc

#ifdef DEBUG_VER
CALL e%RaiseInformation(modName//'::'//myName//' - '// &
  & '[START]')
#endif

CALL param%Initiate()
CALL SetAbstractMaterialParam(param=param, prefix=obj%GetPrefix(),  &
  & name=obj%GetPrefix())
CALL obj%Initiate(param=param)
CALL param%DEALLOCATE()

! get name of the property from the node (table)
CALL toml_get(table, "name", name, origin=origin, stat=stat)

isOK = ALLOCATED(name) .AND. (stat .EQ. toml_stat%success)
IF (.NOT. isOK) THEN
  CALL e%RaiseError(modName//'::'//myName//' - '// &
    & '[INTERNAL ERROR] :: cannot find/read "name" in the config file.')
  RETURN
END IF

CALL obj%AddMaterial(name=name)
afunc => NULL()
afunc => obj%GetMaterialPointer(name=name)
isOK = ASSOCIATED(afunc)

IF (.NOT. isOK) THEN
  CALL e%RaiseError(modName//'::'//myName//' - '// &
    & '[INTERNAL ERROR] :: Error while adding a material to list.')
  RETURN
END IF

CALL afunc%ImportFromToml(table=table)
afunc => NULL()
name = ""

#ifdef DEBUG_VER
CALL e%RaiseInformation(modName//'::'//myName//' - '// &
  & '[END] ')
#endif DEBUG_VER

END PROCEDURE obj_ImportFromToml_table

!----------------------------------------------------------------------------
!
!----------------------------------------------------------------------------

SUBROUTINE obj_ImportFromToml_array(obj, array)
  CLASS(AbstractMaterial_), INTENT(INOUT) :: obj
  TYPE(toml_array), POINTER, INTENT(INOUT) :: array
  CHARACTER(*), PARAMETER :: myName = "obj_ImportFromToml_array()"
  TYPE(toml_table), POINTER :: node
  INTEGER(I4B) :: origin, stat, tsize, ii
  LOGICAL(LGT) :: isOK
  TYPE(ParameterList_) :: param
  CHARACTER(:), ALLOCATABLE :: name
  CLASS(UserFunction_), POINTER :: afunc

#ifdef DEBUG_VER
  CALL e%RaiseInformation(modName//'::'//myName//' - '// &
    & '[START]')
#endif

  tsize = toml_len(array)

  CALL param%Initiate()
  CALL SetAbstractMaterialParam(param=param, prefix=obj%GetPrefix(),  &
    & name=obj%GetPrefix())
  CALL obj%Initiate(param=param)
  CALL param%DEALLOCATE()

  DO ii = 1, tsize
    node => NULL()
    CALL toml_get(array, ii, node)
    isOK = ASSOCIATED(node)

    IF (.NOT. isOK) THEN
      CALL e%RaiseError(modName//'::'//myName//' - '// &
        & '[INTERNAL ERROR] :: In toml file '//tostring(ii)//  &
        & 'th material cannot be read.')
      RETURN
    END IF

    ! get name of the property from the node (table)
    name = ""
    CALL toml_get(node, "name", name, origin=origin, stat=stat)

    isOK = ALLOCATED(name) .AND. (stat .EQ. toml_stat%success)
    IF (.NOT. isOK) THEN
      CALL e%RaiseError(modName//'::'//myName//' - '// &
       & '[INTERNAL ERROR] :: cannot find/read "name" from material number ' &
        & //tostring(ii)//' in the config file.')
      RETURN
    END IF

    CALL obj%AddMaterial(name=name)
    afunc => NULL()
    afunc => obj%GetMaterialPointer(name=name)
    isOK = ASSOCIATED(afunc)

    IF (.NOT. isOK) THEN
      CALL e%RaiseError(modName//'::'//myName//' - '// &
        & '[INTERNAL ERROR] :: Error while adding material name='//  &
        & name//' to list. This is '//tostring(ii)//'th material.')
      RETURN
    END IF

    CALL afunc%ImportFromToml(table=node)
  END DO

  afunc => NULL()
  node => NULL()

#ifdef DEBUG_VER
  CALL e%RaiseInformation(modName//'::'//myName//' - '// &
    & '[END]')
#endif

END SUBROUTINE obj_ImportFromToml_array

!----------------------------------------------------------------------------
!                                                           ImportFromToml
!----------------------------------------------------------------------------

MODULE PROCEDURE obj_ImportFromToml1
CHARACTER(*), PARAMETER :: myName = "obj_ImportFromToml1()"
TYPE(toml_table), POINTER :: node
TYPE(toml_array), POINTER :: array
INTEGER(I4B) :: origin, stat
LOGICAL(LGT) :: isTable, isArray
TYPE(ParameterList_) :: param

#ifdef DEBUG_VER
CALL e%RaiseInformation(modName//'::'//myName//' - '// &
  & '[START] ImportFromToml()')
#endif

! get tomlName from the table
node => NULL()
CALL toml_get(table, toml_mat_prop_name, node, origin=origin,  &
  & requested=.FALSE., stat=stat)

! The node can be a table or array of table; first thing first.
isTable = ASSOCIATED(node) .AND. (stat .EQ. toml_stat%success)

IF (isTable) THEN
  CALL obj_ImportFromToml_table(obj=obj, table=node)
  NULLIFY (node, array)
  RETURN
END IF

array => NULL()
! Try for an array of material tables
CALL toml_get(table, toml_mat_prop_name, array, origin=origin,  &
  & requested=.FALSE., stat=stat)

isArray = ASSOCIATED(array) .AND. (stat .EQ. toml_stat%success)
IF (.NOT. isArray) THEN
  CALL e%RaiseError(modName//'::'//myName//' - '// &
  & '[INTERNAL ERROR] :: Cannot found the array from the toml config.')
  RETURN
END IF

CALL obj_ImportFromToml_array(obj=obj, array=array)
NULLIFY (node, array)

#ifdef DEBUG_VER
CALL e%RaiseInformation(modName//'::'//myName//' - '// &
  & '[END] ImportFromToml()')
#endif
END PROCEDURE obj_ImportFromToml1

!----------------------------------------------------------------------------
!                                                            ImportFromToml
!----------------------------------------------------------------------------

MODULE PROCEDURE obj_ImportFromToml2
CHARACTER(*), PARAMETER :: myName = "obj_ImportFromToml2()"
TYPE(toml_table), ALLOCATABLE :: table0
TYPE(toml_table), POINTER :: table
INTEGER(I4B) :: origin, stat
LOGICAL(LGT) :: isok
TYPE(ParameterList_) :: param

#ifdef DEBUG_VER
CALL e%RaiseInformation(modName//'::'//myName//' - '// &
  & '[START]')
#endif

CALL GetValue(table=table0, afile=afile, filename=filename)

table => NULL()
CALL toml_get(table0, tomlName, table, origin=origin, requested=.FALSE.,  &
  & stat=stat)
isok = ASSOCIATED(table) .AND. (stat .EQ. toml_stat%success)
IF (.NOT. isok) THEN
  CALL e%RaiseError(modName//'::'//myName//' - '// &
    & '[INTERNAL ERROR] :: Cannot found tomlName = '//tomlName//  &
    & ' from the toml config.')
  RETURN
END IF

CALL obj%ImportFromToml(table=table)

NULLIFY (table)

#ifdef DEBUG_VER
CALL e%RaiseInformation(modName//'::'//myName//' - '// &
  & '[END]')
#endif
END PROCEDURE obj_ImportFromToml2

END SUBMODULE IOMethods
