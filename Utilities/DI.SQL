--  ----------------------------------------------------------------------------------------------------
--
--  FILE NAME      : di.sql
--  DESCRIPTION    : Look for a table into the Oracle Dict
--  AUTHOR         : Antonio NAVARRO - /\/\/
--  CREATE         : 30.11.00
--  LAST MODIFIED  : 28.10.11
--  USAGE          : Look for a table into the Oracle Dict
--  CALL SYNTAXIS  : @di.sql
--  [NOTES]        : 
--   
--  ----------------------------------------------------------------------------------------------------


COLUMN "Table Name" FORMAT A25
COLUMN "DESCRIPTION"  FORMAT A500

SELECT  TABLE_NAME AS "NOMBRE TABLA",
        COMMENTS   AS "DESCRIPCION"
FROM    DICT
WHERE   TABLE_NAME LIKE '%&1%'; 

