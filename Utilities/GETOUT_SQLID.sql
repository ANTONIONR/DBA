
--  ----------------------------------------------------------------------------------------------------
--
--  FILE NAME      : GETOUT_SQLID.SQL
--  DESCRIPTION    : This script flush a sqlid from library cache
--  AUTHOR         : Antonio NAVARRO - /\/\/
--  CREATE         : 16.10.14
--  LAST MODIFIED  : 16.10.14
--  USAGE          : This script flush a sqlid. Parameter 1 is the sqlid to flush from library cache
--  CALL SYNTAXIS  : @getout_sqlid.sql  sqlid
--  [NOTES]        :
--   
--  ----------------------------------------------------------------------------------------------------


SET FEED OFF VER OFF LIN 32767 PAGES 0 TIMI OFF LONG 32767000 LONGC 32767 TRIMS ON AUTOT OFF;
SET SERVEROUT ON SIZE UNLIMITED;


PRO
PRO 1. Enter SQLID (required)
DEF p_SQLID = '&&1';
PRO



VAR SQLID     VARCHAR2(13);



DECLARE
  
  exit_return        BINARY_INTEGER;      /* Check the control return by the call to the procedure */
  A_ADDRESS          RAW (8);             /* Addres for a SQLID */
  A_HASH_VALU        NUMBER (20);         /* Hash_value for a SQLID */


BEGIN
  -- assign variables 
  :SQLID  := '&&p_SQLID';
  
    
  SELECT ADDRESS, HASH_VALUE 
  INTO  A_ADDRESS, A_HASH_VALU
  FROM V$SQLAREA WHERE SQL_ID = :SQLID;

  SYS.DBMS_SHARED_POOL.PURGE ('' || A_ADDRESS ||',' || A_HASH_VALU || '', 'C'); 
  

END;
/


