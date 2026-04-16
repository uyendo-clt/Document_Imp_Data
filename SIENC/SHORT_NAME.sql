 SELECT  CASE   WHEN REGEXP_COUNT(CUR_DATA.BANK_NAME, '\([^)]*\)') >= 2 THEN 
                    REGEXP_SUBSTR(CUR_DATA.BANK_NAME, '\(([^)]*)\)', 1, 2, NULL, 1)
                WHEN REGEXP_COUNT(CUR_DATA.BANK_NAME, '\([^)]*\)') = 1 THEN 
                    REGEXP_SUBSTR(CUR_DATA.BANK_NAME, '\(([^)]*)\)', 1, 1, NULL, 1)
                ELSE 
                     NULL
              END AS SHORT_NAME