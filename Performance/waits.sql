
--  ----------------------------------------------------------------------------------------------------
--
--  FILE NAME      : WAITS.SQL
--  DESCRIPTION    : Clasical view for see events waits group by event
--  AUTHOR         : Antonio NAVARRO - /\/\/
--  CREATE         : 11.08.03
--  LAST MODIFIED  : 11.08.03
--  USAGE          : Clasical view for see events waits group by event
--  CALL SYNTAXIS  : @waits.sql 
--  [NOTES]        :
--   
--  ----------------------------------------------------------------------------------------------------


PROMPT 
PROMPT ESPERAS POR EVENTOS !!!
SELECT EVENT, COUNT (*) FROM V$SESSION_WAIT GROUP BY EVENT;
 


 