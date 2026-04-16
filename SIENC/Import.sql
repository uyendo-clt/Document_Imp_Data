begin
    for cur in (select * from TAC_GFFA_MST where del_if = 0)
    loop
        update TAC_GFFA_MST
        set FA_USE_DATE = cur.FA_DEPR_DATE
        where pk = cur.pk;
    end loop;
end;


begin
    for cur in (select A.PK, A.FA_CD, A.FA_DEPR_DATE, TMP.C2,  TMP.C3 , DEL_IF
                from TAC_GFFA_MST A, TMP_TMP1 TMP WHERE  A.FA_CD = TMP.C2 AND DEL_IF = 0)
    loop
        update TAC_GFFA_MST
        set FA_DEPR_DATE = cur.C3
        where pk = cur.pk;
    end loop;
end;

begin
    for cur in (select VOUCHER_NO, A.PK, TMP.C1, A.FA_CD, TMP.C2,  TMP.C3 , DEL_IF
                from TAC_GFFA_MST A, TMP_TMP2 TMP 
                WHERE  A.FA_CD = TMP.C2 AND NVL(C4, 'N') = 'N'
                AND A.DEL_IF = 0 
                AND TMP.C1 > 0 
                AND TMP.C2 is not null and TMP.C3 is not null 
                order by TMP.C2 asc)
    loop
        update TAC_GFFA_MST
        set VOUCHER_NO = cur.C3
        where pk = cur.pk;
        
        update TMP_TMP2
        set C4 = 'Y'
        where C1 = cur.C1;
    end loop;
end;
--DELETE TMP_TMP_U;

table tạm : TMP_TMP_U, TMP_TMP_U1

CREATE TABLE new_table AS
SELECT * FROM old_table;

BEGIN
    FOR CUR IN (
        SELECT A.PK, FA_BEGIN_DEPR_FAMT, FA_BEGIN_DEPR_AMT, A.FA_CD , U.C1, U.C2, U.C3, U.C4
        FROM TAC_GFFA_MST A, TMP_TMP_U U 
        WHERE U.C2 = A.FA_CD AND A.DEL_IF = 0 AND INSTRUMENT <> 'PE' ORDER BY A.PK ASC --395
    )
        LOOP
            UPDATE TMP_TMP_U1
            SET C6 = CUR.FA_BEGIN_DEPR_FAMT,
            C7 = CUR.FA_BEGIN_DEPR_AMT,
            C8 = CUR.PK
            WHERE C1 = CUR.C1 
            AND C2 = CUR.C2;
        END LOOP;
END;

SELECT C5
FROM TMP_TMP_U
WHERE NOT REGEXP_LIKE(C5, '^\s*\d+(\.\d+)?\s*$');

begin
    for cur in (select  A.PK, TMP.C1, A.FA_CD, TMP.C2, TMP.C3 AMT_VND,  TMP.C4 AMT_USD 
                from TAC_GFFA_MST A, TMP_TMP_U TMP 
                WHERE  A.FA_CD = TMP.C2 AND NVL(C5, 'N') = 'N'
                AND A.DEL_IF = 0 
                AND TMP.C1 > 0 
                order by TMP.C2 asc)
    loop
        update TAC_GFFA_MST
        set BEGIN_ACC_DEPR_AMT = cur.AMT_VND,
        BEGIN_ACC_DEPR_FAMT  = cur.AMT_USD
        where pk = cur.pk;
        
        update TMP_TMP_U
        set C5 = 'Y'
        where C1 = cur.C1;
    end loop;
end;