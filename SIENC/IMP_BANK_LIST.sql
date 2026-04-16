--DELETE TMP_TEMP;
DECLARE L_TSI_BANK_CODE_LIST NUMBER;
P_CRT_BY VARCHAR2(100):='vng-237';
BEGIN
    FOR CUR_DATA IN
    (
        SELECT DISTINCT PK, C1 BANK_CODE, C2 BANK_NAME, C3 REGION_NAME, C4 SHORT_NAME
		FROM TMP_TEMP WHERE PK >0
		AND NVL(C11,'NOT_YET') <>  'IMP'
        ORDER BY C1 ASC
    )
    LOOP 
        SELECT TSI_BANK_CODE_LIST_SEQ.NEXTVAL INTO L_TSI_BANK_CODE_LIST FROM DUAL;


        INSERT INTO TSI_BANK_CODE_LIST ( PK, BANK_CODE, BANK_NAME, SHORT_NAME, REGION_NAME, 
                                        FBANK_NAME, SHORT_FBANK_NAME, DEL_IF, CRT_BY, CRT_DT
                                
                             )
        VALUES(     L_TSI_BANK_CODE_LIST,
                   CUR_DATA.BANK_CODE,
                   CUR_DATA.BANK_NAME,
                   CUR_DATA.SHORT_NAME,
                   CUR_DATA.REGION_NAME,
                   CUR_DATA.BANK_NAME,
                   CUR_DATA.SHORT_NAME,
                   0,
                   P_CRT_BY,
                   SYSDATE
            );
        
         UPDATE TMP_TEMP SET C11 = 'IMP'
            WHERE PK = CUR_DATA.PK;   
    END LOOP;
        
END;      