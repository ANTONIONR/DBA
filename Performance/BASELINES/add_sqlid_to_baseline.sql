
--  ----------------------------------------------------------------------------------------------------
--
--  FILE NAME      : ADD_SQLID_TO_BASELINE.SQL
--  DESCRIPTION    : This script add a SQLID (from library cache) with his PHV to a SQL_HANDLE
--  AUTHOR         : Antonio NAVARRO - /\/\/
--  CREATE         : 16.10.14
--  LAST MODIFIED  : 16.10.14
--  USAGE          : This script inputs three parameters. Parameter 1 is as SQL_HANDLE (must exists) 
--                   Parameter 2 is a SQLID and Parameter 3 is a PHV
--  CALL SYNTAXIS  : @add_sqlid_to_baseline.sql SQL_HANDLE SQLID  PHV
--  [NOTES]        :
--   
--  ----------------------------------------------------------------------------------------------------


SET FEED OFF VER OFF LIN 32767 PAGES 0 TIMI OFF LONG 32767000 LONGC 32767 TRIMS ON AUTOT OFF;
SET SERVEROUT ON SIZE UNLIMITED;


-- alter session set optimizer_features_enable='12.1.0.2';
-- alter session set optimizer_use_sql_plan_baselines=FALSE;

PRO
PRO 1. Enter SQL_HANDLE (required)
DEF e_sqlhandle = '&&1';
PRO
PRO 1. Enter SQLID (required)
DEF e_sqlid = '&&2';
PRO
PRO 2. Enter Plan Hash Value (required)
DEF e_phv = '&&3';
PRO


VAR L_SQL_HANDLE     VARCHAR2 (128);
VAR L_SQLID          VARCHAR2 (13);
VAR L_PHV            NUMBER;


DECLARE
  
  exit_return        binary_integer;      /* Check the control return by the call to the procedure */
  SqlHandle          varchar2(40);        /* SQL Handle */
  OldPlanName        varchar2(40);        /* Old Plan Name */
  NewPlanName        varchar2(40);        /* New Plan Name */


BEGIN
  -- assign variables
  :L_SQL_HANDLE  := '&&e_sqlhandle';
  :L_SQLID       := '&&e_sqlid';
  :L_PHV         := &&e_phv;
  
  
  /******
  var res number
exec :res := dbms_spm.load_plans_from_cursor_cache( -
sql_id => 'a5fmqk35d1qff', -
plan_hash_value => '3900861775', -
sql_handle => 'SQL_8c2dc9565c05bf89');

print res       <<< no debe devolver cero 
*************/
  
   
  exit_return := dbms_spm.load_plans_from_cursor_cache (
    sql_handle      => :L_SQL_HANDLE,
    sql_id          => :L_SQLID, 
    plan_hash_value => :L_PHV);
    
    
  IF exit_return != 0 THEN 
     DBMS_OUTPUT.PUT_LINE (' SQLID ' || :L_SQLID|| ' ADD TO BASELINE (SQL_HANDLE) ' || :L_SQL_HANDLE  );
  ELSE
     DBMS_OUTPUT.PUT_LINE (' ERROR ADDING SQLID TO BASELINE ');
     RETURN;
  END IF;     
  
END;
/



PRO
PRO --------------------------------------------------- iScripts --------------------------------------------------  

PRO 
PRO @drop_baseline [Plan Name]                       @show_sqlid [sqlid]               
PRO
PRO ---------------------------------------------------------------------------------------------------------------



undef L_SQLID
undef L_PHV  

