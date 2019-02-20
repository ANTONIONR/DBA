
--  ----------------------------------------------------------------------------------------------------
--
--  FILE NAME      : SQLADVAWR.SQL
--  DESCRIPTION    : Create a sql tuning taks from a sqlid into the AWR
--  AUTHOR         : Antonio NAVARRO - /\/\/
--  CREATE         : 21.03.11
--  LAST MODIFIED  : 21.03.11
--  USAGE          : This script inputs one parameter. Parameter 1 is a sqlid that we need to optimize
--  CALL SYNTAXIS  : @sqladvawr.sql 3332234233
--  [NOTES]        :
--   
--  ----------------------------------------------------------------------------------------------------


SET SERVEROUTPUT ON SIZE 100000

-- Identified this session
set appi /\/\/
exec dbms_application_info.set_client_info('Task opti. Ext 5686');



BEGIN
	
  DBMS_OUTPUT.PUT_LINE (CHR (10));                                                                           
  DBMS_OUTPUT.PUT_LINE ('======================= LOOK FOR SNAP CONTAINS SQLID =========================	');  
  DBMS_OUTPUT.PUT_LINE (CHR (10));                                                                           
  DBMS_OUTPUT.PUT_LINE ('SELECT SNAP_ID         ');
  DBMS_OUTPUT.PUT_LINE ('FROM DBA_HIST_SQLSTAT  ');
  DBMS_OUTPUT.PUT_LINE ('WHERE SQL_ID=''&1''    ');
  DBMS_OUTPUT.PUT_LINE ('ORDER BY SNAP_ID;	    ');
	
  DBMS_OUTPUT.PUT_LINE (CHR (10));
  DBMS_OUTPUT.PUT_LINE ('============================= CREATE TASK ==============================	');
  DBMS_OUTPUT.PUT_LINE (CHR (10));
  DBMS_OUTPUT.PUT_LINE ('DECLARE                                                                        ');
  DBMS_OUTPUT.PUT_LINE ('  Output  VARCHAR2(100);                                                       ');
  DBMS_OUTPUT.PUT_LINE ('BEGIN                                                                          ');
  DBMS_OUTPUT.PUT_LINE ('  Output := DBMS_SQLTUNE.create_tuning_task (                                  ');
  DBMS_OUTPUT.PUT_LINE ('                          BEGIN_SNAP =>  ! ! ! SET BEGIN_SNAP ! ! !,           ');
  DBMS_OUTPUT.PUT_LINE ('                          END_SNAP   =>  ! ! ! SET END_SNAP   ! ! !,           ');
  DBMS_OUTPUT.PUT_LINE ('                          sql_id      => ''&1'',                               ');
  DBMS_OUTPUT.PUT_LINE ('                          scope       => DBMS_SQLTUNE.scope_comprehensive,     ');
  DBMS_OUTPUT.PUT_LINE ('                          time_limit  => 500,                                  ');
  DBMS_OUTPUT.PUT_LINE ('                          task_name   => ''TASK ANR &1''  ,                   ');
  DBMS_OUTPUT.PUT_LINE ('                          description => ''Anr task for &1'');                 ');
  DBMS_OUTPUT.PUT_LINE ('  DBMS_OUTPUT.put_line(''Task created: '' || Output);                          ');
  DBMS_OUTPUT.PUT_LINE ('END;                                                                           ');
  DBMS_OUTPUT.PUT_LINE ('/                                                                              ');

  DBMS_OUTPUT.PUT_LINE (CHR (10));
  DBMS_OUTPUT.PUT_LINE ('============================= EXECUTE THE TASK  ==============================	');
  DBMS_OUTPUT.PUT_LINE (CHR (10));
  DBMS_OUTPUT.PUT_LINE ('EXEC DBMS_SQLTUNE.execute_tuning_task(task_name => ''TASK ANR &1'');          ');

  DBMS_OUTPUT.PUT_LINE (CHR (10));
  DBMS_OUTPUT.PUT_LINE ('============================= QUERY THE REPORT  ==============================	');
  DBMS_OUTPUT.PUT_LINE (CHR (10));
  DBMS_OUTPUT.PUT_LINE ('set long 50000                                                                  ');
  DBMS_OUTPUT.PUT_LINE ('set linesize 100                                                               ');
  DBMS_OUTPUT.PUT_LINE ('select dbms_sqltune.report_tuning_task(''TASK ANR &1'') from dual;            ');
  
  DBMS_OUTPUT.PUT_LINE (CHR (10));                                                                                                  
  DBMS_OUTPUT.PUT_LINE ('================================= DROP TASK  ==================================	');                         
  DBMS_OUTPUT.PUT_LINE (CHR (10));                                                                                                    
  DBMS_OUTPUT.PUT_LINE ('BEGIN                                                                          ');
  DBMS_OUTPUT.PUT_LINE ('DBMS_SQLTUNE.DROP_TUNING_TASK (''TASK ANR &1'');                              ');
  DBMS_OUTPUT.PUT_LINE ('END;                                                                           ');
  DBMS_OUTPUT.PUT_LINE ('/                                                                              ');

  DBMS_OUTPUT.PUT_LINE (CHR (10));                                                                         
  DBMS_OUTPUT.PUT_LINE ('=============================== DROP PROFILE ===============================	');
  DBMS_OUTPUT.PUT_LINE (CHR (10));                                                                         
  DBMS_OUTPUT.PUT_LINE ('select name from dba_sql_profiles;                                             ');
  DBMS_OUTPUT.PUT_LINE ('exec dbms_sqltune.drop_sql_profile('' !!! LOOK FOR THE NAME !!! '')               '); 

END;
/


