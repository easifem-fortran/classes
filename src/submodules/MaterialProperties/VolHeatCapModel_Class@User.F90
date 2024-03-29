SUBMODULE(VolHeatCapModel_Class) User
IMPLICIT NONE
CONTAINS

!----------------------------------------------------------------------------
!                                                userVolHeatCap_Pointer
!----------------------------------------------------------------------------

MODULE PROCEDURE userVolHeatCap_Pointer
  ALLOCATE( ans )
  ans%getValue => userVolHeatCap_getval
END PROCEDURE userVolHeatCap_Pointer

!----------------------------------------------------------------------------
!                                                      userVolHeatCap_getval
!----------------------------------------------------------------------------

MODULE PROCEDURE userVolHeatCap_getval
  ans = obj%ConstVolHeatCapVal
END PROCEDURE userVolHeatCap_getval

!----------------------------------------------------------------------------
!
!----------------------------------------------------------------------------

END SUBMODULE User