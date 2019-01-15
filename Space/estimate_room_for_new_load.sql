


CAT_VIG_NAT_OBJ_PROD_TARIFA (250.000) 
CAT_REFERENCIA_OBJ_OBJETO (500.000)
CAT_COMERCIALIZACION (10 millones)
CAT_VIGENCIA_COMERCIALIZACION (10 millones)
CAT_COMER_ALTA_WEB_SERVICES (6 millones)


select /*+ full (x) parallel (x, 4) */ count (*) from CAT_VIG_NAT_OBJ_PROD_TARIFA x;
select /*+ full (x) parallel (x, 4) */ count (*) from CAT_REFERENCIA_OBJ_OBJETO x;
select /*+ full (x) parallel (x, 4) */ count (*) from CAT_COMERCIALIZACION x;
select /*+ full (x) parallel (x, 4) */ count (*) from CAT_VIGENCIA_COMERCIALIZACION x;
select /*+ full (x) parallel (x, 4) */ count (*) from CAT_COMER_ALTA_WEB_SERVICES x;




ESPACIO/FILAS  


SQL> select /*+ full (x) parallel (x, 4) */ count (*) from CAT_VIG_NAT_OBJ_PROD_TARIFA x;

  COUNT(*)
----------
 225727460

SQL> select /*+ full (x) parallel (x, 4) */ count (*) from CAT_REFERENCIA_OBJ_OBJETO x;

  COUNT(*)
----------
  33141995

SQL> select /*+ full (x) parallel (x, 4) */ count (*) from CAT_COMERCIALIZACION x;

  COUNT(*)
----------
1443485417

SQL> select /*+ full (x) parallel (x, 4) */ count (*) from CAT_VIGENCIA_COMERCIALIZACION x;

  COUNT(*)
----------
1433140839

SQL> select /*+ full (x) parallel (x, 4) */ count (*) from CAT_COMER_ALTA_WEB_SERVICES x;

  COUNT(*)
----------
 974573336

SQL>
SQL>


select tablespace_name, table_name from dba_tables where table_name in ('VIG_NAT_OBJ_PROD_TARIFA','REFERENCIA_OBJ_OBJETO','COMERCIALIZACION','VIGENCIA_COMERCIALIZACION','COMER_ALTA_WEB_SERVICES')


--
select tablespace_name, sum (bytes)/1048576 from dba_data_files where tablespace_name in
(
select tablespace_name from dba_tables where table_name in ('VIG_NAT_OBJ_PROD_TARIFA','REFERENCIA_OBJ_OBJETO','COMERCIALIZACION','VIGENCIA_COMERCIALIZACION','COMER_ALTA_WEB_SERVICES')
)
group by tablespace_name
order by 1 asc
/

select tablespace_name, sum (bytes)/1048576 from dba_free_space where tablespace_name in
(
select tablespace_name from dba_tables where table_name in ('VIG_NAT_OBJ_PROD_TARIFA','REFERENCIA_OBJ_OBJETO','COMERCIALIZACION','VIGENCIA_COMERCIALIZACION','COMER_ALTA_WEB_SERVICES')
)
group by tablespace_name
order by 1 asc
/




TABLESPACE_NAME                SUM(BYTES)/1048576
------------------------------ ------------------ -------------   -------------
MABO_VIGCOMER_DAT                          162816     10878,375   VIGENCIA_COMERCIALIZACION    1433140839
SMS_AM128M_1D                               85549    6697,96094   REFERENCIA_OBJ_OBJETO        33141995
SMS_AN128M_1D                              169179     5529,9375   COMERCIALIZACION             1443485417
SMS_IM512M_7D                          201284,016    10909,9219   COMER_ALTA_WEB_SERVICES      974573336
SMS_LN064M_1D                               36960    5458,24219   VIG_NAT_OBJ_PROD_TARIFA      225727460



select tablespace_name from dba_indexes where table_name in ('VIG_NAT_OBJ_PROD_TARIFA','REFERENCIA_OBJ_OBJETO','COMERCIALIZACION','VIGENCIA_COMERCIALIZACION','COMER_ALTA_WEB_SERVICES')
/


--
select tablespace_name, sum (bytes)/1048576 from dba_data_files where tablespace_name in
(
select tablespace_name from dba_indexes where table_name in ('VIG_NAT_OBJ_PROD_TARIFA','REFERENCIA_OBJ_OBJETO','COMERCIALIZACION','VIGENCIA_COMERCIALIZACION','COMER_ALTA_WEB_SERVICES')
)
group by tablespace_name
order by 1 asc
/

select tablespace_name, sum (bytes)/1048576 from dba_free_space where tablespace_name in
(
select tablespace_name from dba_indexes where table_name in ('VIG_NAT_OBJ_PROD_TARIFA','REFERENCIA_OBJ_OBJETO','COMERCIALIZACION','VIGENCIA_COMERCIALIZACION','COMER_ALTA_WEB_SERVICES')
)
group by tablespace_name
order by 1 asc
/



TABLESPACE_NAME                SUM(BYTES)/1048576
------------------------------ ------------------
MABO_COMER_INX                         234752.188      22918.8125
MABO_VIGCOMER_INX                          306368      34484.25
SMS_AN128M_1I                              178408      10904.7891
SMS_AN128M_3I                              136166       1485.08594
SMS_IM064M_2I                               12304       2622.82813
SMS_IM064M_4I                               47958       4705.01563



======================================================================


select sum(bytes)/1048576 from dba_segments where segment_name ='VIG_NAT_OBJ_PROD_TARIFA';

select sum(bytes)/1048576 from dba_segments where segment_name ='REFERENCIA_OBJ_OBJETO';

select sum(bytes)/1048576 from dba_segments where segment_name ='COMERCIALIZACION';

select sum(bytes)/1048576 from dba_segments where segment_name ='VIGENCIA_COMERCIALIZACION';

select sum(bytes)/1048576 from dba_segments where segment_name ='COMER_ALTA_WEB_SERVICES';


select sum(bytes)/1048576, ((sum(bytes)/1048576) * 250000) / 225727460 from dba_segments where segment_name ='VIG_NAT_OBJ_PROD_TARIFA';   --       17094.2188                              18.9323651
select sum(bytes)/1048576, ((sum(bytes)/1048576) * 500000) / 33141995 from dba_segments where segment_name ='REFERENCIA_OBJ_OBJETO';     --        1280                             19.3108472
select sum(bytes)/1048576, ((sum(bytes)/1048576) * 10000000) / 1443485417 from dba_segments where segment_name ='COMERCIALIZACION';    --             135038                                 935.499579
select sum(bytes)/1048576, ((sum(bytes)/1048576) * 10000000) / 1433140839 from dba_segments where segment_name ='VIGENCIA_COMERCIALIZACION';  --              151936                                 1060.16098
select sum(bytes)/1048576, ((sum(bytes)/1048576) * 6000000) / 974573336   from dba_segments where segment_name ='COMER_ALTA_WEB_SERVICES';    --
 102918.203                               633.620063



100 mb  -> 12f 

x   mb  -> 10f    x = (100 mb * 10fn)  / 12 fa


--- 

DECLARE 

CREATE OR REPLACE FUNCTION 
ESPACIO_ESTIMADO (FILAS_ACT, FILAS_NEW, TABLA)
BEGIN

 contar filas actuales tabla
 espacio actual (por segmento) tabla
 estimar espacio nuevo necesario R3

 indices
 espacio actual (por segmento) indices asociados a la tabla
 estimar espacio nuevo necesario R3
END;
/


CAT_VIG_NAT_OBJ_PROD_TARIFA (250.000) 
CAT_REFERENCIA_OBJ_OBJETO (500.000)
CAT_COMERCIALIZACION (10 millones)
CAT_VIGENCIA_COMERCIALIZACION (10 millones)
CAT_COMER_ALTA_WEB_SERVICES (6 millones)




TABLESPACE_NAME                SUM(BYTES)/1048576
------------------------------ ------------------ -------------   -------------
MABO_VIGCOMER_DAT                          162816     10878,375   VIGENCIA_COMERCIALIZACION    1433140839
SMS_AM128M_1D                               85549    6697,96094   REFERENCIA_OBJ_OBJETO        33141995    XXXXXXX
SMS_AN128M_1D                              169179     5529,9375   COMERCIALIZACION             1443485417  XXXXXXX
SMS_IM512M_7D                          201284,016    10909,9219   COMER_ALTA_WEB_SERVICES      974573336   XXXXXXX
SMS_LN064M_1D                               36960    5458,24219   VIG_NAT_OBJ_PROD_TARIFA      225727460   XXXXXXX


DECLARE
   SPACE            PLS_INTEGER;
   FREE_SPACE       PLS_INTEGER;
   FILAS_ACTUAL     NUMBER          :=  974573336;
   FILAS_NUEVAS     NUMBER          :=  6000000;
   TABLA            VARCHAR2(100)   := 'COMER_ALTA_WEB_SERVICES';
   TBS_NAME         VARCHAR2(100);
   maxby            PLS_INTEGER;
   minby            PLS_INTEGER;
   avgby            PLS_INTEGER;  

   FILAS_ACTUAL     NUMBER          :=  974573336;
   FILAS_NUEVAS     NUMBER          :=  6000000;
   TABLA            VARCHAR2(100)   := 'COMER_ALTA_WEB_SERVICES';


   FILAS_ACTUAL     NUMBER          :=  1433140839;
   FILAS_NUEVAS     NUMBER          :=  10000000;
   TABLA            VARCHAR2(100)   := 'VIGENCIA_COMERCIALIZACION';



SET LINES 120
SET SERVEROUTPUT ON SIZE 50000
DECLARE
   SPACE            PLS_INTEGER;
   FREE_SPACE       PLS_INTEGER;
   FILAS_ACTUAL     NUMBER          :=  1433140839;
   FILAS_NUEVAS     NUMBER          :=  10000000;
   TABLA            VARCHAR2(100)   := 'VIGENCIA_COMERCIALIZACION';
   TBS_NAME         VARCHAR2(100);
   maxby            PLS_INTEGER;
   minby            PLS_INTEGER;
   avgby            PLS_INTEGER;  
BEGIN
   select ((sum(bytes)/1048576) * FILAS_NUEVAS) / FILAS_ACTUAL INTO SPACE  from dba_segments where segment_name = TABLA;

   DBMS_OUTPUT.PUT_LINE ('------------------------------------------------------------------------------');
   DBMS_OUTPUT.PUT_LINE ('ANALIZING FOR TABLE           :   ' || TABLA );
   DBMS_OUTPUT.PUT_LINE ('NEW SPACE REQUIRED (in MB)    :   ' || SPACE || ' for ' || FILAS_NUEVAS || ' new rows');
   

   select tablespace_name into TBS_NAME from dba_segments where segment_name =TABLA;
   select sum(bytes)/1048576 INTO FREE_SPACE from dba_free_space where tablespace_name = TBS_NAME;
   DBMS_OUTPUT.PUT_LINE ('FREE IN TBS (in MB)           :   ' || FREE_SPACE);

   select max (bytes)/1048576, min (bytes)/1048576, avg(bytes)/1048576 into maxby, minby, avgby
       from dba_free_space where tablespace_name = TBS_NAME;     
   DBMS_OUTPUT.PUT_LINE ('TABLESPACE                    :   '|| TBS_NAME || ' required: ' || space || 'M Avaliable: ' || FREE_SPACE  || 'M [max: ' || maxby || 'M min: ' || minby || 'M avg: ' || avgby || 'M]');
   
   IF SPACE <= FREE_SPACE THEN
      DBMS_OUTPUT.PUT_LINE ('ACTION                        :   SPACE OK  ');
   ELSE
      DBMS_OUTPUT.PUT_LINE ('ACTION                        :   ADD SPACE TO TABLESPACE ' || TBS_NAME);
   END IF;

   DBMS_OUTPUT.PUT_LINE ('.');
   DBMS_OUTPUT.PUT_LINE ('------------------------------------------------------------------------------');
   -- ASSOCIATED INDEXES -------
   -- !!! THE TABLE IS UNIQUE IN THE DATABASE !!!
   FOR AssociatedIndexes IN (
       SELECT INDEX_NAME FROM DBA_INDEXES WHERE TABLE_NAME = TABLA
   )
   LOOP      
       select ((sum(bytes)/1048576) * FILAS_NUEVAS) / FILAS_ACTUAL INTO SPACE  from dba_segments where segment_name = AssociatedIndexes.index_name ;
       
       select tablespace_name into TBS_NAME from dba_indexes where index_name =AssociatedIndexes.index_name; 
       select sum(bytes)/1048576 INTO FREE_SPACE from dba_free_space where tablespace_name = TBS_NAME;

       select max (bytes)/1048576, min (bytes)/1048576, avg(bytes)/1048576 into maxby, minby, avgby
       from dba_free_space where tablespace_name = TBS_NAME;

       IF SPACE <= FREE_SPACE THEN 
           DBMS_OUTPUT.PUT_LINE ('INDEX  :   ' || AssociatedIndexes.index_name || ' NO ACTION   ' || TBS_NAME || ' required: ' || space || 'M Avaliable: ' || FREE_SPACE  || 'M [max: ' || maxby || 'M min: ' || minby || 'M avg: ' || avgby || 'M]');
       ELSE 
           DBMS_OUTPUT.PUT_LINE ('ACCION :   ' || AssociatedIndexes.index_name || ' ADD DBF !!! ' || TBS_NAME || ' required: ' || space || 'M Avaliable: ' || FREE_SPACE  || 'M [max: ' || maxby || 'M min: ' || minby || 'M avg: ' || avgby || 'M]');
       END IF;


   END LOOP;

END;
/


          *  * *   P R E T T Y   * * *

SET LINESIZE 180 
SET SERVEROUTPUT ON SIZE 50000

DECLARE
   SPACE            PLS_INTEGER;                                           -- Space required for the new rows
   FREE_SPACE       PLS_INTEGER;                                           -- Free space at TBS
   FILAS_ACTUAL     NUMBER          :=  1433140839;
   FILAS_NUEVAS     NUMBER          :=  10000000;
   TABLA            VARCHAR2(50)     := 'VIGENCIA_COMERCIALIZACION';
   TBS_NAME         VARCHAR2(50);                                          -- TBS name, for data and indexes
   maxby            PLS_INTEGER;                                           -- Maximus chunk of free space
   minby            PLS_INTEGER;                                           -- Minimus chunk of free space
   avgby            PLS_INTEGER;                                           -- Average chunk of free space
   actionstr        VARCHAR2(15);                                          -- Action to execute
BEGIN
   SELECT ((sum(bytes)/1048576) * FILAS_NUEVAS) / FILAS_ACTUAL INTO SPACE  FROM dba_segments WHERE segment_name = TABLA;

   DBMS_OUTPUT.PUT_LINE ('------------------------------------------------------------------------------------------------------------------------------------------------------------');
   DBMS_OUTPUT.PUT_LINE ('ANALYZE FOR TABL  E           :   ' || TABLA );
   DBMS_OUTPUT.PUT_LINE ('NEW SPACE REQUIRED (in MB)    :   ' || SPACE || ' for ' || FILAS_NUEVAS || ' new rows');
   

   SELECT tablespace_name INTO TBS_NAME FROM dba_segments WHERE segment_name =TABLA;
   SELECT sum(bytes)/1048576 INTO FREE_SPACE FROM dba_free_space WHERE tablespace_name = TBS_NAME;
   DBMS_OUTPUT.PUT_LINE ('FREE IN TBS (in MB)           :   ' || FREE_SPACE);

   SELECT max (bytes)/1048576, min (bytes)/1048576, avg(bytes)/1048576 INTO maxby, minby, avgby
       FROM dba_free_space WHERE tablespace_name = TBS_NAME;     
   DBMS_OUTPUT.PUT_LINE ('TABLESPACE                    :   '|| TBS_NAME || ' required: ' || space || 'M Avaliable: ' || FREE_SPACE  || 'M [max: ' || maxby || 'M min: ' || minby || 'M avg: ' || avgby || 'M]');
   
   IF SPACE <= FREE_SPACE THEN
      DBMS_OUTPUT.PUT_LINE ('ACTION                        :   SPACE OK  ');
   ELSE
      DBMS_OUTPUT.PUT_LINE ('ACTION                        :   ADD SPACE TO TABLESPACE ' || TBS_NAME);
   END IF;

   DBMS_OUTPUT.PUT_LINE ('.');
   DBMS_OUTPUT.PUT_LINE ('------------------------------------------------------------------------------------------------------------------------------------------------------------');
   -- ASSOCIATED INDEXES -------
   -- !!! THE TABLE IS UNIQUE IN THE DATABASE !!!
   FOR AssociatedIndexes IN (
       SELECT INDEX_NAME FROM DBA_INDEXES WHERE TABLE_NAME = TABLA
   )
   LOOP      
       SELECT ((sum(bytes)/1048576) * FILAS_NUEVAS) / FILAS_ACTUAL INTO SPACE  FROM dba_segments WHERE segment_name = AssociatedIndexes.index_name ;
       
       SELECT tablespace_name INTO TBS_NAME FROM dba_indexes WHERE index_name =AssociatedIndexes.index_name; 
       SELECT sum(bytes)/1048576 INTO FREE_SPACE FROM dba_free_space WHERE tablespace_name = TBS_NAME;

       SELECT max (bytes)/1048576, min (bytes)/1048576, avg(bytes)/1048576 INTO maxby, minby, avgby
       FROM dba_free_space WHERE tablespace_name = TBS_NAME;

       IF SPACE <= FREE_SPACE THEN            
           actionstr := ' NO ACTION   ';
       ELSE            
           actionstr := ' ADD DBF !!! ';
       END IF;
       DBMS_OUTPUT.PUT_LINE ('ACCION :   ' || LPAD (to_char(AssociatedIndexes.index_name),20) || chr(9) || actionstr || chr(9) || TBS_NAME || ' Required: ' || chr(9) || space || 'M Avaliable: ' || chr(9) || FREE_SPACE  || 'M [max: ' || chr(9) || maxby || 'M min: ' || chr(9) || minby || 'M avg: ' || chr(9) || avgby || 'M]');

   END LOOP;

END;
/





<<<<  PENDING TASKS  >>>>

PENDIENTES  -> AGRUPAR CUANDO INDICES COMPARTEN MISMO TBS
FORMATEAR   -> MAS CHULO

1 NIVEL DE INDICES, NO SE COMTEMPLAN ESS DISPARADORES QUE HAGAN INSERT EN OTRAS PARTES
2 AUDITORIA QUE PUEDA GENERAR TRANSACIONES POR LA TABLA





CAT_VIG_NAT_OBJ_PROD_TARIFA (250.000) 
CAT_REFERENCIA_OBJ_OBJETO (500.000)
CAT_COMERCIALIZACION (10 millones)
CAT_VIGENCIA_COMERCIALIZACION (10 millones)
CAT_COMER_ALTA_WEB_SERVICES (6 millones)


------------------------------------------------------------------------------
ANALIZING FOR TABLE           :   COMER_ALTA_WEB_SERVICES
NEW SPACE REQUIRED (in MB)    :   634 for 6000000 new rows
FREE IN TBS (in MB)           :   10910
TABLESPACE                    :   SMS_IM512M_7D required: 634M Avaliable: 10910M [max: 2480M min: 1M avg: 191M]
ACTION                        :   SPACE OK
.
------------------------------------------------------------------------------
INDEX  :   COMALTWSER_PK NO ACTION   SMS_AN128M_3I required: 432M Avaliable: 1485M [max: 496M min: 0M avg: 19M]
INDEX  :   COMALTWSER_OBJ_FK_I NO ACTION   SMS_IM064M_4I required: 164M Avaliable: 4577M [max: 496M min: 0M avg: 117M]
INDEX  :   COMALTWSER_I NO ACTION   SMS_AN128M_1I required: 444M Avaliable: 10777M [max: 496M min: 0M avg: 115M]

PL/SQL procedure successfully completed.





------------------------------------------------------------------------------
ANALIZING FOR TABLE           :   VIG_NAT_OBJ_PROD_TARIFA
NEW SPACE REQUIRED (in MB)    :   19 for 250000 new rows
FREE IN TBS (in MB)           :   5202
TABLESPACE                    :   SMS_LN064M_1D required: 19M Avaliable: 5202M [max: 2160M min: 0M avg: 113M]
ACTION                        :   SPACE OK
.
------------------------------------------------------------------------------
INDEX  :   VNATOBJPTA_PK NO ACTION   SMS_AN128M_1I required: 17M Avaliable: 10777M [max: 496M min: 0M avg: 115M]

PL/SQL procedure successfully completed.







------------------------------------------------------------------------------
ANALIZING FOR TABLE           :   COMERCIALIZACION
NEW SPACE REQUIRED (in MB)    :   935 for 10000000 new rows
FREE IN TBS (in MB)           :   5530
TABLESPACE                    :   SMS_AN128M_1D required: 935M Avaliable: 5530M [max: 496M min: 0M avg: 75M]
ACTION                        :   SPACE OK
.
------------------------------------------------------------------------------
INDEX  :   COMER_PRODLCOM_I NO ACTION   MABO_COMER_INX required: 662M Avaliable: 22919M [max: 2304M min: 0M avg: 364M]
INDEX  :   COMER_PK NO ACTION   MABO_COMER_INX required: 806M Avaliable: 22919M [max: 2304M min: 0M avg: 364M]

PL/SQL procedure successfully completed.






------------------------------------------------------------------------------
ANALIZING FOR TABLE           :   REFERENCIA_OBJ_OBJETO
NEW SPACE REQUIRED (in MB)    :   19 for 500000 new rows
FREE IN TBS (in MB)           :   6698
TABLESPACE                    :   SMS_AM128M_1D required: 19M Avaliable: 6698M [max: 496M min: 0M avg: 120M]
ACTION                        :   SPACE OK
.
------------------------------------------------------------------------------
INDEX  :   REFOBJ_OBJ_I NO ACTION   SMS_IM064M_2I required: 14M Avaliable: 2623M [max: 496M min: 0M avg: 109M]
INDEX  :   REFOBJ_PK NO ACTION   SMS_IM064M_2I required: 18M Avaliable: 2623M [max: 496M min: 0M avg: 109M]

PL/SQL procedure successfully completed.

SQL>




------------------------------------------------------------------------------
ANALIZING FOR TABLE           :   VIGENCIA_COMERCIALIZACION
NEW SPACE REQUIRED (in MB)    :   1060 for 10000000 new rows
FREE IN TBS (in MB)           :   10878
TABLESPACE                    :   MABO_VIGCOMER_DAT required: 1060M Avaliable: 10878M [max: 2496M min: 40M avg: 389M]
ACTION                        :   SPACE OK
.
------------------------------------------------------------------------------
INDEX  :   VIGCOMER_OBEM_I NO ACTION   MABO_VIGCOMER_INX required: 399M Avaliable: 34484M [max: 3968M min: 0M avg: 371M]
INDEX  :   VIGCOMER_PROMO_I NO ACTION   MABO_VIGCOMER_INX required: 595M Avaliable: 34484M [max: 3968M min: 0M avg:
371M]
INDEX  :   VIGCOMER_PK NO ACTION   MABO_VIGCOMER_INX required: 903M Avaliable: 34484M [max: 3968M min: 0M avg: 371M]

PL/SQL procedure successfully completed.
