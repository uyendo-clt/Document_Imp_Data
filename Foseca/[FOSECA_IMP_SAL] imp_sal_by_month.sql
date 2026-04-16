--DELETE TMP_TEMP;
DECLARE L_TAC_HGTRH_PK NUMBER;
L_THR_EMPLOYEE_PK NUMBER;
L_TCO_ORG_PK NUMBER;
L_TCO_BSUSER_PK NUMBER;
L_DATE VARCHAR2(8); 
L_USER_ID VARCHAR2(100):='vng-154';
P_CRT_BY VARCHAR2(100):=L_USER_ID ||TO_CHAR(SYSDATE,'YYYYMMDD');
L_SUM_AMT NUMBER:=0;
BEGIN
    FOR CUR_HGTRH IN
    (
        SELECT DISTINCT  C1 VOUCHER_NO, C3 TRANS_CD,TO_CHAR(TO_DATE(C2,'mm/dd/yyyy'),'yyyymmdd') AS  TR_DATE, C4 RAMARK2,--, SUBSTR(C4,0,1) P_TYPE,
				(SELECT A.PK FROM TAC_ABTRTYPE A WHERE A.DEL_IF = 0 AND A.TR_TYPE = C3)P_TRANS_PK ,
				( 
					SELECT PK TCO_BUSPARTNER_PK 
					FROM TCO_BUSPARTNER A 
					WHERE A.DEL_IF = 0 
					AND TRIM(UPPER(A.PARTNER_ID)) = TRIM(UPPER(NVL(C5,DECODE(SUBSTR(C1,0,2),'JV','PD-FOSS PREMIUM',DECODE(SUBSTR(C4,0,1),'B','BHXHTD', 'L','FOSECAVN','K', 'CONGDOAN')))))
				) AS TCO_BUSPARTNER_PK,
            SUM(C8) OVER(PARTITION BY C1) AMT
		FROM TMP_TEMP WHERE PK >0
		AND NVL(C11,'NOT_YET') <>  'IMP'
        ORDER BY C1 ASC
    )
    LOOP 
                SELECT THR_ABEMP_PK, PK 
                INTO L_THR_EMPLOYEE_PK, L_TCO_BSUSER_PK
                FROM GASP.TES_USER
                WHERE USER_ID = L_USER_ID;
                
                SELECT MAX (TCO_ORG_PK)
                INTO L_TCO_ORG_PK
                FROM THR_EMPLOYEE
                WHERE PK = L_THR_EMPLOYEE_PK;
        SELECT TAC_HGTRH_SEQ.NEXTVAL INTO L_TAC_HGTRH_PK FROM DUAL;


        INSERT INTO TAC_HGTRH ( PK,TCO_COMPANY_PK,VOUCHER_TYPE,VOUCHERNO,
                                TAC_ABTRTYPE_PK,TCO_ORG_PK,TR_FORM,TCO_BSUSER_PK,TR_PROC,REMARK,REMARK2,
                                TR_STATUS,TR_ENCLOSE,AUTO_YN,TR_DATE,TR_SEQ,TR_TABLENM,TR_TABLE_PK,
                                DEL_IF,CRT_BY,CRT_DT,REMARK3,TCO_BUSPARTNER_PK,TAC_EMPLOYEE_ADV_PK, TOT_TRAMT, TOT_AMT
                             )
        VALUES(     L_TAC_HGTRH_PK,
                   999,
                   'GJ',
                   CUR_HGTRH.VOUCHER_NO,
                   CUR_HGTRH.P_TRANS_PK,
                   L_TCO_ORG_PK,
                   'GFHG000001',
                   L_TCO_BSUSER_PK,
                   'COC10020',
                   CUR_HGTRH.RAMARK2,
                   CUR_HGTRH.RAMARK2,
                   '1',
                   '',
                   'N',
                   TO_DATE (CUR_HGTRH.TR_DATE, 'YYYYMMDD'),
                   '',
                   'TAC_HGTRH',
                   L_TAC_HGTRH_PK,
                   0,
                   P_CRT_BY,
                   SYSDATE,
                   '',
                   CUR_HGTRH.TCO_BUSPARTNER_PK,
                   L_THR_EMPLOYEE_PK, CUR_HGTRH.AMT, CUR_HGTRH.AMT
            );

        IF L_TAC_HGTRH_PK IS NOT NULL THEN 
            FOR CUR_HGTRD IN
            (
                SELECT A.*, ROWNUM P_DRCR_ORD,(SELECT Z.PK TAC_ABACCTCODE_PK_DR FROM TAC_ABACCTCODE Z WHERE Z.DEL_IF = 0 AND Z.AC_CD = A.AC_CD_DR) TAC_ABACCTCODE_PK_DR,
                        (SELECT MAX(G.PK) TAC_ABPLCENTER_PK 
                        FROM
                        TAC_ABPLCENTER G, TAC_ABPL Z
                        WHERE G.DEL_IF = 0
                        AND Z.DEL_IF = 0
                        AND G.TAC_ABPL_PK = Z.PK
                        AND Z.PL_CD = A.PL_CD)  TAC_ABPLCENTER_PK
                FROM(
                SELECT  PK, C1 VOUCHER_NO, C2 TR_DATE, C3 TRANS_CD, C4 RAMARK2, C5 PARTNER_NM, C6 AC_CD_DR, C7  AC_CD_CR, C8 AMT, C9 PL_CD, C10 PL_NM
                FROM TMP_TEMP
                WHERE C1 = CUR_HGTRH.VOUCHER_NO
                ORDER BY 1) A
            )
            LOOP  
                    
                        INSERT INTO TAC_HGTRD (PK,TAC_HGTRH_PK,TAC_ABACCTCODE_PK,DRCR_TYPE,DRCR_ORD,CCY,
                        TR_AMT,TR_RATE,BK_RATE,TR_BOOKAMT,remark,REMARK2,EXPENSE_TYPE,
                        DEL_IF,CRT_BY,CRT_DT,TYPE_REF,ACTUAL_RATE,TYPE_REF2,REMARK3, TAC_ABPLCENTER_PK)
                        VALUES ( TAC_HGTRD_SEQ.NEXTVAL,
                               L_TAC_HGTRH_PK,
                               CUR_HGTRD.TAC_ABACCTCODE_PK_DR,
                               'D',
                               CUR_HGTRD.P_DRCR_ORD,
                               'VND',
                               CUR_HGTRD.AMT,
                               1,
                               1,
                               CUR_HGTRD.AMT,
                               CUR_HGTRD.RAMARK2,
                               CUR_HGTRD.RAMARK2,
                               'Y',
                               0,
                               P_CRT_BY,
                               SYSDATE,
                               1,
                               1,
                               1,
                               '', CUR_HGTRD.TAC_ABPLCENTER_PK);
               
             
                UPDATE TMP_TEMP SET C11 = 'IMP'
                WHERE PK = CUR_HGTRD.PK;
            END LOOP;
            
             FOR CUR_HGTRD1 IN
            (
                SELECT A.*, ROWNUM P_DRCR_ORD,(SELECT Z.PK TAC_ABACCTCODE_PK_DR FROM TAC_ABACCTCODE Z WHERE Z.DEL_IF = 0 AND Z.AC_CD = A.AC_CD_CR) TAC_ABACCTCODE_PK_CR 
                FROM(
                SELECT  (C7)  AC_CD_CR, SUM(C8) AMT , MAX(C4) RAMARK2
                FROM TMP_TEMP 
                WHERE C1 = CUR_HGTRH.VOUCHER_NO
                GROUP BY C7) A
            )
            LOOP  
                    
                        INSERT INTO TAC_HGTRD (PK,TAC_HGTRH_PK,TAC_ABACCTCODE_PK,DRCR_TYPE,DRCR_ORD,CCY,
                        TR_AMT,TR_RATE,BK_RATE,TR_BOOKAMT,remark,REMARK2,EXPENSE_TYPE,
                        DEL_IF,CRT_BY,CRT_DT,TYPE_REF,ACTUAL_RATE,TYPE_REF2,REMARK3)
                        VALUES ( TAC_HGTRD_SEQ.NEXTVAL,
                               L_TAC_HGTRH_PK,
                               CUR_HGTRD1.TAC_ABACCTCODE_PK_CR,
                               'C',
                               CUR_HGTRD1.P_DRCR_ORD,
                               'VND',
                               CUR_HGTRD1.AMT,
                               1,
                               1,
                               CUR_HGTRD1.AMT,
                               CUR_HGTRD1.RAMARK2,
                               CUR_HGTRD1.RAMARK2,
                               'Y',
                               0,
                               P_CRT_BY,
                               SYSDATE,
                               1,
                               1,
                               1,
                               '');
               
              
            END LOOP;
            
--            SAL%001 334200 LUONG VN THÁNG  
--            SAL%002 338300 BHXH CÔNG TY ÐÓNG THÁNG  
--            SAL%003 338400 BHYT CÔNG TY ÐÓNG THÁNG  
--            SAL%004 338300 BHTNLD CÔNG TY ÐÓNG THÁNG  
--            SAL%005 338900 BHTN CÔNG TY ÐÓNG THÁNG 
--            SAL%006 338200 KPCD CÔNG TY ÐÓNG THÁNG  
            L_TAC_HGTRH_PK:=NULL;
            L_SUM_AMT:=0;
        END IF;
        
    END LOOP;
        
END;      
--
--SELECT *
--FROM TAC_HGTRh WHERE CRT_BY = '[VNG-154] 20221109';
--            SELECT A.*, ROWNUM P_DRCR_ORD,(SELECT Z.PK TAC_ABACCTCODE_PK_DR FROM TAC_ABACCTCODE Z WHERE Z.DEL_IF = 0 AND Z.AC_CD = A.AC_CD_DR) TAC_ABACCTCODE_PK_DR,
--                        (SELECT G.PK TAC_ABPLCENTER_PK 
--                        FROM
--                        TAC_ABPLCENTER G, TAC_ABPL Z
--                        WHERE G.DEL_IF = 0
--                        AND Z.DEL_IF = 0
--                        AND G.TAC_ABPL_PK = Z.PK
--                        AND Z.PL_CD = A.PL_CD)  TAC_ABPLCENTER_PK
--                FROM(
--                SELECT  PK, C1 VOUCHER_NO, C2 TR_DATE, C3 TRANS_CD, C4 RAMARK2, C5 PARTNER_NM, C6 AC_CD_DR, C7  AC_CD_CR, C8 AMT, C9 PL_CD, C10 PL_NM
--                FROM TMP_TEMP
--                WHERE C1 = 'SAL22_10001'
--                ORDER BY 1) A
--
--AC_UPD_60060010_DTL  
--AC_SEL_60050010_TRANSGROUP
--
--SELECT *
--FROM TAC_HGTRD 
--WHERE TAC_HGTRH_PK = 1200650
--
--SELECT PK TRANS_PK, 
--FROM TAC_ABTRTYPE A
--WHERE A.DEL_IF = 0
--AND A.TR_TYPE = 'G36';
--
--
--SELECT PK TCO_BUSPARTNER_PK, PARTNER_NAME
--FROM TCO_BUSPARTNER A
--WHERE A.DEL_IF = 0
--AND A.PARTNER_ID = 'FOSECAVN';
--
--SELECT PK TAC_ABACCTCODE_PK_DR
--FROM TAC_ABACCTCODE A
--WHERE A.DEL_IF = 0
--AND A.AC_CD = '622100';
--
--SELECT PK TAC_ABACCTCODE_PK_CR
--FROM TAC_ABACCTCODE A
--WHERE A.DEL_IF = 0
--AND A.AC_CD = '334200';
--
--
--SELECT A.PK TAC_ABPLCENTER_PK 
--FROM
--TAC_ABPLCENTER A, TAC_ABPL B
--WHERE A.DEL_IF = 0
--AND B.DEL_IF = 0
--AND A.TAC_ABPL_PK = B.PK
--AND B.PL_CD = 'FCT000125'
--
--
--1200650	SAL22_09001	20220930	G36	ACCOUNTING SLIP	                 7,998,520,799	LUONG VN THÁNG 09.2022	2	ACCHUONGNTM	
--1200544	SAL22_09002	20220930	G36	ACCOUNTING SLIP	                   779,637,501	BHXH CÔNG TY ÐÓNG THÁNG 09.2022	2	VNG-035	
--1208968	SAL22_09003	20220930	G36	ACCOUNTING SLIP	                   133,652,138	BHYT CÔNG TY ÐÓNG THÁNG 09.2022	2	ACCHUONGNTM	
--1200545	SAL22_09004	20220930	G36	ACCOUNTING SLIP	                    22,275,358	BHTNLD CÔNG TY ÐÓNG THÁNG 09.2022	2	VNG-035	
--1200547	SAL22_09005	20220930	G36	ACCOUNTING SLIP	                    89,101,438	KPCD CÔNG TY ÐÓNG THÁNG 09.2022	2	VNG-035	
--1209591	SAL22_09006	20220930	G36	ACCOUNTING SLIP	                    50,000,000	QUY?T TOÁN T?M ?NG LUONG THÁNG 09.2022	2	ACCHUONGNTM	
--
--;
-- SELECT    C1 VOUCHER_NO, C3 TRANS_CD, TO_DATE(C2,'DDMMYYYY') TR_DATE, C4 RAMARK2 FROM TMP_TEMP WHERE PK >0
--        ORDER BY C1 ASC;
--
--
--SELECT TO_DATE('20221031','YYYYMMDD')FROM DUAL

--
--SELECT ROWID, A.* 
--FROM TAC_HGTRH A
--WHERE DEL_IF = 0
--AND CRT_BY LIKE '[VNG-154]%'
--AND VOUCHERNO LIKE 'SAL23_%'
--AND TR_STATUS = 2