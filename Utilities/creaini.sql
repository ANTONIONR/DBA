--  ----------------------------------------------------------------------------------------------------
--
--  FILE NAME      : creaini.sql
--  DESCRIPTION    : Crea a init.ora from v$parameter
--  AUTHOR         : Antonio NAVARRO - /\/\/
--  CREATE         : 11.12.01
--  LAST MODIFIED  : 28.10.11
--  USAGE          : para Oracle RDBMS 7.3 & 9.x
--  CALL SYNTAXIS  : @creaini.sql
--  [NOTES]        : 
--   
--  ----------------------------------------------------------------------------------------------------



set heading off
set feedback off
set pages 0
set newpage 1
set termout off
set timing off
spool c:\initdb.ora

Prompt #################################################################
prompt #
select '# initdb.ora - created ' || to_char(sysdate,'DD/MM/YY HH24:MI')
from dual;
prompt #
prompt # This ficle has been create from the DB
select  '# database:  ' || name || ', created in ' || to_char(created,'DD/MM/YY HH24:MI')
from  v$database;
prompt #
Prompt #################################################################
prompt # Modified values
Prompt #################################################################
prompt
select  '# ' || description || chr(10) || name || ' = ' || value || chr(10)
from  v$parameter
where   isdefault = 'FALSE'
order   by num;
prompt
Prompt #################################################################
prompt # Values on default
Prompt #################################################################
prompt
select  '# ' || description || chr(10) ||name || ' = ' || value || chr(10)
from  v$parameter
where isdefault = 'TRUE'
order   by num;

spool off
set termout on
set timing on

REM edit c:\initdb.ora

