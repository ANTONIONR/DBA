---  ----------------------------------------------------------------------------------------------------
--
--  FILE NAME      : sga_resizes.sql
--  DESCRIPTION    : Report all SGA resizes from startup
--  AUTHOR         : Antonio NAVARRO - /\/\/
--  CREATE         : 08.03.05
--  LAST MODIFIED  : 06.01.18
--  USAGE          : Usefull for see SGA pressure and set up minimal values for specifies pools
--  CALL SYNTAXIS  : @sga_resizes.sql
--  [NOTES]        : 
--   
--  ----------------------------------------------------------------------------------------------------


SET FEED OFF VER OFF LIN 32767 PAGES 1000 TIMI ON LONG 32767000 LONGC 32767 TRIMS ON AUTOT OFF;
SET SERVEROUTPUT ON SIZE UNLIMITED


COLUMN   INITIAL_SIZE_MB   FORMAT A20                          
COLUMN   TARGET_SIZE_MB    FORMAT A20
COLUMN   FINAL_SIZE_MB     FORMAT A20
COLUMN   PARAMETER         FORMAT A25
COLUMN   COMPONENT         FORMAT A35


SELECT start_time,
       end_time,
       component,
       oper_type,
       oper_mode,
       parameter,
       CASE 
         WHEN initial_size > POWER(2,50) THEN ROUND(initial_size/POWER(2,50),1)||' P'
         WHEN initial_size > POWER(2,40) THEN ROUND(initial_size/POWER(2,40),1)||' T'
         WHEN initial_size > POWER(2,30) THEN ROUND(initial_size/POWER(2,30),1)||' G'
         WHEN initial_size > POWER(2,20) THEN ROUND(initial_size/POWER(2,20),1)||' M'
         WHEN initial_size > POWER(2,10) THEN ROUND(initial_size/POWER(2,10),1)||' K'
         ELSE initial_size||' B' END AS initial_size_mb,   
       CASE                                                                    
         WHEN target_size > POWER(2,50) THEN ROUND(target_size/POWER(2,50),1)||' P' 
         WHEN target_size > POWER(2,40) THEN ROUND(target_size/POWER(2,40),1)||' T' 
         WHEN target_size > POWER(2,30) THEN ROUND(target_size/POWER(2,30),1)||' G' 
         WHEN target_size > POWER(2,20) THEN ROUND(target_size/POWER(2,20),1)||' M' 
         WHEN target_size > POWER(2,10) THEN ROUND(target_size/POWER(2,10),1)||' K' 
         ELSE target_size||' B' END AS target_size_mb,                              
       CASE                                                                    
         WHEN final_size > POWER(2,50) THEN ROUND(final_size/POWER(2,50),1)||' P' 
         WHEN final_size > POWER(2,40) THEN ROUND(final_size/POWER(2,40),1)||' T' 
         WHEN final_size > POWER(2,30) THEN ROUND(final_size/POWER(2,30),1)||' G' 
         WHEN final_size > POWER(2,20) THEN ROUND(final_size/POWER(2,20),1)||' M' 
         WHEN final_size > POWER(2,10) THEN ROUND(final_size/POWER(2,10),1)||' K' 
         ELSE final_size||' B' END AS final_size_mb,                       
       status
FROM   v$sga_resize_ops
ORDER BY start_time;

PRO 
PRO  * N O T E S * 
PRO 
PRO #1 Excessive grow and shrink actions can be a problem of insufficient memory
PRO
PRO #2 In AWR review the SGA breakdown difference Section for the interested time interval
PRO 




