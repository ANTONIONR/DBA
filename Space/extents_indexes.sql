
--  ----------------------------------------------------------------------------------------------------
--
--  FILE NAME      : EXTENTS_INDEXES.SQL
--  DESCRIPTION    : Check indexes with extents < number asked
--  AUTHOR         : Antonio NAVARRO - /\/\/
--  CREATE         : 01.03.2000
--  LAST MODIFIED  : 01.03.2000
--  USAGE          : Check indexes with extents < number asked. It offer a possible ampliation
--  CALL SYNTAXIS  : @extents_indexes.sql
--  [NOTES]        :
--   
--  ----------------------------------------------------------------------------------------------------


prompt .
ACCEPT extensiones PROMPT 'NUMBER OF EXTENSIONS?   : '

SET VERIFY OFF 
SET LINESIZE 1000
SET PAGESIZE 1000


select 
   t.owner as "Owner", 
   t.index_name as "Index Name", 
   t.max_extents - s.extents as "Free Ext." ,
   'alter index ' || t.owner ||'.'|| t.index_name || ' storage (maxextents ' || to_char (s.extents + 519) || ');' as "Offer"
from dba_indexes t, dba_segments s
where
t.owner = s.owner and t.index_name = s.segment_name and 
t.MAX_EXTENTS < (s.extents + &extensiones)
order by 3 asc
/

     



     