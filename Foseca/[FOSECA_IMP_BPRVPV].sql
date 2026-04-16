DECLARE L_TAC_BPRVPV_PK NUMBER;
L_THR_EMPLOYEE_PK NUMBER;
L_TCO_ORG_PK NUMBER;
L_TCO_BSUSER_PK NUMBER;
L_DATE VARCHAR2(8); 
L_USER_ID VARCHAR2(100):='vng-154';
P_CRT_BY VARCHAR2(100):=L_USER_ID ||TO_CHAR(SYSDATE,'YYYYMMDD');
L_SUM_AMT NUMBER:=0;
V_CUST_PK_DR NUMBER;
V_CUST_NM_DR VARCHAR2(1000);
V_CUST_PK_CR NUMBER;
V_CUST_NM_CR VARCHAR2(1000);
V_DETAIL_DR_PK NUMBER;
V_DETAIL_CR_PK NUMBER;
BEGIN
    FOR CUR_BPRVPV IN
    (
        SELECT PK, TO_CHAR(TO_DATE(C2,'mm/dd/yyyy'),'yyyymmdd') AS  TR_DATE, C3 VOUCHERNO, 
                (SELECT Z.PK TAC_ABACCTCODE_PK_DR FROM TAC_ABACCTCODE Z WHERE Z.DEL_IF = 0 AND Z.AC_CD = C4) TAC_ABACCTCODE_PK_DR,
                (SELECT Z.PK TAC_ABACCTCODE_PK_DR FROM TAC_ABACCTCODE Z WHERE Z.DEL_IF = 0 AND Z.AC_CD = C5) TAC_ABACCTCODE_PK_CR,
                C6 CCY_DR,  C7 CCY_CR, C8 TR_RATE_DR, C9 TR_RATE_CR, C10 TR_AMT, C11 BOOK_AMT,
                C12 REMARK,C13 REMARK2,
                ( SELECT PK TCO_BUSPARTNER_PK FROM TCO_BUSPARTNER A WHERE A.DEL_IF = 0 AND TRIM(UPPER(A.PARTNER_ID)) = TRIM(UPPER(C16))
				) AS TCO_BUSPARTNER_PK,
				C16 CUST_ID,
				C17 PARTNER_LNAME,
                (SELECT A.PK EXPENSE_PK FROM TAC_ABITEMCODE A WHERE A.DEL_IF = 0 AND A.ITEMCODE = C29 AND ITEMCODE_NM = C30) EXPENSE_PK,
				C29 EXPENSE_TYPE,
				C30 EXPENSE_NAME,
                (SELECT B.PK TAC_ABDEPOMT_PK FROM TAC_ABDEPOMT B WHERE B.DEL_IF = 0 AND B.BANK_ID = C32) TAC_ABDEPOMT_PK,
				C31 DEPOSIT_ACCOUNT_NO,
				C32 DEPOSIT_ACCOUNT_NM,
 				(SELECT A.PK FROM TAC_ABTRTYPE A WHERE A.DEL_IF = 0 AND A.TR_TYPE = 'Y001') TAC_ABTRTYPE_PK,
 				C11 TOTAL
		FROM TMP_TEMP 
		WHERE  NVL(C33,'NOT_YET') <>  'IMP'
		AND PK = 2
        ORDER BY PK ASC
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
                
        SELECT TAC_BPRVPV_SEQ.NEXTVAL INTO L_TAC_BPRVPV_PK FROM DUAL;


         INSERT INTO TAC_BPRVPV(
             PK                     ,TCO_COMPANY_PK             ,VOUCHER_TYPE               ,TR_SEQ                 ,AUTO_YN        
            ,VOUCHERNO              ,TR_DATE                    ,TCO_org_PK                ,TCO_BSUSER_PK          ,TR_TYPE
            ,TR_REASON              ,TR_PERSON                  ,TCO_BUSPARTNER_PK          ,BUSPARTNER_LNM         ,REMARK 
            ,REMARK2                ,CLOSE_YN                   ,TR_STATUS                  ,TR_ENCLOSE,            DEL_IF 
            ,CRT_BY                 ,CRT_DT, TAC_EMPLOYEE_ADV_PK, TAC_ABTRTYPE_PK, REMARK3, TOTAL, WEBCASH_REMARK)
        VALUES(
             L_TAC_BPRVPV_PK       ,999                        ,'BN'                           ,NULL                        ,DECODE('F', 'T', 'Y', 'N')
            ,CUR_BPRVPV.VOUCHERNO   ,CUR_BPRVPV.TR_DATE         ,L_TCO_ORG_PK                   ,L_TCO_BSUSER_PK            ,1
            ,''                     ,''                        ,CUR_BPRVPV.TCO_BUSPARTNER_PK    ,CUR_BPRVPV.PARTNER_LNAME   ,CUR_BPRVPV.REMARK
            ,CUR_BPRVPV.REMARK2    ,'N'                        ,'1'                             ,''                         , 0
            ,P_CRT_BY               ,SYSDATE                   ,L_THR_EMPLOYEE_PK               , CUR_BPRVPV.TAC_ABTRTYPE_PK, '',  CUR_BPRVPV.TOTAL, 'ERP_267007');

        IF L_TAC_BPRVPV_PK IS NOT NULL THEN 
                    -----------------INSERT DEBIT ACCOUNT--------------
                        SELECT DECODE(T.CUST_YN, 'Y', CUR_BPRVPV.TCO_BUSPARTNER_PK,''),  DECODE(T.CUST_YN, 'Y', CUR_BPRVPV.PARTNER_LNAME, '')
                           INTO V_CUST_PK_DR, V_CUST_NM_DR
                           FROM TAC_ABACCTCODE T
                            WHERE T.PK  = CUR_BPRVPV.TAC_ABACCTCODE_PK_DR
                            AND T.DEL_IF  = 0;  
                            
                       SELECT TAC_BPRVPVD_SEQ.NEXTVAL INTO V_DETAIL_DR_PK FROM DUAL;      
                       
                      INSERT INTO TAC_BPRVPVD (PK, TAC_ABACCTCODE_PK, TYPE_REF, DRCR_TYPE, CCY,
                                           TR_RATE, BK_RATE, TRANS_AMT,BOOKS_AMT,TAX_RATE,
                                           VAT_FAMT,VAT_AMT, VAT_DEDUCT_FAMT,VAT_DEDUCT_AMT,remark,
                                           REMARK2,TAC_BPRVPV_PK,CRT_BY,CRT_DT,DEL_IF, DRCR_ORD,REMARK3, TOTAL_TRANS_AMT,TOTAL_BOOKS_AMT, TCO_BUSPARTNER_PK, BUSPARTNER_LNM)
                                           
                       VALUES (V_DETAIL_DR_PK, CUR_BPRVPV.TAC_ABACCTCODE_PK_DR, 1, 'D', CUR_BPRVPV.CCY_DR,
                               CUR_BPRVPV.TR_RATE_DR,CUR_BPRVPV.TR_RATE_DR, CUR_BPRVPV.TR_AMT, CUR_BPRVPV.BOOK_AMT, NULL,
                               NULL, NULL, NULL, NULL,CUR_BPRVPV.REMARK,
                               CUR_BPRVPV.REMARK2,L_TAC_BPRVPV_PK,P_CRT_BY, SYSDATE,0, '1', '',CUR_BPRVPV.TR_AMT, CUR_BPRVPV.BOOK_AMT, V_CUST_PK_DR, V_CUST_NM_DR);
                         
                    -----------------INSERT DEBIT CONTROL  ITEM--------------      
                          FOR CUR IN (
                                SELECT A.PK, A.TAC_ABITEM_PK, A.TAC_ABACCTCODE_PK, A.TAC_ABITEM_ALIAS
                                FROM TAC_ABACCTITEM A
                                WHERE A.TAC_ABACCTCODE_PK IN (CUR_BPRVPV.TAC_ABACCTCODE_PK_DR)
                                AND A.DEL_IF = 0
                            )
                            LOOP
                                IF CUR.TAC_ABITEM_ALIAS = 'DEPOSIT ACCOUNT NO' THEN  
                                        INSERT INTO TAC_BPRVPVDITEM (PK, TAC_BPRVPVD_PK, TAC_ABACCTITEM_PK,ITEM, ITEM_NM, ITEM_TABLE_PK,TABLE_NM,CRT_BY,CRT_DT)
                                        VALUES (TAC_BPRVPVDITEM_SEQ.NEXTVAL, V_DETAIL_DR_PK, CUR.PK,CUR_BPRVPV.DEPOSIT_ACCOUNT_NM, CUR_BPRVPV.DEPOSIT_ACCOUNT_NM, CUR_BPRVPV.TAC_ABDEPOMT_PK, 'TAC_ABDEPOMT', P_CRT_BY,SYSDATE); 
                                ELSIF  CUR.TAC_ABITEM_ALIAS = 'BENEFICIARY BANK' THEN  
                                        INSERT INTO TAC_BPRVPVDITEM (PK, TAC_BPRVPVD_PK, TAC_ABACCTITEM_PK,ITEM, ITEM_NM, ITEM_TABLE_PK,TABLE_NM,CRT_BY,CRT_DT)
                                        VALUES (TAC_BPRVPVDITEM_SEQ.NEXTVAL, V_DETAIL_DR_PK, CUR.PK, '', '', CUR_BPRVPV.TAC_ABDEPOMT_PK, '', P_CRT_BY, SYSDATE); 
                                ELSIF CUR.TAC_ABITEM_ALIAS = 'EXPENSE TYPE' THEN  
                                        INSERT INTO TAC_BPRVPVDITEM (PK, TAC_BPRVPVD_PK, TAC_ABACCTITEM_PK,ITEM, ITEM_NM, ITEM_TABLE_PK,TABLE_NM,CRT_BY,CRT_DT)
                                        VALUES (TAC_BPRVPVDITEM_SEQ.NEXTVAL, V_DETAIL_DR_PK, CUR.PK,CUR_BPRVPV.EXPENSE_TYPE, CUR_BPRVPV.EXPENSE_NAME, CUR_BPRVPV.EXPENSE_PK, 'TAC_ABITEMCODE', P_CRT_BY,SYSDATE); 
                                ELSIF CUR.TAC_ABITEM_ALIAS = 'CUSTOMER NAME' THEN  
                                        INSERT INTO TAC_BPRVPVDITEM (PK, TAC_BPRVPVD_PK, TAC_ABACCTITEM_PK,ITEM, ITEM_NM, ITEM_TABLE_PK,TABLE_NM,CRT_BY,CRT_DT)
                                        VALUES (TAC_BPRVPVDITEM_SEQ.NEXTVAL, V_DETAIL_DR_PK, CUR.PK,CUR_BPRVPV.CUST_ID, CUR_BPRVPV.PARTNER_LNAME, NULL, '', P_CRT_BY,SYSDATE); 
                                ELSE
                                    IF CUR.PK > 0 THEN
                                        INSERT INTO TAC_BPRVPVDITEM (PK, TAC_BPRVPVD_PK, TAC_ABACCTITEM_PK,ITEM, ITEM_NM, ITEM_TABLE_PK,TABLE_NM,CRT_BY,CRT_DT)
                                        VALUES (TAC_BPRVPVDITEM_SEQ.NEXTVAL, V_DETAIL_DR_PK, CUR.PK,'','', NULL, '', P_CRT_BY,SYSDATE);        
                                    END IF;    
                                END IF;
                                
                                                                           
                            END LOOP;        
                    -----------------INSERT CREDIT ACCOUNT--------------
                        
                        SELECT DECODE(T.CUST_YN, 'Y', CUR_BPRVPV.TCO_BUSPARTNER_PK,''),  DECODE(T.CUST_YN, 'Y', CUR_BPRVPV.PARTNER_LNAME, '')
                           INTO V_CUST_PK_CR, V_CUST_NM_CR
                           FROM TAC_ABACCTCODE T
                            WHERE T.PK  = CUR_BPRVPV.TAC_ABACCTCODE_PK_CR
                            AND T.DEL_IF  = 0; 
                        
                       SELECT TAC_BPRVPVD_SEQ.NEXTVAL INTO V_DETAIL_CR_PK FROM DUAL;   
                           
                      INSERT INTO TAC_BPRVPVD (PK, TAC_ABACCTCODE_PK, TYPE_REF, DRCR_TYPE, CCY,
                                           TR_RATE, BK_RATE, TRANS_AMT,BOOKS_AMT,TAX_RATE,
                                           VAT_FAMT,VAT_AMT, VAT_DEDUCT_FAMT,VAT_DEDUCT_AMT,remark,
                                           REMARK2,TAC_BPRVPV_PK,CRT_BY,CRT_DT,DEL_IF, DRCR_ORD,REMARK3, TOTAL_TRANS_AMT,TOTAL_BOOKS_AMT, TCO_BUSPARTNER_PK, BUSPARTNER_LNM)
                                           
                       VALUES (V_DETAIL_CR_PK, CUR_BPRVPV.TAC_ABACCTCODE_PK_CR, 1, 'C', CUR_BPRVPV.CCY_CR,
                               CUR_BPRVPV.TR_RATE_CR, CUR_BPRVPV.TR_RATE_CR, CUR_BPRVPV.TR_AMT, CUR_BPRVPV.BOOK_AMT, NULL,
                               NULL, NULL, NULL, NULL,CUR_BPRVPV.REMARK,
                               CUR_BPRVPV.REMARK2,L_TAC_BPRVPV_PK,P_CRT_BY, SYSDATE,0, '1', '',CUR_BPRVPV.TR_AMT, CUR_BPRVPV.BOOK_AMT, V_CUST_PK_CR, V_CUST_NM_CR);
                               
                        FOR CUR IN (
                                SELECT A.PK, A.TAC_ABITEM_PK, A.TAC_ABACCTCODE_PK, A.TAC_ABITEM_ALIAS
                                FROM TAC_ABACCTITEM A
                                WHERE A.TAC_ABACCTCODE_PK IN (CUR_BPRVPV.TAC_ABACCTCODE_PK_CR)
                                AND A.DEL_IF = 0
                            )
                            LOOP
                                IF CUR.TAC_ABITEM_ALIAS = 'DEPOSIT ACCOUNT NO' THEN  
                                        INSERT INTO TAC_BPRVPVDITEM (PK, TAC_BPRVPVD_PK, TAC_ABACCTITEM_PK,ITEM, ITEM_NM, ITEM_TABLE_PK,TABLE_NM,CRT_BY,CRT_DT)
                                        VALUES (TAC_BPRVPVDITEM_SEQ.NEXTVAL, V_DETAIL_CR_PK, CUR.PK, CUR_BPRVPV.DEPOSIT_ACCOUNT_NM, CUR_BPRVPV.DEPOSIT_ACCOUNT_NM, CUR_BPRVPV.TAC_ABDEPOMT_PK, 'TAC_ABDEPOMT', P_CRT_BY,SYSDATE); 
                                ELSIF  CUR.TAC_ABITEM_ALIAS = 'BENEFICIARY BANK' THEN  
                                        INSERT INTO TAC_BPRVPVDITEM (PK, TAC_BPRVPVD_PK, TAC_ABACCTITEM_PK,ITEM, ITEM_NM, ITEM_TABLE_PK,TABLE_NM,CRT_BY,CRT_DT)
                                        VALUES (TAC_BPRVPVDITEM_SEQ.NEXTVAL, V_DETAIL_CR_PK, CUR.PK, '', '', CUR_BPRVPV.TAC_ABDEPOMT_PK, '', P_CRT_BY, SYSDATE); 
                                ELSIF CUR.TAC_ABITEM_ALIAS = 'EXPENSE TYPE' THEN  
                                        INSERT INTO TAC_BPRVPVDITEM (PK, TAC_BPRVPVD_PK, TAC_ABACCTITEM_PK,ITEM, ITEM_NM, ITEM_TABLE_PK,TABLE_NM,CRT_BY,CRT_DT)
                                        VALUES (TAC_BPRVPVDITEM_SEQ.NEXTVAL, V_DETAIL_CR_PK, CUR.PK,CUR_BPRVPV.EXPENSE_TYPE, CUR_BPRVPV.EXPENSE_NAME, CUR_BPRVPV.EXPENSE_PK, 'TAC_ABITEMCODE', P_CRT_BY,SYSDATE); 
                                ELSIF CUR.TAC_ABITEM_ALIAS = 'CUSTOMER NAME' THEN  
                                        INSERT INTO TAC_BPRVPVDITEM (PK, TAC_BPRVPVD_PK, TAC_ABACCTITEM_PK,ITEM, ITEM_NM, ITEM_TABLE_PK,TABLE_NM,CRT_BY,CRT_DT)
                                        VALUES (TAC_BPRVPVDITEM_SEQ.NEXTVAL, V_DETAIL_CR_PK, CUR.PK,CUR_BPRVPV.CUST_ID, CUR_BPRVPV.PARTNER_LNAME, NULL, '', P_CRT_BY,SYSDATE); 
                                ELSE
                                    IF CUR.PK > 0 THEN
                                        INSERT INTO TAC_BPRVPVDITEM (PK, TAC_BPRVPVD_PK, TAC_ABACCTITEM_PK,ITEM, ITEM_NM, ITEM_TABLE_PK,TABLE_NM,CRT_BY,CRT_DT)
                                        VALUES (TAC_BPRVPVDITEM_SEQ.NEXTVAL, V_DETAIL_CR_PK, CUR.PK, '', '', NULL, '', P_CRT_BY,SYSDATE);        
                                    END IF;    
                                END IF;
                                
                                                                           
                            END LOOP;    
                                       
            L_TAC_BPRVPV_PK:=NULL;
        END IF;
        
            UPDATE TMP_TEMP
            SET   C33 = 'IMP'
            WHERE PK = CUR_BPRVPV.PK;
    END LOOP;
        
END;      