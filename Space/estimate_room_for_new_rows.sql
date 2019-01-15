--  ----------------------------------------------------------------------------------------------------
--
--  FILE NAME      : estimate_room_for_new_rows.sql
--  DESCRIPTION    : Calculate space required for insert new rows
--  AUTHOR         : Antonio NAVARRO - /\/\/
--  CREATE         : 28.10.99
--  LAST MODIFIED  : 08.01.18
--  USAGE          : This script inputs three parameters. Parameter 1 is number actual rows into the table
--                   parameter 2 is number new rows and parameter 3 is the table name (assume not duplicate
--                   name in other schemas) 
--  CALL SYNTAXIS  : @estimate_room_for_new_rows.sql 100000000 5000000 SALES_PREVIEW
--  [NOTES]        :
--   
--  ----------------------------------------------------------------------------------------------------

SET FEED OFF VER OFF LIN 32767 PAGES 0 TIMI OFF LONG 32767000 LONGC 32767 TRIMS ON AUTOT OFF;
SET SERVEROUTPUT ON SIZE 50000

PRO
PRO 1. Enter number of actual rows (required)
DEF rows_act = '&&1';
PRO
PRO 2. Enter number of estimate new rows (required)
DEF rows_new = '&&2';
PRO
PRO 2. Enter name of table (required)
DEF table_nm = '&&3';

VAR FILAS_ACTUAL  NUMBER;
VAR FILAS_NUEVAS  NUMBER;
VAR TABLA         VARCHAR2(50);

DECLARE
   SPACE            PLS_INTEGER;             -- Space required for the new rows
   FREE_SPACE       PLS_INTEGER;             -- Free space at TBS
   TBS_NAME         VARCHAR2(50);            -- TBS name, for data and indexes
   maxby            PLS_INTEGER;             -- Maximus chunk of free space
   minby            PLS_INTEGER;             -- Minimus chunk of free space
   avgby            PLS_INTEGER;             -- Average chunk of free space
   actionstr        VARCHAR2(15);            -- Action to execute
BEGIN
   -- assign variables 
   :FILAS_ACTUAL  :=  &&rows_act;
   :FILAS_NUEVAS  :=  &&rows_new;
   :TABLA         :=  '&&table_nm';
  
   DBMS_OUTPUT.PUT_LINE ('------------------------------------------------------------------------------------------------------------------------------------------------------------');
   DBMS_OUTPUT.PUT_LINE ('ACTUAL ROWS   ' ||  :FILAS_ACTUAL);
   DBMS_OUTPUT.PUT_LINE ('NEW ROWS      ' ||  :FILAS_NUEVAS);
   DBMS_OUTPUT.PUT_LINE ('TABLE         ' ||  :TABLA);


   SELECT ((sum(bytes)/1048576) * :FILAS_NUEVAS) / :FILAS_ACTUAL INTO SPACE  FROM dba_segments WHERE segment_name = :TABLA;
       

   DBMS_OUTPUT.PUT_LINE ('------------------------------------------------------------------------------------------------------------------------------------------------------------');
   DBMS_OUTPUT.PUT_LINE ('ANALYZE FOR TABL  E           :   ' || :TABLA );
   DBMS_OUTPUT.PUT_LINE ('NEW SPACE REQUIRED (in MB)    :   ' || SPACE || ' for ' || :FILAS_NUEVAS || ' new rows');        

   SELECT tablespace_name INTO TBS_NAME FROM dba_segments WHERE segment_name =:TABLA;      
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
       SELECT INDEX_NAME FROM DBA_INDEXES WHERE TABLE_NAME = :TABLA
   )
   LOOP      
       SELECT ((sum(bytes)/1048576) * :FILAS_NUEVAS) / :FILAS_ACTUAL INTO SPACE  FROM dba_segments WHERE segment_name = AssociatedIndexes.index_name ;
       
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




