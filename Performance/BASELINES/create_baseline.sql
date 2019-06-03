
--  ----------------------------------------------------------------------------------------------------
--
--  FILE NAME      : CREATE_BASELINE.SQL
--  DESCRIPTION    : This script create a baseline from sqlid in shared pool
--  AUTHOR         : Antonio NAVARRO - /\/\/
--  CREATE         : 16.10.14
--  LAST MODIFIED  : 16.10.14
--  USAGE          : This script inputs two parameters. Parameter 1 is as sqlid Parameter 2 is a PHV
--  CALL SYNTAXIS  : @create_baseline.sql  SQLID  PHV
--  [NOTES]        :
--   
--  ----------------------------------------------------------------------------------------------------


SET FEED OFF VER OFF LIN 32767 PAGES 0 TIMI OFF LONG 32767000 LONGC 32767 TRIMS ON AUTOT OFF;
SET SERVEROUT ON SIZE UNLIMITED;


-- alter session set optimizer_features_enable='12.1.0.2';
-- alter session set optimizer_use_sql_plan_baselines=FALSE;

PRO
PRO 1. Enter SQLID (required)
DEF e_sqlid = '&&1';
PRO
PRO 2. Enter Plan Hash Value (required)
DEF e_phv = '&&2';
PRO



VAR L_SQLID     VARCHAR2(13);
VAR L_PHV       NUMBER;


DECLARE
  
  exit_return        binary_integer;      /* Check the control return by the call to the procedure */
  SqlHandle          varchar2(40);        /* SQL Handle */
  OldPlanName        varchar2(40);        /* Old Plan Name */
  NewPlanName        varchar2(40);        /* New Plan Name */


BEGIN
  -- assign variables 
  :L_SQLID  := '&&e_sqlid';
  :L_PHV    := &&e_phv;
  
  exit_return := dbms_spm.load_plans_from_cursor_cache (
    sql_id          => :L_SQLID, 
    plan_hash_value => :L_PHV);
    
    
  IF exit_return != 0 THEN 
     DBMS_OUTPUT.PUT_LINE (' BASELINE CREATED ');
  ELSE
     DBMS_OUTPUT.PUT_LINE (' ERROR CREATING BASELINE ');
     RETURN;
  END IF;
     
 
  -- Select the last created into the last 4 seconds 
  -- Improve to the last one 
  SELECT SQL_HANDLE, PLAN_NAME, 'ANR_' || :L_SQLID || '_' || :L_PHV
  INTO SqlHandle, OldPlanName, NewPlanName
  FROM DBA_SQL_PLAN_BASELINES 
  WHERE CREATED > SYSDATE-(1/24/60/15);
 
  exit_return := dbms_spm.alter_sql_plan_baseline (
  sql_handle      => SqlHandle,
  plan_name       => OldPlanName,
  attribute_name  => 'PLAN_NAME',
  attribute_value => NewPlanName);

  IF exit_return != -1 THEN 
     DBMS_OUTPUT.PUT_LINE (' BASELINE RENAMED TO ' || NewPlanName);
  ELSE
     DBMS_OUTPUT.PUT_LINE (' ERROR RENAMING BASELINE ');
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

