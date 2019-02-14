--  ----------------------------------------------------------------------------------------------------
--
--  FILE NAME      : ACTIVES.SQL
--  DESCRIPTION    : Acives session (based in gv$session view)
--  AUTHOR         : Antonio NAVARRO - /\/\/
--  CREATE         : 28.10.18
--  LAST MODIFIED  : 28.10.18
--  USAGE          : This script return the active sessions, exclude internal daemons
--  CALL SYNTAXIS  : @actives.sql 
--  [NOTES]        :
--   
--  ----------------------------------------------------------------------------------------------------




column username    format a15
column sid         format 999999
column machine     format a30
column B           format a1
column S           format a1
column N           format 99
column Time        format a8
column SQL_ID      format a15
column event       format a30



select  -- /\/\/ 
   inst_id as N,  
   sid, 
   username,    
   case when last_call_et >= 3600 then '+1H' else to_char (last_call_et) end as time,
   decode (lockwait,NULL,'N','Y') AS B, 
   decode (server,'DEDICATED','D','SHARED','S','NONE','N','*') AS S,  
   decode (sql_id,NULL,'NOP',sql_id) ||','|| decode (sql_child_number,NULL,'NOP',sql_child_number) as SQL_ID,
   machine, 
   event    
from gv$session   where status ='ACTIVE' and username is not null order by username
/


