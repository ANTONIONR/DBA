--  ----------------------------------------------------------------------------------------------------
--
--  FILE NAME      : create_trigger_audit.sql
--  DESCRIPTION    : Template for create simple audit for tables
--  AUTHOR         : Antonio NAVARRO - /\/\/
--  CREATE         : 22.05.99
--  LAST MODIFIED  : 28.10.11
--  USAGE          : This script inputs two parameters. Parameter 1 is a flag to specify if
--  CALL SYNTAXIS  : @create_trigger_audit.sql
--  [NOTES]        : Tables required had two attributes (last_modified and cod_operator). When a 
--                   row is modified or inserted a track with the timestamp and user who perform the 
--                   action is record in the row. Only valid for the last operation. 
--   
--  ----------------------------------------------------------------------------------------------------


WHENEVER OSERROR EXIT 2


SET FEED OFF VER OFF LIN 32767 PAGES 0 TIMI OFF LONG 32767000 LONGC 32767 TRIMS ON AUTOT OFF;
SET SERVEROUT ON SIZE UNLIMITED;
SPO CREATE_TRIGGER_AUDIT_TABLE_X.log

-- ALTER SESSION SET GLOBAL_NAMES = FALSE;
-- ALTER SESSION ENABLE RESUMABLE TIMEOUT 86400;
-- ALTER SESSION SET EVENTS '10359 TRACE NAME CONTEXT FOREVER, LEVEL 1';

-- ALTER TABLE ANR.TABLE_X ADD COLUMN (LAST_MODIFIED   DATE);
-- ALTER TABLE ANR.TABLE_X ADD COLUMN (COD_OPERATOR    VARCHAR2(30));

CREATE OR REPLACE
TRIGGER ANR.TG_AUDIT_TABLE_X
AFTER INSERT OR UPDATE 
ON ANR.TABLE_X
FOR EACH ROW
BEGIN 
  :new.last_modified := sysdate;
  :new.cod_operator := substr(user,1,30); 
END; 
/

ALTER TRIGGER "ANR"."TG_AUDIT_TABLE_X" ENABLE;
EXIT










