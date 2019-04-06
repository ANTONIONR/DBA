
--  ----------------------------------------------------------------------------------------------------
--
--  FILE NAME      : HISTOGRAM_TREAD_FILES.SQL
--  DESCRIPTION    : Genereate histogram for read time files
--  AUTHOR         : Antonio NAVARRO - /\/\/
--  CREATE         : 28.10.99
--  LAST MODIFIED  : 28.10.99
--  USAGE          : Genereate histogram for read time files
--  CALL SYNTAXIS  : @histogram_tread_files.sql 
--  [NOTES]        :
--   
--  ----------------------------------------------------------------------------------------------------

-- Identified this session
set appi /\/\/
exec dbms_application_info.set_client_info('Anavarro');


begin sys.dbms_application_info.set_module('Ext. Indra 5686', null); end;
col read_time format a9 heading "Read Time|(ms)"
col reads format 99,999,999 heading "Reads"
col histogram format a51 heading ""
set pagesize 10000
set lines 100 
set echo on 

SELECT LAG(singleblkrdtim_milli, 1) 
         OVER (ORDER BY singleblkrdtim_milli) 
          || '<' || singleblkrdtim_milli read_time, 
       SUM(singleblkrds) reads,
       RPAD(' ', ROUND(SUM(singleblkrds) * 50 / 
         MAX(SUM(singleblkrds)) OVER ()), '*')  histogram
FROM v$file_histogram
GROUP BY singleblkrdtim_milli
ORDER BY singleblkrdtim_milli; 

