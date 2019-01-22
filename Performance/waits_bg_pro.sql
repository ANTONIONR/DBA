--  ----------------------------------------------------------------------------------------------------
--
--  FILE NAME      : waits_bg_pro.sql
--  DESCRIPTION    : Show the events waited by internal processes
--  AUTHOR         : Antonio NAVARRO - /\/\/
--  CREATE         : 27.07.01
--  LAST MODIFIED  : 18.03.15
--  USAGE          : 
--  CALL SYNTAXIS  : @waits_bg_pro.sql
--  [NOTES]        : 
--   
--  ----------------------------------------------------------------------------------------------------


WHENEVER OSERROR EXIT 2

SET FEED OFF VER OFF LIN 32767 PAGES 0 TIMI OFF LONG 32767000 LONGC 32767 TRIMS ON AUTOT OFF;
SET SERVEROUT ON SIZE UNLIMITED;
BREAK ON NAME SKIP 1

SELECT 
  NAME,
  SE.EVENT,
  TOTAL_WAITS,
  TOTAL_TIMEOUTS,
  TIME_WAITED,
  AVERAGE_WAIT,
  MAX_WAIT
FROM
  V$SESSION_EVENT SE,
  V$BGPROCESS     BG,
  V$SESSION       S
WHERE 
  BG.PADDR <> '00'   AND
  BG.PADDR = S.PADDR AND
  S.SID = SE.SID
ORDER BY 1, 2
/



