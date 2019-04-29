
--  ----------------------------------------------------------------------------------------------------
--
--  FILE NAME      : CREATE_TRIGGER_LOGON_TRACE.SQL
--  DESCRIPTION    : Create a trigger for logon for a username what enable tracing
--  AUTHOR         : Antonio NAVARRO - /\/\/
--  CREATE         : 29.04.19
--  LAST MODIFIED  : 29.04.19
--  USAGE          : This script inputs one parameter. Parameter 1 is a username for which want 
--                   enable the trace
--  CALL SYNTAXIS  : @create_trigger_logon_trace.sql username
--  [NOTES]        :
--   
--  ----------------------------------------------------------------------------------------------------

SET FEED OFF VER OFF LIN 32767 PAGES 0 TIMI OFF LONG 32767000 LONGC 32767 TRIMS ON AUTOT OFF;
SET SERVEROUT ON SIZE UNLIMITED;



PRO
PRO 1. Enter Username (required)
DEF e_Username = '&&1';
PRO



VAR i_Username     VARCHAR2(30);



DECLARE
BEGIN   
	
  -- assign variables 
  :i_Username  := '&&e_Username';	          
	
DBMS_OUTPUT.PUT_LINE (CHR (10));	
DBMS_OUTPUT.PUT_LINE (CHR (10));

DBMS_OUTPUT.PUT_LINE ('-- It is necessary ALTER SESSION privilege to user can execute the trace ');          
DBMS_OUTPUT.PUT_LINE (CHR (10));
DBMS_OUTPUT.PUT_LINE ('GRANT ALTER SESSION TO ' || :i_Username );
DBMS_OUTPUT.PUT_LINE (CHR (10));
DBMS_OUTPUT.PUT_LINE (CHR (10));

DBMS_OUTPUT.PUT_LINE ('-- DROP THE TRIGGER ');
DBMS_OUTPUT.PUT_LINE ('DROP TRIGGER  ' || :i_Username || '.STARTSQLTRACING; ');
DBMS_OUTPUT.PUT_LINE (CHR (10));
DBMS_OUTPUT.PUT_LINE (CHR (10));

DBMS_OUTPUT.PUT_LINE ('______________________________________________________________________________________________________________________');
DBMS_OUTPUT.PUT_LINE (CHR (10));
DBMS_OUTPUT.PUT_LINE ('create or replace trigger '  || :i_Username || '.STARTSQLTRACING AFTER logon on ' || :i_Username || '.schema         ');
DBMS_OUTPUT.PUT_LINE ('begin                                                                                                                ');
DBMS_OUTPUT.PUT_LINE ('    -- execute immediate ''alter session set timed_statistics=true'';                                                ');
DBMS_OUTPUT.PUT_LINE ('    execute immediate ''alter session set tracefile_identifier=''''NAME_TRC'''''';                                       ');
DBMS_OUTPUT.PUT_LINE ('    execute immediate ''alter session set max_dump_file_size=unlimited'';                                            ');
DBMS_OUTPUT.PUT_LINE ('    execute immediate ''alter session set events ''''10046 trace name context forever, level 12'''''';               ');
DBMS_OUTPUT.PUT_LINE ('    execute immediate ''alter session set events ''''10053 trace name context forever, level 1'''''';                ');
DBMS_OUTPUT.PUT_LINE ('                                                                                                                     ');
DBMS_OUTPUT.PUT_LINE ('    --   execute immediate ''alter session set events ''''8103 trace name errorstack level 3'''''';                  ');
DBMS_OUTPUT.PUT_LINE ('    --   execute immediate ''alter session set events ''10236 trace name context forever, level 1'''''';             ');
DBMS_OUTPUT.PUT_LINE ('    --   execute immediate ''alter session set db_file_multiblock_read_count=1'';                                    ');
DBMS_OUTPUT.PUT_LINE ('    --   execute immediate ''alter session set tracefile_identifier=''ANAVARRO_VB'''';                               ');
DBMS_OUTPUT.PUT_LINE ('                                                                                                                     ');
DBMS_OUTPUT.PUT_LINE ('    --   execute immediate ''alter session set events ''10032 trace name context forever'''''';                      ');
DBMS_OUTPUT.PUT_LINE ('    --   execute immediate ''alter session set optimizer_dynamic_sampling=0'';                                       ');
DBMS_OUTPUT.PUT_LINE ('    --   execute immediate ''alter session set events ''10357 trace name context forever, level 31'''''';            ');
DBMS_OUTPUT.PUT_LINE ('                                                                                                                     ');
DBMS_OUTPUT.PUT_LINE ('end;                                                                                                                 ');
DBMS_OUTPUT.PUT_LINE ('/                                                                                                                    ');
DBMS_OUTPUT.PUT_LINE (CHR (10));
DBMS_OUTPUT.PUT_LINE (CHR (10));


END;
/


