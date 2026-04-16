begin
    for cur in (
               SELECT A.PK, 421 TLG_IN_WAREHOUSE_PK
                            , 150 ACC_WH_PK
                            , 5356 as TAC_ABACCTCODE_PK_VAT      
                            , 5312 as TAC_ABACCTCODE_PK_AR       
                            , case when A.TAC_ABACCTCODE_PK_REV = 5445 then  5444 else 5447 end TAC_ABACCTCODE_PK_REV
                            , 5402 as TAC_ABACCTCODE_PK_ADV  
                  FROM TLG_LG_TRANS_WH A,TLG_IN_WAREHOUSE B,TLG_IN_TRANS_CODE D
                        ,TAC_ABACCTCODE H,TAC_ABACCTCODE T,TLG_PB_WORK_PROCESS G,TLG_IN_WAREHOUSE F, TLG_IT_ITEMGRP P,
                        TAC_ABPL PL_C, TAC_ABPL PL_D
                  WHERE A.DEL_IF = 0 AND B.DEL_IF(+) = 0
                  AND A.TLG_IN_WAREHOUSE_PK = B.PK(+)
                  AND (B.TCO_BUSPLACE_PK = 135 or 135 is null)
                  AND D.DEL_IF = 0
                  AND H.DEL_IF(+) = 0 AND T.DEL_IF(+) = 0
                  AND A.D_TAC_ABACCTCODE_PK = H.PK(+)
                  AND A.C_TAC_ABACCTCODE_PK = T.PK(+)
                  AND PL_D.DEL_IF(+) = 0
                  AND A.D_TAC_ABPL_PK = PL_D.PK(+)
                  AND PL_C.DEL_IF(+) = 0
                  AND A.C_TAC_ABPL_PK = PL_C.PK(+)
                  AND G.DEL_IF(+) = 0
                  AND A.TLG_PB_WORK_PROCESS_PK = G.PK(+)
                  AND F.DEL_IF(+) = 0
                  AND A.REF_WAREHOUSE_PK = F.PK(+)
                  and b.tlg_in_storage_pk in (select h.pk from tlg_in_storage h where h.del_if=0 and h.tco_company_pk = 22134)
                  AND P.DEL_IF = 0
                  AND A.TLG_IT_ITEMGRP_PK = P.PK
                  AND NVL(A.TRIN_TYPE,A.TROUT_TYPE) = D.TRANS_CODE
                  AND DECODE('ALL','ALL','ALL',A.TLG_PB_LINE_PK) = 'ALL'
                  AND DECODE('I100','ALL','ALL',NVL(A.TRIN_TYPE,A.TROUT_TYPE)) = 'I100'
                  AND DECODE('ALL','ALL','ALL',D.TRANS_TYPE) = 'ALL'
                  AND DECODE('ALL','ALL','ALL',B.WH_TYPE) = 'ALL'
                  AND DECODE('ALL','ALL','ALL',B.PK) = 'ALL'
                  AND (A.TLG_IT_ITEMGRP_PK IN
                                  (    SELECT PK
                                         FROM TLG_IT_ITEMGRP
                                        WHERE DEL_IF = 0
                                   CONNECT BY PRIOR PK = P_PK
                                   START WITH P_PK = '')
                            OR A.TLG_IT_ITEMGRP_PK = ''
                            OR '' IS NULL)
                   AND A.FROM_MONTH <= NVL(202603,A.FROM_MONTH) AND NVL(A.TO_MONTH,202603) >= 202603
                   AND ('' IS NULL OR NVL(A.COST_YN,'N') = '')
                   AND ('' IS NULL OR NVL(A.SYS_YN,'N') = '')
                   AND (A.SLIP_TYPE = 'ALL' or 'ALL' = 'ALL') 
                   AND A.TLG_IN_WAREHOUSE_PK = 367
                   AND A.PK in (34683,34299,33148,34254,34201, 28001,35563,34202,28002,35763, 34266,34203,28003,35963,34199) 
                    ORDER BY D.ACC_TRANS_CODE,B.WH_NAME
                    --29321, 34649,35683,30789,35565
--34207,35564,35566,34301,35569
--34683,34299,33148,34254,34201
--28001,35563,34202,28002,35763
--34266,34203,28003,35963,34199
         )
         loop
            
             INSERT INTO TLG_LG_TRANS_WH
                         (
                                PK, TRIN_TYPE, TROUT_TYPE, DEL_IF, CRT_DT, CRT_BY
                              , TLG_IN_WAREHOUSE_PK, TLG_IT_ITEMGRP_PK, REF_WAREHOUSE_PK
                              ,   FROM_MONTH,TO_MONTH,DESCRIPTION
                              , D_TAC_ABACCTCODE_PK, C_TAC_ABACCTCODE_PK, D_TAC_ABPL_PK, C_TAC_ABPL_PK
                              , SLIP_TYPE,TR_TYPE 
                              , ACC_WH_PK
                              , ACC_TRIN_TYPE
                              , ACC_TROUT_TYPE
                              , ACC_TR_TYPE, REF_ACC_WH_PK, TLG_PB_WORK_PROCESS_PK
                              , COST_YN, SYS_YN
                              , REF_ITEM_GROUP_PK
                              , TAC_ABACCTCODE_PK_VAT      
                              , TAC_ABACCTCODE_PK_AR       
                              , TAC_ABACCTCODE_PK_REV      
                              , TAC_ABACCTCODE_PK_ADV   
                              , TAC_ABACCTCODE_TO_DR
                              , TAC_ABACCTCODE_TO_CR   
                         )           
                 select 
                      TLG_LG_TRANS_WH_SEQ.NEXTVAL   ,
                       TRIN_TYPE, TROUT_TYPE, DEL_IF, CRT_DT, '267007'
                      , cur.TLG_IN_WAREHOUSE_PK, TLG_IT_ITEMGRP_PK, REF_WAREHOUSE_PK
                      , FROM_MONTH,TO_MONTH, DESCRIPTION
                      , D_TAC_ABACCTCODE_PK, C_TAC_ABACCTCODE_PK, D_TAC_ABPL_PK, C_TAC_ABPL_PK
                      , SLIP_TYPE,TR_TYPE 
                      , cur.ACC_WH_PK
                      , ACC_TRIN_TYPE
                      , ACC_TROUT_TYPE
                      , ACC_TR_TYPE, REF_ACC_WH_PK, TLG_PB_WORK_PROCESS_PK
                      , COST_YN, SYS_YN
                      , REF_ITEM_GROUP_PK
                      , cur.TAC_ABACCTCODE_PK_VAT      
                      , cur.TAC_ABACCTCODE_PK_AR       
                      , cur.TAC_ABACCTCODE_PK_REV      
                      , cur.TAC_ABACCTCODE_PK_ADV   
                      , TAC_ABACCTCODE_TO_DR
                      , TAC_ABACCTCODE_TO_CR   
                      from TLG_LG_TRANS_WH 
                      where pk = cur.pk  ;           
              
        end loop;
         

end;

begin
    for cur in (
              SELECT A.PK, A.TRIN_TYPE,A.TROUT_TYPE,801 TLG_IN_WAREHOUSE_PK , 464 ACC_WH_PK, SLIP_TYPE 
                  FROM TLG_LG_TRANS_WH A,TLG_IN_WAREHOUSE B,TLG_IN_TRANS_CODE D
                        ,TAC_ABACCTCODE H,TAC_ABACCTCODE T,TLG_PB_WORK_PROCESS G,TLG_IN_WAREHOUSE F, TLG_IT_ITEMGRP P,
                        TAC_ABPL PL_C, TAC_ABPL PL_D
                  WHERE A.DEL_IF = 0 AND B.DEL_IF(+) = 0
                  AND A.TLG_IN_WAREHOUSE_PK = B.PK(+)
                  AND (B.TCO_BUSPLACE_PK = 135 or 135 is null)
                  AND D.DEL_IF = 0
                  AND H.DEL_IF(+) = 0 AND T.DEL_IF(+) = 0
                  AND A.D_TAC_ABACCTCODE_PK = H.PK(+)
                  AND A.C_TAC_ABACCTCODE_PK = T.PK(+)
                  AND PL_D.DEL_IF(+) = 0
                  AND A.D_TAC_ABPL_PK = PL_D.PK(+)
                  AND PL_C.DEL_IF(+) = 0
                  AND A.C_TAC_ABPL_PK = PL_C.PK(+)
                  AND G.DEL_IF(+) = 0
                  AND A.TLG_PB_WORK_PROCESS_PK = G.PK(+)
                  AND F.DEL_IF(+) = 0
                  AND A.REF_WAREHOUSE_PK = F.PK(+)
                  and b.tlg_in_storage_pk in (select h.pk from tlg_in_storage h where h.del_if=0 and h.tco_company_pk = 22134)
                  AND P.DEL_IF = 0
                  AND A.TLG_IT_ITEMGRP_PK = P.PK
                  AND NVL(A.TRIN_TYPE,A.TROUT_TYPE) = D.TRANS_CODE
                  AND DECODE('ALL','ALL','ALL',A.TLG_PB_LINE_PK) = 'ALL'
                  AND DECODE('ALL','ALL','ALL',NVL(A.TRIN_TYPE,A.TROUT_TYPE)) = 'ALL'
                  AND DECODE('ALL','ALL','ALL',D.TRANS_TYPE) = 'ALL'
                  AND DECODE('ALL','ALL','ALL',B.WH_TYPE) = 'ALL'
                  AND DECODE('ALL','ALL','ALL',B.PK) = 'ALL'
                  AND (A.TLG_IT_ITEMGRP_PK IN
                                  (    SELECT PK
                                         FROM TLG_IT_ITEMGRP
                                        WHERE DEL_IF = 0
                                   CONNECT BY PRIOR PK = P_PK
                                   START WITH P_PK = '')
                            OR A.TLG_IT_ITEMGRP_PK = ''
                            OR '' IS NULL)
                   AND A.FROM_MONTH <= NVL(202604,A.FROM_MONTH) AND NVL(A.TO_MONTH,202604) >= 202604
                   AND ('' IS NULL OR NVL(A.COST_YN,'N') = '')
                   AND ('' IS NULL OR NVL(A.SYS_YN,'N') = '')
                   AND (A.SLIP_TYPE = 'ALL' or 'ALL' = 'ALL') 
                   AND A.TLG_IN_WAREHOUSE_PK = 461
                   AND A.ACC_WH_PK = 302
                    ORDER BY D.ACC_TRANS_CODE,B.WH_NAME
         )
         loop
            
             INSERT INTO TLG_LG_TRANS_WH
                         (
                                PK, TRIN_TYPE, TROUT_TYPE, DEL_IF, CRT_DT, CRT_BY
                              , TLG_IN_WAREHOUSE_PK, TLG_IT_ITEMGRP_PK, REF_WAREHOUSE_PK
                              ,   FROM_MONTH,TO_MONTH,DESCRIPTION
                              , D_TAC_ABACCTCODE_PK, C_TAC_ABACCTCODE_PK, D_TAC_ABPL_PK, C_TAC_ABPL_PK
                              , SLIP_TYPE,TR_TYPE 
                              , ACC_WH_PK
                              , ACC_TRIN_TYPE
                              , ACC_TROUT_TYPE
                              , ACC_TR_TYPE, REF_ACC_WH_PK, TLG_PB_WORK_PROCESS_PK
                              , COST_YN, SYS_YN
                              , REF_ITEM_GROUP_PK
                              , TAC_ABACCTCODE_PK_VAT      
                              , TAC_ABACCTCODE_PK_AR       
                              , TAC_ABACCTCODE_PK_REV      
                              , TAC_ABACCTCODE_PK_ADV   
                              , TAC_ABACCTCODE_TO_DR
                              , TAC_ABACCTCODE_TO_CR
                         )           
                 select 
                      TLG_LG_TRANS_WH_SEQ.NEXTVAL   ,
                       TRIN_TYPE, TROUT_TYPE, DEL_IF, CRT_DT, '267007_HN203'
                      , cur.TLG_IN_WAREHOUSE_PK, TLG_IT_ITEMGRP_PK, REF_WAREHOUSE_PK
                      , FROM_MONTH,TO_MONTH, DESCRIPTION
                      , D_TAC_ABACCTCODE_PK, C_TAC_ABACCTCODE_PK, D_TAC_ABPL_PK, C_TAC_ABPL_PK
                      , cur.SLIP_TYPE,TR_TYPE 
                      , cur.ACC_WH_PK
                      , ACC_TRIN_TYPE
                      , ACC_TROUT_TYPE
                      , ACC_TR_TYPE, REF_ACC_WH_PK, TLG_PB_WORK_PROCESS_PK
                      , COST_YN, SYS_YN
                      , REF_ITEM_GROUP_PK
                      , TAC_ABACCTCODE_PK_VAT      
                      , TAC_ABACCTCODE_PK_AR       
                      , TAC_ABACCTCODE_PK_REV      
                      , TAC_ABACCTCODE_PK_ADV   
                      , TAC_ABACCTCODE_TO_DR
                      , TAC_ABACCTCODE_TO_CR  
                      from TLG_LG_TRANS_WH 
                      where pk = cur.pk  ;           
              
        end loop;
         

end;