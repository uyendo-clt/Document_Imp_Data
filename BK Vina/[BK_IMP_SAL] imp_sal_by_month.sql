--DELETE TMP_TEMP_ACNT;
DECLARE 
L_USER_ID VARCHAR2(100):='vng-237';
P_CRT_BY VARCHAR2(100):=L_USER_ID;
BEGIN
    FOR CUR_HGTRH IN
    (
        SELECT DISTINCT C1 TAC_HGTRH_PK, C2 VOUCHERNO, C3 TRANS_DT, SUM(C12) OVER(PARTITION BY C1) AMT 
		FROM TMP_TEMP_ACNT WHERE PK >0
		AND NVL(C18,'NOT_YET') <>  'IMP'
		AND C1 = '297817'
        ORDER BY C1 ASC
    )
    LOOP 
                
        
        IF CUR_HGTRH.TAC_HGTRH_PK IS NOT NULL THEN 
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
                SELECT  PK, C1 TAC_HGTRH_PK,C2 VOUCHER_NO, C3 TR_DATE, C4 TRANS_CD, C5 REMARK, C6 RAMARK2, 
                ( SELECT PK TCO_BUSPARTNER_PK FROM TCO_BUSPARTNER A WHERE A.DEL_IF = 0 AND TRIM(UPPER(A.PARTNER_NAME)) = TRIM(UPPER('BUMKOO INDUSTRIAL CO.,LTD'))) AS TCO_BUSPARTNER_PK,
                ( SELECT PARTNER_ID FROM TCO_BUSPARTNER A WHERE A.DEL_IF = 0 AND TRIM(UPPER(A.PARTNER_NAME)) = TRIM(UPPER('BUMKOO INDUSTRIAL CO.,LTD'))) AS PARTNER_ID,
                ( SELECT PARTNER_NAME FROM TCO_BUSPARTNER A WHERE A.DEL_IF = 0 AND TRIM(UPPER(A.PARTNER_NAME)) = TRIM(UPPER('BUMKOO INDUSTRIAL CO.,LTD'))) AS PARTNER_NAME,
                C8 AC_CD_DR, C9  AC_CD_CR, C11 TR_AMT, C12 TR_BOOKAMT, C14 PL_CD, C15 PL_NM, C16 TYPE_REF
                FROM TMP_TEMP_ACNT
                WHERE C1 = CUR_HGTRH.TAC_HGTRH_PK
                ORDER BY 1) A
            )
            LOOP  
                    
                        INSERT INTO TAC_HGTRD (PK,TAC_HGTRH_PK,TAC_ABACCTCODE_PK,DRCR_TYPE,DRCR_ORD,CCY,
                        TR_AMT,TR_RATE,BK_RATE,TR_BOOKAMT,remark,REMARK2,EXPENSE_TYPE,
                        DEL_IF,CRT_BY,CRT_DT,TYPE_REF,TYPE_REF2, TAC_ABPLCENTER_PK)
                        VALUES ( TAC_HGTRD_SEQ.NEXTVAL,
                               CUR_HGTRH.TAC_HGTRH_PK,
                               CUR_HGTRD.TAC_ABACCTCODE_PK_DR,
                               'D',
                               CUR_HGTRD.P_DRCR_ORD,
                               'VND',
                               CUR_HGTRD.TR_AMT,
                               1,
                               1,
                               CUR_HGTRD.TR_BOOKAMT,
                               CUR_HGTRD.REMARK,
                               CUR_HGTRD.RAMARK2,
                               'Y',
                               0,
                               P_CRT_BY,
                               SYSDATE,
                               CUR_HGTRD.TYPE_REF,
                               1,
                               CUR_HGTRD.TAC_ABPLCENTER_PK);
               
             
                UPDATE TMP_TEMP_ACNT SET C18 = 'IMP'
                WHERE PK = CUR_HGTRD.PK;
            END LOOP;
            
            FOR CUR_HGTRD1 IN
            (
                SELECT A.*, ROWNUM P_DRCR_ORD,(SELECT Z.PK TAC_ABACCTCODE_PK_DR FROM TAC_ABACCTCODE Z WHERE Z.DEL_IF = 0 AND Z.AC_CD = A.AC_CD_CR) TAC_ABACCTCODE_PK_CR 
                FROM(
                SELECT  (C9)  AC_CD_CR, SUM(C11) TR_AMT , SUM(C12) TR_BOOKAMT , MAX(C5) REMARK , MAX(C6) RAMARK2, MAX(C16) TYPE_REF
                FROM TMP_TEMP_ACNT 
                WHERE C1 = CUR_HGTRH.TAC_HGTRH_PK
                GROUP BY C9) A
            )
            LOOP  
                    
                        INSERT INTO TAC_HGTRD (PK,TAC_HGTRH_PK,TAC_ABACCTCODE_PK,DRCR_TYPE,DRCR_ORD,CCY,
                        TR_AMT,TR_RATE,BK_RATE,TR_BOOKAMT,remark,REMARK2,EXPENSE_TYPE,
                        DEL_IF,CRT_BY,CRT_DT,TYPE_REF,TYPE_REF2)
                        VALUES ( TAC_HGTRD_SEQ.NEXTVAL,
                               CUR_HGTRH.TAC_HGTRH_PK,
                               CUR_HGTRD1.TAC_ABACCTCODE_PK_CR,
                               'C',
                               CUR_HGTRD1.P_DRCR_ORD,
                               'VND',
                               CUR_HGTRD1.TR_AMT,
                               1,
                               1,
                               CUR_HGTRD1.TR_BOOKAMT,
                               CUR_HGTRD1.REMARK,
                               CUR_HGTRD1.RAMARK2,
                               'Y',
                               0,
                               P_CRT_BY,
                               SYSDATE,
                               CUR_HGTRD1.TYPE_REF,
                               1);
               
              
            END LOOP;
        END IF;
        UPDATE TAC_HGTRH 
        SET TOT_AMT = CUR_HGTRH.AMT
        WHERE PK = CUR_HGTRH.TAC_HGTRH_PK AND DEL_IF = 0;
    END LOOP;
        
END;      