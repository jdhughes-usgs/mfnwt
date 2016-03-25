C
C ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
C LINK-MT3DMS (LMT) PACKAGE V7 FOR MODFLOW-2005
C Modified from LMT V6 for MODFLOW-2000 as documented in:
C     Zheng, C., M.C. Hill, and P.A. Hsieh, 2001,
C         MODFLOW-2000, the U.S. Geological Survey modular ground-water
C         model--User guide to the LMT6 Package, the linkage with
C         MT3DMS for multispecies mass transport modeling:
C         U.S. Geological Survey Open-File Report 01-82
C
C Revision History: 
C     Version 7.0: 08-08-2008 cz
C     Version 7.0: 08-15-2009 swm: added LMTMODULE to support LGR
C     Version 7.0: 02-12-2010 swm: rolled in include file
C ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
C
C
      MODULE LMTMODULE
         INTEGER, SAVE, POINTER ::ISSMT3D,IUMT3D,ILMTFMT,ISFRLAKCONNECT,
     +                            IUZFSFRCONNECT,IUZFLAKCONNECT,
     +                            NPCKGTXT,IUZFFLOWS,ISFRFLOWS,ILAKFLOWS
        TYPE LMTTYPE
         INTEGER, POINTER ::ISSMT3D,IUMT3D,ILMTFMT,ISFRLAKCONNECT,
     +                      IUZFSFRCONNECT,IUZFLAKCONNECT,NPCKGTXT,
     +                      IUZFFLOWS,ISFRFLOWS,ILAKFLOWS
        END TYPE
        TYPE(LMTTYPE), SAVE  ::LMTDAT(10)
      END MODULE LMTMODULE
C
      SUBROUTINE LMT7BAS7AR(INUNIT,CUNIT,IGRID)
C **********************************************************************
C OPEN AND READ THE INPUT FILE FOR THE LINK-MT3DMS PACKAGE VERSION 7.
C CHECK KEY FLOW MODEL INFORMATION AND SAVE IT IN THE HEADER OF
C THE MODFLOW-MT3DMS LINK FILE FOR USE IN MT3DMS TRANSPORT SIMULATION.
C NOTE THE 'STANDARD' HEADER OPTION IS NO LONGER SUPPORTED. INSTEAD,
C THE 'EXTENDED' HEADER OPTION IS THE DEFAULT. THE RESULTING LINK FILE 
C IS ONLY COMPATIBLE WITH MT3DMS VERSION [4.00] OR LATER.
!rgn------REVISION NUMBER CHANGED TO INDICATE MODIFICATIONS FOR NWT 
!rgn------NEW VERSION NUMBER 1.1.0, 9/11/2015
C **********************************************************************
C last modified: 08-08-2008
C last modified: 10-21-2010 swm: added MTMNW1 & MTMNW2
C      
      USE GLOBAL,   ONLY:NCOL,NROW,NLAY,NPER,NODES,NIUNIT,IUNIT,
     &                   ISSFLG,IBOUND,IOUT
      USE LMTMODULE,ONLY:ISSMT3D,IUMT3D,ILMTFMT,IUZFLAKCONNECT,
     &                   IUZFSFRCONNECT,ISFRLAKCONNECT,NPCKGTXT,
     &                   IUZFFLOWS,ISFRFLOWS,ILAKFLOWS
      USE GWFUZFMODULE, ONLY:IUZFOPT,IRUNFLG,IETFLG,IRUNBND
      USE GWFSFRMODULE, ONLY:IOTSG,IDIVAR,NSS
C--USE FILE SPECIFICATION of MODFLOW-2005
      INCLUDE 'openspec.inc'
      LOGICAL       LOP,FIRSTVAL
      CHARACTER*4   CUNIT(NIUNIT)
      CHARACTER*200 LINE,FNAME,NME
      CHARACTER*8   OUTPUT_FILE_HEADER
      CHARACTER*11  OUTPUT_FILE_FORMAT      
      DATA          INLMT,MTBCF,MTLPF,MTHUF,MTWEL,MTDRN,MTRCH,MTEVT,
     &              MTRIV,MTSTR,MTGHB,MTRES,MTFHB,MTDRT,MTETS,MTSUB,
     &              MTIBS,MTLAK,MTMNW,MTSWT,MTSFR,MTUZF
     &             /22*0/
C     -----------------------------------------------------------------    
      ALLOCATE(ISSMT3D,IUMT3D,ILMTFMT,IUZFSFRCONNECT,IUZFLAKCONNECT,
     +         ISFRLAKCONNECT,NPCKGTXT,IUZFFLOWS,ISFRFLOWS,ILAKFLOWS)
      NPCKGTXT=0
C
C--SET POINTERS FOR THE CURRENT GRID 
cswm: already set in main (GWF2BAS7OC)      CALL SGWF2BAS7PNT(IGRID)     
C
C--CHECK for OPTIONS/PACKAGES USED IN CURRENT SIMULATION
      IUMT3D=0
      DO IU=1,NIUNIT
        IF(CUNIT(IU).EQ.'LMT6') THEN
          INLMT=IUNIT(IU)
          
        ELSEIF(CUNIT(IU).EQ.'BCF6') THEN
          MTBCF=IUNIT(IU)
        ELSEIF(CUNIT(IU).EQ.'LPF ') THEN
          MTLPF=IUNIT(IU)
        ELSEIF(CUNIT(IU).EQ.'HUF2') THEN
          MTHUF=IUNIT(IU)
        ELSEIF(CUNIT(IU).EQ.'WEL ') THEN
          MTWEL=IUNIT(IU)
        ELSEIF(CUNIT(IU).EQ.'DRN ') THEN
          MTDRN=IUNIT(IU)
        ELSEIF(CUNIT(IU).EQ.'RCH ') THEN
          MTRCH=IUNIT(IU)
        ELSEIF(CUNIT(IU).EQ.'EVT ') THEN
          MTEVT=IUNIT(IU)
        ELSEIF(CUNIT(IU).EQ.'RIV ') THEN
          MTRIV=IUNIT(IU)
        ELSEIF(CUNIT(IU).EQ.'STR ') THEN
          MTSTR=IUNIT(IU)
          NPCKGTXT = NPCKGTXT + 1
        ELSEIF(CUNIT(IU).EQ.'GHB ') THEN
          MTGHB=IUNIT(IU)
        ELSEIF(CUNIT(IU).EQ.'RES ') THEN
          MTRES=IUNIT(IU)
          NPCKGTXT = NPCKGTXT + 1
        ELSEIF(CUNIT(IU).EQ.'FHB ') THEN
          MTFHB=IUNIT(IU)
          NPCKGTXT = NPCKGTXT + 1
        ELSEIF(CUNIT(IU).EQ.'DRT ') THEN
          MTDRT=IUNIT(IU)
          NPCKGTXT = NPCKGTXT + 1
        ELSEIF(CUNIT(IU).EQ.'ETS ') THEN
          MTETS=IUNIT(IU)
          NPCKGTXT = NPCKGTXT + 1
        ELSEIF(CUNIT(IU).EQ.'SUB ') THEN
          MTSUB=IUNIT(IU)
        ELSEIF(CUNIT(IU).EQ.'IBS ') THEN
          MTIBS=IUNIT(IU)
          NPCKGTXT = NPCKGTXT + 1
        ELSEIF(CUNIT(IU).EQ.'LAK ') THEN
          MTLAK=IUNIT(IU)
          NPCKGTXT = NPCKGTXT + 1
        ELSEIF(CUNIT(IU).EQ.'MNW1') THEN
          MTMNW1=IUNIT(IU)
          NPCKGTXT = NPCKGTXT + 1
        ELSEIF(CUNIT(IU).EQ.'MNW2') THEN
!swm: store separate to not get clobbered by MNW1
          MTMNW2=IUNIT(IU)   
          NPCKGTXT = NPCKGTXT + 1
        ELSEIF(CUNIT(IU).EQ.'SWT ') THEN
          MTSWT=IUNIT(IU)
          NPCKGTXT = NPCKGTXT + 1
        ELSEIF(CUNIT(IU).EQ.'SFR ') THEN
          MTSFR=IUNIT(IU)
          NPCKGTXT = NPCKGTXT + 1
        ELSEIF(CUNIT(IU).EQ.'UZF ') THEN
          MTUZF=IUNIT(IU)
          NPCKGTXT = NPCKGTXT + 1
        ENDIF
      ENDDO            
!swm: SET MTMNW IF EITHER MNW1 OR MNW2 IS ACTIVE
      IF(MTMNW1.NE.0) MTMNW=MTMNW1
      IF(MTMNW2.NE.0) MTMNW=MTMNW2
C
C--IF LMT7 PACKAGE IS NOT ACTIVATED, SKIP TO END AND RETURN
      IF(INLMT.EQ.0) GOTO 9999
C
C--ASSIGN DEFAULTS TO LMT INPUT VARIABLES AND OUTPUT FILE NAME
      IUMT3D=333
      OUTPUT_FILE_HEADER='EXTENDED'
      ILMTHEAD=1
      OUTPUT_FILE_FORMAT='UNFORMATTED'
      ILMTFMT=0     
      INQUIRE(UNIT=INLMT,NAME=NME,OPENED=LOP)
      IFLEN=INDEX(NME,' ')-1
      DO NC=IFLEN,2,-1
        IF(NME(NC:NC).EQ.'.') THEN      
          FNAME=NME(1:NC-1)//'.FTL'
          GO TO 10
        ENDIF
      ENDDO    
      FNAME=NME(1:IFLEN)//'.FTL'     
C
C--READ ONE LINE OF LMT PACKAGE INPUT FILE
      FIRSTVAL=.TRUE.
      IUZFSFRCONNECT=0
      ISFRLAKCONNECT=0
      IUZFLAKCONNECT=0
      IUZFFLOWS=0
      ISFRFLOWS=0
      ILAKFLOWS=0
C
   10 READ(INLMT,'(A)',END=1000) LINE
      IF(LINE.EQ.' ') GOTO 10
      IF(LINE(1:1).EQ.'#') GOTO 10
C
C--DECODE THE INPUT RECORD
      LLOC=1
      CALL URWORD(LINE,LLOC,ITYP1,ITYP2,1,N,R,IOUT,INLMT)
C
C--CHECK FOR "OUTPUT_FILE_NAME" KEYWORD AND GET FILE NAME
      IF(LINE(ITYP1:ITYP2).EQ.'OUTPUT_FILE_NAME') THEN
        CALL URWORD(LINE,LLOC,INAM1,INAM2,0,N,R,IOUT,INLMT)
        IFLEN=INAM2-INAM1+1
        IF(LINE(INAM1:INAM2).EQ.' ') THEN
        ELSE
          FNAME=LINE(INAM1:INAM2)
        ENDIF
C
C--CHECK FOR "OUTPUT_FILE_UNIT" KEYWORD AND GET UNIT NUMBER
      ELSEIF(LINE(ITYP1:ITYP2).EQ.'OUTPUT_FILE_UNIT') THEN
        CALL URWORD(LINE,LLOC,ISTART,ISTOP,2,IU,R,IOUT,INLMT)
        IF(IU.GT.0) THEN
          IUMT3D=IU
        ELSEIF(IU.LT.0) THEN
          WRITE(IOUT,11) IU
          WRITE(*,11) IU
          CALL USTOP(' ')
        ENDIF
C
C--CHECK FOR "OUTPUT_FILE_HEADER" KEYWORD AND GET INPUT VALUE
      ELSEIF(LINE(ITYP1:ITYP2).EQ.'OUTPUT_FILE_HEADER') THEN
        CALL URWORD(LINE,LLOC,ISTART,ISTOP,1,N,R,IOUT,INLMT)
        IF(LINE(ISTART:ISTOP).EQ.' '.OR.
     &     LINE(ISTART:ISTOP).EQ.'EXTENDED') THEN
          OUTPUT_FILE_HEADER='EXTENDED'
          ILMTHEAD=1
        ELSEIF(LINE(ISTART:ISTOP).EQ.'STANDARD') THEN
          WRITE(IOUT,120)
          WRITE(*,120)                   
        ELSE
          WRITE(IOUT,12) LINE(ISTART:ISTOP)
          WRITE(*,12) LINE(ISTART:ISTOP)
          CALL USTOP(' ')
        ENDIF
C
C--CHECK FOR "OUTPUT_FILE_FORMAT" KEYWORD AND GET INPUT VALUE
      ELSEIF(LINE(ITYP1:ITYP2).EQ.'OUTPUT_FILE_FORMAT') THEN
        CALL URWORD(LINE,LLOC,ISTART,ISTOP,1,N,R,IOUT,INLMT)
        IF(LINE(ISTART:ISTOP).EQ.' '.OR.
     &     LINE(ISTART:ISTOP).EQ.'UNFORMATTED') THEN
          OUTPUT_FILE_FORMAT='UNFORMATTED'
          ILMTFMT=0
        ELSEIF(LINE(ISTART:ISTOP).EQ.'FORMATTED') THEN
          OUTPUT_FILE_FORMAT='FORMATTED'
          ILMTFMT=1
        ELSE
          WRITE(IOUT,14) LINE(ISTART:ISTOP)
          WRITE(*,14) LINE(ISTART:ISTOP)
          CALL USTOP(' ')
        ENDIF
C
C--CHECK FOR "PACKAGE_FLOWS" KEYWORD AND GET INPUT 
      ELSEIF(LINE(ITYP1:ITYP2).EQ.'PACKAGE_FLOWS') THEN
        ISTOP=ITYP2
   20   ISTART=ISTOP + 1
        CALL URWORD(LINE,LLOC,ISTART,ISTOP,1,N,R,IOUT,INLMT)
        IF(LINE(ISTART:ISTOP).EQ.' ') THEN
          IF(FIRSTVAL) THEN 
            WRITE(IOUT,15) 
            GOTO 1000
          ELSE
            CONTINUE
          ENDIF
        ELSEIF(LINE(ISTART:ISTOP).EQ.'ALL') THEN ! ALL = "all available"
          !Activate connections in SFR, LAK, and UZF, provided they are active
          IF(MTUZF.NE.0.AND.IUZOPT.NE.0) THEN
            IUZFFLOWS=1
            NPCKGTXT = NPCKGTXT + 1
          ENDIF
          IF(MTSFR.NE.0) THEN
            ISFRFLOWS=1
            NPCKGTXT = NPCKGTXT + 1
          ENDIF
          IF(MTLAK.NE.0) THEN
            ILAKFLOWS=1
            NPCKGTXT = NPCKGTXT + 1
          ENDIF
          !edm: Determine which combinations of packages is active to determine 
          !     how many CONNECTions there are
          IF(IUZFFLOWS.EQ.1.AND.ISFRFLOWS.EQ.1.AND.
     &                        IUZFOPT.NE.0.AND.IRUNFLG.NE.0) THEN
            DO I=1,NROW
              DO J=1,NCOL
                IF(IRUNBND(J,I).GT.0) THEN ! check IRUNBND for at least 1 positive connection
                  IUZFSFRCONNECT=1
                  NPCKGTXT = NPCKGTXT + 1
                  EXIT
                ENDIF
              ENDDO
            ENDDO
          ENDIF
          IF(IUZFFLOWS.EQ.1.AND.ILAKFLOWS.EQ.1.AND.
     &                        IUZFOPT.NE.0.AND.IRUNFLG.NE.0) THEN
            DO I=1,NROW
              DO J=1,NCOL
                IF(IRUNBND(J,I).LT.0) THEN ! check IRUNBND for at least 1 negative (lake) connection
                  IUZFLAKCONNECT=1
                  NPCKGTXT = NPCKGTXT + 1
                  EXIT
                ENDIF
              ENDDO
            ENDDO
          ENDIF
C--EDM Cycle through all IUPSEG and IOUTSEG variables to see if there is a negative value, 
C  indicating that there is at least one SFR->LAK or LAK->SFR connection.
          IF(ISFRFLOWS.EQ.1.AND.ILAKFLOWS.EQ.1) THEN
            DO I=1,NSS
              IF(IOTSG(I).LT.0.OR.IDIVAR(I,1).LT.0) THEN ! check for a stream dumping to a lake, or lake dumping to a stream
                ISFRLAKCONNECT=1
                NPCKTXT = NPCKTXT + 1
                EXIT
              ENDIF              
            ENDDO
          ENDIF
        ELSEIF(LINE(ISTART:ISTOP).EQ.'SFR'.OR.
     +         LINE(ISTART:ISTOP).EQ.'LAK'.OR.
     +         LINE(ISTART:ISTOP).EQ.'UZF') THEN
          SELECT CASE (LINE(ISTART:ISTOP))
            CASE ('SFR')
              IF(MTSFR.NE.0) THEN
                ISFRFLOWS=1
                NPCKGTXT = NPCKGTXT + 1
              ENDIF
              ! Determine if a LAK connection exists. UZF connections only exist 
              ! if the UZF package is active and can be set at that time.
              ! Because the ISFRLAKCONNECT could have already been set by the 
              ! call to CASE('LAK'), need to check that it hasn't been set yet.
              IF(.NOT.ISFRLAKCONNECT.EQ.1) THEN
                IF(ISFRFLOWS.EQ.1.AND.ILAKFLOWS.EQ.1) THEN
                  DO I=1,NSS
                    IF(IOTSG(I).LT.0.OR.IDIVAR(I,1).LT.0) THEN ! check for a stream dumping to a lake, or lake dumping to a stream
                      ISFRLAKCONNECT=1
                      NPCKTXT = NPCKTXT + 1
                      EXIT
                    ENDIF
                  ENDDO
                ENDIF
              ENDIF
              FIRSTVAL=.FALSE.
            CASE ('LAK')
              IF(MTLAK.NE.0) THEN
                ILAKFLOWS=1
                NPCKGTXT = NPCKGTXT + 1
              ENDIF
              ! Determine if a SFR connection exists. UZF connections only exist 
              ! if the UZF package is active and can be set at that time.
              ! Because the ISFRLAKCONNECT could have already been set by the 
              ! call to CASE('SFR'), need to check that it hasn't been set yet.
              IF(.NOT.ISFRLAKCONNECT.EQ.1) THEN
                IF(ISFRFLOWS.EQ.1.AND.ILAKFLOWS.EQ.1) THEN
                  DO I=1,NSS
                    IF(IOTSG(I).LT.0.OR.IDIVAR(I,1).LT.0) THEN ! check for a stream dumping to a lake, or lake dumping to a stream
                      ISFRLAKCONNECT=1
                      NPCKTXT = NPCKTXT + 1
                      EXIT
                    ENDIF
                  ENDDO
                ENDIF
              ENDIF
              FIRSTVAL=.FALSE.
            CASE ('UZF')
              IF(MTUZF.NE.0) THEN
                IUZFFLOWS=1
                NPCKGTXT = NPCKGTXT + 1
              ENDIF
              ! Determine if SFR/LAK connections exist and set on a case by case basis. 
              IF(IUZFFLOWS.EQ.1.AND.MTSFR.NE.0.AND.
     &                            IUZFOPT.NE.0.AND.IRUNFLG.NE.0) THEN
                DO I=1,NROW
                  DO J=1,NCOL
                    IF(IRUNBND(J,I).GT.0) THEN ! check IRUNBND for at least 1 positive connection
                      IUZFSFRCONNECT=1
                      NPCKGTXT = NPCKGTXT + 1
                      EXIT
                    ENDIF
                  ENDDO
                ENDDO
              ENDIF
              IF(IUZFFLOWS.EQ.1.AND.MTLAK.NE.0.AND.
     &                            IUZFOPT.NE.0.AND.IRUNFLG.NE.0) THEN
                DO I=1,NROW
                  DO J=1,NCOL
                    IF(IRUNBND(J,I).LT.0) THEN ! check IRUNBND for at least 1 negative (lake) connection
                      IUZFLAKCONNECT=1
                      NPCKGTXT = NPCKGTXT + 1
                      EXIT
                    ENDIF
                  ENDDO
                ENDDO
              ENDIF
              FIRSTVAL=.FALSE.
          END SELECT
          GOTO 20
        ELSE
          WRITE(IOUT,16) LINE(ISTART:ISTOP)
          CALL USTOP(' ')
        ENDIF
C
C--ERROR DECODING LMT INPUT KEYWORDS
      ELSE
        WRITE(IOUT,28) LINE
        WRITE(*,28) LINE
        CALL USTOP(' ')
      ENDIF
C
C--CONTINUE TO THE NEXT INPUT RECORD IN LMT FILE
      GOTO 10
C
   11 FORMAT(/1X,'ERROR READING LMT PACKAGE INPUT DATA:',
     & /1X,'INVALID OUTPUT FILE UNIT: ',I5)
   12 FORMAT(/1X,'ERROR READING LMT PACKAGE INPUT DATA:',
     & /1X,'INVALID OUTPUT_FILE_HEADER CODE: ',A)
   14 FORMAT(/1X,'ERROR READING LMT PACKAGE INPUT DATA:',
     & /1X,'INVALID OUTPUT_FILE_FORMAT SPECIFIER: ',A)
   15 FORMAT(/1X,'SURFACE FLOW CONNECTIONS WILL NOT BE ',
     & 'WRITTEN TO THE FLOW-TRANSPORT LINK FILE')
   16 FORMAT(/1X,'THE FOLLOWING PACKAGE HAS NO SUPPORT ',
     & 'FOR SURFACE FLOW CONNECTIONS OR IS',
     & /1X,'AN UNRECOGNIZED KEYWORD IN THE LMT INPUT FILE: ',A)
   28 FORMAT(/1X,'ERROR READING LMT PACKAGE INPUT DATA:',
     & /1X,'UNRECOGNIZED KEYWORD: ',A)
  120 FORMAT(/1X,'WARNING READING LMT PACKAGE INPUT DATA:',
     &       /1X,'[STANDARD] HEADER NO LONGER SUPPORTED; ',
     &           '[EXTENDED] HEADER USED INSTEAD.')     
C     
 1000 CONTINUE     
C
C--ENSURE A UNIQUE UNIT NUMBER FOR LINK-MT3DMS OUTPUT FILE
      IF(IUMT3D.EQ.IOUT .OR. IUMT3D.EQ.INUNIT) THEN
        WRITE(IOUT,1010) IUMT3D
        WRITE(*,1010) IUMT3D
        CALL USTOP(' ')
      ELSE
        DO IU=1,NIUNIT       
          IF(IUMT3D.EQ.IUNIT(IU)) THEN
            WRITE(IOUT,1010) IUMT3D
            WRITE(*,1010) IUMT3D
            CALL USTOP(' ')
          ENDIF
        ENDDO
      ENDIF  
 1010 FORMAT(/1X,'ERROR IN LMT PACKAGE INPT DATA:'
     &       /1X,'UNIT NUMBER GIVEN FOR FLOW-TRANSPORT LINK FILE:', 
     &        I4,' ALREADY IN USE;' 
     &       /1X,'SPECIFY A UNIQUE UNIT NUMBER.')   
C
C--OPEN THE LINK-MT3DMS OUTPUT FILE NEEDED BY MT3DMS
C--AND PRINT AN IDENTIFYING MESSAGE IN MODFLOW OUTPUT FILE  
      INQUIRE(UNIT=IUMT3D,OPENED=LOP)
      IF(LOP) THEN
        REWIND (IUMT3D)
      ELSE
        IF(ILMTFMT.EQ.0) THEN
          OPEN(IUMT3D,FILE=FNAME,FORM=FORM,ACCESS=ACCESS,
     &      ACTION=ACTION(2),STATUS='REPLACE')
        ELSEIF(ILMTFMT.EQ.1) THEN
          OPEN(IUMT3D,FILE=FNAME,FORM='FORMATTED',ACTION=ACTION(2),
     &      STATUS='REPLACE',DELIM='APOSTROPHE')
        ENDIF
      ENDIF
C
      WRITE(IOUT,30) FNAME,IUMT3D,
     &               OUTPUT_FILE_FORMAT,OUTPUT_FILE_HEADER
   30 FORMAT(//1X,'***Link-MT3DMS Package v7***',
     &        /1x,'OPENING LINK-MT3DMS OUTPUT FILE: ',A,
     &        /1X,'ON UNIT NUMBER: ',I5,
     &        /1X,'FILE TYPE: ',A,
     &        /1X,'HEADER OPTION: ',A,
     &        /1X,'***Link-MT3DMS Package v7***',/1X)
C
C--GATHER AND CHECK KEY FLOW MODEL INFORMATION
      ISSMT3D=1    !loop through all stress periods        
      DO N=1,NPER    !to check if any transient sp is used
        IF(ISSFLG(N).EQ.0) THEN
          ISSMT3D=0
          EXIT
        ENDIF
      ENDDO                  
      MTISS=ISSMT3D
      MTNPER=NPER 
C
      MTCHD=0    !loop through the entire grid to get
      DO K=1,NLAY    !total number of constant-head cells
        DO I=1,NROW
          DO J=1,NCOL
            IF(IBOUND(J,I,K).LT.0) MTCHD=MTCHD+1
          ENDDO
        ENDDO
      ENDDO
C
C--ERROR CHECKING BEFORT OUTPUT
      IF(MTEVT.GT.0.AND.MTETS.GT.0) THEN
        WRITE(IOUT,1300)
        WRITE(*,1300)
        CALL USTOP(' ')
      ENDIF    
 1300 FORMAT(/1X,'ERROR IN LMT PACKAGE INPT DATA:'
     &  /1X,'Both EVT and ETS Packages are used in flow simulation;'
     &  /1X,'Only one is allowed in the same transport simulation.')
C
C--WRITE A HEADER TO MODFLOW-MT3DMS LINK FILE
      IF(OUTPUT_FILE_HEADER.EQ.'EXTENDED') THEN        
        IF(ILMTFMT.EQ.0) THEN
          WRITE(IUMT3D) 'MT3D4.00.00',
     &     MTWEL,MTDRN,MTRCH,MTEVT,MTRIV,MTGHB,MTCHD,MTISS,MTNPER,
     &     MTSTR,MTRES,MTFHB,MTDRT,MTETS,MTSUB,MTIBS,MTLAK,MTMNW,
     &     MTSWT,MTSFR,MTUZF
        ELSEIF(ILMTFMT.EQ.1) THEN
          WRITE(IUMT3D,*) 'MT3D4.00.00',
     &     MTWEL,MTDRN,MTRCH,MTEVT,MTRIV,MTGHB,MTCHD,MTISS,MTNPER,
     &     MTSTR,MTRES,MTFHB,MTDRT,MTETS,MTSUB,MTIBS,MTLAK,MTMNW,
     &     MTSWT,MTSFR,MTUZF
        ENDIF
      ENDIF

C------SAVE POINTER DATA TO ARRARYS
      CALL SLMT7PSV(IGRID)
C
C--NORMAL RETURN
 9999 RETURN
      END
C
      SUBROUTINE LMT7BD(KKSTP,KKPER,IGRID)
C **********************************************************************
C  WRITE TERMS TO THE FLOW-TRANSPORT LINK FILE FOR USE BY MT3DMS FOR
C  TRANSPORT SIMULATIONS.  THE CODE BELOW IS COPIED FROM THE lmt7.inc 
C  FILE.  INSTEAD OF USING THE INCLUDE FILE, THE CODE IS PUT INTO THIS
C  SUBROUTINE AND CALLED FROM MAIN.
C **********************************************************************
C last modified: 02-12-2010
C     
      USE GLOBAL,ONLY:IOUT,IUNIT
      USE LMTMODULE,ONLY:ISSMT3D,IUMT3D,ILMTFMT 

C--SWM: SWAP POINTERS FOR LMT DATA TO CURRENT GRID
        CALL SLMT7PNT(IGRID)
C
C--WRITE A NOTIFICATION LINE TO MODFLOW OUTPUT FILE
        WRITE(IOUT,9876) IUMT3D,KKSTP,KKPER
 9876   FORMAT(/1X,'SAVING SATURATED THICKNESS AND FLOW TERMS ON UNIT',
     &   I5,' FOR MT3DMS',/1X,'BY THE LINK-MT3DMS PACKAGE V7',
     &   ' AT TIME STEP',I5,', STRESS PERIOD',I5/)
C
C--COLLECT AND SAVE ALL RELEVANT FLOW MODEL INFORMATION
        IF(IUNIT(55).GT.0) 
     &   CALL LMT7UZF1(ILMTFMT,ISSMT3D,IUMT3D,KKSTP,KKPER,IGRID)
        IF(IUNIT(1) .GT.0) 
     &   CALL LMT7BCF7(ILMTFMT,ISSMT3D,IUMT3D,KKSTP,KKPER,IGRID)
        IF(IUNIT(23).GT.0) 
     &   CALL LMT7LPF7(ILMTFMT,ISSMT3D,IUMT3D,KKSTP,KKPER,IGRID)
         IF(IUNIT(62).GT.0) 
     &   CALL LMT7UPW1(ILMTFMT,ISSMT3D,IUMT3D,KKSTP,KKPER,IGRID)
        IF(IUNIT(37).GT.0) 
     &   CALL LMT7HUF7(ILMTFMT,ISSMT3D,IUMT3D,
     &   KKSTP,KKPER,IUNIT(47),IGRID)
        IF(IUNIT(2) .GT.0) 
     &   CALL LMT7WEL7(IUNIT(62),ILMTFMT,IUMT3D,KKSTP,KKPER,IGRID)
        IF(IUNIT(3) .GT.0) 
     &   CALL LMT7DRN7(ILMTFMT,IUMT3D,KKSTP,KKPER,IGRID)
        IF(IUNIT(8) .GT.0) 
     &   CALL LMT7RCH7(ILMTFMT,IUMT3D,KKSTP,KKPER,IGRID)
        IF(IUNIT(5) .GT.0) 
     &   CALL LMT7EVT7(ILMTFMT,IUMT3D,KKSTP,KKPER,IGRID)
        IF(IUNIT(39).GT.0) 
     &   CALL LMT7ETS7(ILMTFMT,IUMT3D,KKSTP,KKPER,IGRID) 
        IF(IUNIT(55).GT.0) 
     &   CALL LMT7UZFET(ILMTFMT,ISSMT3D,IUMT3D,KKSTP,KKPER,IGRID)
        IF(IUNIT(4) .GT.0)
     &   CALL LMT7RIV7(ILMTFMT,IUMT3D,KKSTP,KKPER,IGRID)
        IF(IUNIT(7) .GT.0) 
     &   CALL LMT7GHB7(ILMTFMT,IUMT3D,KKSTP,KKPER,IGRID)
        IF(IUNIT(18).GT.0) 
     &   CALL LMT7STR7(ILMTFMT,IUMT3D,KKSTP,KKPER,IGRID)
        IF(IUNIT(17).GT.0) 
     &   CALL LMT7RES7(ILMTFMT,IUMT3D,KKSTP,KKPER,IGRID)
        IF(IUNIT(16).GT.0) 
     &   CALL LMT7FHB7(ILMTFMT,IUMT3D,KKSTP,KKPER,IGRID)
        IF(IUNIT(52).GT.0) 
     &   CALL LMT7MNW17(ILMTFMT,IUMT3D,KKSTP,KKPER,IGRID)
        IF(IUNIT(50).GT.0) 
     &   CALL LMT7MNW27(ILMTFMT,IUMT3D,KKSTP,KKPER,IGRID)
        IF(IUNIT(40).GT.0) 
     &   CALL LMT7DRT7(ILMTFMT,IUMT3D,KKSTP,KKPER,IGRID)
C--SURFACE WATER NETWORK: CONNECTIONS & Q's
        IF(IUNIT(44).GT.0)
     &   CALL LMT7SFR2(ILMTFMT,IUMT3D,KKSTP,KKPER,IGRID)
        IF(IUNIT(22).GT.0)
     &   CALL LMT7LAK3(ILMTFMT,IUMT3D,KKSTP,KKPER,IGRID)
        IF(IUNIT(55).GT.0.AND.IUNIT(44).GT.0)
     &   CALL LMT7UZFCONNECT(ILMTFMT,IUMT3D,KKSTP,KKPER,IGRID)
C
      RETURN
      END
C
      SUBROUTINE LMT7BCF7(ILMTFMT,ISSMT3D,IUMT3D,KSTP,KPER,IGRID)
C *********************************************************************
C SAVE SATURATED CELL THICKNESS; FLOW ACROSS THREE CELL INTERFACES;
C TRANSIENT FLUID-STORAGE; AND LOCATIONS AND FLOW RATES OF
C CONSTANT-HEAD CELLS FOR USE BY MT3D.  THIS SUBROUTINE IS CALLED
C ONLY IF THE 'BCF' PACKAGE IS USED IN MODFLOW.
C *********************************************************************
C Modified from Harbaugh (2005)
C last modified: 08-08-2008
C
      USE GLOBAL,      ONLY:NCOL,NROW,NLAY,ISSFLG,IBOUND,HNEW,HOLD,
     &                      BUFF,CR,CC,CV,BOTM,LBOTM
      USE GWFBASMODULE,ONLY:DELT
      USE GWFBCFMODULE,ONLY:LAYCON,SC1,SC2
      CHARACTER*16 TEXT     
      DOUBLE PRECISION HD
C
C--SET POINTERS FOR THE CURRENT GRID     
cswm: already set in GWF2BCF7BDS      CALL SGWF2BCF7PNT(IGRID)      
C      
C--GET STEADY-STATE FLAG FOR THE CURRENT STRESS PERIOD               
      ISSCURRENT=ISSFLG(KPER)
C
C--CALCULATE AND SAVE SATURATED THICKNESS
      TEXT='THKSAT'
      ZERO=0.
      ONE=1.
C
C--INITIALIZE BUFF ARRAY WITH 1.E30 FOR INACTIVE CELLS
C--OR FLAG -111 FOR ACTIVE CELLS   
      FlagInactive=1.E30
      FlagActive=-111.
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            IF(IBOUND(J,I,K).EQ.0) THEN
              BUFF(J,I,K)=FlagInactive
            ELSE
              BUFF(J,I,K)=FlagActive
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--CALCULATE SATURATED THICKNESS FOR UNCONFINED/CONVERTIBLE
C--LAYERS AND STORE IN ARRAY BUFF
      DO K=1,NLAY
        IF(LAYCON(K).EQ.0 .OR. LAYCON(K).EQ.2) CYCLE
        DO I=1,NROW
          DO J=1,NCOL
            IF(IBOUND(J,I,K).NE.0) THEN
              TMP=HNEW(J,I,K)
              BUFF(J,I,K)=TMP-BOTM(J,I,LBOTM(K))
              IF(LAYCON(K).EQ.3) THEN
                THKLAY=BOTM(J,I,LBOTM(K)-1)-BOTM(J,I,LBOTM(K))
                IF(BUFF(J,I,K).GT.THKLAY) BUFF(J,I,K)=THKLAY
              ENDIF
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--SAVE THE CONTENTS OF THE BUFFER
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT
        WRITE(IUMT3D) BUFF
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT
        WRITE(IUMT3D,*) BUFF
      ENDIF
C
C--CALCULATE AND SAVE FLOW ACROSS RIGHT FACE
      NCM1=NCOL-1
      IF(NCM1.LT.1) GO TO 405
      TEXT='QXX'
C
C--CLEAR THE BUFFER     
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            BUFF(J,I,K)=ZERO
          ENDDO
        ENDDO
      ENDDO
C
C--FOR EACH CELL
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCM1
            IF(IBOUND(J,I,K).NE.0.AND.IBOUND(J+1,I,K).NE.0) THEN
              HDIFF=HNEW(J,I,K)-HNEW(J+1,I,K)
              BUFF(J,I,K)=HDIFF*CR(J,I,K)
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--RECORD CONTENTS OF BUFFER
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT
        WRITE(IUMT3D) BUFF
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT
        WRITE(IUMT3D,*) BUFF
      ENDIF
C
  405 CONTINUE
C
C--CALCULATE AND SAVE FLOW ACROSS FRONT FACE
      NRM1=NROW-1
      IF(NRM1.LT.1) GO TO 505
      TEXT='QYY'
C
C--CLEAR THE BUFFER
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            BUFF(J,I,K)=ZERO
          ENDDO
        ENDDO
      ENDDO
C
C--FOR EACH CELL
      DO K=1,NLAY
        DO I=1,NRM1
          DO J=1,NCOL
            IF(IBOUND(J,I,K).NE.0.AND.IBOUND(J,I+1,K).NE.0) THEN
              HDIFF=HNEW(J,I,K)-HNEW(J,I+1,K)
              BUFF(J,I,K)=HDIFF*CC(J,I,K)
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--RECORD CONTENTS OF BUFFER.
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT
        WRITE(IUMT3D) BUFF
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT
        WRITE(IUMT3D,*) BUFF
      ENDIF
C
  505 CONTINUE
C
C--CALCULATE AND SAVE FLOW ACROSS FRONT FACE
      NLM1=NLAY-1
      IF(NLM1.LT.1) GO TO 700
      TEXT='QZZ'
C
C--CLEAR THE BUFFER
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            BUFF(J,I,K)=ZERO
          ENDDO
        ENDDO
      ENDDO
C
C--FOR EACH CELL CALCULATE FLOW THRU LOWER FACE & STORE IN BUFFER
      DO K=1,NLM1
        DO I=1,NROW
          DO J=1,NCOL
            IF(IBOUND(J,I,K).NE.0.AND.IBOUND(J,I,K+1).NE.0) THEN
              HD=HNEW(J,I,K+1)
              IF(LAYCON(K+1).EQ.3 .OR. LAYCON(K+1).EQ.2) THEN
                TMP=HD
                IF(TMP.LT.BOTM(J,I,LBOTM(K+1)-1))
     &           HD=BOTM(J,I,LBOTM(K+1)-1)
              ENDIF
              HDIFF=HNEW(J,I,K)-HD
              BUFF(J,I,K)=HDIFF*CV(J,I,K)
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--RECORD CONTENTS OF BUFFER.
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT
        WRITE(IUMT3D) BUFF
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT
        WRITE(IUMT3D,*) BUFF
      ENDIF
C
  700 CONTINUE
C
C--CALCULATE AND SAVE GROUNDWATER STORAGE IF TRANSIENT
      IF(ISSMT3D.NE.0) GO TO 705
      TEXT='STO'
C
C--INITIALIZE AND CLEAR BUFFER
      TLED=ONE/DELT
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            BUFF(J,I,K)=ZERO
          ENDDO
        ENDDO
      ENDDO
      IF(ISSCURRENT.NE.0) GOTO 704
C
C--RUN THROUGH EVERY CELL IN THE GRID
      KT=0
      DO K=1,NLAY
        LC=LAYCON(K)
        IF(LC.EQ.3 .OR. LC.EQ.2) KT=KT+1
        DO I=1,NROW
          DO J=1,NCOL
C
C--CALCULATE FLOW FROM STORAGE (VARIABLE HEAD CELLS ONLY)
            IF(IBOUND(J,I,K).GT.0) THEN
              HSING=HNEW(J,I,K)
              IF(LC.NE.3 .AND. LC.NE.2) THEN
                RHO=SC1(J,I,K)*TLED
                STRG=RHO*HOLD(J,I,K) - RHO*HSING
              ELSE
                TP=BOTM(J,I,LBOTM(K)-1)
                RHO2=SC2(J,I,KT)*TLED
                RHO1=SC1(J,I,K)*TLED
                SOLD=RHO2
                IF(HOLD(J,I,K).GT.TP) SOLD=RHO1
                SNEW=RHO2
                IF(HSING.GT.TP) SNEW=RHO1
                STRG=SOLD*(HOLD(J,I,K)-TP) + SNEW*TP - SNEW*HSING
              ENDIF
              BUFF(J,I,K)=STRG
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--RECORD CONTENTS OF BUFFER.
  704 IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT
        WRITE(IUMT3D) BUFF
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT
        WRITE(IUMT3D,*) BUFF
      ENDIF
C
  705 CONTINUE
C
C--CALCULATE FLOW INTO OR OUT OF CONSTANT-HEAD CELLS
      TEXT='CNH'
      NCNH=0
C
C--CLEAR BUFFER
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            BUFF(J,I,K)=ZERO
          ENDDO
        ENDDO
      ENDDO
C
C--FOR EACH CELL IF IT IS CONSTANT HEAD COMPUTE FLOW ACROSS 6
C--FACES.
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
C
C--IF CELL IS NOT CONSTANT HEAD SKIP IT & GO ON TO NEXT CELL.
            IF(IBOUND(J,I,K).GE.0) CYCLE
            NCNH=NCNH+1
C
C--CLEAR FIELDS FOR SIX FLOW RATES.
            X1=ZERO
            X2=ZERO
            X3=ZERO
            X4=ZERO
            X5=ZERO
            X6=ZERO
C
C--CALCULATE FLOW THROUGH THE LEFT FACE
C
C--IF THERE IS AN INACTIVE CELL ON THE OTHER SIDE OF THIS
C--FACE THEN GO ON TO THE NEXT FACE.
            IF(J.EQ.1) GO TO 30
            IF(IBOUND(J-1,I,K).EQ.0) GO TO 30
            HDIFF=HNEW(J,I,K)-HNEW(J-1,I,K)
C
C--CALCULATE FLOW THROUGH THIS FACE INTO THE ADJACENT CELL.
            X1=HDIFF*CR(J-1,I,K)
C
C--CALCULATE FLOW THROUGH THE RIGHT FACE
   30       IF(J.EQ.NCOL) GO TO 60
            IF(IBOUND(J+1,I,K).EQ.0) GO TO 60
            HDIFF=HNEW(J,I,K)-HNEW(J+1,I,K)
            X2=HDIFF*CR(J,I,K)
C
C--CALCULATE FLOW THROUGH THE BACK FACE.
   60       IF(I.EQ.1) GO TO 90
            IF (IBOUND(J,I-1,K).EQ.0) GO TO 90
            HDIFF=HNEW(J,I,K)-HNEW(J,I-1,K)
            X3=HDIFF*CC(J,I-1,K)
C
C--CALCULATE FLOW THROUGH THE FRONT FACE.
   90       IF(I.EQ.NROW) GO TO 120
            IF(IBOUND(J,I+1,K).EQ.0) GO TO 120
            HDIFF=HNEW(J,I,K)-HNEW(J,I+1,K)
            X4=HDIFF*CC(J,I,K)
C
C--CALCULATE FLOW THROUGH THE UPPER FACE
  120       IF(K.EQ.1) GO TO 150
            IF (IBOUND(J,I,K-1).EQ.0) GO TO 150
            HD=HNEW(J,I,K)
            IF(LAYCON(K).NE.3 .AND. LAYCON(K).NE.2) GO TO 122
            TMP=HD
            IF(TMP.LT.BOTM(J,I,LBOTM(K)-1))
     &       HD=BOTM(J,I,LBOTM(K)-1)
  122       HDIFF=HD-HNEW(J,I,K-1)
            X5=HDIFF*CV(J,I,K-1)
C
C--CALCULATE FLOW THROUGH THE LOWER FACE.
  150       IF(K.EQ.NLAY) GO TO 180
            IF(IBOUND(J,I,K+1).EQ.0) GO TO 180
            HD=HNEW(J,I,K+1)
            IF(LAYCON(K+1).NE.3 .AND. LAYCON(K+1).NE.2) GO TO 152
            TMP=HD
            IF(TMP.LT.BOTM(J,I,LBOTM(K+1)-1))
     &       HD=BOTM(J,I,LBOTM(K+1)-1)
  152       HDIFF=HNEW(J,I,K)-HD
            X6=HDIFF*CV(J,I,K)
C
C--SUM UP FLOWS THROUGH SIX SIDES OF CONSTANT HEAD CELL.
  180       BUFF(J,I,K)=X1+X2+X3+X4+X5+X6
          ENDDO
        ENDDO
      ENDDO
C
C--RECORD CONTENTS OF BUFFER.
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT,NCNH
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT,NCNH
      ENDIF
C
C--IF THERE ARE NO CONSTANT-HEAD CELLS THEN SKIP
      IF(NCNH.LE.0) GOTO 1000
C
C--WRITE CONSTANT-HEAD CELL LOCATIONS AND RATES
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            IF(IBOUND(J,I,K).GE.0) CYCLE
            IF(ILMTFMT.EQ.0) THEN
              WRITE(IUMT3D)   K,I,J,BUFF(J,I,K)            
            ELSEIF(ILMTFMT.EQ.1) THEN
              WRITE(IUMT3D,*) K,I,J,BUFF(J,I,K)              
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--RETURN
 1000 CONTINUE
      RETURN
      END
C
C
      SUBROUTINE LMT7LPF7(ILMTFMT,ISSMT3D,IUMT3D,KSTP,KPER,IGRID)
C *********************************************************************
C SAVE FLOW ACROSS THREE CELL INTERFACES (QXX, QYY, QZZ), FLOW RATE TO
C OR FROM TRANSIENT FLUID-STORAGE (QSTO), AND LOCATIONS AND FLOW RATES
C OF CONSTANT-HEAD CELLS FOR USE BY MT3D.  THIS SUBROUTINE IS CALLED
C ONLY IF THE 'LPF' PACKAGE IS USED IN MODFLOW.
C *********************************************************************
C Modified from Harbaugh(2005)
C last modified: 08-08-2008
C
      USE GLOBAL,      ONLY:NCOL,NROW,NLAY,ISSFLG,IBOUND,HNEW,HOLD,
     &                      BUFF,CR,CC,CV,BOTM,LBOTM
      USE GWFBASMODULE,ONLY:DELT
      USE GWFLPFMODULE,ONLY:LAYTYP,SC1,SC2
      CHARACTER*16 TEXT
      DOUBLE PRECISION HD
C
C--SET POINTERS FOR THE CURRENT GRID      
cswm: already set GWF2LPF7BDS      CALL SGWF2LPF7PNT(IGRID)
C      
C--GET STEADY-STATE FLAG FOR THE CURRENT STRESS PERIOD
      ISSCURRENT=ISSFLG(KPER)      
C
C--CALCULATE AND SAVE SATURATED THICKNESS
      TEXT='THKSAT'
      ZERO=0.
      ONE=1.
C
C--INITIALIZE BUFF ARRAY WITH 1.E30 FOR INACTIVE CELLS
C--OR FLAG -111 FOR ACTIVE CELLS
      FlagInactive=1.E30
      FlagActive=-111.
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            IF(IBOUND(J,I,K).EQ.0) THEN
              BUFF(J,I,K)=FlagInactive
            ELSE
              BUFF(J,I,K)=FlagActive
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--CALCULATE SATURATED THICKNESS FOR UNCONFINED/CONVERTIBLE
C--LAYERS AND STORE IN ARRAY BUFF
      DO K=1,NLAY
        IF(LAYTYP(K).EQ.0) CYCLE
        DO I=1,NROW
          DO J=1,NCOL
            IF(IBOUND(J,I,K).NE.0) THEN
              TMP=HNEW(J,I,K)
              BUFF(J,I,K)=TMP-BOTM(J,I,LBOTM(K))
              THKLAY=BOTM(J,I,LBOTM(K)-1)-BOTM(J,I,LBOTM(K))
              IF(BUFF(J,I,K).GT.THKLAY) BUFF(J,I,K)=THKLAY
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--SAVE THE CONTENTS OF THE BUFFER
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT
        WRITE(IUMT3D) BUFF
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT
        WRITE(IUMT3D,*) BUFF
      ENDIF
C
C--CALCULATE AND SAVE FLOW ACROSS RIGHT FACE
      NCM1=NCOL-1
      IF(NCM1.LT.1) GO TO 405
      TEXT='QXX'
C
C--CLEAR THE BUFFER
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            BUFF(J,I,K)=ZERO
          ENDDO
        ENDDO
      ENDDO
C
C--FOR EACH CELL
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCM1
            IF(IBOUND(J,I,K).NE.0.AND.IBOUND(J+1,I,K).NE.0) THEN
              HDIFF=HNEW(J,I,K)-HNEW(J+1,I,K)
              BUFF(J,I,K)=HDIFF*CR(J,I,K)
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--RECORD CONTENTS OF BUFFER
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT
        WRITE(IUMT3D) BUFF
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT
        WRITE(IUMT3D,*) BUFF
      ENDIF
C
  405 CONTINUE
C
C--CALCULATE AND SAVE FLOW ACROSS FRONT FACE
      NRM1=NROW-1
      IF(NRM1.LT.1) GO TO 505
      TEXT='QYY'
C
C--CLEAR THE BUFFER
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            BUFF(J,I,K)=ZERO
          ENDDO
        ENDDO
      ENDDO
C
C--FOR EACH CELL
      DO K=1,NLAY
        DO I=1,NRM1
          DO J=1,NCOL
            IF(IBOUND(J,I,K).NE.0.AND.IBOUND(J,I+1,K).NE.0) THEN
              HDIFF=HNEW(J,I,K)-HNEW(J,I+1,K)
              BUFF(J,I,K)=HDIFF*CC(J,I,K)
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--RECORD CONTENTS OF BUFFER.
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT
        WRITE(IUMT3D) BUFF
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT
        WRITE(IUMT3D,*) BUFF
      ENDIF
C
  505 CONTINUE
C
C--CALCULATE AND SAVE FLOW ACROSS FRONT FACE
      NLM1=NLAY-1
      IF(NLM1.LT.1) GO TO 700
      TEXT='QZZ'
C
C--CLEAR THE BUFFER
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            BUFF(J,I,K)=ZERO
          ENDDO
        ENDDO
      ENDDO
C
C--FOR EACH CELL CALCULATE FLOW THRU LOWER FACE & STORE IN BUFFER
      DO K=1,NLM1
        DO I=1,NROW
          DO J=1,NCOL
            IF(IBOUND(J,I,K).NE.0.AND.IBOUND(J,I,K+1).NE.0) THEN
              HD=HNEW(J,I,K+1)
              IF(LAYTYP(K+1).NE.0) THEN
                TMP=HD
                TOP=BOTM(J,I,LBOTM(K+1)-1)
                IF(TMP.LT.TOP) HD=TOP
              ENDIF
              HDIFF=HNEW(J,I,K)-HD
              BUFF(J,I,K)=HDIFF*CV(J,I,K)
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--RECORD CONTENTS OF BUFFER.
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT
        WRITE(IUMT3D) BUFF
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT
        WRITE(IUMT3D,*) BUFF
      ENDIF
C
  700 CONTINUE
C
C--CALCULATE AND SAVE GROUNDWATER STORAGE IF TRANSIENT
      IF(ISSMT3D.NE.0) GO TO 705
      TEXT='STO'
C
C--INITIALIZE AND CLEAR BUFFER           
cswm: moved below      TLED=ONE/DELT
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            BUFF(J,I,K)=ZERO
          ENDDO
        ENDDO
      ENDDO
      IF(ISSCURRENT.NE.0) GOTO 704
C
C--RUN THROUGH EVERY CELL IN THE GRID
      TLED=ONE/DELT !swm: moved after check for transient sp
      KT=0
      DO K=1,NLAY
        LC=LAYTYP(K)
        IF(LC.NE.0) KT=KT+1
        DO I=1,NROW
          DO J=1,NCOL
C
C--CALCULATE FLOW FROM STORAGE (VARIABLE HEAD CELLS ONLY)
            IF(IBOUND(J,I,K).GT.0) THEN
              HSING=HNEW(J,I,K)
              IF(LC.EQ.0) THEN
                RHO=SC1(J,I,K)*TLED
                STRG=RHO*HOLD(J,I,K) - RHO*HSING
              ELSE
                TP=BOTM(J,I,LBOTM(K)-1)
                RHO2=SC2(J,I,KT)*TLED
                RHO1=SC1(J,I,K)*TLED
                SOLD=RHO2
                IF(HOLD(J,I,K).GT.TP) SOLD=RHO1
                SNEW=RHO2
                IF(HSING.GT.TP) SNEW=RHO1
                STRG=SOLD*(HOLD(J,I,K)-TP) + SNEW*TP - SNEW*HSING
              ENDIF
              BUFF(J,I,K)=STRG
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--RECORD CONTENTS OF BUFFER.
  704 IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT
        WRITE(IUMT3D) BUFF
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT
        WRITE(IUMT3D,*) BUFF
      ENDIF
C
  705 CONTINUE
C
C--CALCULATE FLOW INTO OR OUT OF CONSTANT-HEAD CELLS
      TEXT='CNH'
      NCNH=0
C
C--CLEAR BUFFER
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            BUFF(J,I,K)=ZERO
          ENDDO
        ENDDO
      ENDDO
C
C--FOR EACH CELL IF IT IS CONSTANT HEAD COMPUTE FLOW ACROSS 6
C--FACES.
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
C
C--IF CELL IS NOT CONSTANT HEAD SKIP IT & GO ON TO NEXT CELL.
            IF(IBOUND(J,I,K).GE.0) CYCLE
            NCNH=NCNH+1
C
C--CLEAR FIELDS FOR SIX FLOW RATES.
            X1=ZERO
            X2=ZERO
            X3=ZERO
            X4=ZERO
            X5=ZERO
            X6=ZERO
C
C--CALCULATE FLOW THROUGH THE LEFT FACE
C
C--IF THERE IS AN INACTIVE CELL ON THE OTHER SIDE OF THIS
C--FACE THEN GO ON TO THE NEXT FACE.
            IF(J.EQ.1) GO TO 30
            IF(IBOUND(J-1,I,K).EQ.0) GO TO 30
            HDIFF=HNEW(J,I,K)-HNEW(J-1,I,K)
C
C--CALCULATE FLOW THROUGH THIS FACE INTO THE ADJACENT CELL.
            X1=HDIFF*CR(J-1,I,K)
C
C--CALCULATE FLOW THROUGH THE RIGHT FACE
   30       IF(J.EQ.NCOL) GO TO 60
            IF(IBOUND(J+1,I,K).EQ.0) GO TO 60
            HDIFF=HNEW(J,I,K)-HNEW(J+1,I,K)
            X2=HDIFF*CR(J,I,K)
C
C--CALCULATE FLOW THROUGH THE BACK FACE.
   60       IF(I.EQ.1) GO TO 90
            IF (IBOUND(J,I-1,K).EQ.0) GO TO 90
            HDIFF=HNEW(J,I,K)-HNEW(J,I-1,K)
            X3=HDIFF*CC(J,I-1,K)
C
C--CALCULATE FLOW THROUGH THE FRONT FACE.
   90       IF(I.EQ.NROW) GO TO 120
            IF(IBOUND(J,I+1,K).EQ.0) GO TO 120
            HDIFF=HNEW(J,I,K)-HNEW(J,I+1,K)
            X4=HDIFF*CC(J,I,K)
C
C--CALCULATE FLOW THROUGH THE UPPER FACE
  120       IF(K.EQ.1) GO TO 150
            IF (IBOUND(J,I,K-1).EQ.0) GO TO 150
            HD=HNEW(J,I,K)
            IF(LAYTYP(K).EQ.0) GO TO 122
            TMP=HD
            TOP=BOTM(J,I,LBOTM(K)-1)
            IF(TMP.LT.TOP) HD=TOP
  122       HDIFF=HD-HNEW(J,I,K-1)
            X5=HDIFF*CV(J,I,K-1)
C
C--CALCULATE FLOW THROUGH THE LOWER FACE.
  150       IF(K.EQ.NLAY) GO TO 180
            IF(IBOUND(J,I,K+1).EQ.0) GO TO 180
            HD=HNEW(J,I,K+1)
            IF(LAYTYP(K+1).EQ.0) GO TO 152
            TMP=HD
            TOP=BOTM(J,I,LBOTM(K+1)-1)
            IF(TMP.LT.TOP) HD=TOP
  152       HDIFF=HNEW(J,I,K)-HD
            X6=HDIFF*CV(J,I,K)
C
C--SUM UP FLOWS THROUGH SIX SIDES OF CONSTANT HEAD CELL.
  180       BUFF(J,I,K)=X1+X2+X3+X4+X5+X6
          ENDDO
        ENDDO
      ENDDO
C
C--RECORD CONTENTS OF BUFFER.
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT,NCNH
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT,NCNH
      ENDIF
C
C--IF THERE ARE NO CONSTANT-HEAD CELLS THEN SKIP
      IF(NCNH.LE.0) GOTO 1000
C
C--WRITE CONSTANT-HEAD CELL LOCATIONS AND RATES
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            IF(IBOUND(J,I,K).GE.0) CYCLE
            IF(ILMTFMT.EQ.0) THEN
              WRITE(IUMT3D)   K,I,J,BUFF(J,I,K)
            ELSEIF(ILMTFMT.EQ.1) THEN
              WRITE(IUMT3D,*) K,I,J,BUFF(J,I,K)
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--RETURN
 1000 CONTINUE
      RETURN
      END
C
      SUBROUTINE LMT7UPW1(ILMTFMT,ISSMT3D,IUMT3D,KSTP,KPER,IGRID)
C *********************************************************************
C SAVE FLOW ACROSS THREE CELL INTERFACES (QXX, QYY, QZZ), FLOW RATE TO
C OR FROM TRANSIENT FLUID-STORAGE (QSTO), AND LOCATIONS AND FLOW RATES
C OF CONSTANT-HEAD CELLS FOR USE BY MT3D.  THIS SUBROUTINE IS CALLED
C ONLY IF THE 'UPW' PACKAGE IS USED IN MODFLOW.
C *********************************************************************
C Modified from Harbaugh(2005)
C last modified: 08-08-2008
C
      USE GLOBAL,      ONLY:NCOL,NROW,NLAY,ISSFLG,IBOUND,HNEW,HOLD,
     &                      BUFF,CR,CC,CV,BOTM,LBOTM
      USE GWFBASMODULE,ONLY:DELT
      USE GWFUPWMODULE,ONLY:LAYTYPUPW,SC1,SC2UPW,Sn,So
      USE GWFNWTMODULE,ONLY:Icell 
      CHARACTER*16 TEXT
      DOUBLE PRECISION HD, HH, CLOSEZERO, QKM1
      INTEGER ICHECK
C
C--SET POINTERS FOR THE CURRENT GRID      
      CALL SGWF2UPW1PNT(IGRID)
C      
C--GET STEADY-STATE FLAG FOR THE CURRENT STRESS PERIOD
      ISSCURRENT=ISSFLG(KPER)      
C
C--CALCULATE AND SAVE SATURATED THICKNESS
      TEXT='THKSAT'
      ZERO=0.
      ONE=1.
      CLOSEZERO = 1.0d-6
C
C--INITIALIZE BUFF ARRAY WITH 1.E30 FOR INACTIVE CELLS
C--OR FLAG -111 FOR ACTIVE CELLS
      FlagInactive=1.E30
      FlagActive=-111.
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            IF(IBOUND(J,I,K).EQ.0) THEN
              BUFF(J,I,K)=FlagInactive
            ELSE
              BUFF(J,I,K)=FlagActive
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--CALCULATE SATURATED THICKNESS FOR UNCONFINED/CONVERTIBLE
C--LAYERS AND STORE IN ARRAY BUFF
      DO K=1,NLAY
        IF(LAYTYPUPW(K).EQ.0) CYCLE
        DO I=1,NROW
          DO J=1,NCOL
            IF(IBOUND(J,I,K).NE.0) THEN
              TMP=HNEW(J,I,K)
              BUFF(J,I,K)=TMP-BOTM(J,I,LBOTM(K))
              THKLAY=BOTM(J,I,LBOTM(K)-1)-BOTM(J,I,LBOTM(K))
              IF(BUFF(J,I,K).GT.THKLAY) BUFF(J,I,K)=THKLAY
              IF(BUFF(J,I,K).LT.0.0) BUFF(J,I,K)=0.0
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--SAVE THE CONTENTS OF THE BUFFER
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT
        WRITE(IUMT3D) BUFF
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT
        WRITE(IUMT3D,*) BUFF
      ENDIF
C
C--CALCULATE AND SAVE FLOW ACROSS RIGHT FACE
      NCM1=NCOL-1
      IF(NCM1.LT.1) GO TO 405
      TEXT='QXX'
C
C--CLEAR THE BUFFER
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            BUFF(J,I,K)=ZERO
          ENDDO
        ENDDO
      ENDDO
C
C--FOR EACH CELL (have to check for upstream weighting.)
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCM1
            IF(IBOUND(J,I,K).NE.0.AND.IBOUND(J+1,I,K).NE.0) THEN
              HDIFF=HNEW(J,I,K)-HNEW(J+1,I,K)
              IF(LAYTYPUPW(K).NE.0) THEN
                IF ( HDIFF.GT.0.0 ) THEN
                  TTOP = BOTM(J,I,LBOTM(K)-1)
                  BBOT = BOTM(J,I,LBOTM(K))
                  HH = HNEW(J,I,K)
                  ij = Icell(J,I,K)
                ELSE
                  TTOP = BOTM(J+1,I,LBOTM(K)-1)
                  BBOT = BOTM(J+1,I,LBOTM(K))
                  HH = HNEW(J+1,I,K)
                  ij = Icell(J+1,I,K)
                END IF
                BUFF(J,I,K)=HDIFF*CR(J,I,K)*(TTOP-BBOT)*Sn(ij)
                IF ( HH-BBOT.LT.CLOSEZERO ) BUFF(J,I,K) = 0.0
              ELSE
                BUFF(J,I,K)=HDIFF*CR(J,I,K)
              END IF
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--RECORD CONTENTS OF BUFFER
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT
        WRITE(IUMT3D) BUFF
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT
        WRITE(IUMT3D,*) BUFF
      ENDIF
C
  405 CONTINUE
C
C--CALCULATE AND SAVE FLOW ACROSS FRONT FACE
      NRM1=NROW-1
      IF(NRM1.LT.1) GO TO 505
      TEXT='QYY'
C
C--CLEAR THE BUFFER
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            BUFF(J,I,K)=ZERO
          ENDDO
        ENDDO
      ENDDO
C
C--FOR EACH CELL
      DO K=1,NLAY
        DO I=1,NRM1
          DO J=1,NCOL
            IF(IBOUND(J,I,K).NE.0.AND.IBOUND(J,I+1,K).NE.0) THEN
              HDIFF=HNEW(J,I,K)-HNEW(J,I+1,K)
              IF(LAYTYPUPW(K).NE.0) THEN
                IF ( HDIFF.GT.0.0 ) THEN
                  TTOP = BOTM(J,I,LBOTM(K)-1)
                  BBOT = BOTM(J,I,LBOTM(K))
                  HH = HNEW(J,I,K)
                  ij = Icell(J,I,K)
                ELSE
                  TTOP = BOTM(J,I+1,LBOTM(K)-1)
                  BBOT = BOTM(J,I+1,LBOTM(K))
                  HH = HNEW(J,I+1,K)
                  ij = Icell(J,I+1,K)
                END IF
                BUFF(J,I,K)=HDIFF*CC(J,I,K)*(TTOP-BBOT)*Sn(ij)
                IF ( HH-BBOT.LT.CLOSEZERO ) BUFF(J,I,K) = 0.0
              ELSE
                BUFF(J,I,K)=HDIFF*CC(J,I,K)
              END IF
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--RECORD CONTENTS OF BUFFER.
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT
        WRITE(IUMT3D) BUFF
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT
        WRITE(IUMT3D,*) BUFF
      ENDIF
C
  505 CONTINUE
C
C--CALCULATE AND SAVE FLOW ACROSS FRONT FACE
      NLM1=NLAY-1
      IF(NLM1.LT.1) GO TO 700
      TEXT='QZZ'
C
C--CLEAR THE BUFFER
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            BUFF(J,I,K)=ZERO
          ENDDO
        ENDDO
      ENDDO
C
C--FOR EACH CELL CALCULATE FLOW THRU LOWER FACE & STORE IN BUFFER
      DO K=1,NLM1
        DO I=1,NROW
          DO J=1,NCOL
            IF(IBOUND(J,I,K).NE.0.AND.IBOUND(J,I,K+1).NE.0) THEN
              QKM1 = 0.0
              IF ( K.GT.1 ) THEN
                IF ( IBOUND(J,I,K-1) /= 0 ) THEN
                HDIFF = HNEW(J,I,K-1)-HNEW(J,I,K)
                IF ( IBOUND(J,I,K-1).GT.0 )QKM1 = abs(HDIFF*CV(J,I,K-1))
                ICHECK = 1
                IF ( HNEW(J,I,K)-BOTM(J,I,K).LT.CLOSEZERO ) THEN
                  ICHECK = 0    
                  IF ( QKM1.GT.CLOSEZERO ) ICHECK = 1
                  IF (J.GT.1)then
                  IF(HNEW(J-1,I,K)-BOTM(J-1,I,K).GT.CLOSEZERO)ICHECK = 1
                  end if
                  if(j.lt.NCOL)then
                  IF(HNEW(J+1,I,K)-BOTM(J+1,I,K).GT.CLOSEZERO)ICHECK = 1
                  end if
                  if(i.gt.1)then
                  IF(HNEW(J,I-1,K)-BOTM(J,I-1,K).GT.CLOSEZERO)ICHECK = 1
                  end if
                  if(i.lt.nrow)then
                  IF(HNEW(J,I+1,K)-BOTM(J,I+1,K).GT.CLOSEZERO)ICHECK = 1
                  end if
                END IF
                ELSE
                  ICHECK = 1
                END IF
              ELSE
                ICHECK = 1
              END IF
              HD=HNEW(J,I,K+1)
!             IF(LAYTYPUPW(K+1).NE.0) THEN     ! No vertical correction for UPW.
!               TMP=HD
!               TOP=BOTM(J,I,LBOTM(K+1)-1)
!               IF(TMP.LT.TOP) HD=TOP
!             ENDIF
!              IF ( HNEW(J,I,K).GT.BOTM(J,I,K) ) THEN
                IF ( ICHECK.NE.0 ) THEN
                  HDIFF=HNEW(J,I,K)-HD
                  BUFF(J,I,K)=HDIFF*CV(J,I,K)
                END IF
!              END IF
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--RECORD CONTENTS OF BUFFER.
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT
        WRITE(IUMT3D) BUFF
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT
        WRITE(IUMT3D,*) BUFF
      ENDIF
C
  700 CONTINUE
C
C--CALCULATE AND SAVE GROUNDWATER STORAGE IF TRANSIENT
      IF(ISSMT3D.NE.0) GO TO 705
      TEXT='STO'
C
C--INITIALIZE AND CLEAR BUFFER           
      TLED=ONE/DELT
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            BUFF(J,I,K)=ZERO
          ENDDO
        ENDDO
      ENDDO
      IF(ISSCURRENT.NE.0) GOTO 704
C
C--RUN THROUGH EVERY CELL IN THE GRID
      KT=0
      DO K=1,NLAY
        LC=LAYTYPUPW(K)
        IF(LC.NE.0) KT=KT+1
        DO I=1,NROW
          DO J=1,NCOL
C
C--CALCULATE FLOW FROM STORAGE (VARIABLE HEAD CELLS ONLY)
            IF(IBOUND(J,I,K).GT.0) THEN
              HSING=HNEW(J,I,K)
 !             IF(LC.EQ.0) THEN
 !               RHO=SC1(J,I,K)*TLED
 !               STRG=RHO*HOLD(J,I,K) - RHO*HSING
 !             ELSE
                TP=BOTM(J,I,LBOTM(K)-1)
                IF ( LC.GT.0 ) THEN
                  RHO2=SC2UPW(J,I,KT)*TLED
                ELSE
                  RHO2=0.0
                END IF
                RHO1=SC1(J,I,K)*TLED             
                TP=BOTM(J,I,LBOTM(K)-1)
                BT=BOTM(J,I,LBOTM(K))
                THICK = (TP-BT)
                RHO2 = SC2UPW(J,I,K)*TLED 
                ij = Icell(J,I,K)
                RHO1 = SC1(J,I,K)*TLED
                STRG= - THICK*RHO2*(Sn(ij)-So(ij)) - 
     +                  Sn(ij)*THICK*RHO1*(HSING-HOLD(J,I,K))
 !             ENDIF
              BUFF(J,I,K)=STRG
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--RECORD CONTENTS OF BUFFER.
  704 IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT
        WRITE(IUMT3D) BUFF
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT
        WRITE(IUMT3D,*) BUFF
      ENDIF
C
  705 CONTINUE
C
C--CALCULATE FLOW INTO OR OUT OF CONSTANT-HEAD CELLS
      TEXT='CNH'
      NCNH=0
C
C--CLEAR BUFFER
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            BUFF(J,I,K)=ZERO
          ENDDO
        ENDDO
      ENDDO
C
C--FOR EACH CELL IF IT IS CONSTANT HEAD COMPUTE FLOW ACROSS 6
C--FACES.
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
C
C--IF CELL IS NOT CONSTANT HEAD SKIP IT & GO ON TO NEXT CELL.
            IF(IBOUND(J,I,K).GE.0) CYCLE
            NCNH=NCNH+1
C
C--CLEAR FIELDS FOR SIX FLOW RATES.
            X1=ZERO
            X2=ZERO
            X3=ZERO
            X4=ZERO
            X5=ZERO
            X6=ZERO
C
C--CALCULATE FLOW THROUGH THE LEFT FACE
C
C--IF THERE IS AN INACTIVE CELL ON THE OTHER SIDE OF THIS
C--FACE THEN GO ON TO THE NEXT FACE.
            IF(J.EQ.1) GO TO 30
            IF(IBOUND(J-1,I,K).EQ.0) GO TO 30
            HDIFF=HNEW(J,I,K)-HNEW(J-1,I,K)
C
C--CALCULATE FLOW THROUGH THIS FACE INTO THE ADJACENT CELL.
            IF(LAYTYPUPW(K).NE.0) THEN
              IF ( HDIFF.GE.0.0 ) THEN
                TTOP = BOTM(J,I,LBOTM(K)-1)
                BBOT = BOTM(J,I,LBOTM(K))
                THICK = TTOP - BBOT
                ij = Icell(J,I,K)
                X1=HDIFF*CR(J-1,I,K)*THICK*Sn(ij)
                HH = HNEW(J,I,K)
                IF ( HH-BBOT.LT.CLOSEZERO ) X1 = 0.0
              ELSE
                TTOP = BOTM(J-1,I,LBOTM(K)-1)
                BBOT = BOTM(J-1,I,LBOTM(K))
                THICK = TTOP - BBOT
                ij = Icell(J-1,I,K)
                X1=HDIFF*CR(J-1,I,K)*THICK*Sn(ij)
                HH = HNEW(J-1,I,K)
                IF ( HH-BBOT.LT.CLOSEZERO ) X1 = 0.0
              END IF
            ELSE
              X1=HDIFF*CR(J-1,I,K)
            END IF
            
C
C--CALCULATE FLOW THROUGH THE RIGHT FACE
   30       IF(J.EQ.NCOL) GO TO 60
            IF(IBOUND(J+1,I,K).EQ.0) GO TO 60
            HDIFF=HNEW(J,I,K)-HNEW(J+1,I,K)
            IF(LAYTYPUPW(K).NE.0) THEN
              IF ( HDIFF.GE.0.0 ) THEN
                TTOP = BOTM(J,I,LBOTM(K)-1)
                BBOT = BOTM(J,I,LBOTM(K))
                THICK = TTOP - BBOT
                ij = Icell(J,I,K)
                X2=HDIFF*CR(J,I,K)*THICK*Sn(ij)
                HH = HNEW(J,I,K)
                IF ( HH-BBOT.LT.CLOSEZERO ) X2 = 0.0
              ELSE
                TTOP = BOTM(J+1,I,LBOTM(K)-1)
                BBOT = BOTM(J+1,I,LBOTM(K))
                THICK = TTOP - BBOT
                ij = Icell(J+1,I,K)
                X2=HDIFF*CR(J,I,K)*THICK*Sn(ij)
                HH = HNEW(J+1,I,K)
                IF ( HH-BBOT.LT.CLOSEZERO ) X2 = 0.0
              END IF
            ELSE
              X2=HDIFF*CR(J,I,K)
            END IF
C
C--CALCULATE FLOW THROUGH THE BACK FACE.
   60       IF(I.EQ.1) GO TO 90
            IF (IBOUND(J,I-1,K).EQ.0) GO TO 90
            HDIFF=HNEW(J,I,K)-HNEW(J,I-1,K)
            IF(LAYTYPUPW(K).NE.0) THEN
              IF ( HDIFF.GE.0.0 ) THEN
                TTOP = BOTM(J,I,LBOTM(K)-1)
                BBOT = BOTM(J,I,LBOTM(K))
                THICK = TTOP - BBOT
                ij =  Icell(J,I,K)
                X3=HDIFF*CC(J,I-1,K)*THICK*Sn(ij)
                HH = HNEW(J,I,K)
                IF ( HH-BBOT.LT.CLOSEZERO ) X3 = 0.0
              ELSE
                TTOP = BOTM(J,I-1,LBOTM(K)-1)
                BBOT = BOTM(J,I-1,LBOTM(K))
                THICK = TTOP - BBOT
                ij =  Icell(J,I-1,K)
                X3=HDIFF*CC(J,I-1,K)*THICK*Sn(ij)
                 HH = HNEW(J,I-1,K)
                IF ( HH-BBOT.LT.CLOSEZERO ) X3 = 0.0
              END IF
            ELSE
              X3=HDIFF*CC(J,I-1,K)
            END IF
C
C--CALCULATE FLOW THROUGH THE FRONT FACE.
   90       IF(I.EQ.NROW) GO TO 120
            IF(IBOUND(J,I+1,K).EQ.0) GO TO 120
            HDIFF=HNEW(J,I,K)-HNEW(J,I+1,K)
            IF(LAYTYPUPW(K).NE.0) THEN
              IF ( HDIFF.GE.0.0 ) THEN
                TTOP = BOTM(J,I,LBOTM(K)-1)
                BBOT = BOTM(J,I,LBOTM(K))
                THICK = TTOP - BBOT
                ij = Icell(J,I,K)
                X4=HDIFF*CC(J,I,K)*THICK*Sn(ij)
                HH = HNEW(J,I,K)
                IF ( HH-BBOT.LT.CLOSEZERO ) X4 = 0.0
              ELSE
                TTOP = BOTM(J,I+1,LBOTM(K)-1)
                BBOT = BOTM(J,I+1,LBOTM(K))
                THICK = TTOP - BBOT
                ij = Icell(J,I+1,K)
                X4=HDIFF*CC(J,I,K)*THICK*Sn(ij)
                HH = HNEW(J,I+1,K)
                IF ( HH-BBOT.LT.CLOSEZERO ) X4 = 0.0
              END IF
            ELSE
              X4=HDIFF*CC(J,I,K)
            END IF
C
C--CALCULATE FLOW THROUGH THE UPPER FACE
  120       IF(K.EQ.1) GO TO 150
            IF (IBOUND(J,I,K-1).EQ.0) GO TO 150
            HD=HNEW(J,I,K)
            IF(LAYTYPUPW(K).EQ.0) GO TO 122
            TMP=HD
            TOP=BOTM(J,I,LBOTM(K)-1)
!            IF(TMP.LT.TOP) HD=TOP   ! No vertial correction for UPW.
  122       HDIFF=HD-HNEW(J,I,K-1)
            X5=HDIFF*CV(J,I,K-1)
C
C--CALCULATE FLOW THROUGH THE LOWER FACE.
  150       IF(K.EQ.NLAY) GO TO 180
            IF(IBOUND(J,I,K+1).EQ.0) GO TO 180
            HD=HNEW(J,I,K+1)
            IF(LAYTYPUPW(K+1).EQ.0) GO TO 152
            TMP=HD
            TOP=BOTM(J,I,LBOTM(K+1)-1)
!            IF(TMP.LT.TOP) HD=TOP   ! No vertial correction for UPW.
  152       HDIFF=HNEW(J,I,K)-HD
            X6=HDIFF*CV(J,I,K)
C
C--SUM UP FLOWS THROUGH SIX SIDES OF CONSTANT HEAD CELL.
  180       BUFF(J,I,K)=X1+X2+X3+X4+X5+X6
          ENDDO
        ENDDO
      ENDDO
C
C--RECORD CONTENTS OF BUFFER.
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT,NCNH
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT,NCNH
      ENDIF
C
C--IF THERE ARE NO CONSTANT-HEAD CELLS THEN SKIP
      IF(NCNH.LE.0) GOTO 1000
C
C--WRITE CONSTANT-HEAD CELL LOCATIONS AND RATES
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            IF(IBOUND(J,I,K).GE.0) CYCLE
            IF(ILMTFMT.EQ.0) THEN
              WRITE(IUMT3D)   K,I,J,BUFF(J,I,K)
            ELSEIF(ILMTFMT.EQ.1) THEN
              WRITE(IUMT3D,*) K,I,J,BUFF(J,I,K)
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--RETURN
 1000 CONTINUE
      RETURN
      END
C
C
      SUBROUTINE LMT7HUF7(ILMTFMT,ISSMT3D,IUMT3D,KSTP,KPER,ILVDA,IGRID)
C **********************************************************************
C SAVE FLOW ACROSS THREE CELL INTERFACES (QXX, QYY, QZZ), FLOW RATE TO
C OR FROM TRANSIENT FLUID-STORAGE (QSTO), AND LOCATIONS AND FLOW RATES
C OF CONSTANT-HEAD CELLS FOR USE BY MT3D.  THIS SUBROUTINE IS CALLED
C ONLY IF THE 'HUF' PACKAGE IS USED IN MODFLOW.
C **********************************************************************
C Modified from Anderman and Hill (2000), Harbaugh (2005)
C last modified: 08-08-2008
C
      USE GLOBAL,      ONLY:NCOL,NROW,NLAY,ISSFLG,IBOUND,HNEW,HOLD,BOTM,
     &                      LBOTM,DELR,DELC,BUFF,IOUT,CR,CC,CV
      USE GWFBASMODULE,ONLY:DELT
      USE GWFHUFMODULE,ONLY:LTHUF,SC1,HUFTHK,NHUF,VDHT      
      CHARACTER*16 TEXT
      DOUBLE PRECISION HD,DFL,DFR,DFT,DFB,HN
C    
C--SET POINTERS FOR THE CURRENT GRID   
cswm: already set in GWF2HUF7BDS      CALL SGWF2HUF7PNT(IGRID) 
C      
C--GET STEADY-STATE FLAG FOR THE CURRENT STRESS PERIOD      
      ISSCURRENT=ISSFLG(KPER)
C
C--CALCULATE AND SAVE SATURATED THICKNESS
      TEXT='THKSAT'
      ZERO=0.
      ONE=1.   
C
C--INITIALIZE BUFF ARRAY WITH 1.E30 FOR INACTIVE CELLS
C--OR FLAG -111 FOR ACTIVE CELLS
      FlagInactive=1.E30
      FlagActive=-111.   
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            IF(IBOUND(J,I,K).EQ.0) THEN
              BUFF(J,I,K)=FlagInactive
            ELSE
              BUFF(J,I,K)=FlagActive
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--CALCULATE SATURATED THICKNESS FOR UNCONFINED/CONVERTIBLE
C--LAYERS AND STORE IN ARRAY BUFF
      DO K=1,NLAY
        IF(LTHUF(K).EQ.0) CYCLE
        DO I=1,NROW
          DO J=1,NCOL
            IF(IBOUND(J,I,K).NE.0) THEN
              TMP=HNEW(J,I,K)
              BUFF(J,I,K)=TMP-BOTM(J,I,LBOTM(K))
              THKLAY=BOTM(J,I,LBOTM(K)-1)-BOTM(J,I,LBOTM(K))
              IF(BUFF(J,I,K).GT.THKLAY) BUFF(J,I,K)=THKLAY
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--SAVE THE CONTENTS OF THE BUFFER
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT
        WRITE(IUMT3D) BUFF
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT
        WRITE(IUMT3D,*) BUFF
      ENDIF
C
C--CALCULATE AND SAVE FLOW ACROSS RIGHT FACE
      NCM1=NCOL-1
      IF(NCM1.LT.1) GO TO 405
      TEXT='QXX'
C
C--CLEAR THE BUFFER
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            BUFF(J,I,K)=ZERO
          ENDDO
        ENDDO
      ENDDO
C
C--FOR EACH CELL
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCM1
            IF(IBOUND(J,I,K).NE.0.AND.IBOUND(J+1,I,K).NE.0) THEN        
              if(ILVDA.gt.0) then
                CALL SGWF2HUF7VDF9(I,J,K,VDHT,HNEW,IBOUND,
     &           NLAY,NROW,NCOL,DFL,DFR,DFT,DFB)
                BUFF(J,I,K) = DFR
              else                       
                HDIFF=HNEW(J,I,K)-HNEW(J+1,I,K)
                BUFF(J,I,K)=HDIFF*CR(J,I,K)
              endif  
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--RECORD CONTENTS OF BUFFER
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT
        WRITE(IUMT3D) BUFF
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT
        WRITE(IUMT3D,*) BUFF
      ENDIF
C
  405 CONTINUE
C
C--CALCULATE AND SAVE FLOW ACROSS FRONT FACE
      NRM1=NROW-1
      IF(NRM1.LT.1) GO TO 505
      TEXT='QYY'
C
C--CLEAR THE BUFFER
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            BUFF(J,I,K)=ZERO
          ENDDO
        ENDDO
      ENDDO
C
C--FOR EACH CELL
      DO K=1,NLAY
        DO I=1,NRM1
          DO J=1,NCOL
            IF(IBOUND(J,I,K).NE.0.AND.IBOUND(J,I+1,K).NE.0) THEN
              if(ILVDA.gt.0) then
                CALL SGWF2HUF7VDF9(I,J,K,VDHT,HNEW,IBOUND,
     &           NLAY,NROW,NCOL,DFL,DFR,DFT,DFB)
                BUFF(J,I,K) = DFT
              else                        
                HDIFF=HNEW(J,I,K)-HNEW(J,I+1,K)
                BUFF(J,I,K)=HDIFF*CC(J,I,K)
              endif  
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--RECORD CONTENTS OF BUFFER.
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT
        WRITE(IUMT3D) BUFF
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT
        WRITE(IUMT3D,*) BUFF
      ENDIF
C
  505 CONTINUE
C
C--CALCULATE AND SAVE FLOW ACROSS LOWER FACE
      NLM1=NLAY-1
      IF(NLM1.LT.1) GO TO 700
      TEXT='QZZ'
C
C--CLEAR THE BUFFER
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            BUFF(J,I,K)=ZERO
          ENDDO
        ENDDO
      ENDDO
C
C--FOR EACH CELL 
      DO K=1,NLM1
        DO I=1,NROW
          DO J=1,NCOL
            IF(IBOUND(J,I,K).NE.0.AND.IBOUND(J,I,K+1).NE.0) THEN
              HD=HNEW(J,I,K+1)
              IF(LTHUF(K+1).NE.0) THEN
                TMP=HD
                TOP=BOTM(J,I,LBOTM(K+1)-1)
                IF(TMP.LT.TOP) HD=TOP
              ENDIF
              HDIFF=HNEW(J,I,K)-HD
              BUFF(J,I,K)=HDIFF*CV(J,I,K)
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--RECORD CONTENTS OF BUFFER.
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT
        WRITE(IUMT3D) BUFF
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT
        WRITE(IUMT3D,*) BUFF
      ENDIF
C
  700 CONTINUE
C
C--CALCULATE AND SAVE GROUNDWATER STORAGE IF TRANSIENT
      IF(ISSMT3D.NE.0) GO TO 705
      TEXT='STO'
C
C--INITIALIZE and CLEAR BUFFER
      TLED=ONE/DELT
      DO K=1,NLAY 
        DO I=1,NROW
          DO J=1,NCOL
            BUFF(J,I,K)=ZERO
          ENDDO
        ENDDO
      ENDDO
      IF(ISSCURRENT.NE.0) GOTO 704
C
C5------LOOP THROUGH EVERY CELL IN THE GRID.
      KT=0
      DO K=1,NLAY
        LC=LTHUF(K)
        IF(LC.NE.0) KT=KT+1
        DO I=1,NROW
          DO J=1,NCOL
C
C6------SKIP NO-FLOW AND CONSTANT-HEAD CELLS.
            IF(IBOUND(J,I,K).LE.0) CYCLE
            HN=HNEW(J,I,K)
            HO=HOLD(J,I,K)
            STRG=ZERO
C
C7-----CHECK LAYER TYPE TO SEE IF ONE STORAGE CAPACITY OR TWO.
            IF(LC.EQ.0) GO TO 285
            TOP=BOTM(J,I,LBOTM(K)-1)
            BOT=BOTM(J,I,LBOTM(K))
            IF(HO.GT.TOP.AND.HN.GT.TOP) GOTO 285
C
C7A----TWO STORAGE CAPACITIES.
C---------------Compute SC1 Component
            IF(HO.GT.TOP) THEN
              STRG=SC1(J,I,K)*(HO-TOP)*TLED
            ELSEIF(HN.GT.TOP) THEN
              STRG=SC1(J,I,K)*TLED*(TOP-HN)
            ENDIF
C---------------Compute SC2 Component
            CALL SGWF2HUF7SC2(1,J,I,K,TOP,BOT,HN,HO,TLED,CHCOF,STRG,
     &       HUFTHK,NCOL,NROW,NHUF,DELR(J)*DELC(I),IOUT)          
C------STRG=SOLD*(HOLD(J,I,K)-TP) + SNEW*TP - SNEW*HSING
            GOTO 288
C
C7B----ONE STORAGE CAPACITY.
  285       RHO=SC1(J,I,K)*TLED
            STRG=RHO*(HO-HN)
C
C8-----STORE CELL-BY-CELL FLOW IN BUFFER
  288       BUFF(J,I,K)=STRG
C
          ENDDO
        ENDDO
      ENDDO
C
C--RECORD CONTENTS OF BUFFER.
  704 IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT
        WRITE(IUMT3D) BUFF
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT
        WRITE(IUMT3D,*) BUFF
      ENDIF
C
  705 CONTINUE
C
C--CALCULATE FLOW INTO OR OUT OF CONSTANT-HEAD CELLS
      TEXT='CNH'
      NCNH=0
C
C--CLEAR BUFFER
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            BUFF(J,I,K)=ZERO
          ENDDO
        ENDDO
      ENDDO
C
C--FOR EACH CELL IF IT IS CONSTANT HEAD COMPUTE FLOW ACROSS 6
C--FACES.
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
C
C--IF CELL IS NOT CONSTANT HEAD SKIP IT & GO ON TO NEXT CELL.
            IF (IBOUND(J,I,K).GE.0) CYCLE
            NCNH=NCNH+1
C
C--CLEAR FIELDS FOR SIX FLOW RATES.
            X1=ZERO
            X2=ZERO
            X3=ZERO
            X4=ZERO
            X5=ZERO
            X6=ZERO
C            
C--COMPUTE HORIZONTAL FLUXES IF THE LVDA CAPABILITY IS USED            
            if(ILVDA.gt.0)
     &       CALL SGWF2HUF7VDF9(I,J,K,VDHT,HNEW,IBOUND,
     &       NLAY,NROW,NCOL,DFL,DFR,DFT,DFB)                        
C
C--CALCULATE FLOW THROUGH THE LEFT FACE
C
C--IF THERE IS AN INACTIVE CELL ON THE OTHER SIDE OF THIS
C--FACE THEN GO ON TO THE NEXT FACE.
            IF(J.EQ.1) GO TO 30
            IF(IBOUND(J-1,I,K).EQ.0) GO TO 30
C
C--CALCULATE FLOW THROUGH THIS FACE INTO THE ADJACENT CELL.
            if(ILVDA.gt.0) then
              X1 = -DFL
            else
              HDIFF=HNEW(J,I,K)-HNEW(J-1,I,K)            
              X1=HDIFF*CR(J-1,I,K)
            endif  
C
C--CALCULATE FLOW THROUGH THE RIGHT FACE
   30       IF(J.EQ.NCOL) GO TO 60
            IF(IBOUND(J+1,I,K).EQ.0) GO TO 60
            if(ILVDA.gt.0) then
              X2 = DFR
            else                       
              HDIFF=HNEW(J,I,K)-HNEW(J+1,I,K)
              X2=HDIFF*CR(J,I,K)
            endif  
C
C--CALCULATE FLOW THROUGH THE BACK FACE.
   60       IF(I.EQ.1) GO TO 90
            IF (IBOUND(J,I-1,K).EQ.0) GO TO 90
            if(ILVDA.gt.0) then
              X3 = -DFT
            else                       
              HDIFF=HNEW(J,I,K)-HNEW(J,I-1,K)
              X3=HDIFF*CC(J,I-1,K)
            endif  
C
C--CALCULATE FLOW THROUGH THE FRONT FACE.
   90       IF(I.EQ.NROW) GO TO 120
            IF(IBOUND(J,I+1,K).EQ.0) GO TO 120
            if(ILVDA.gt.0) then
              X4 = DFB
            else             
              HDIFF=HNEW(J,I,K)-HNEW(J,I+1,K)
              X4=HDIFF*CC(J,I,K)
            endif  
C
C--CALCULATE FLOW THROUGH THE UPPER FACE
  120       IF(K.EQ.1) GO TO 150
            IF (IBOUND(J,I,K-1).EQ.0) GO TO 150
            HD=HNEW(J,I,K)
            IF(LTHUF(K).EQ.0) GO TO 122
            TMP=HD
            TOP=BOTM(J,I,LBOTM(K)-1)
            IF(TMP.LT.TOP) HD=TOP
  122       HDIFF=HD-HNEW(J,I,K-1)
            X5=HDIFF*CV(J,I,K-1)
C
C--CALCULATE FLOW THROUGH THE LOWER FACE.
  150       IF(K.EQ.NLAY) GO TO 180
            IF(IBOUND(J,I,K+1).EQ.0) GO TO 180
            HD=HNEW(J,I,K+1)
            IF(LTHUF(K+1).EQ.0) GO TO 152
            TMP=HD
            TOP=BOTM(J,I,LBOTM(K+1)-1)
            IF(TMP.LT.TOP) HD=TOP
  152       HDIFF=HNEW(J,I,K)-HD
            X6=HDIFF*CV(J,I,K)
C
C--SUM UP FLOWS THROUGH SIX SIDES OF CONSTANT HEAD CELL.
  180       BUFF(J,I,K)=X1+X2+X3+X4+X5+X6
C
          ENDDO
        ENDDO
      ENDDO
C
C--RECORD CONTENTS OF BUFFER.
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT,NCNH
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT,NCNH
      ENDIF
C
C--IF THERE ARE NO CONSTANT-HEAD CELLS THEN SKIP
      IF(NCNH.LE.0) GOTO 1000
C
C--WRITE CONSTANT-HEAD CELL LOCATIONS AND RATES
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            IF(IBOUND(J,I,K).GE.0) CYCLE
            IF(ILMTFMT.EQ.0) THEN
              WRITE(IUMT3D)   K,I,J,BUFF(J,I,K)
            ELSEIF(ILMTFMT.EQ.1) THEN
              WRITE(IUMT3D,*) K,I,J,BUFF(J,I,K)
            ENDIF              
          ENDDO
        ENDDO
      ENDDO
C
C--RETURN
 1000 CONTINUE
      RETURN
      END
C
C
      SUBROUTINE LMT7WEL7(IUNITUPW,ILMTFMT,IUMT3D,KSTP,KPER,IGRID)
C *********************************************************************
C SAVE WELL CELL LOCATIONS AND VOLUMETRIC FLOW RATES FOR USE BY MT3D.
C *********************************************************************
C Modified from  Harbaugh (2005)
C last modified: 08-08-2008
C
      USE GLOBAL,      ONLY:NCOL,NROW,NLAY,IBOUND,BOTM,LBOTM,HNEW
      USE GWFWELMODULE,ONLY:NWELLS,WELL,PSIRAMP
      USE GWFUPWMODULE,ONLY:LAYTYPUPW
      CHARACTER*16 TEXT
      double precision bbot, Hh, cof1, cof2, cof3, Qp, x, s
      double precision ttop
C      
C--SET POINTERS FOR THE CURRENT GRID   
cswm: already set in      CALL SGWF2WEL7PNT(IGRID)
C      
      TEXT='WEL'   
      ZERO=0.
C
C--WRITE AN IDENTIFYING HEADER
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT,NWELLS
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT,NWELLS
      ENDIF
C
C--IF THERE ARE NO WELLS RETURN
      IF(NWELLS.LE.0) GO TO 9999
C
C--WRITE WELL LOCATION AND RATE ONE AT A TIME
      DO L=1,NWELLS
        IL=WELL(1,L)
        IR=WELL(2,L)
        IC=WELL(3,L)
C
C--IF CELL IS EXTERNAL Q=0
        Q=ZERO
        IF(IBOUND(IC,IR,IL).GT.0) THEN
          Q=WELL(4,L)
          IF ( IUNITUPW.GT.0 ) THEN
            IF ( LAYTYPUPW(il).GT.0 ) THEN
              bbot = Botm(IC, IR, Lbotm(IL))
              ttop = Botm(IC, IR, Lbotm(IL)-1)
              Hh = HNEW(ic,ir,il)
              x = (Hh-bbot)
              s = PSIRAMP
              s = s*(Ttop-Bbot)
              aa = -1.0d0/(s**2.0d0)
              b = 2.0d0/s
              cof1 = x**2.0D0
              cof2 = -(2.0D0*x)/(s**3.0D0)
              cof3 = 3.0D0/(s**2.0D0)
              Qp = cof1*(cof2+cof3)
              IF ( x.LT.0.0D0 ) THEN
                Qp = 0.0D0
              ELSEIF ( x-s.GT.-1.0e-14 ) THEN
                Qp = 1.0D0
              END IF
              IF ( Qp.LT.1.0 ) THEN
                Q = Q*Qp
              END IF
            END IF
          END IF
        END IF
        IF(ILMTFMT.EQ.0) THEN
          WRITE(IUMT3D) IL,IR,IC,Q
        ELSEIF(ILMTFMT.EQ.1) THEN
          WRITE(IUMT3D,*) IL,IR,IC,Q
        ENDIF
      ENDDO
C
C--RETURN
 9999 RETURN
      END
C
C
      SUBROUTINE LMT7DRN7(ILMTFMT,IUMT3D,KSTP,KPER,IGRID)
C ********************************************************************
C SAVE DRAIN CELL LOCATIONS AND VOLUMETRIC FLOW RATES FOR USE BY MT3D.
C ********************************************************************
C Modified from Harbaugh (2005)
C last modified: 08-08-2008
C
      USE GLOBAL,      ONLY:NCOL,NROW,NLAY,IBOUND,HNEW,BUFF
      USE GWFDRNMODULE,ONLY:NDRAIN,DRAI
      CHARACTER*16 TEXT
      DOUBLE PRECISION HHNEW,EEL,CCDRN,CEL,QQ
C    
C--SET POINTERS FOR THE CURRENT GRID
c swm: already set in GWF2DRN7BD      CALL SGWF2DRN7PNT(IGRID)
C      
      TEXT='DRN'
      ZERO=0.
C
C--WRITE AN IDENTIFYING HEADER
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT,NDRAIN
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT,NDRAIN
      ENDIF
C
C--IF THERE ARE NO DRAINS THEN SKIP
      IF(NDRAIN.LE.0) GO TO 9999
C
C--FOR EACH DRAIN ACCUMULATE DRAIN FLOW
      DO L=1,NDRAIN
C
C--GET LAYER, ROW & COLUMN OF CELL CONTAINING REACH.
        IL=DRAI(1,L)
        IR=DRAI(2,L)
        IC=DRAI(3,L)
        QQ=ZERO
C
C--CALCULATE Q FOR ACTIVE CELLS
        IF(IBOUND(IC,IR,IL).GT.0) THEN
C
C--GET DRAIN PARAMETERS FROM DRAIN LIST.
          EL=DRAI(4,L)
          EEL=EL
          C=DRAI(5,L)
          CCDRN=C
          HHNEW=HNEW(IC,IR,IL)
          CEL=C*EL
C
C--IF HEAD LOWER THAN DRAIN THEN FORGET THIS CELL.
C--OTHERWISE, CALCULATE Q=C*(EL-HHNEW).
          IF(HHNEW.GT.EEL) QQ=CEL - CCDRN*HHNEW
        ENDIF
        Q=QQ
C
C--WRITE DRAIN LOCATION AND RATE
        IF(ILMTFMT.EQ.0) THEN
          WRITE(IUMT3D)   IL,IR,IC,Q
        ELSEIF(ILMTFMT.EQ.1) THEN
          WRITE(IUMT3D,*) IL,IR,IC,Q
        ENDIF  
C        
      ENDDO
C
C--RETURN
 9999 RETURN
      END
C
C
      SUBROUTINE LMT7RIV7(ILMTFMT,IUMT3D,KSTP,KPER,IGRID)
C *********************************************************************
C SAVE RIVER CELL LOCATIONS AND VOLUMETRIC FLOW RATES FOR USE BY MT3D.
C *********************************************************************
C Modified from Harbaugh (2005)
C last modified: 08-08-2008
C
      USE GLOBAL,      ONLY:NCOL,NROW,NLAY,IBOUND,HNEW
      USE GWFRIVMODULE,ONLY:NRIVER,RIVR
      CHARACTER*16 TEXT      
      DOUBLE PRECISION HHNEW,CHRIV,RRBOT,CCRIV
C
C--SET POINTERS FOR THE CURRENT GRID
c swm: already set in GWF2RIV7BD      CALL SGWF2RIV7PNT(IGRID)      
C      
      TEXT='RIV'      
      ZERO=0.
      RATE=ZERO
C
C--WRITE AN IDENTIFYING HEADER
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT,NRIVER
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT,NRIVER
      ENDIF
C
C--IF NO REACHES SKIP
      IF(NRIVER.LE.0) GO TO 9999
C
C--FOR EACH RIVER REACH ACCUMULATE RIVER FLOW
      DO L=1,NRIVER
C
C--GET LAYER, ROW & COLUMN OF CELL CONTAINING REACH.
        IL=RIVR(1,L)
        IR=RIVR(2,L)
        IC=RIVR(3,L)
C
C--IF CELL IS EXTERNAL RATE=0
        IF(IBOUND(IC,IR,IL).LE.0) THEN
          RATE=ZERO
C
C--GET RIVER PARAMETERS FROM RIVER LIST.
        ELSE
          HRIV=RIVR(4,L)
          CRIV=RIVR(5,L)
          RBOT=RIVR(6,L)
          HHNEW=HNEW(IC,IR,IL)
          CHRIV=CRIV*HRIV
          CCRIV=CRIV
          RRBOT=RBOT
C
C--COMPARE HEAD IN AQUIFER TO BOTTOM OF RIVERBED.
C
C--AQUIFER HEAD > BOTTOM THEN RATE=CRIV*(HRIV-HNEW).
          IF(HHNEW.GT.RRBOT) RATE=CHRIV-CCRIV*HHNEW
C
C--AQUIFER HEAD < BOTTOM THEN RATE=CRIV*(HRIV-RBOT)
          IF(HHNEW.LE.RRBOT) RATE=CRIV*(HRIV-RBOT)
        ENDIF
C
C--WRITE RIVER REACH LOCATION AND RATE
        IF(ILMTFMT.EQ.0) THEN
          WRITE(IUMT3D) IL,IR,IC,RATE
        ELSEIF(ILMTFMT.EQ.1) THEN
          WRITE(IUMT3D,*) IL,IR,IC,RATE
        ENDIF
C        
      ENDDO
C
C--RETURN
 9999 RETURN
      END
C
C
      SUBROUTINE LMT7RCH7(ILMTFMT,IUMT3D,KSTP,KPER,IGRID)
C *******************************************************************
C SAVE RECHARGE LAYER LOCATION AND VOLUMETRIC FLOW RATES
C FOR USE BY MT3D.
C *******************************************************************
C Modified from Harbaugh (2005)
C last modified: 08-08-2008
C
      USE GLOBAL,      ONLY:NCOL,NROW,NLAY,IBOUND,BUFF
      USE GWFRCHMODULE,ONLY:NRCHOP,RECH,IRCH
      CHARACTER*16 TEXT
C
C--SET POINTERS FOR THE CURRENT GRID
c swm: already set in GWF2RCH7BD      CALL SGWF2RCH7PNT(IGRID)   
C         
      TEXT='RCH'
      ZERO=0.
C
C--WRITE AN IDENTIFYING HEADER
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT
      ENDIF
C
C--CLEAR THE BUFFER.
      DO IL=1,NLAY
        DO IR=1,NROW
          DO IC=1,NCOL
            BUFF(IC,IR,IL)=ZERO
          ENDDO
        ENDDO
      ENDDO
C
C--IF NRCHOP=1 RECH GOES INTO LAYER 1.
      IF(NRCHOP.EQ.1) THEN
        IL=1
        IF(ILMTFMT.EQ.0) WRITE(IUMT3D)   ((IL,J=1,NCOL),I=1,NROW)
        IF(ILMTFMT.EQ.1) WRITE(IUMT3D,*) ((IL,J=1,NCOL),I=1,NROW)
C
C--STORE RECH RATE IN BUFF FOR ACTIVE CELLS
        DO I=1,NROW
          DO J=1,NCOL
            IF(IBOUND(J,I,1).GT.0) BUFF(J,I,1)=RECH(J,I)
          ENDDO
        ENDDO
        IF(ILMTFMT.EQ.0) THEN 
          WRITE(IUMT3D)   ((BUFF(J,I,1),J=1,NCOL),I=1,NROW)
        ELSEIF(ILMTFMT.EQ.1) THEN
          WRITE(IUMT3D,*) ((BUFF(J,I,1),J=1,NCOL),I=1,NROW)
        ENDIF
C
C--IF NRCHOP=2 OR 3 RECH IS IN LAYER SHOWN IN INDICATOR ARRAY(IRCH).
      ELSEIF(NRCHOP.NE.1) THEN
        IF(ILMTFMT.EQ.0) THEN
          WRITE(IUMT3D)   ((IRCH(J,I),J=1,NCOL),I=1,NROW)
        ELSEIF(ILMTFMT.EQ.1) THEN
          WRITE(IUMT3D,*) ((IRCH(J,I),J=1,NCOL),I=1,NROW)
        ENDIF  
C
C--STORE RECH RATE IN BUFF FOR ACTIVE CELLS
        DO I=1,NROW
          DO J=1,NCOL
            IL=IRCH(J,I)
            IF(IL.EQ.0) CYCLE
            IF(IBOUND(J,I,IL).GT.0) THEN
              BUFF(J,I,1)=RECH(J,I)
            ENDIF
          ENDDO
        ENDDO
        IF(ILMTFMT.EQ.0) THEN 
          WRITE(IUMT3D)   ((BUFF(J,I,1),J=1,NCOL),I=1,NROW)
        ELSEIF(ILMTFMT.EQ.1) THEN
          WRITE(IUMT3D,*) ((BUFF(J,I,1),J=1,NCOL),I=1,NROW)
        ENDIF  
      ENDIF
C
C--RETURN
      RETURN
      END
C
C
      SUBROUTINE LMT7EVT7(ILMTFMT,IUMT3D,KSTP,KPER,IGRID)
C ******************************************************************
C SAVE EVAPOTRANSPIRATION LAYER LOCATION AND VOLUMETRIC FLOW RATES
C FOR USE BY MT3D.
C ******************************************************************
C Modified from Harbaugh (2005)
C last modified: 08-08-2008
C
      USE GLOBAL,      ONLY:NCOL,NROW,NLAY,IBOUND,HNEW,BUFF      
      USE GWFEVTMODULE,ONLY:NEVTOP,EVTR,EXDP,SURF,IEVT
      CHARACTER*16 TEXT
      DOUBLE PRECISION QQ,HH,XX,DD,SS,HHCOF,RRHS      
C   
C--SET POINTERS FOR THE CURRENT GRID
c swm: already set in GWF2EVT7BD      CALL SGWF2EVT7PNT(IGRID)
C            
      TEXT='EVT'
      ZERO=0.      
C
C--WRITE AN IDENTIFYING HEADER
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT
      ENDIF
C
C--CLEAR THE BUFFER.
      DO IL=1,NLAY
        DO IR=1,NROW
          DO IC=1,NCOL
            BUFF(IC,IR,IL)=ZERO
          ENDDO
        ENDDO
      ENDDO   
C
C--PROCESS EACH HORIZONTAL CELL LOCATION
C--AND STORE ET RATES IN BUFFER (IC,IR,1)
      DO IR=1,NROW
        DO IC=1,NCOL
C
C--IF OPTION 1 SET THE LAYER INDEX EQUAL TO 1
          IF(NEVTOP.EQ.1) THEN
            IL=1
C
C--IF OPTION 2 OR 3 GET LAYER INDEX FROM IEVT ARRAY
          ELSEIF(NEVTOP.NE.1) THEN
            IL=IEVT(IC,IR)
            IF(IL.EQ.0) CYCLE
          ENDIF
C
C--IF CELL IS EXTERNAL THEN IGNORE IT.
          IF(IBOUND(IC,IR,IL).LE.0) CYCLE
          C=EVTR(IC,IR)
          S=SURF(IC,IR)
          SS=S
          HH=HNEW(IC,IR,IL)
C
C--IF AQUIFER HEAD => SURF,SET Q=MAX ET RATE
          IF(HH.GE.SS) THEN
            QQ=-C
C
C--IF DEPTH=>EXTINCTION DEPTH, ET IS 0
C--OTHERWISE, LINEAR RANGE: Q=-HNEW*EVTR/EXDP -EVTR +EVTR*SURF/EXDP
          ELSE
            X=EXDP(IC,IR)
            XX=X
            DD=SS-HH
            IF(DD.GE.XX) THEN
              QQ=ZERO
            ELSE
              HHCOF=-C/X
              RRHS=(C*S/X)-C
              QQ= HH*HHCOF + RRHS
            ENDIF
          ENDIF
C
C--ADD Q TO BUFFER 1
          BUFF(IC,IR,1)=QQ
        ENDDO
      ENDDO
C
C--RECORD THEM.
      IF(NEVTOP.EQ.1) THEN
        IL=1
        IF(ILMTFMT.EQ.0) WRITE(IUMT3D)   ((IL,J=1,NCOL),I=1,NROW)
        IF(ILMTFMT.EQ.1) WRITE(IUMT3D,*) ((IL,J=1,NCOL),I=1,NROW)
      ELSEIF(NEVTOP.NE.1) THEN
        IF(ILMTFMT.EQ.0) WRITE(IUMT3D)   ((IEVT(J,I),J=1,NCOL),I=1,NROW)
        IF(ILMTFMT.EQ.1) WRITE(IUMT3D,*) ((IEVT(J,I),J=1,NCOL),I=1,NROW)
      ENDIF
C
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) ((BUFF(J,I,1),J=1,NCOL),I=1,NROW)
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) ((BUFF(J,I,1),J=1,NCOL),I=1,NROW)
      ENDIF
C
C--RETURN
      RETURN
      END
C
C
      SUBROUTINE LMT7GHB7(ILMTFMT,IUMT3D,KSTP,KPER,IGRID)
C *****************************************************************
C SAVE HEAD-DEPENDENT BOUNDARY CELL LOCATIONS AND VOLUMETRIC FLOW
C RATES FOR USE BY MT3D.
C *****************************************************************
C Modified from Harbaugh (2005)
C last modified: 08-08-2008
C
      USE GLOBAL,      ONLY:NCOL,NROW,NLAY,IBOUND,HNEW,BUFF
      USE GWFGHBMODULE,ONLY:NBOUND,BNDS
      CHARACTER*16 TEXT
      DOUBLE PRECISION CCGHB,CHB
C
C--SET POINTERS FOR THE CURRENT GRID     
c swm: already set in GWF2GHB7BD      CALL SGWF2GHB7PNT(IGRID)
C      
      TEXT='GHB'
      ZERO=0.      
C
C--WRITE AN IDENTIFYING HEADER
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT,NBOUND
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT,NBOUND
      ENDIF
C
C--IF NO BOUNDARIES THEN SKIP
      IF(NBOUND.LE.0) GO TO 9999
C
C--FOR EACH GENERAL HEAD BOUND ACCUMULATE FLOW INTO AQUIFER
      DO L=1,NBOUND
C
C--GET LAYER, ROW AND COLUMN OF EACH GENERAL HEAD BOUNDARY.
        IL=BNDS(1,L)
        IR=BNDS(2,L)
        IC=BNDS(3,L)
C
C--RATE=0 IF IBOUND=<0
        RATE=ZERO
        IF(IBOUND(IC,IR,IL).GT.0) THEN
C
C--GET PARAMETERS FROM BOUNDARY LIST.          
          HB=BNDS(4,L)
          C=BNDS(5,L)
          CCGHB=C          
          CHB=C*HB
C
C--CALCULATE THE FOW RATE INTO THE CELL
          RATE= CHB - CCGHB*HNEW(IC,IR,IL)
        ENDIF
C
C--WRITE HEAD DEP. BOUND. LOCATION AND RATE
        IF(ILMTFMT.EQ.0) THEN
          WRITE(IUMT3D) IL,IR,IC,RATE
        ELSEIF(ILMTFMT.EQ.1) THEN
          WRITE(IUMT3D,*) IL,IR,IC,RATE
        ENDIF
      ENDDO
C
C--RETURN
 9999 RETURN
      END
C
C
      SUBROUTINE LMT7FHB7(ILMTFMT,IUMT3D,KSTP,KPER,IGRID)
C **********************************************************************
C SAVE SPECIFIED-FLOW CELL LOCATIONS AND VOLUMETRIC FLOW RATES
C FOR USE BY MT3D.
C **********************************************************************
C Modified from Leake and Lilly (1997), and Harbaugh (2005)
C last modified: 08-08-2008
C
      USE GLOBAL,      ONLY:NCOL,NROW,NLAY,IBOUND     
      USE GWFFHBMODULE,ONLY:NFLW,IFLLOC,BDFV
      CHARACTER*16 TEXT
C   
C--SET POINTERS FOR THE CURRENT GRID
c swm: already set in GWF2FHB7BD      CALL SGWF2FHB7PNT(IGRID)
C      
      TEXT='FHB'
      ZERO=0.
C
C--WRITE AN IDENTIFYING HEADER
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT,NFLW
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT,NFLW
      ENDIF
C
C--IF NO SPECIFIED-FLOW CELL, RETURN
      IF(NFLW.LE.0) GO TO 9999
C
C--PROCESS SPECIFIED-FLOW CELLS ONE AT A TIME.

      DO L=1,NFLW
C
C--GET LAYER, ROW, AND COLUMN NUMBERS
        IR=IFLLOC(2,L)
        IC=IFLLOC(3,L)
        IL=IFLLOC(1,L)
        Q=ZERO
C
C--GET FLOW RATE FROM SPECIFIED-FLOW LIST
        IF(IBOUND(IC,IR,IL).GT.0) Q=BDFV(1,L)
C
C--WRITE SPECIFIED-FLOW CELL LOCATION AND RATE
        IF(ILMTFMT.EQ.0) THEN
          WRITE(IUMT3D) IL,IR,IC,Q
        ELSEIF(ILMTFMT.EQ.1) THEN
          WRITE(IUMT3D,*) IL,IR,IC,Q
        ENDIF
      ENDDO
C
C--NORMAL RETURN
 9999 RETURN
      END
C
C
      SUBROUTINE LMT7RES7(ILMTFMT,IUMT3D,KSTP,KPER,IGRID)
C **********************************************************************
C SAVE RESERVOIR CELL LOCATIONS AND VOLUMETRIC FLOW RATES
C FOR USE BY MT3D.
C **********************************************************************
C Modified from Fenske et al., (1996), Harbaugh (2005)
C last modified: 08-08-2008
C
      USE GLOBAL ,      ONLY: HNEW,IBOUND,BUFF,NCOL,NROW,NLAY 
      USE GWFRESMODULE, ONLY: NRES,NRESOP,IRES,IRESL,BRES,CRES,
     &                        BBRES,HRES  
      CHARACTER*16 TEXT    
C
C--SET POINTERS FOR THE CURRENT GRID      
c swm: already set in GWF2RES7BD      CALL SGWF2RES7PNT(IGRID)            
C      
      TEXT='RES'
      ZERO=0.
C
C--CLEAR BUFFER
      DO IL=1,NLAY
        DO IR=1,NROW
          DO IC=1,NCOL
            BUFF(IC,IR,IL)=ZERO
          ENDDO
        ENDDO
      ENDDO
C
C--FOR EACH RESERVOIR REACH ACCUMULATE RESERVOIR FLOW
      DO 200 I=1,NROW
      DO 190 J=1,NCOL
      NR=IRES(J,I)
      IF(NR.LE.0) GO TO 190
      IF(NR.GT.NRES) GO TO 190
      IR=I
      IC=J
C
C--FIND LAYER NUMBER FOR RESERVOIR CELL
      IF(NRESOP.EQ.1) THEN
       IL=1
      ELSE IF(NRESOP.EQ.2) THEN
       IL=IRESL(IC,IR)
      ELSE
       DO 60 K=1,NLAY
       IL=K
C--UPPERMOST ACTIVE CELL FOUND, SAVE LAYER INDEX IN 'IL'
       IF(IBOUND(IC,IR,IL).GT.0) GO TO 70
C--SKIP THIS CELL IF VERTICAL COLUMN CONTAINS A CONSTANT-
C--HEAD CELL ABOVE RESERVOIR LOCATION
       IF(IBOUND(IC,IR,IL).LT.0) GO TO 190
   60  CONTINUE
       GO TO 190
      ENDIF
C
C--IF THE CELL IS EXTERNAL SKIP IT.
      IF(IBOUND(IC,IR,IL).LE.0) GO TO 190
C
C--IF RESERVOIR STAGE IS BELOW RESERVOIR BOTTOM, SKIP IT
   70 HR=HRES(NR)
      IF(HR.LE.BRES(IC,IR))  GO TO 190
C--SINCE RESERVOIR IS ACTIVE AT THIS LOCATION,
C--GET THE RESERVOIR DATA.
      CR=CRES(IC,IR)
      RBOT=BBRES(IC,IR)
      HHNEW=HNEW(IC,IR,IL)
C
C--COMPUTE RATE OF FLOW BETWEEN GROUND-WATER SYSTEM AND RESERVOIR.
C
C--GROUND-WATER HEAD > BOTTOM THEN RATE=CR*(HR-HNEW).
      IF(HHNEW.GT.RBOT) RATE=CR*(HR-HHNEW)
C
C--GROUND-WATER HEAD < BOTTOM THEN RATE=CR*(HR-RBOT)
      IF(HHNEW.LE.RBOT) RATE=CR*(HR-RBOT)
C
C--ADD RATE TO BUFFER.
      BUFF(IC,IR,IL)=BUFF(IC,IR,IL)+RATE
  190 CONTINUE
  200 CONTINUE
C
C--COUNT RES CELLS WITH NONZERO FLOW RATE
      NTEMP=0
      DO IL=1,NLAY
        DO IR=1,NROW
          DO IC=1,NCOL
            IF(IBOUND(IC,IR,IL).LE.0) CYCLE
            IF(BUFF(IC,IR,IL).NE.ZERO) THEN
              NTEMP=NTEMP+1
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--WRITE AN IDENTIFYING HEADER
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT,NTEMP
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT,NTEMP
      ENDIF
C
C--IF NO RES CELLS WITH NONZERO Q, RETURN
      IF(NTEMP.EQ.0) GO TO 9999
C
C--WRITE RES CELL LOCATION AND FLOW RATE
      DO IL=1,NLAY
        DO IR=1,NROW
          DO IC=1,NCOL
            IF(IBOUND(IC,IR,IL).LE.0) CYCLE
            RATE=BUFF(IC,IR,IL)
            IF(RATE.NE.ZERO) THEN
              IF(ILMTFMT.EQ.0) THEN
                WRITE(IUMT3D)   IL,IR,IC,RATE
              ELSEIF(ILMTFMT.EQ.1) THEN
                WRITE(IUMT3D,*) IL,IR,IC,RATE
              ENDIF  
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--NORMAL RETURN
 9999 RETURN
      END
C
C
      SUBROUTINE LMT7STR7(ILMTFMT,IUMT3D,KSTP,KPER,IGRID)
C **********************************************************************
C SAVE STREAM CELL LOCATIONS AND VOLUMETRIC FLOW RATES FOR USE BY MT3D.
C **********************************************************************
C Modified from Prudic (1989), Harbaugh (2005)
C last modified: 08-08-2008
C
      USE GLOBAL,      ONLY:NCOL,NROW,NLAY,IBOUND      
      USE GWFSTRMODULE,ONLY:NSTREM,STRM,ISTRM
      CHARACTER*16 TEXT     
C
C--SET POINTERS FOR THE CURRENT GRID      
c swm: already set in GWF2STR7BD   CALL SGWF2STR7PNT(IGRID)    
C                    
      TEXT='STR'
      ZERO=0.
C
C--WRITE AN IDENTIFYING HEADER
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT,NSTREM
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT,NSTREM
      ENDIF
C
C--IF NO REACHES, SKIP
      IF(NSTREM.EQ.0) GO TO 9999
C
C--FOR EACH STREAM REACH GET LEAKAGE TO OR FROM IT
      DO L=1,NSTREM
C
C--GET REACH LOCATION AND FLOW RATE
        IL=ISTRM(1,L)
        IR=ISTRM(2,L)
        IC=ISTRM(3,L)
        IF(IBOUND(IC,IR,IL).LE.0) THEN
          RATE=ZERO
        ELSE
          RATE=STRM(11,L)
        ENDIF
C
C--WRITE STREAM REACH LOCATION AND RATE
        IF(ILMTFMT.EQ.0) THEN
          WRITE(IUMT3D) IL,IR,IC,RATE
        ELSEIF(ILMTFMT.EQ.1) THEN
          WRITE(IUMT3D,*) IL,IR,IC,RATE
        ENDIF
C        
      ENDDO
C
C--NORMAL RETURN
 9999 RETURN
      END
C
C
      SUBROUTINE LMT7MNW17(ILMTFMT,IUMT3D,KSTP,KPER,IGRID)
C *********************************************************************
C SAVE MNW LOCATIONS AND VOLUMETRIC FLOW RATES FOR USE BY MT3D.
C *********************************************************************
C Modified from MNW by Halford and Hanson (2002)
C last modification: 08-08-2008
C
      USE GLOBAL,      ONLY:NCOL,NROW,NLAY,IBOUND
      USE GWFMNW1MODULE,ONLY:NWELL2,WELL2
      CHARACTER*16 TEXT
C
C--SET POINTERS FOR THE CURRENT GRID
      CALL SGWF2MNW1PNT(IGRID)
C      
      TEXT='MNW'
      ZERO=0.
C
C--WRITE AN IDENTIFYING HEADER
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT,NWELL2
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT,NWELL2
      ENDIF
C
C--IF THERE ARE NO WELLS RETURN
      IF(NWELL2.LE.0) GO TO 9999
C
C--PROCESS WELL LIST
      DO m = 1,nwell2
        n = ifrl( well2(1,m) )
        il = (n-1) / (ncol*nrow) + 1
        ir = mod((n-1),ncol*nrow)/ncol + 1
        ic = mod((n-1),ncol) + 1
        IDwell = ifrl(well2(18,m))  !IDwell in well2(18,m); cdl 4/19/05
        Q = well2(17,m)
C
C--IF CELL IS EXTERNAL Q=0
        IF(IBOUND(IC,IR,IL).LE.0) Q=ZERO
C
C--DUMMY VARIABLE QSW NOT USED, SET TO 0
        QSW=ZERO
C
C--SAVE TO OUTPUT FILE
        IF(ILMTFMT.EQ.0) THEN
          WRITE(IUMT3D) IL,IR,IC,Q,IDwell,QSW
        ELSEIF(ILMTFMT.EQ.1) THEN
          WRITE(IUMT3D,*) IL,IR,IC,Q,IDwell,QSW
        ENDIF
      ENDDO
C
C--RETURN
 9999 RETURN
      END
C
C
C
      SUBROUTINE LMT7MNW27(ILMTFMT,IUMT3D,KSTP,KPER,IGRID)
C *********************************************************************
C SAVE MNW LOCATIONS AND VOLUMETRIC FLOW RATES FOR USE BY MT3D.
C *********************************************************************
C Modified from MNW by Halford and Hanson (2002)
C last modification: 08-08-2008
C Modified from MNW2 by Konikow and Hornberger (2009)
C modification: 10-21-2010:  swm  
C last modification: 2-16-2012:  awh
C
      USE GLOBAL,      ONLY:NCOL,NROW,NLAY,IBOUND
      USE GWFMNW2MODULE,ONLY:NMNW2,NTOTNOD,MNW2,MNWNOD,MNWMAX
      INTEGER firstnode, lastnode
      CHARACTER*16 TEXT
C
C--SET POINTERS FOR THE CURRENT GRID
c swm: already set in GWF2MNW7BD      CALL SGWF2MNW7PNT(IGRID)
C      
      TEXT='MNW'
      ZERO=0.
c swm: SET NUMBER OF ACTIVE WELL NODES BASED ON NMNW2 AND NTOTNOD
      NACTW=NTOTNOD
      IF(NMNW2.LE.0) NACTW=0
C
C--WRITE AN IDENTIFYING HEADER
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT,NACTW
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT,NACTW
      ENDIF
C
C--IF THERE ARE NO WELLS RETURN
      IF(NMNW2.LE.0) GO TO 9999
C
C--PROCESS WELL LIST -- write Q for all nodes even if inactive
c  Loop over all wells
      DO iw=1,MNWMAX
        IDwell = iw
c  active well check
        firstnode=MNW2(4,iw)
        lastnode=MNW2(4,iw)+ABS(MNW2(2,iw))-1
c   Loop over nodes in well
        do INODE=firstnode,lastnode
          il=MNWNOD(1,INODE)              
          ir=MNWNOD(2,INODE)              
          ic=MNWNOD(3,INODE)              
C
C--IF CELL IS EXTERNAL OR WELL INACTIVE Q=0
          IF(IBOUND(IC,IR,IL).LE.0 .OR. MNW2(1,iw).LE.0.) then
            Q=ZERO
          else
            Q=MNWNOD(4,INODE)
          end if
C
C--DUMMY VARIABLE QSW NOT USED, SET TO 0
          QSW=ZERO
C
C--SAVE TO OUTPUT FILE
          IF(ILMTFMT.EQ.0) THEN
            WRITE(IUMT3D) IL,IR,IC,Q,iw,QSW
          ELSEIF(ILMTFMT.EQ.1) THEN
            WRITE(IUMT3D,*) IL,IR,IC,Q,iw,QSW
          ENDIF
        enddo
      ENDDO
C
C--RETURN
 9999 RETURN
      END
C
C
      SUBROUTINE LMT7ETS7(ILMTFMT,IUMT3D,KSTP,KPER,IGRID)
C ********************************************************************
C SAVE SEGMENTED EVAPOTRANSPIRATION LAYER INDICES (IF NLAY>1) AND
C VOLUMETRIC FLOW RATES FOR USE BY MT3D.
C ********************************************************************
C Modified from Banta (2000), Harbaugh (2005)
C last modified: 08-08-2008
C
      USE GLOBAL ,      ONLY: HNEW,IBOUND,BUFF,NCOL,NROW,NLAY      
      USE GWFETSMODULE, ONLY: NETSOP,NETSEG,IETS,ETSR,ETSX,ETSS,
     &                        PXDP,PETM
      CHARACTER*16 TEXT
      DOUBLE PRECISION QQ,HH,SS,DD,XX,HHCOF,RRHS,PXDP1,PXDP2
C
C--SET POINTERS FOR THE CURRENT GRID
      CALL SGWF2ETS7PNT(IGRID)
C      
      TEXT='ETS'
      ZERO=0.      
C
C--WRITE AN IDENTIFYING HEADER
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT
      ENDIF      
C
C--CLEAR THE BUFFER
      DO IL=1,NLAY
        DO IR=1,NROW
          DO IC=1,NCOL
            BUFF(IC,IR,IL)=ZERO
          ENDDO   
        ENDDO   
      ENDDO   
C
C--PROCESS EACH HORIZONTAL CELL LOCATION
      DO IR=1,NROW
        DO IC=1,NCOL
C
C--SET THE LAYER INDEX EQUAL TO 1.
          IL=1
C
C--IF OPTION 2 IS SPECIFIED THEN GET LAYER INDEX FROM IETS ARRAY
          IF (NETSOP.EQ.2) IL=IETS(IC,IR)
          IF (IL.EQ.0) CYCLE
C
C--IF CELL IS EXTERNAL THEN IGNORE IT.
          IF (IBOUND(IC,IR,IL).LE.0) CYCLE
C          
          C=ETSR(IC,IR)
          S=ETSS(IC,IR)
          SS=S
          HH=HNEW(IC,IR,IL)
C
C--IF HEAD IN CELL => ETSS,SET Q=MAX ET RATE.
          IF (HH.GE.SS) THEN
            QQ=-C
          ELSE
C
C--IF DEPTH=>EXTINCTION DEPTH, ET IS 0.
            X=ETSX(IC,IR)
            XX=X
            DD=SS-HH
            IF (DD.LT.XX) THEN
C--VARIABLE RANGE.  CALCULATE Q DEPENDING ON NUMBER OF SEGMENTS
C
              IF (NETSEG.GT.1) THEN
C               DETERMINE WHICH SEGMENT APPLIES BASED ON HEAD, AND
C               CALCULATE TERMS TO ADD TO RHS AND HCOF
C
C               SET PROPORTIONS CORRESPONDING TO ETSS ELEVATION
                PXDP1 = 0.0
                PETM1 = 1.0
                DO ISEG = 1,NETSEG
C                 SET PROPORTIONS CORRESPONDING TO LOWER END OF
C                 SEGMENT
                  IF (ISEG.LT.NETSEG) THEN
                    PXDP2 = PXDP(IC,IR,ISEG)
                    PETM2 = PETM(IC,IR,ISEG)
                  ELSE
                    PXDP2 = 1.0
                    PETM2 = 0.0
                  ENDIF
                  IF (DD.LE.PXDP2*XX) THEN
C                   HEAD IS IN DOMAIN OF THIS SEGMENT
                    EXIT
                  ENDIF
C                 PROPORTIONS AT LOWER END OF SEGMENT WILL BE FOR
C                 UPPER END OF SEGMENT NEXT TIME THROUGH LOOP
                  PXDP1 = PXDP2
                  PETM1 = PETM2
                ENDDO   
C--CALCULATE ET RATE BASED ON SEGMENT THAT APPLIES AT HEAD
C--ELEVATION
                HHCOF = -(PETM1-PETM2)*C/((PXDP2-PXDP1)*X)
                RRHS = -HHCOF*(S-PXDP1*X) - PETM1*C
              ELSE
C--SIMPLE LINEAR RELATION.  Q=-ETSR*(HNEW-(ETSS-ETSX))/ETSX, WHICH
C--IS FORMULATED AS Q= -HNEW*ETSR/ETSX + (ETSR*ETSS/ETSX -ETSR).
                HHCOF = -C/X
                RRHS = (C*S/X) - C
              ENDIF
              QQ = HH*HHCOF + RRHS
            ELSE
              QQ = ZERO
            ENDIF
          ENDIF  
C
C--ADD Q TO BUFFER.
          Q=QQ
          BUFF(IC,IR,1)=Q
        ENDDO   
      ENDDO   
C
C--RECORD THEM
      IF(NETSOP.EQ.1) THEN
        IL=1
        IF(ILMTFMT.EQ.0) WRITE(IUMT3D)  ((IL,J=1,NCOL),I=1,NROW)
        IF(ILMTFMT.EQ.1) WRITE(IUMT3D,*)((IL,J=1,NCOL),I=1,NROW)
      ELSEIF(NETSOP.NE.1) THEN
        IF(ILMTFMT.EQ.0) THEN 
          WRITE(IUMT3D)   ((IETS(J,I),J=1,NCOL),I=1,NROW)
        ELSEIF(ILMTFMT.EQ.1) THEN
          WRITE(IUMT3D,*) ((IETS(J,I),J=1,NCOL),I=1,NROW)
        ENDIF  
      ENDIF
C
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D)   ((BUFF(J,I,1),J=1,NCOL),I=1,NROW)
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) ((BUFF(J,I,1),J=1,NCOL),I=1,NROW)
      ENDIF
C
C--RETURN
      RETURN
      END
C
C
      SUBROUTINE LMT7DRT7(ILMTFMT,IUMT3D,KSTP,KPER,IGRID)
C ******************************************************************
C SAVE DRT (Drain with Return Flow) CELL LOCATIONS AND 
C VOLUMETRIC FLOW RATES FOR USE BY MT3D.
C ******************************************************************
C Modified from Banta (2000), Harbaugh (2005)
C last modified: 08-08-2008
C
      USE GLOBAL ,      ONLY: HNEW,IBOUND,NCOL,NROW,NLAY
      USE GWFDRTMODULE, ONLY: DRTF,NDRTCL,IDRTFL,NRFLOW
      CHARACTER*16 TEXT
      DOUBLE PRECISION HHNEW,EEL,CC,CEL,QQ,QQIN
C
C--SET POINTERS FOR THE CURRENT GRID
      CALL SGWF2DRT7PNT(IGRID)
C      
      TEXT='DRT'
      ZERO=0.
C
C--WRITE AN IDENTIFYING HEADER
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT,NDRTCL+NRFLOW
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT,NDRTCL+NRFLOW
      ENDIF      
C
C--IF THERE ARE NO DRAIN-RETURN CELLS, SKIP.
      IF (NDRTCL+NRFLOW.LE.0) GO TO 9999
C
C--LOOP THROUGH EACH DRAIN-RETURN CELL, CALCULATING FLOW.
      DO L=1,NDRTCL
C
C--GET LAYER, ROW & COLUMN OF CELL CONTAINING DRAIN.
        IL=DRTF(1,L)
        IR=DRTF(2,L)
        IC=DRTF(3,L)
        Q=ZERO
        ILR=0
        IF(IDRTFL.GT.0) THEN
          QIN=ZERO
          ILR=DRTF(6,L)
          IRR=DRTF(7,L)
          ICR=DRTF(8,L)
          IF(IBOUND(ICR,IRR,ILR).LE.0) ILR=0
        ENDIF                
C
C--IF CELL IS NO-FLOW OR CONSTANT-HEAD, IGNORE IT.
        IF (IBOUND(IC,IR,IL).LE.0) GOTO 99
C
C--GET DRAIN PARAMETERS FROM DRAIN-RETURN LIST.
        EL=DRTF(4,L)
        EEL=EL
        C=DRTF(5,L)
        HHNEW=HNEW(IC,IR,IL)
C
C--IF HEAD HIGHER THAN DRAIN, CALCULATE Q=C*(EL-HHNEW).
        IF(HHNEW.GT.EEL) THEN
          CC=C
          CEL=C*EL
          QQ=CEL - CC*HHNEW
          Q=QQ          
          IF(IDRTFL.GT.0) THEN           
            IF(ILR.NE.0) THEN
              RFPROP = DRTF(9,L)
              QQIN = RFPROP*(CC*HHNEW-CEL)
              QIN = QQIN
            ENDIF
          ENDIF
        ENDIF
   99   CONTINUE     
C
C--WRITE DRT LOCATION AND RATE (both host and recipient)
        mhost=0
        QSW=ZERO
C       main drain (host to recipient cell)
        IF(ILMTFMT.EQ.0) WRITE(IUMT3D)   IL,IR,IC,Q,mhost,QSW
        IF(ILMTFMT.EQ.1) WRITE(IUMT3D,*) IL,IR,IC,Q,mhost,QSW 
C       return flow recipient cell 
        if(IDRTFL.GT.0 .AND. ILR.GT.0) then
          mhost = ncol*nrow*(IL-1) + ncol*(IR-1) + IC
          IF(ILMTFMT.EQ.0) THEN
            WRITE(IUMT3D)   ILR,IRR,ICR,QIN,mhost,QSW            
          ELSEIF(ILMTFMT.EQ.1) THEN 
            WRITE(IUMT3D,*) ILR,IRR,ICR,QIN,mhost,QSW
          ENDIF
        endif
      ENDDO   
C
C--RETURN
 9999 RETURN
      END
C
C
      SUBROUTINE LMT7UZF1(ILMTFMT,ISSMT3D,IUMT3D,KSTP,KPER,IGRID)
C *********************************************************************
C SAVE FLOW THROUGH UNSATURATED CELL IN VERTICAL DIRECTION.
C THIS SUBROUTINE IS CALLED ONLY IF THE 'UZF' PACKAGE
C IS USED IN MODFLOW AND SOLUTE ROUTING IS ACTIVE IN 'UZF'.
C *********************************************************************
C
C last modified: 05-13-2010
C
      USE GLOBAL,      ONLY:NCOL,NROW,NLAY,IBOUND,HNEW,HOLD,
     &                      BUFF,BOTM,DELR,DELC
      USE GWFBASMODULE,ONLY:DELT, HNOFLO
      USE GWFUZFMODULE,ONLY:IUZFBND, RTSOLWC, RTSOLFL, IUZHOLD,
     &                      RTSOLDS, SEEPOUT, IUZM, RTSOLUTE,
     &                      IUZFOPT
      CHARACTER*16 TEXT1, TEXT2, TEXT3, TEXT4
      REAL cellarea
C
C--SET POINTERS FOR THE CURRENT GRID      
      CALL SGWF2UZF1PNT(IGRID)
      IF ( RTSOLUTE.LE.0 ) RETURN
C            
      TEXT1='WATER CONTENT'
      TEXT2='UZ FLUX'
      TEXT3='UZQSTO'
      TEXT4='GWQOUT'
C
C--CLEAR THE BUFFER
      DO IL=1,NLAY
        DO IR=1,NROW
          DO IC=1,NCOL
            BUFF(IC,IR,IL)=0.0
          ENDDO   
        ENDDO   
      ENDDO
      numcells = NCOL*NROW
C
C--FOR EACH CELL CALCULATE WATER CONTENT & STORE IN BUFFER
      IF ( IUZM.GT.0 .AND. IUZFOPT.GT.0 ) THEN
      DO K = 1, NLAY
        l = 0
        DO ll = 1, numcells
          I = IUZHOLD(1, ll)
          J = IUZHOLD(2, ll)
          IF( IUZFBND(J,I).NE.0 ) THEN
            l = l + 1
            IF( K.GE.IUZFBND(J,I) ) THEN
              IF( HNEW(J,I,K).LT.BOTM(J,I,K-1) )THEN
                BUFF(J,I,K)=RTSOLWC(K,ll)
              ELSEIF ( ABS(SNGL(HNEW(J,I,K))-HNOFLO).LT.1.0 ) THEN
                BUFF(J,I,K)=RTSOLWC(K,ll)
              END IF
            END IF
          END IF
        ENDDO
      END DO
C
C--RECORD CONTENTS OF BUFFER.
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT1
        WRITE(IUMT3D) BUFF
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT1
        WRITE(IUMT3D,*) BUFF
      ENDIF
C
C
C--CLEAR THE BUFFER
      DO IL=1,NLAY
        DO IR=1,NROW
          DO IC=1,NCOL
            BUFF(IC,IR,IL)=0.0
          ENDDO   
        ENDDO   
      ENDDO
      END IF
!  101 format(10e12.5)
C
C--FOR EACH CELL CALCULATE FLUX THROUGH LOWER FACE & STORE IN BUFFER
      DO K = 1, NLAY
        l = 0
        DO ll = 1, numcells
          I = IUZHOLD(1, ll)
          J = IUZHOLD(2, ll)
          IF( IUZFBND(J,I).NE.0 ) THEN
            l = l + 1
            IF( K.GE.IUZFBND(J,I) ) THEN
                cellarea = DELR(J)*DELC(I)
                BUFF(J,I,K)=RTSOLFL(K,ll)*cellarea
                IF ( abs(BUFF(J,I,K)).LT.1.0e-10 )
     +               BUFF(J,I,K) = 0.0
            END IF
          END IF
        ENDDO
      END DO
C
C--RECORD CONTENTS OF BUFFER.
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT2
        WRITE(IUMT3D) BUFF
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT2
        WRITE(IUMT3D,*) BUFF
      ENDIF
C
C--CLEAR THE BUFFER
      DO IL=1,NLAY
        DO IR=1,NROW
          DO IC=1,NCOL
            BUFF(IC,IR,IL)=0.0
          ENDDO   
        ENDDO   
      ENDDO
C--FOR EACH CELL CALCULATE CHANGE IN STORAGE & STORE IN BUFFER
      IF ( IUZM.GT.0 .AND. IUZFOPT.GT.0 ) THEN
      DO K = 1, NLAY
        l = 0
        DO ll = 1, numcells
          I = IUZHOLD(1, ll)
          J = IUZHOLD(2, ll)
          IF( IUZFBND(J,I).NE.0 ) THEN
            l = l + 1
            IF( K.GE.IUZFBND(J,I) ) THEN
              IF( HNEW(J,I,K).LT.BOTM(J,I,K-1) ) THEN
                cellarea = DELR(J)*DELC(I)
                BUFF(J,I,K)=RTSOLDS(K,ll)*cellarea
              ELSEIF ( ABS(SNGL(HNEW(J,I,K))-HNOFLO).LT.1.0 ) THEN
                cellarea = DELR(J)*DELC(I)
                BUFF(J,I,K)=RTSOLDS(K,ll)*cellarea
              END IF
            END IF
          END IF
        ENDDO
      END DO
      END IF
C
C--RECORD CONTENTS OF BUFFER.
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT3
        WRITE(IUMT3D) BUFF
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT3
        WRITE(IUMT3D,*) BUFF
      ENDIF
C
C
      RETURN
      END
      SUBROUTINE LMT7UZFET(ILMTFMT,ISSMT3D,IUMT3D,KSTP,KPER,IGRID)
C *********************************************************************
C SAVE FLOW THROUGH UNSATURATED CELL IN VERTICAL DIRECTION.
C THIS SUBROUTINE IS CALLED ONLY IF THE 'UZF' PACKAGE
C IS USED IN MODFLOW AND SOLUTE ROUTING IS ACTIVE IN 'UZF'.
C *********************************************************************
C
C last modified: 05-13-2010
C
      USE GLOBAL,      ONLY:NCOL,NROW,NLAY,IBOUND,HNEW,HOLD,
     &                      BUFF,BOTM,DELR,DELC
      USE GWFBASMODULE,ONLY:DELT, HNOFLO
      USE GWFUZFMODULE,ONLY:IUZFBND, GRIDET, IUZHOLD, IETFLG, GWET,
     &                      SEEPOUT, RTSOLUTE, IUZFOPT
      CHARACTER*16 TEXT1, TEXT2
      REAL cellarea
      IF ( RTSOLUTE.LE.0 ) RETURN
      IF ( IETFLG.LE.0 ) RETURN
C
C--SET POINTERS FOR THE CURRENT GRID      
      CALL SGWF2UZF1PNT(IGRID)
C            
      TEXT1='UZ-ET'
C
C--CLEAR THE BUFFER FOR UZ ET
      DO IL=1,NLAY
        DO IR=1,NROW
          DO IC=1,NCOL
            BUFF(IC,IR,IL)=0.0
          ENDDO   
        ENDDO   
      ENDDO
      numcells = NCOL*NROW
C
C--FOR EACH CELL CALCULATE UZ ET & STORE IN BUFFER
      IF ( IUZM.GT.0 .AND. IUZFOPT.GT.0 ) THEN
      DO K = 1, NLAY
        l = 0
        DO ll = 1, numcells
          I = IUZHOLD(1, ll)
          J = IUZHOLD(2, ll)
          IF( IUZFBND(J,I).NE.0 ) THEN
            l = l + 1
            IF( K.GE.IUZFBND(J,I) ) THEN
              IF( HNEW(J,I,K).LT.BOTM(J,I,K-1) )THEN
                cellarea = DELR(J)*DELC(I)
                BUFF(J,I,K)=-GRIDET(J,I,K)*cellarea/DELT
              ELSEIF ( ABS(SNGL(HNEW(J,I,K))-HNOFLO).LT.1.0 ) THEN
                cellarea = DELR(J)*DELC(I)
                BUFF(J,I,K)=-GRIDET(J,I,K)*cellarea/DELT
                GRIDET(J,I,K) = 0.0
              END IF
            END IF
          END IF
        ENDDO
      END DO
      END IF
C
C--RECORD CONTENTS OF BUFFER.
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT1
        WRITE(IUMT3D) BUFF
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT1
        WRITE(IUMT3D,*) BUFF
      ENDIF
C
C--CLEAR THE BUFFER FOR GW ET
      TEXT2='GW-ET'
      DO IL=1,NLAY
        DO IR=1,NROW
          DO IC=1,NCOL
            BUFF(IC,IR,IL)=0.0
          ENDDO   
        ENDDO   
      ENDDO
      numcells = NCOL*NROW
C
C--FOR EACH CELL CALCULATE GW ET & STORE IN BUFFER
      DO I=1,NROW
        DO J=1,NCOL
          K = ABS(IUZFBND(J,I))
          IF ( K.NE.0 ) THEN
            IF ( IBOUND(J,I,K).GT.0 ) THEN
              BUFF(J,I,K)=-GWET(J,I)
            END IF
          END IF
        ENDDO
      ENDDO
C
C--RECORD CONTENTS OF BUFFER.
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT2
        WRITE(IUMT3D) BUFF
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT2
        WRITE(IUMT3D,*) BUFF
      ENDIF
      RETURN
      END
C
      SUBROUTINE LMT7UZFCONNECT(ILMTFMT,IUMT3D,KSTP,KPER,IGRID)
C ******************************************************************
C SAVE UZF->SFR2 & UZF->LAK CONNECTIONS
C THIS SUBROUTINE IS CALLED ONLY IF THE 'UZF1' AND 'SFR2' OR IF
C 'UZF1' AND 'LAK3' PACKAGES ARE USED IN THE MODFLOW SOLUTION.
C ******************************************************************
C DATE CREATED: 8-14-2013
      USE GLOBAL,       ONLY:NCOL,NROW,NLAY,IOUT,IBOUND,IUNIT
      USE GWFSFRMODULE, ONLY:NSTRM,ISTRM,STRM,ISEG,NSEGDIM,SEG,NSS,
     &                       STROUT,NINTOT
      USE GWFLAKMODULE, ONLY:VOL,NSFRLAK,LAKSFR,ILKSEG,ILKRCH,SWLAK
      USE GWFUZFMODULE, ONLY:IRUNBND,REJ_INF,EXCESPP,SEEPOUT,LAYNUM
C
      CHARACTER*16 TEXT
      CHARACTER*4  TEXT2,TEXT3
      INTEGER IC,IR,KK,NCON,NSEGRCH,SEGNUM,SEG_INFO
      INTEGER OL,OR,OC,ISTSG,NREACH,LK
      INTEGER CT,NCLOSE,NSFRGRW,NSFREXC,NSFRREJ,NLAKGRW,NLAKEXC
      INTEGER NLAKEREJ,NSNKGRW,NSNKEXC,NSNKREJ  !EDM
      REAL    Q,LEN_FRAC,CLOSEZERO
      DIMENSION SEG_INFO(2,NSS)  !FOR STORING NRCH PER SEG
C
      TEXT='UZF CONNECTIONS'
      CLOSEZERO=1E-15
C
!!C--DETERMINE HOW MANY REACHES PER SEGMENT THERE ARE
!!C  FIRST, INITIALIZE, THEN TALLY
!!      DO II=1,NSS
!!        SEG_INFO(1,II)=II
!!        SEG_INFO(2,II)=0
!!      ENDDO
!!C
!!      DO II=1,NSS
!!        DO JJ=1,NSTRM
!!          IF(
!!          SEG_INFO(2,II)=SEG_INFO(2,II)+1
!!        ENDDO
!!      ENDDO
C
C--DETERMINE HOW MANY LIST ITEMS THERE ARE
      NCON=0
      DO IR=1,NROW
        DO IC=1,NCOL
          SEGNUM=IRUNBND(IC,IR)
C
          IF(SEGNUM.GT.0) THEN
            IF(SEEPOUT(IC,IR).NE.0.) THEN  !GROUNDWATER DISCHARGE
              NSEGRCH=ISEG(4,SEGNUM)
              NCON=NCON+NSEGRCH
            ENDIF
C           
            IF(EXCESPP(IC,IR).NE.0.) THEN  !INFIL EXCEEDING K_vert
              NSEGRCH=ISEG(4,SEGNUM)
              NCON=NCON+NSEGRCH
            ENDIF
C     
            IF(REJ_INF(IC,IR).NE.0.) THEN  !SHAL GW INHIBITING INFIL
              NSEGRCH=ISEG(4,SEGNUM)
              NCON=NCON+NSEGRCH
            ENDIF
C
          ELSEIF(SEGNUM.LT.0) THEN  !1 ENTRY NEEDED FOR Q TO LK PER CELL
C
            IF(SEEPOUT(IC,IR).NE.0.) THEN  !GROUNDWATER DISCHARGE
              NCON=NCON+1
            ENDIF
C           
            IF(EXCESPP(IC,IR).NE.0.) THEN  !INFIL EXCEEDING K_vert
              NCON=NCON+1
            ENDIF
C     
            IF(REJ_INF(IC,IR).NE.0.) THEN  !SHAL GW INHIBITING INFIL
              NCON=NCON+1
            ENDIF
C
          ELSE
            IF(SEEPOUT(IC,IR).NE.0.) THEN  !GROUNDWATER DISCHARGE
              NCON=NCON+1
            ENDIF
C
            IF(EXCESPP(IC,IR).NE.0.) THEN  !INFIL EXCEEDING K VERT
              NCON=NCON+1
            ENDIF
C
            IF(REJ_INF(IC,IR).NE.0) THEN     !SHAL GW INHIBITING INFIL
              NCON=NCON+1
            ENDIF
          ENDIF
C
        ENDDO
      ENDDO
C
C--WRITE AN IDENTIFYING HEADER
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT,NCON
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT,NCON
      ENDIF
C
C--IF THERE ARE NO WELLS RETURN
      IF(NCON.EQ.0) GO TO 9999
C
C--WRITE CONNECTION INFORMATION AS FOLLOWS:
C  TYPE(GRW/EXC/REJ),DESTINATION(S/L),Origin L/R/C, Destination REACH L/R/C (IF STRM) ELSE LAK #, Q (L^3)
C
      NSFRGRW=0
      NSFREXC=0
      NSFRREJ=0
      NLAKGRW=0
      NLAKEXC=0
      NLAKREJ=0
      NSNKGRW=0
      NSNKEXC=0
      NSNKREJ=0
      NCLOSE=0
      DO IR=1,NROW
        DO IC=1,NCOL
          SEGNUM=IRUNBND(IC,IR)
          IF(SEGNUM.GT.0) THEN   !IF POSITIVE THEN OUTFLOW TO STREAM
            IF(SEEPOUT(IC,IR).NE.0. .OR. EXCESPP(IC,IR).NE.0. .OR. 
     &         REJ_INF(IC,IR).NE.0.) THEN
C
              OL=LAYNUM(IC,IR)
              OR=IR
              OC=IC
C
              DO KK=1,ISEG(4,SEGNUM) !FOR EACH REACH IN THE SEGMENT
                TEXT3='SFR'
C              
C--FOR THE CURRENT SEGMENT/REACH COMBO, FIND CORRESPONDING LAY,ROW,COL INFO IN ISTRM
                CT=1
                DO WHILE(.NOT.((ISTRM(4,CT).EQ.SEGNUM).AND.
     &                         (ISTRM(5,CT).EQ.KK)))
                  CT=CT+1
                ENDDO
                LEN_FRAC=STRM(1,CT)/SEG(1,SEGNUM)
C
C--GROUNDWATER DISCHARGE -> STREAM SEGMENT
                IF(SEEPOUT(IC,IR).NE.0.) THEN
                  Q=SEEPOUT(IC,IR)
                  IF(Q.LT.CLOSEZERO) CYCLE
                    NSFRGRW=NSFRGRW+1
                  TEXT2='GRW'
                  IF(ILMTFMT.EQ.0) THEN
                    WRITE(IUMT3D) TEXT3,TEXT2,OL,OR,OC,SEGNUM,KK,
     &                            Q*LEN_FRAC
                  ELSEIF(ILMTFMT.EQ.1) THEN
                    WRITE(IUMT3D,991) TEXT3,TEXT2,OL,OR,OC,SEGNUM,KK,
     &                            Q*LEN_FRAC
  991               FORMAT(2a6,5i6,f10.6)
                  ENDIF
                ENDIF
C--INFILTRATION INHIBITED DUE TO SHALLOW GROUNDWATER -> STREAM SEGMENT
                IF(EXCESPP(IC,IR).NE.0.) THEN
                  Q=EXCESPP(IC,IR)
                  IF(Q.LT.CLOSEZERO) CYCLE
                  NSFREXC=NSFREXC+1
                  TEXT2='EXC'
                  IF(ILMTFMT.EQ.0) THEN
                    WRITE(IUMT3D) TEXT3,TEXT2,OL,OR,OC,SEGNUM,KK,
     &                            Q*LEN_FRAC
                  ELSEIF(ILMTFMT.EQ.1) THEN
                    WRITE(IUMT3D,991) TEXT3,TEXT2,OL,OR,OC,SEGNUM,KK,
     &                            Q*LEN_FRAC
                  ENDIF
                ENDIF
C--REJECTED INFILTRATION DUE TO APPLICATION RATE > Kv -> STREAM SEGMENT
                IF(REJ_INF(IC,IR).NE.0.) THEN
                  Q=REJ_INF(IC,IR)
                  IF(Q.LT.CLOSEZERO) CYCLE
                  NSFRREJ=NSFRREJ+1
                  TEXT2='REJ'
                  IF(ILMTFMT.EQ.0) THEN
                    WRITE(IUMT3D) TEXT3,TEXT2,OL,OR,OC,SEGNUM,KK,
     &                            Q*LEN_FRAC
                  ELSEIF(ILMTFMT.EQ.1) THEN
                    WRITE(IUMT3D,991) TEXT3,TEXT2,OL,OR,OC,SEGNUM,KK,
     &                            Q*LEN_FRAC
                  ENDIF
                ENDIF
              ENDDO
            ENDIF
C
          ELSEIF(SEGNUM.LT.0) THEN  !RUNOFF GOES TO LAKE
C
            LK=ABS(IRUNBND(IC,IR))
            OL=LAYNUM(IC,IR)
            OR=IR
            OC=IC
            TEXT3='LAK'
C--GROUNDWATER DISCHARGE -> LAKE
            IF(SEEPOUT(IC,IR).NE.0.) THEN
              Q=SEEPOUT(IC,IR)
              IF(Q.LT.CLOSEZERO) CYCLE
              TEXT2='GRW'
              IF(ILMTFMT.EQ.0) THEN
                WRITE(IUMT3D) TEXT3,TEXT2,OL,OR,OC,LK,Q
              ELSEIF(ILMTFMT.EQ.1) THEN
                WRITE(IUMT3D,*) TEXT3,TEXT2,OL,OR,OC,LK,Q
              ENDIF
            ENDIF
C--INFILTRATION INHIBITED DUE TO SHALLOW GROUNDWATER -> LAKE
            IF(EXCESPP(IC,IR).NE.0.) THEN
              Q=EXCESPP(IC,IR)
              IF(Q.LT.CLOSEZERO) CYCLE
              NLAKEXC=NLAKEXC+1
              TEXT2='EXC'
              IF(ILMTFMT.EQ.0) THEN
                WRITE(IUMT3D) TEXT3,TEXT2,OL,OR,OC,LK,Q
              ELSEIF(ILMTFMT.EQ.1) THEN
                WRITE(IUMT3D,*) TEXT3,TEXT2,OL,OR,OC,LK,Q
              ENDIF
            ENDIF
C--REJECTED INFILTRATION DUE TO APPLICATION RATE > Kv -> LAKE
            IF(REJ_INF(IC,IR).NE.0.) THEN
              Q=REJ_INF(IC,IR)
              IF(Q.LT.CLOSEZERO) CYCLE
              NLAKREJ=NLAKREJ+1
              TEXT2='REJ'
              IF(ILMTFMT.EQ.0) THEN
                WRITE(IUMT3D) TEXT3,TEXT2,OL,OR,OC,LK,Q
              ELSEIF(ILMTFMT.EQ.1) THEN
                WRITE(IUMT3D,*) TEXT3,TEXT2,OL,OR,OC,LK,Q
              ENDIF
            ENDIF
C
          ELSE  !IRUNFLG=0 OR IRUNBND(J,I)=0 (EITHER WAY, WATER LEAVES SYSTEM)
C
            IF(SEEPOUT(IC,IR).NE.0. .OR. EXCESPP(IC,IR).NE.0. .OR. 
     &         REJ_INF(IC,IR).NE.0.) THEN
              TEXT3='SNK'
              OL=LAYNUM(IC,IR)
              OR=IR
              OC=IC
C--GROUNDWATER DISCHARGE -> SINK
              IF(SEEPOUT(IC,IR).NE.0.) THEN
                Q=SEEPOUT(IC,IR)
                IF(Q.LT.CLOSEZERO) CYCLE
                NSNKGRW=NSNKGRW+1
                TEXT2='GRW'
                IF(ILMTFMT.EQ.0) THEN
                  WRITE(IUMT3D) TEXT3,TEXT2,OL,OR,OC,Q
                ELSEIF(ILMTFMT.EQ.1) THEN
                  WRITE(IUMT3D,*) TEXT3,TEXT2,OL,OR,OC,Q
                ENDIF
              ENDIF
C--INFILTRATION INHIBITED DUE TO SHALLOW GROUNDWATER -> SINK
              IF(EXCESPP(IC,IR).NE.0.) THEN
                Q=EXCESPP(IC,IR)
                IF(Q.LT.CLOSEZERO) CYCLE
                NSNKEXC=NSNKEXC+1
                TEXT2='EXC'
                IF(ILMTFMT.EQ.0) THEN
                  WRITE(IUMT3D) TEXT3,TEXT2,OL,OR,OC,Q
                ELSEIF(ILMTFMT.EQ.1) THEN
                  WRITE(IUMT3D,*) TEXT3,TEXT2,OL,OR,OC,Q
                ENDIF
              ENDIF
C--REJECTED INFILTRATION DUE TO APPLICATION RATE > Kv -> LAKE
              IF(REJ_INF(IC,IR).NE.0.) THEN
                Q=REJ_INF(IC,IR)
                IF(Q.LT.CLOSEZERO) CYCLE
                NSNKREJ=NSNKREJ+1
                TEXT2='REJ'
                IF(ILMTFMT.EQ.0) THEN
                  WRITE(IUMT3D) TEXT3,TEXT2,OL,OR,OC,LK,Q
                ELSEIF(ILMTFMT.EQ.1) THEN
                  WRITE(IUMT3D,*) TEXT3,TEXT2,OL,OR,OC,LK,Q
                ENDIF
              ENDIF
C
            ENDIF
          ENDIF
          !IF(Q.LT.CLOSEZERO) THEN
          !  NCLOSE=NCLOSE+1
          !  WRITE(*,*) 'NCLOSE',NCLOSE
          !ENDIF
        ENDDO
      ENDDO
C
9999  RETURN
      END
C      
C
      SUBROUTINE LMT7SFR2(ILMTFMT,IUMT3D,KSTP,KPER,IGRID)
C ******************************************************************
C SAVE SFR2 CELL LOCATIONS AND VOLUMETRIC FLOW RATES FOR USE BY MT3D
C THIS SUBROUTINE IS CALLED ONLY IF THE 'SFR2' PACKAGE IS USED IN 
C THE MODFLOW SOLUTION.
C ******************************************************************
C DATE CREATED: 7-25-2013
      USE GLOBAL,       ONLY:NCOL,NROW,NLAY,IOUT,IBOUND,IUNIT
      USE GWFSFRMODULE, ONLY:NSTRM,ISTRM,STRM,ISEG,NSEGDIM,SEG,
     &                       IOTSG,IDIVAR,FXLKOT,NSS,DVRSFLW,SGOTFLW,
     &                       STROUT,NINTOT
      USE GWFLAKMODULE, ONLY:VOL,NSFRLAK,LAKSFR,ILKSEG,ILKRCH,SWLAK
C
      IMPLICIT NONE
      CHARACTER*16 TEXT
      INTEGER MXSGMT,MXRCH,LASTRCH,L,NREACH,LL,IL,IC,IR,ILAY,
     &        KSTP,KPER,IUMT3D,ISTSG,ILMTFMT,ISSMT3D,IGRID
      INTEGER III,JJJ,LK,IDISP,NINFLOW,ITRIB
      REAL    STRLEN,TRBFLW,FLOWIN
      DOUBLE PRECISION CLOSEZERO
C
      DIMENSION LASTRCH(NSS)
C
      TEXT='SFR'
      CLOSEZERO = 1.0e-15
C
C--STORE LAST REACH NUMBER OF EACH SEGMENT
C--DETERMINE MAX REACHES AND SEGMENTS
      MXSGMT=0
      MXRCH=0
      LASTRCH=0
      DO L=1,NSTRM
        ISTSG = ISTRM(4, l)
        NREACH = ISTRM(5, l)
        IF(NREACH.GT.LASTRCH(ISTSG)) LASTRCH(ISTSG)=NREACH
        IF(ISTSG.GT.MXSGMT) MXSGMT=ISTSG
        IF(NREACH.GT.MXRCH) MXRCH=NREACH
      ENDDO
C
C--WRITE AN IDENTIFYING HEADER
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT,NSTRM,NINTOT,MXSGMT,
     1    MXRCH
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT,NSTRM,NINTOT,MXSGMT,MXRCH
      ENDIF      
C
C
C--IF THERE ARE NO STREAM CELLS, SKIP.
      IF (NSTRM.LE.0) RETURN
C
C--UPDATE LAKE WITH LAST REACH NUMBER
      IF(IUNIT(22).GT.0) THEN  !IUNIT(22): LAK
        DO L=1,NSFRLAK
          ISTSG=ILKSEG(L)
          ILKRCH(L)=LASTRCH(ISTSG)
        ENDDO
      ENDIF
C
C--LOOP THROUGH EACH STREAM CELL
      DO L=1,Nstrm
        LL = L - 1
        IL = ISTRM(1, L)
        IR = ISTRM(2, L)
        IC = ISTRM(3, L)
C
C25-----SEARCH FOR UPPER MOST ACTIVE CELL IN STREAM REACH.
        ILAY = IL
        TOPCELL: DO WHILE (ILAY.LE.NLAY)
          IF(IBOUND(IC,IR,ILAY).EQ.0) THEN
            ILAY = ILAY + 1
          ELSE
            EXIT TOPCELL
          END IF
        END DO TOPCELL
        IF (ILAY.LE.NLAY) IL = ILAY
C
C6------DETERMINE STREAM SEGMENT AND REACH NUMBER.
        ISTSG = ISTRM(4, L)
        NREACH = ISTRM(5, L)
        STRLEN = STRM(1, L)
C
        FLOWIN = 0.0D0
        NINFLOW = 0
        IDISP = 0
        III = 0
        JJJ = 0
C
C---------------------------------------------------------------
C-------DETERMINE ALL INFLOW NODES, RATES, DISPERSION IDENTIFIER
        IF(NREACH.EQ.1) THEN
          IF(ISEG(3,ISTSG).EQ.5) THEN
            FLOWIN = SEG(2,ISTSG)
            NINFLOW = 1
            IDISP = 0
            III = -ISTSG
            JJJ = -NREACH
          ENDIF
C
C9-------COMPUTE INFLOW OF A STREAM SEGMENT EMANATING FROM A LAKE.
Cdep   Revised this section because outflow computed in Lake Package.
          IF((IUNIT(22).GT.0).AND.(IDIVAR(1,ISTSG).LT.0)) THEN
            LK = IABS(IDIVAR(1,ISTSG))
            III = LK
            JJJ = 0
C--THE FOLLOWING LINES ARE NEEDED AT THE END OF THE LMT7LAK3 SUBROUTINE
            NSFRLAK = NSFRLAK + 1
            ILKSEG(NSFRLAK) = ISTSG
            ILKRCH(NSFRLAK) = 1
            LAKSFR(NSFRLAK) = LK
            IF(SEG(2,ISTSG).GT.CLOSEZERO.AND.VOL(LK).GT.CLOSEZERO) THEN
              FLOWIN = FXLKOT(ISTSG)
              NINFLOW = 1
              IDISP = 0
            END IF
C
C10-----SPECIFIED FLOW FROM LAKE IS ZERO AND ICALC IS ZERO.
            IF (ISEG(1,ISTSG).EQ.0) THEN  !ISEG(1,x)=ICALC
              FLOWIN = FXLKOT(ISTSG)
              NINFLOW=1
              IDISP=0
            END IF
C10Bdep    OUTFLOW FROM LAKE NOW COMPUTED IN LAKE PACKAGE.
            IF(FXLKOT(ISTSG).LE.CLOSEZERO ) THEN
              FLOWIN = STROUT(ISTSG)
              NINFLOW=1
              IDISP=0
            END IF
            SWLAK(NSFRLAK)=FLOWIN
          END IF
C
C14-----COMPUTE ONE OR MORE DIVERSIONS FROM UPSTREAM SEGMENT.
Crgn&dep   revised computation of diversions and added subroutine
          IF(ISTSG.GT.1)THEN
C
C20-----SET FLOW INTO DIVERSION IF SEGMENT IS DIVERSION.
            IF( ISEG(3,ISTSG).EQ.6 ) THEN
              IF(IDIVAR(1,ISTSG).GT.0 ) THEN
                FLOWIN = DVRSFLW(ISTSG)
                NINFLOW=1
                IDISP=0
                III=IDIVAR(1,ISTSG)
                JJJ=LASTRCH(III)
              ENDIF
            END IF
          END IF
C
C21-----SUM TRIBUTARY OUTFLOW AND USE AS INFLOW INTO DOWNSTREAM SEGMENT.
          IF(ISTSG.GE.1.AND.ISEG(3,ISTSG).EQ.7) THEN
            ITRIB = 1
            FLOWIN = 0.0D0
            NINFLOW=0
            DO WHILE(ITRIB.LE.NSS)
              IF(ISTSG.EQ.IOTSG(ITRIB)) THEN
                TRBFLW = SGOTFLW(ITRIB)
                FLOWIN = FLOWIN + TRBFLW
                NINFLOW = NINFLOW+1
              END IF
              ITRIB = ITRIB + 1
            END DO
            FLOWIN = FLOWIN + SEG(2,ISTSG)
            NINFLOW = NINFLOW + 1
            IDISP = 1
          ENDIF
C
C22-----SET INFLOW EQUAL TO OUTFLOW FROM UPSTREAM REACH WHEN REACH
C         IS GREATER THAN 1.
        ELSE IF(NREACH.GT.1) THEN
          FLOWIN = STRM(9, LL)
          NINFLOW = 1
          IDISP = 1
          III=ISTRM(4, LL)
          JJJ=ISTRM(5, LL)
        END IF
C---------------------------------------------------------------
C
C-------NOTES ON INDICES
C     Istrm(4, L): SEGMENT NUMBER
C     Istrm(5, L): REACH NUMBER
C     Strm(1, L) : STRLEN (Set above)
C     Strm(9, L) : FLOW OUT OF REACH
C     Strm(10, L): FLOW INTO REACH
C     Strm(11, L): FLOW TO AQUIFER
C     Strm(12, L): SPECIFIED volumetric rate of overland runoff into stream reach
C     Strm(13, L): Volumetric rate of evapotranspiration from stream reach.
C     Strm(14, L): Volumetric rate of precipitation to stream reach.
C     Strm(31, L): Cross-sectional area
C
C-------WRITE TO FTL FILE
        IF(ILMTFMT.EQ.0) THEN
          WRITE(IUMT3D) IL, IR, IC, ISTRM(4,L), ISTRM(5, L),
     +                         STRLEN,STRM(31,L),
     +                         STRM(11,L), STRM(9,L),
     +                         STRM(12,L), STRM(14,L),
     +                         STRM(13,L), NINFLOW
        ELSEIF(ILMTFMT.EQ.1) THEN
          WRITE(IUMT3D,*) IL,IR,IC,ISTRM(4,L),ISTRM(5,L),
     +                         STRLEN,STRM(31,L),
     +                         STRM(11,L), STRM(9,L),
     +                         STRM(12,L), STRM(14,L),
     +                         STRM(13,L), NINFLOW
        ENDIF
C
C-------WRITE INFLOW SEGMENT, REACH, FLOW RATE, AND DISPERSION FLAG
        IF(NINFLOW.EQ.1) THEN
          IF(ILMTFMT.EQ.0) THEN
            WRITE(IUMT3D) III,JJJ,FLOWIN,IDISP
          ELSEIF(ILMTFMT.EQ.1) THEN
            WRITE(IUMT3D,*) III,JJJ,FLOWIN,IDISP
          ENDIF
        ELSEIF(NINFLOW.GT.1) THEN
          IDISP=1
          IF(NREACH.EQ.1) THEN
            IF(ISTSG.GE.1.AND.ISEG(3,ISTSG).EQ.7) THEN
              ITRIB = 1
              FLOWIN = 0.0D0
              DO WHILE(ITRIB.LE.NSS)
                IF(ISTSG.EQ.IOTSG(ITRIB) ) THEN
                  TRBFLW = SGOTFLW(ITRIB)
                  FLOWIN = TRBFLW
                  III=ITRIB
                  JJJ=LASTRCH(III)
                  IF(ILMTFMT.EQ.0) THEN
                    WRITE(IUMT3D) III,JJJ,FLOWIN,IDISP
                  ELSEIF(ILMTFMT.EQ.1) THEN
                    WRITE(IUMT3D,*) III,JJJ,FLOWIN,IDISP
                  ENDIF
                END IF
                ITRIB = ITRIB + 1
              END DO
              FLOWIN = SEG(2, ISTSG)
              IDISP = 0
              III = -ISTSG
              JJJ = -NREACH
              IF(ILMTFMT.EQ.0) THEN
                WRITE(IUMT3D) III,JJJ,FLOWIN,IDISP
              ELSEIF(ILMTFMT.EQ.1) THEN
                WRITE(IUMT3D,*) III,JJJ,FLOWIN,IDISP
              ENDIF
            ENDIF
          ENDIF
        ENDIF
C
      ENDDO
C
      RETURN
      END
C
C
      SUBROUTINE LMT7LAK3(ILMTFMT,IUMT3D,KSTP,KPER,IGRID)
C ******************************************************************
C SAVE SFR2 CELL LOCATIONS AND VOLUMETRIC FLOW RATES FOR USE BY MT3D
C ******************************************************************
C DATE CREATED: 7-25-2013
      USE GLOBAL,       ONLY:NCOL,NROW,NLAY,IOUT
      USE GWFLAKMODULE, ONLY:VOL,NLAKES,LKNODE,ILAKE,MXLKND,VOLOLD,
     &                       PRECIP,EVAP,RUNF,RUNOFF,WITHDRW,FLOB,
     &                       NSFRLAK,LAKSFR,ILKSEG,ILKRCH,SWLAK,
     &                       DELVOLLAK
      CHARACTER*16 TEXT
      INTEGER NN,L,IL,IR,IC,LAKE
      REAL    Q
C
      TEXT='LAK'
C
C--WRITE AN IDENTIFYING HEADER
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT,NLAKES,LKNODE,
     &                NSFRLAK
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT,NLAKES,LKNODE,NSFRLAK
      ENDIF      
C
C-----WRITE LAKE SPECIFIC TERMS
      DO NN=1,NLAKES
        IF(ILMTFMT.EQ.0) THEN
C---------!-222 STANDIN FOR VIVEK'S DELVOLLAK?
          WRITE(IUMT3D) NN,VOLOLD(NN),DELVOLLAK(NN),PRECIP(NN),  
     1                EVAP(NN),RUNF(NN),WITHDRW(NN)  !RUNOFF
        ELSEIF(ILMTFMT.EQ.1) THEN
          WRITE(IUMT3D,*) NN,VOLOLD(NN),DELVOLLAK(NN),PRECIP(NN),
     1                  EVAP(NN),RUNF(NN),WITHDRW(NN)  !Removed RUNOFF
        ENDIF        
      ENDDO
C
C-----WRITE EXCHANGE TERMS WITH GW. LKNODE=# OF LAK-AQIF INTERFACES
      DO L=1,LKNODE
        IL=ILAKE(1,L)
        IR=ILAKE(2,L)
        IC=ILAKE(3,L)
        LAKE=ILAKE(4,L)
        Q=FLOB(L)
        IF(ILMTFMT.EQ.0) THEN
          WRITE(IUMT3D) LAKE,IL,IR,IC,Q
        ELSEIF(ILMTFMT.EQ.1) THEN
          WRITE(IUMT3D,*) LAKE,IL,IR,IC,Q
        ENDIF        
      ENDDO
C
C-----WRITE EXCHANGE TERMS WITH SFR
      DO I=1,NSFRLAK
        IF(ILMTFMT.EQ.0) THEN
          WRITE(IUMT3D) LAKSFR(I),ILKSEG(I),ILKRCH(I),SWLAK(I)
        ELSEIF(ILMTFMT.EQ.1) THEN
          WRITE(IUMT3D,*) LAKSFR(I),ILKSEG(I),ILKRCH(I),SWLAK(I)
        ENDIF        
      ENDDO
C
      RETURN
      END
C
C
C***********************************************************************
      SUBROUTINE SLMT7PNT(IGRID)
C     ******************************************************************
C     CHANGE POINTERS FOR LMT DATA TO A DIFFERENT GRID
C     ******************************************************************
C
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
      USE LMTMODULE
C     ------------------------------------------------------------------
C
      ISSMT3D=>LMTDAT(IGRID)%ISSMT3D
      IUMT3D=>LMTDAT(IGRID)%IUMT3D
      ILMTFMT=>LMTDAT(IGRID)%ILMTFMT
      RETURN
      END
C***********************************************************************
      SUBROUTINE SLMT7PSV(IGRID)
C     ******************************************************************
C     SAVE POINTERS ARRAYS FOR LMT DATA TO APPROPRIATE GRID
C     ******************************************************************
C
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
      USE LMTMODULE
C     ------------------------------------------------------------------
C
      LMTDAT(IGRID)%ISSMT3D=>ISSMT3D
      LMTDAT(IGRID)%IUMT3D=>IUMT3D
      LMTDAT(IGRID)%ILMTFMT=>ILMTFMT
C
      RETURN
      END
C***********************************************************************
      SUBROUTINE LMT7DA(IGRID)
C     ******************************************************************
C     DEALLOCATE LMT DATA
C     ******************************************************************
C
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
      USE LMTMODULE
C     ------------------------------------------------------------------
C
      DEALLOCATE(LMTDAT(IGRID)%ISSMT3D)
      DEALLOCATE(LMTDAT(IGRID)%IUMT3D)
      DEALLOCATE(LMTDAT(IGRID)%ILMTFMT)
      DEALLOCATE(IUZFLAKCONNECT)
      DEALLOCATE(IUZFSFRCONNECT)
      DEALLOCATE(ISFRLAKCONNECT)
      DEALLOCATE(NPCKGTXT)
      DEALLOCATE(IUZFFLOWS)
      DEALLOCATE(ISFRFLOWS)
      DEALLOCATE(ILAKFLOWS)
C
      RETURN
      END