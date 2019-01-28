---  ----------------------------------------------------------------------------------------------------
--
--  FILE NAME      : activate_index_monitoring.sql
--  DESCRIPTION    : Activate monitoring for all indexes
--  AUTHOR         : Antonio NAVARRO - /\/\/
--  CREATE         : 18.07.09
--  LAST MODIFIED  : 08.01.18
--  USAGE          : This script active monitoring for all indexes into the schema who executes this 
--                   script.
--  CALL SYNTAXIS  : @activate_index_monitoring.sql
--  [NOTES]        : In big databases or with a big number of transactions would hung the system
--   
--  ----------------------------------------------------------------------------------------------------


SET FEED OFF VER OFF LIN 32767 PAGES 0 TIMI ON LONG 32767000 LONGC 32767 TRIMS ON AUTOT OFF;
SET SERVEROUTPUT ON SIZE UNLIMITED

 
BEGIN
   FOR r IN (SELECT index_name
               FROM user_indexes)
   LOOP
      EXECUTE IMMEDIATE 'ALTER INDEX ' || r.index_name || 
        ' MONITORING USAGE';
   END LOOP;
END;

