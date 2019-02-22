

--  ----------------------------------------------------------------------------------------------------
--
--  FILE NAME      : EXTENTS_TABLES.SQL
--  DESCRIPTION    : Check tables with extents < number asked
--  AUTHOR         : Antonio NAVARRO - /\/\/
--  CREATE         : 01.03.2000
--  LAST MODIFIED  : 01.03.2000
--  USAGE          : Check tables with extents < number asked. It offer a possible ampliation
--  CALL SYNTAXIS  : @extents_tables.sql
--  [NOTES]        :
--   
--  ----------------------------------------------------------------------------------------------------



prompt .
ACCEPT extensiones PROMPT 'EXTENSIONS NUMBER?   : '

SET VERIFY OFF 
SET LINESIZE 1000
SET PAGESIZE 1000

select 
  t.owner as "Owner", 
  t.table_name as "Table Name", 
  t.max_extents - s.extents as "Free Ext.", 
  'alter table ' || t.owner ||'.'|| t.table_name || ' storage (maxextents ' || to_char (s.extents + 519) || ');' as "Offer"
from dba_tables t, dba_segments s
where
t.owner = s.owner and t.table_name = s.segment_name and 
t.MAX_EXTENTS < (s.extents + &extensiones)
order by 3 asc
/

     