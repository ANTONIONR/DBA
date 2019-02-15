--  ----------------------------------------------------------------------------------------------------
--
--  FILE NAME      : ACTIVES2.SQL
--  DESCRIPTION    : Active sessions, more data like sql, chids, times
--  AUTHOR         : Antonio NAVARRO - /\/\/
--  CREATE         : 28.10.18
--  LAST MODIFIED  : 28.10.18
--  USAGE          : Active sessions, more heavy query and more data like sql, chids, times
--  CALL SYNTAXIS  : @actives2.sql
--  [NOTES]        :
--   
--  ----------------------------------------------------------------------------------------------------


column username    format a15
column sid         format 999999
column machine     format a30
column B           format a1
column S           format a1
column N           format 9
column Time        format a8
column SQL_ID      format a15
column event       format a30
column sql_text    format a40
column execs       format 9999999
column et_secs     format a11

select  -- /\/\/ 
   s.inst_id as N,  
   sid, 
   username,    
   case when last_call_et >= 3600 then '+1H' else to_char (last_call_et) end as time,
   decode (lockwait,NULL,'N','Y') AS B, 
   decode (server,'DEDICATED','D','SHARED','S','NONE','N','*') AS S,   
   decode (s.sql_id,NULL,'NOP',s.sql_id) ||','|| decode (s.sql_child_number,NULL,'NOP',s.sql_child_number) as SQL_ID,
   q.executions execs,
   TO_CHAR(ROUND(elapsed_time/1e6,3),'99,990.000') et_secs,
   SUBSTR(q.sql_text, 1, 40) sql_text,
   event
from gv$session s, gv$sql q
 WHERE s.status = 'ACTIVE'
   AND q.inst_id = s.inst_id
   AND q.sql_id = s.sql_id
   AND q.child_number = s.sql_child_number
   order by username   
/


