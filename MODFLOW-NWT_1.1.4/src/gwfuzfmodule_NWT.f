      MODULE GWFUZFMODULE
        CHARACTER(LEN=64) :: Version_uzf
        REAL,PARAMETER :: CLOSEZERO=1.0E-15
        DOUBLE PRECISION,PARAMETER :: NEARZERO=1.0D-30
        DOUBLE PRECISION,PARAMETER :: ZEROD15=1.0D-15, ZEROD9=1.0D-09
        DOUBLE PRECISION,PARAMETER :: ZEROD6=1.0D-06
        DOUBLE PRECISION,PARAMETER :: ZEROD7=1.0D-07,ZEROD5=1.0D-05
        INTEGER         ,PARAMETER :: IRUNBIG = 10000
        INTEGER,SAVE, POINTER :: UZFRESTART
        INTEGER,SAVE,POINTER :: NUMCELLS, TOTCELLS, Iseepsupress 
        INTEGER,SAVE,POINTER :: ISAVEFINF
        INTEGER,SAVE,POINTER :: IPRCNT,Ireadsurfk,Isurfkreject
        INTEGER,SAVE, POINTER :: Iseepreject
        INTEGER,SAVE,POINTER :: ITHTIFLG, ITHTRFLG,UNITRECH,UNITDIS
        DOUBLE PRECISION,SAVE :: THETAB, FLUXB, FLUXHLD2
        DOUBLE PRECISION,SAVE,DIMENSION(:),POINTER :: CHECKTIME
        INTEGER,SAVE,DIMENSION(:),POINTER :: MORE
        INTEGER,SAVE,DIMENSION(:,:),POINTER :: LAYNUM
        INTEGER,SAVE,POINTER   ::NUZTOP, IUZFOPT, IRUNFLG, IETFLG, IUZM
        INTEGER,SAVE,POINTER   ::IUZFCB1, IUZFCB2, NTRAIL, NWAV, NSETS
        INTEGER,SAVE,POINTER   ::IUZFB22, IUZFB11, ETOPT
        INTEGER,SAVE,POINTER   ::NUZGAG, NUZGAGAR, NUZCL, NUZRW, IGSFLOW
        INTEGER,SAVE,POINTER   ::RTSOLUTE, IETBUD, INETFLUX, ETOFH_FLAG
        INTEGER,SAVE,  DIMENSION(:),    POINTER :: ITRLSTH
        INTEGER,SAVE,  DIMENSION(:,:),  POINTER :: IRUNBND, IUZFBND
        INTEGER,SAVE,  DIMENSION(:,:),  POINTER :: IUZLIST, NWAVST
        INTEGER,SAVE,  DIMENSION(:,:),  POINTER :: IUZHOLD
        INTEGER,SAVE,  DIMENSION(:,:),  POINTER :: LTRLST, ITRLST
        INTEGER,SAVE,  DIMENSION(:),  POINTER :: LTRLIT, ITRLIT
        REAL,   SAVE,POINTER   ::TOTRUNOFF, SURFDEP
        REAL,   SAVE,  DIMENSION(:),    POINTER :: FBINS
        REAL,   SAVE,  DIMENSION(:,:),  POINTER :: SEEPOUT, EXCESPP, VKS
        REAL,   SAVE,  DIMENSION(:,:),  POINTER :: SURFK
        REAL,   SAVE,  DIMENSION(:,:),  POINTER :: AIR_ENTRY, H_ROOT
        REAL,   SAVE,  DIMENSION(:,:),  POINTER :: REJ_INF
        REAL,   SAVE,  DIMENSION(:,:),  POINTER :: TO_CFP
        REAL,   SAVE,  DIMENSION(:,:),  POINTER :: EPS, THTS, THTI, THTR
        REAL,   SAVE,  DIMENSION(:,:),  POINTER :: PETRATE, ROOTDPTH
        REAL,   SAVE,  DIMENSION(:,:),  POINTER :: WCWILT,FINF,FINFSAVE
        REAL,   SAVE,  DIMENSION(:,:),  POINTER :: UZFETOUT, GWET
        REAL,   SAVE,  DIMENSION(:,:),  POINTER :: FNETEXFIL1
        REAL,   SAVE,  DIMENSION(:,:),  POINTER :: FNETEXFIL2, CUMGWET
        REAL,   SAVE,  POINTER :: TIMEPRINT
        DOUBLE PRECISION, SAVE, POINTER :: SMOOTHET
        DOUBLE PRECISION, SAVE, DIMENSION(:),  POINTER :: CUMUZVOL 
        DOUBLE PRECISION, SAVE, DIMENSION(:),  POINTER :: UZTSRAT
        DOUBLE PRECISION, SAVE, DIMENSION(:,:),POINTER :: UZFLWT, UZSTOR
        DOUBLE PRECISION, SAVE, DIMENSION(:,:),POINTER :: UZDPST, UZTHST
        DOUBLE PRECISION, SAVE, DIMENSION(:),POINTER :: UZDPIT, UZTHIT
        DOUBLE PRECISION, SAVE, DIMENSION(:,:),POINTER :: UZSPST, UZFLST
        DOUBLE PRECISION, SAVE, DIMENSION(:),POINTER :: UZSPIT, UZFLIT
        DOUBLE PRECISION, SAVE, DIMENSION(:,:),POINTER :: DELSTOR
        DOUBLE PRECISION, SAVE, DIMENSION(:,:),POINTER :: UZOLSFLX
        DOUBLE PRECISION, SAVE, DIMENSION(:,:),POINTER :: HLDUZF
        DOUBLE PRECISION, SAVE, DIMENSION(:,:),POINTER :: RTSOLWC
        DOUBLE PRECISION, SAVE, DIMENSION(:,:),POINTER :: RTSOLFL
        DOUBLE PRECISION, SAVE, DIMENSION(:,:),POINTER :: RTSOLDS
        DOUBLE PRECISION, SAVE, DIMENSION(:,:,:),POINTER :: UZTOTBAL
        DOUBLE PRECISION, SAVE, DIMENSION(:,:,:),POINTER :: GRIDSTOR
        DOUBLE PRECISION, SAVE, DIMENSION(:,:,:),POINTER :: GRIDET
      TYPE GWFUZFTYPE
        INTEGER,     POINTER   ::NUZTOP, IUZFOPT, IRUNFLG, IETFLG, IUZM
        INTEGER,     POINTER   ::IUZFCB1, IUZFCB2, NTRAIL, NWAV, NSETS
        INTEGER,     POINTER   ::IUZFB22, IUZFB11, ETOPT
        INTEGER,     POINTER   ::NUZGAG, NUZGAGAR, NUZCL, NUZRW, IGSFLOW
        INTEGER,     POINTER   ::RTSOLUTE, IETBUD, INETFLUX, ETOFH_FLAG
        INTEGER,     POINTER   ::NUMCELLS, TOTCELLS, Iseepsupress
        INTEGER,     POINTER   ::ISAVEFINF
        INTEGER,     POINTER   ::IPRCNT, Ireadsurfk, Isurfkreject
        INTEGER,     POINTER   ::Iseepreject
        INTEGER,     POINTER   ::ITHTIFLG, ITHTRFLG, UNITRECH, UNITDIS
        DOUBLE PRECISION,DIMENSION(:),  POINTER :: CHECKTIME
        INTEGER,DIMENSION(:),POINTER :: MORE
        INTEGER,DIMENSION(:,:),POINTER :: LAYNUM
        INTEGER,               POINTER :: UZFRESTART
        INTEGER,       DIMENSION(:),    POINTER :: ITRLSTH
        INTEGER,       DIMENSION(:,:),  POINTER :: IRUNBND, IUZFBND
        INTEGER,       DIMENSION(:,:),  POINTER :: IUZLIST, NWAVST
        INTEGER,       DIMENSION(:,:),  POINTER :: IUZHOLD
        INTEGER,       DIMENSION(:,:),  POINTER :: LTRLST, ITRLST
        INTEGER,       DIMENSION(:),  POINTER :: LTRLIT, ITRLIT
        REAL,          POINTER            ::TOTRUNOFF, SURFDEP
        REAL,          DIMENSION(:),    POINTER :: FBINS
        REAL,          DIMENSION(:,:),  POINTER :: SEEPOUT, EXCESPP, VKS
        REAL,          DIMENSION(:,:),  POINTER :: SURFK
        REAL,          DIMENSION(:,:),  POINTER :: AIR_ENTRY, H_ROOT
        REAL,          DIMENSION(:,:),  POINTER :: REJ_INF
        REAL,          DIMENSION(:,:),  POINTER :: TO_CFP
        REAL,          DIMENSION(:,:),  POINTER :: EPS, THTS, THTI, THTR
        REAL,          DIMENSION(:,:),  POINTER :: PETRATE, ROOTDPTH
        REAL,          DIMENSION(:,:),  POINTER :: WCWILT,FINF,FINFSAVE
        REAL,          DIMENSION(:,:),  POINTER :: UZFETOUT, GWET
        REAL,          DIMENSION(:,:),  POINTER :: FNETEXFIL1
        REAL,          DIMENSION(:,:),  POINTER :: FNETEXFIL2, CUMGWET
        REAL,                           POINTER :: TIMEPRINT
        DOUBLE PRECISION,       POINTER :: SMOOTHET
        DOUBLE PRECISION,       DIMENSION(:),  POINTER :: CUMUZVOL
        DOUBLE PRECISION,       DIMENSION(:),  POINTER :: UZTSRAT
        DOUBLE PRECISION,       DIMENSION(:,:),POINTER :: UZFLWT, UZSTOR
        DOUBLE PRECISION,       DIMENSION(:,:),POINTER :: UZDPST, UZTHST
        DOUBLE PRECISION,       DIMENSION(:),POINTER :: UZDPIT, UZTHIT
        DOUBLE PRECISION,       DIMENSION(:,:),POINTER :: UZSPST, UZFLST
        DOUBLE PRECISION,       DIMENSION(:),POINTER :: UZSPIT, UZFLIT
        DOUBLE PRECISION,       DIMENSION(:,:),POINTER :: DELSTOR
        DOUBLE PRECISION,       DIMENSION(:,:),POINTER :: UZOLSFLX
        DOUBLE PRECISION,       DIMENSION(:,:),POINTER :: HLDUZF
        DOUBLE PRECISION,       DIMENSION(:,:),POINTER :: RTSOLWC
        DOUBLE PRECISION,       DIMENSION(:,:),POINTER :: RTSOLFL
        DOUBLE PRECISION,       DIMENSION(:,:),POINTER :: RTSOLDS
        DOUBLE PRECISION,       DIMENSION(:,:,:),POINTER :: UZTOTBAL
        DOUBLE PRECISION,       DIMENSION(:,:,:),POINTER :: GRIDSTOR
        DOUBLE PRECISION,       DIMENSION(:,:,:),POINTER :: GRIDET
      END TYPE
      TYPE(GWFUZFTYPE), SAVE:: GWFUZFDAT(10)
      END MODULE GWFUZFMODULE