
--  ----------------------------------------------------------------------------------------------------
--
--  FILE NAME      : WAITS2.SQL
--  DESCRIPTION    : Clasical view for see events waits group by event
--  AUTHOR         : Antonio NAVARRO - /\/\/
--  CREATE         : 11.08.03
--  LAST MODIFIED  : 11.08.03
--  USAGE          : Clasical view for see events waits group by event PLUS sql
--  CALL SYNTAXIS  : @waits2.sql 
--  [NOTES]        :
--   
--  ----------------------------------------------------------------------------------------------------


select to_char(logon_time,'dd-mon-yyyy:hh24:mi:ss'), a.sql_text, V.SEQ#, V.SID,S.OSUSER,S.USERNAME,S.STATUS,S.LAST_CALL_ET,V.EVENT,V.P1TEXT,V.WAIT_TIME,V.SECONDS_IN_WAIT,
V.STATE,S.PROGRAM,V.P1,V.P2TEXT,V.P2,v.seq#,v.p3text,v.p3 ,a.address,a.hash_value
FROM V$SESSION S,V$SESSION_WAIT V,v$sqlarea a
WHERE S.USERNAME IS NOT NULL AND
      S.SID=V.SID
AND S.STATUS='ACTIVE'
and s.sql_address=a.address
order by S.LAST_CALL_ET desc
/
