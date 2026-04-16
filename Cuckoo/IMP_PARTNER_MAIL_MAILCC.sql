DELETE TMP_CNV_06
-- begin
--    for cur in (
 
            select A.PK TCO_BUSPARTNER_PK, A.PARTNER_ID, EMAIL_ADDRESS, EMAIL_CC_ADDRESS, TMP.PK TMP_CNV_06_PK, TMP.C2,  TMP.C1,  TMP.C2,  TMP.C6 MAIL, TMP.C7 MAIL_CC, DEL_IF
                from TCO_BUSPARTNER A, TMP_CNV_06 TMP 
                WHERE  A.PARTNER_ID = TMP.C2 
                AND NVL(C9, 'N') = 'N'
                AND A.DEL_IF = 0 
                AND TMP.PK > 0 
                order by TMP.PK asc
--                )
--    loop
--        update TCO_BUSPARTNER
--        set EMAIL_ADDRESS = cur.MAIL,
--            EMAIL_CC_ADDRESS  = cur.MAIL_CC
--          WEBCASH_REMARK = '267007_upd_20260310'
--        where pk = cur.TCO_BUSPARTNER_PK;
--        
--        update TMP_CNV_06 
--        set C9 = 'Y'
--        where PK = cur.TMP_CNV_06_PK;
--    end loop;
--end;


select A.PARTNER_ID from (select ROW_NUMBER () OVER(PARTITION BY PARTNER_ID ORDER BY PARTNER_ID) SEQ_ROWNUM
                , A.PK TCO_BUSPARTNER_PK, A.PARTNER_ID, EMAIL_ADDRESS, EMAIL_CC_ADDRESS, WEBCASH_REMARK, TMP.PK TMP_CNV_06_PK, TMP.C2,  TMP.C1,  TMP.C2,  TMP.C6 MAIL, TMP.C7 MAIL_CC, DEL_IF
                from TCO_BUSPARTNER A, TMP_CNV_06 TMP 
                WHERE  A.PARTNER_ID = TMP.C2 
              -- AND NVL(C9, 'N') = 'N'
                AND A.DEL_IF = 0 
                AND TMP.PK > 0 ) A
                where A.SEQ_ROWNUM > 2;
				
 select count(*)
	from TCO_BUSPARTNER A
	WHERE A.DEL_IF = 0 
	AND WEBCASH_REMARK = '267007_upd_20260310';
	
	
select A.SEQ_ROWNUM, A.TCO_BUSPARTNER_PK, A.PARTNER_ID , WEBCASH_REMARK from (
select ROW_NUMBER () OVER(PARTITION BY PARTNER_ID ORDER BY PARTNER_ID) SEQ_ROWNUM
                , A.PK TCO_BUSPARTNER_PK, A.PARTNER_ID, EMAIL_ADDRESS, EMAIL_CC_ADDRESS, WEBCASH_REMARK, TMP.PK TMP_CNV_06_PK, TMP.C2,  TMP.C1,  TMP.C2,  TMP.C6 MAIL, TMP.C7 MAIL_CC, DEL_IF
                from TCO_BUSPARTNER A, TMP_CNV_06 TMP 
                WHERE  A.PARTNER_ID = TMP.C2 
              -- AND NVL(C9, 'N') = 'N'
                AND A.DEL_IF = 0 
                AND TMP.PK > 0
 ) A
                where A.SEQ_ROWNUM = 1; -- 25346	
				
SELECT TMP.TMP_PARTNER_ID, TMP.MAIL, TMP.MAIL_CC
FROM (
    SELECT DISTINCT C2 AS TMP_PARTNER_ID, C6 AS MAIL, C7 AS MAIL_CC
    FROM TMP_CNV_06
    WHERE pk > 0
) TMP
WHERE NOT EXISTS (
    SELECT 1
    FROM TCO_BUSPARTNER A
    WHERE A.PARTNER_ID = TMP.TMP_PARTNER_ID
      AND A.DEL_IF = 0
);				

  select * from ( select count(*) cnt_cust, TCO_BUSPARTNER_PK from (select A.PK TCO_BUSPARTNER_PK, A.PARTNER_ID, EMAIL_ADDRESS, EMAIL_CC_ADDRESS, WEBCASH_REMARK, TMP_PARTNER_ID, MAIL, MAIL_CC 
               from TCO_BUSPARTNER A, 
               ( select distinct C2 TMP_PARTNER_ID, C6 MAIL, C7 MAIL_CC  from TMP_CNV_06
                where pk > 0-- and NVL(C8, 'N') = 'N'
                ) TMP  
                WHERE  A.PARTNER_ID = TMP.TMP_PARTNER_ID  AND A.DEL_IF = 0 
                and PK IN (6542,
8965,
9220,
9929,
10100
)
                ORDER BY PK asc
                ) 
                group by TCO_BUSPARTNER_PK) where cnt_cust > 1;