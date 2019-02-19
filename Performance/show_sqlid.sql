
--  ----------------------------------------------------------------------------------------------------
--
--  FILE NAME      : SHOW_SQLID.SQL
--  DESCRIPTION    : Show sql text for sqlid
--  AUTHOR         : Antonio NAVARRO - /\/\/
--  CREATE         : 23.11.17
--  LAST MODIFIED  : 23.11.17
--  USAGE          : Show sql text for sqlid passed as parameter plus scripts
--  CALL SYNTAXIS  : @show_sqlid.sql 95473353
--  [NOTES]        :
--   
--  ----------------------------------------------------------------------------------------------------

set verify off
column sql_text format a120

select 
--   sqltext.piece piece , 
  sqltext.address address,
  sqltext.hash_value hash_value ,
  sqltext.sql_text sql_text
from
  v$sqltext sqltext
where 
    sqltext.sql_id= '&1'     
order by sqltext.piece asc 
/

-- LINKS 
set head off 
select 
   '---------------------------------------------- Quick Scripts -------------------------------------------------' || chr (10)  ||  ' ' || chr (10) || 
   '@show_hash_plan '          ||  hash_value  ||
   '           @show_sql_id  '        ||  hash_value  ||
   '            @show_plan2          '  ||  hash_value  ||   chr (10) || 
   '@ver_plan_raw  '           || hash_value  ||  
   '            @show_plan_10 '         ||  hash_value  ||
   '            @show_plan_raw_smart '  || hash_value  || chr (10) ||
   '@bind_variables ' || sql_id || '       @show_paramet ' ||  sql_id    || '        @sqladv '  || sql_id ||  CHR (10) ||
   '@sqladvawr ' || sql_id   || CHR (10) || ' ' || chr (10) || 
   '--------------------------------------------------------------------------------------------------------------'
from
  v$sqltext
where 
   sql_id= '&&1'  and piece = 1 
/




set head on

