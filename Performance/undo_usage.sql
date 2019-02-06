
--  ----------------------------------------------------------------------------------------------------
--
--  FILE NAME      : UNDO_USAGE.SQL
--  DESCRIPTION    : UNDO usage by user
--  AUTHOR         : Antonio NAVARRO - /\/\/
--  CREATE         : 05.10.15
--  LAST MODIFIED  : 05.10.15
--  USAGE          : This script query the usage undo per user
--  CALL SYNTAXIS  : @undo_usage.sql 
--  [NOTES]        :
--   
--  ----------------------------------------------------------------------------------------------------

COLUMN  UNDO_USED   FORMAT A20
COLUMN  RSSIZE      FORMAT A20



SELECT   a.sid, 
         a.username, 
         b.xidusn, 
         b.used_urec,
         b.used_ublk,
         SUBSTR (
                  CASE
                      WHEN b.used_ublk  > POWER(2,50) THEN ROUND(b.used_ublk/POWER(2,50),1)||' P'
                      WHEN b.used_ublk  > POWER(2,40) THEN ROUND(b.used_ublk/POWER(2,40),1)||' T'
                      WHEN b.used_ublk  > POWER(2,30) THEN ROUND(b.used_ublk/POWER(2,30),1)||' G'
                      WHEN b.used_ublk  > POWER(2,20) THEN ROUND(b.used_ublk/POWER(2,20),1)||' M'
                      WHEN b.used_ublk  > POWER(2,10) THEN ROUND(b.used_ublk/POWER(2,10),1)||' K'
                      ELSE b.used_ublk  || ' B' END 
                  ,1 ,20
                ) UNDO_USED,
         SUBSTR (
                  CASE
                      WHEN c.rssize  > POWER(2,50) THEN ROUND(c.rssize/POWER(2,50),1)||' P'
                      WHEN c.rssize  > POWER(2,40) THEN ROUND(c.rssize/POWER(2,40),1)||' T'
                      WHEN c.rssize  > POWER(2,30) THEN ROUND(c.rssize/POWER(2,30),1)||' G'
                      WHEN c.rssize  > POWER(2,20) THEN ROUND(c.rssize/POWER(2,20),1)||' M'
                      WHEN c.rssize  > POWER(2,10) THEN ROUND(c.rssize/POWER(2,10),1)||' K'
                      ELSE c.rssize  || ' B' END 
                  ,1, 20
                ) RSSIZE,
         d.name, c.extents
    FROM gv$session a,
         gv$transaction b,
         gv$rollstat c,
         v$rollname d
   WHERE     a.saddr = b.ses_addr
         AND a.inst_id = b.inst_id
         AND b.inst_id = c.inst_id
         AND b.xidusn = c.usn
         AND b.xidusn = d.usn
ORDER BY b.used_ublk DESC
/



