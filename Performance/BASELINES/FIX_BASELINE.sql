
--  ----------------------------------------------------------------------------------------------------
--
--  FILE NAME      : FIX_BASELINE.SQL
--  DESCRIPTION    : This script fix a baseline for a plan name created
--  AUTHOR         : Antonio NAVARRO - /\/\/
--  CREATE         : 16.10.14
--  LAST MODIFIED  : 16.10.14
--  USAGE          : This script inputs two parameters. Parameter 1 is as plan name
--  CALL SYNTAXIS  : @fix_baseline.sql  my_plan_name
--  [NOTES]        :
--   
--  ----------------------------------------------------------------------------------------------------


SET FEED OFF VER OFF LIN 32767 PAGES 0 TIMI OFF LONG 32767000 LONGC 32767 TRIMS ON AUTOT OFF;
SET SERVEROUT ON SIZE UNLIMITED;


-- alter session set optimizer_features_enable='12.1.0.2';
-- alter session set optimizer_use_sql_plan_baselines=FALSE;

PRO
PRO 1. Enter Plan Name (required)
DEF p_PlanName = '&&1';
PRO



VAR PlanName     VARCHAR2(128);



DECLARE
  
  exit_return        binary_integer;      /* Check the control return by the call to the procedure */
  SqlHandle          varchar2(40);        /* SQL Handle */


BEGIN
  -- assign variables 
  :PlanName  := '&&p_PlanName';
   
 
  -- Get the handle for sql with planname pass as parameter
  SELECT SQL_HANDLE
  INTO SqlHandle
  FROM DBA_SQL_PLAN_BASELINES 
  WHERE PLAN_NAME = :PlanName;
 

  exit_return := DBMS_SPM.ALTER_SQL_PLAN_BASELINE (
     sql_handle        => SqlHandle, 
     plan_name         => :PlanName,
     attribute_name    => 'FIXED',
     attribute_value   => 'YES');
  
  
  IF exit_return != -1 THEN 
     DBMS_OUTPUT.PUT_LINE (' BASELINE FIXED (Plan NAME) : ' || :PlanName);
  ELSE
     DBMS_OUTPUT.PUT_LINE (' ERROR FIXING BASELINE ');
     RETURN;
  END IF;
  
END;
/



undef PlanName



