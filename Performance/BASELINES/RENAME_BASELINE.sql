
--  ----------------------------------------------------------------------------------------------------
--
--  FILE NAME      : RENAME_BASELINE.SQL
--  DESCRIPTION    : This script rename a baseline plan name, from one existing to one new
--  AUTHOR         : Antonio NAVARRO - /\/\/
--  CREATE         : 16.10.14
--  LAST MODIFIED  : 16.10.14
--  USAGE          : This script inputs two parameters. Parameter 1 is as existing plan name Parameter 2 
--                   is a new plan name
--  CALL SYNTAXIS  : @rename_baseline.sql  my_current_plan_name my_new_plan_name
--  [NOTES]        :
--   
--  ----------------------------------------------------------------------------------------------------


SET FEED OFF VER OFF LIN 32767 PAGES 0 TIMI OFF LONG 32767000 LONGC 32767 TRIMS ON AUTOT OFF;
SET SERVEROUT ON SIZE UNLIMITED;


-- alter session set optimizer_features_enable='12.1.0.2';
-- alter session set optimizer_use_sql_plan_baselines=FALSE;

PRO
PRO 1. Enter current Plan Name (required)
DEF p_OldPlanName = '&&1';
PRO
PRO 1. Enter new Plan Name (required)
DEF p_NewPlanName = '&&2';
PRO



VAR OldPlanName     VARCHAR2 (128);
VAR NewPlanName     VARCHAR2 (128);



DECLARE
  
  exit_return        BINARY_INTEGER;       /* Check the control return by the call to the procedure */
  SqlHandle          VARCHAR2 (40);        /* SQL Handle */


BEGIN
  -- assign variables 
  :OldPlanName  := '&&p_OldPlanName';
  :NewPlanName  := '&&p_NewPlanName';
  
    
 
  -- Get the handle for sql with planname pass as parameter
  SELECT SQL_HANDLE
  INTO SqlHandle
  FROM DBA_SQL_PLAN_BASELINES 
  WHERE PLAN_NAME = :OldPlanName;
 
  exit_return := dbms_spm.alter_sql_plan_baseline (
  sql_handle      => SqlHandle,
  plan_name       => :OldPlanName,
  attribute_name  => 'PLAN_NAME',
  attribute_value => :NewPlanName);


  IF exit_return != -1 THEN 
     DBMS_OUTPUT.PUT_LINE (' PLAN NAME ' || :OldPlanName || ' RENAMED TO ' || :NewPlanName);
  ELSE
     DBMS_OUTPUT.PUT_LINE (' ERROR RENAMING PLAN NAME ');
     RETURN;
  END IF;
  
END;
/



undef PlanName

