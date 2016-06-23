      MODULE GWFLAKMODULE
C------OLD USGS VERSION 7.1; JUNE 2006 GWFLAKMODULE; 
C------UPDATED FOR MF-2005, 1.9 RELEASE, FEBRUARY 6, 2012  
C------REVISION NUMBER CHANGED TO BE CONSISTENT WITH NWT RELEASE
C------NEW VERSION NUMBER 1.1.0, 6/21/2016  
C------MINOR UPDATES JAN. 2013 (LFK)
        CHARACTER(LEN=64),PARAMETER ::Version_lak =
     +'$Id: gwf2lak7_NWT.f 2370 2014-07-01 17:35:48Z rniswon $'
        INTEGER,SAVE,POINTER   ::NLAKES,NLAKESAR,ILKCB,NSSITR,LAKUNIT
        INTEGER,SAVE,POINTER   ::MXLKND,LKNODE,ICMX,NCLS,LWRT,NDV,NTRB,
     +                           IRDTAB
        REAL,   SAVE,POINTER   ::THETA,SSCNCR,SURFDEPTH
Cdep    Added SURFDEPTH  3/3/2009
Crgn    Added budget variables for GSFLOW CSV file
        REAL,   SAVE,POINTER   ::TOTGWIN_LAK,TOTGWOT_LAK,TOTDELSTOR_LAK
        REAL,   SAVE,POINTER   ::TOTSTOR_LAK,TOTEVAP_LAK,TOTPPT_LAK
        REAL,   SAVE,POINTER   ::TOTRUNF_LAK,TOTWTHDRW_LAK,TOTSURFIN_LAK
        REAL,   SAVE,POINTER   ::TOTSURFOT_LAK
        INTEGER,SAVE, DIMENSION(:),  POINTER ::ICS, NCNCVR, LIMERR, 
     +                                         LAKTAB
        INTEGER,SAVE, DIMENSION(:,:),POINTER ::ILAKE,ITRB,IDIV,ISUB,IRK
        INTEGER,SAVE, DIMENSION(:,:,:),POINTER ::LKARR1
        REAL,   SAVE, DIMENSION(:),  POINTER ::STAGES
        DOUBLE PRECISION,SAVE,DIMENSION(:), POINTER ::STGNEW,STGOLD,
     +                                        STGITER,VOLOLDD,STGOLD2
        DOUBLE PRECISION,SAVE,DIMENSION(:), POINTER :: RUNF, RUNOFF     !EDM
        REAL,   SAVE, DIMENSION(:),  POINTER ::VOL,FLOB,DSRFOT
        DOUBLE PRECISION,   SAVE, DIMENSION(:),  POINTER ::PRCPLK,EVAPLK
        REAL,   SAVE, DIMENSION(:),  POINTER ::BEDLAK
        REAL,   SAVE, DIMENSION(:),  POINTER ::WTHDRW,RNF,CUMRNF
        REAL,   SAVE, DIMENSION(:),  POINTER ::CUMPPT,CUMEVP,CUMGWI
        REAL,   SAVE, DIMENSION(:),  POINTER ::CUMUZF
        REAL,   SAVE, DIMENSION(:),  POINTER ::CUMGWO,CUMSWI,CUMSWO
        REAL,   SAVE, DIMENSION(:),  POINTER ::CUMWDR,CUMFLX,CNDFCT
        REAL,   SAVE, DIMENSION(:),  POINTER ::VOLINIT
        REAL,   SAVE, DIMENSION(:),  POINTER ::BOTTMS,BGAREA,SSMN,SSMX
Cdep    Added cumulative and time step error budget arrays
        REAL,   SAVE, DIMENSION(:),  POINTER ::CUMVOL,CMLAKERR,CUMLKOUT
        REAL,   SAVE, DIMENSION(:),  POINTER ::CUMLKIN,TSLAKERR,DELVOL
crgn        REAL,   SAVE, DIMENSION(:),  POINTER ::EVAP,PRECIP,SEEP,SEEP3
        DOUBLE PRECISION,   SAVE, DIMENSION(:),  POINTER ::EVAP,PRECIP
        DOUBLE PRECISION,   SAVE, DIMENSION(:),  POINTER ::EVAP3,PRECIP3
        DOUBLE PRECISION,   SAVE, DIMENSION(:),  POINTER ::FLWITER
        DOUBLE PRECISION,   SAVE, DIMENSION(:),  POINTER ::FLWITER3
        DOUBLE PRECISION,   SAVE, DIMENSION(:),  POINTER ::SEEP,SEEP3
        DOUBLE PRECISION,   SAVE, DIMENSION(:),  POINTER ::SEEPUZ
        DOUBLE PRECISION,   SAVE, DIMENSION(:),  POINTER ::WITHDRW
        DOUBLE PRECISION,   SAVE, DIMENSION(:),  POINTER ::SURFA
        REAL,   SAVE, DIMENSION(:),  POINTER ::SURFOT,SURFIN
        REAL,   SAVE, DIMENSION(:),  POINTER ::SUMCNN,SUMCHN
        REAL,   SAVE, DIMENSION(:,:),POINTER ::CLAKE,CRNF,SILLVT
        REAL,   SAVE, DIMENSION(:,:),POINTER ::CAUG,CPPT,CLAKINIT
        REAL,   SAVE, DIMENSION(:,:,:),POINTER ::BDLKN1
Cdep  Added arrays for tracking lake budgets for dry lakes
        REAL,   SAVE, DIMENSION(:),  POINTER ::EVAPO,FLWIN
        REAL,   SAVE, DIMENSION(:),  POINTER ::GWRATELIM
Cdep    Allocate arrays to add runoff from UZF Package
        REAL,   SAVE, DIMENSION(:),  POINTER ::OVRLNDRNF,CUMLNDRNF
Cdep    Allocate arrays for lake depth, area,and volume relations
        DOUBLE PRECISION,   SAVE, DIMENSION(:,:),  POINTER ::DEPTHTABLE
        DOUBLE PRECISION,   SAVE, DIMENSION(:,:),  POINTER ::AREATABLE
        DOUBLE PRECISION,   SAVE, DIMENSION(:,:),  POINTER ::VOLUMETABLE
Cdep    Allocate space for three dummy arrays used in GAGE Package
C         when Solute Transport is active
        REAL,   SAVE, DIMENSION(:,:),POINTER ::XLAKES,XLAKINIT,XLKOLD
Crsr    Allocate arrays in BD subroutine
        INTEGER,SAVE, DIMENSION(:),  POINTER ::LDRY,NCNT,NCNST,KSUB
        INTEGER,SAVE, DIMENSION(:),  POINTER ::MSUB1
        INTEGER,SAVE, DIMENSION(:,:),POINTER ::MSUB
        REAL,   SAVE, DIMENSION(:),  POINTER ::FLXINL,VOLOLD,GWIN,GWOUT
        REAL,   SAVE, DIMENSION(:),  POINTER ::DELH,TDELH,SVT,STGADJ
        REAL,   SAVE, DIMENSION(:,:),POINTER ::LAKSEEP
        INTEGER,SAVE,                POINTER ::NSFRLAK                 !EDM
        INTEGER,SAVE, DIMENSION(:),  POINTER ::LAKSFR,ILKSEG,ILKRCH    !EDM
        REAL,   SAVE, DIMENSION(:),  POINTER ::SWLAK,DELVOLLAK         !EDM
      TYPE GWFLAKTYPE
        INTEGER,      POINTER   ::NLAKES,NLAKESAR,ILKCB,NSSITR,LAKUNIT
        INTEGER,      POINTER   ::MXLKND,LKNODE,ICMX,NCLS,LWRT,NDV,NTRB,
     +                            IRDTAB
Cdep    Added SURFDEPTH 3/3/2009
        REAL,         POINTER   ::THETA,SSCNCR,SURFDEPTH
Crgn    Added budget variables for GSFLOW CSV file
        REAL,         POINTER   ::TOTGWIN_LAK,TOTGWOT_LAK,TOTDELSTOR_LAK
        REAL,         POINTER   ::TOTSTOR_LAK,TOTEVAP_LAK,TOTPPT_LAK
        REAL,         POINTER   ::TOTRUNF_LAK,TOTWTHDRW_LAK
        REAL,         POINTER   ::TOTSURFOT_LAK,TOTSURFIN_LAK
        INTEGER,      DIMENSION(:),  POINTER ::ICS, NCNCVR, LIMERR, 
     +                                         LAKTAB
        INTEGER,      DIMENSION(:,:),POINTER ::ILAKE,ITRB,IDIV,ISUB,IRK
        INTEGER,      DIMENSION(:,:,:),POINTER ::LKARR1
        REAL,         DIMENSION(:),  POINTER ::STAGES
        DOUBLE PRECISION,DIMENSION(:),POINTER ::STGNEW,STGOLD,STGITER,
     +                                        STGOLD2
        DOUBLE PRECISION,DIMENSION(:),POINTER :: RUNF, RUNOFF              !EDM
        DOUBLE PRECISION,DIMENSION(:),POINTER :: VOLOLDD
        REAL,         DIMENSION(:),  POINTER ::VOL,FLOB, DSRFOT
        DOUBLE PRECISION,DIMENSION(:),  POINTER ::PRCPLK,EVAPLK
        REAL,         DIMENSION(:),  POINTER ::BEDLAK
        REAL,         DIMENSION(:),  POINTER ::WTHDRW,RNF,CUMRNF
        REAL,         DIMENSION(:),  POINTER ::CUMPPT,CUMEVP,CUMGWI
        REAL,         DIMENSION(:),  POINTER ::CUMUZF
        REAL,         DIMENSION(:),  POINTER ::CUMGWO,CUMSWI,CUMSWO
        REAL,         DIMENSION(:),  POINTER ::CUMWDR,CUMFLX,CNDFCT
        REAL,         DIMENSION(:),  POINTER ::VOLINIT
        REAL,         DIMENSION(:),  POINTER ::BOTTMS,BGAREA,SSMN,SSMX
Cdep    Added cumulative and time step error budget arrays
        REAL,         DIMENSION(:),  POINTER ::CUMVOL,CMLAKERR,CUMLKOUT
        REAL,         DIMENSION(:),  POINTER ::TSLAKERR,DELVOL,CUMLKIN 
Crgn        REAL,         DIMENSION(:),  POINTER ::EVAP,PRECIP,SEEP,SEEP3
        DOUBLE PRECISION,DIMENSION(:),  POINTER :: EVAP,PRECIP
        DOUBLE PRECISION,DIMENSION(:),  POINTER :: EVAP3,PRECIP3
        DOUBLE PRECISION,DIMENSION(:),  POINTER :: FLWITER
        DOUBLE PRECISION,DIMENSION(:),  POINTER :: FLWITER3
        DOUBLE PRECISION,DIMENSION(:),  POINTER :: SEEP,SEEP3
        DOUBLE PRECISION,DIMENSION(:),  POINTER :: SEEPUZ
        DOUBLE PRECISION,DIMENSION(:),  POINTER :: WITHDRW  
        DOUBLE PRECISION,DIMENSION(:),  POINTER :: SURFA
        REAL,         DIMENSION(:),  POINTER ::SURFIN,SURFOT
        REAL,         DIMENSION(:),  POINTER ::SUMCNN,SUMCHN
        REAL,         DIMENSION(:,:),POINTER ::CLAKE,CRNF,SILLVT
        REAL,         DIMENSION(:,:),POINTER ::CAUG,CPPT,CLAKINIT
        REAL,         DIMENSION(:,:,:),POINTER ::BDLKN1
Cdep  Added arrays for tracking lake budgets for dry lakes
        REAL,         DIMENSION(:),  POINTER ::EVAPO,FLWIN
        REAL,         DIMENSION(:),  POINTER ::GWRATELIM
Cdep    Allocate arrays to add runoff from UZF Package
        REAL,         DIMENSION(:),  POINTER ::OVRLNDRNF,CUMLNDRNF
Cdep    Allocate arrays for lake depth, area, and volume relations
        DOUBLE PRECISION,         DIMENSION(:,:),POINTER ::DEPTHTABLE
        DOUBLE PRECISION,         DIMENSION(:,:),POINTER ::AREATABLE
        DOUBLE PRECISION,         DIMENSION(:,:),POINTER ::VOLUMETABLE
Cdep    Allocate space for three dummy arrays used in GAGE Package
C         when Solute Transport is active
        REAL,         DIMENSION(:,:),POINTER ::XLAKES,XLAKINIT,XLKOLD
Crsr    Allocate arrays in BD subroutine
        INTEGER,      DIMENSION(:),  POINTER ::LDRY,NCNT,NCNST,KSUB
        INTEGER,      DIMENSION(:),  POINTER ::MSUB1
        INTEGER,      DIMENSION(:,:),POINTER ::MSUB
        REAL,         DIMENSION(:),  POINTER ::FLXINL,VOLOLD,GWIN,GWOUT
        REAL,         DIMENSION(:),  POINTER ::DELH,TDELH,SVT,STGADJ
        REAL,         DIMENSION(:,:),POINTER ::LAKSEEP
        INTEGER,                     POINTER ::NSFRLAK                 !EDM
        INTEGER,      DIMENSION(:),  POINTER ::LAKSFR,ILKSEG,ILKRCH    !EDM
        REAL,         DIMENSION(:),  POINTER ::SWLAK,DELVOLLAK         !EDM
      END TYPE
      TYPE(GWFLAKTYPE), SAVE:: GWFLAKDAT(10)
      END MODULE GWFLAKMODULE
