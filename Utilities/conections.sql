--  ----------------------------------------------------------------------------------------------------
--
--  FILE NAME      : connections.sql
--  DESCRIPTION    : Return the connections against a database
--  AUTHOR         : Antonio NAVARRO - /\/\/
--  CREATE         : 11.08.03
--  LAST MODIFIED  : 28.10.11
--  USAGE          : For capacity planning and licenses purposes
--  CALL SYNTAXIS  : @connections.sql
--  [NOTES]        : 
--   
--  ----------------------------------------------------------------------------------------------------


WHENEVER OSERROR EXIT 2


SET FEED OFF VER OFF LIN 32767 PAGES 0 TIMI OFF LONG 32767000 LONGC 32767 TRIMS ON AUTOT OFF;
SET SERVEROUT ON SIZE UNLIMITED;



SELECT 
 rpad(c.name||':',11)|| 
 rpad(' Conexiones actuales: '||(to_number(b.sessions_current)),30)||
'Conexiones acumuladas: '||rpad(substr(a.value,1,10),10)||         
'Maximo de conexiones: '||b.sessions_highwater    "Informacion de conexiones"       
FROM 
  v$sysstat a, 
  v$license b, 
  v$database c                   
WHERE 
  a.name = 'logons cumulative'                            
/

