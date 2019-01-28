---  ----------------------------------------------------------------------------------------------------
--
--  FILE NAME      : bgidle.sql
--  DESCRIPTION    : Background idle percentage 
--  AUTHOR         : Antonio NAVARRO - /\/\/
--  CREATE         : 11.02.01
--  LAST MODIFIED  : 08.01.18
--  USAGE          : This script return a report with idle (and busy) time for background processes 
--                   ess, a DBWx with 100% busy can be a problem the more DBW are needed.
--  CALL SYNTAXIS  : @bgidle.sql
--  [NOTES]        : 
--   
--  ----------------------------------------------------------------------------------------------------


SET FEED OFF VER OFF LIN 32767 PAGES 0 TIMI ON LONG 32767000 LONGC 32767 TRIMS ON AUTOT OFF;
SET SERVEROUTPUT ON SIZE UNLIMITED



DECLARE

  CURSOR datos IS
  SELECT 
    name,
    SE.event,
    time_waited
  FROM 
    v$session_event SE,
    v$bgprocess     BG,
    V$SESSION       S
  WHERE
    BG.PADDR <> '00'   AND
    BG.PADDR = S.PADDR AND
    S.SID    = SE.SID
  ORDER BY 1, 2;
  
  NOMBRE      VARCHAR2 (20);
  EVENTO      VARCHAR2 (80);
  VALOR       NUMBER;
  
  TOTAL       NUMBER;
  OCIOSO      NUMBER;
  NOMOLD      VARCHAR2(20);
  IDLE        NUMBER;
  
BEGIN
                                        
  DBMS_OUTPUT.PUT_LINE ('PROC' || ' ' || '   IDLE (Pct)' || ' ' || '   BUSY (Pct)');
  DBMS_OUTPUT.PUT_LINE ('____' || ' ' || '_____________' || ' ' || '_____________');
  DBMS_OUTPUT.PUT_LINE ('.');
  
  TOTAL := 0;
  IDLE := 0;
  NOMOLD := 'XXX';
  OPEN DATOS;
  LOOP
     FETCH datos INTO NOMBRE, EVENTO, VALOR;
     EXIT WHEN DATOS%NOTFOUND;
     
     IF (NOMOLD = 'XXX') THEN NOMOLD := NOMBRE;
     END IF;
     
     IF (NOMBRE != NOMOLD) THEN    
         
         DBMS_OUTPUT.PUT_LINE (NOMOLD || '       ' || TO_CHAR(ROUND ((100*IDLE)/TOTAL,2),'999.99') || '       ' ||
          TO_CHAR(ROUND (100 - ((100*IDLE)/TOTAL),2),'999.99'));
         
         NOMOLD := NOMBRE;
         TOTAL := 0;
         IDLE := 0;
     END IF;
     
     
     IF (evento = 'rdbms ipc message') OR (evento = 'pmon timer') OR (evento = 'smon timer') THEN
        IDLE :=  VALOR;
     END IF;
     
     TOTAL := TOTAL + VALOR;
     
     
   END LOOP;
   CLOSE DATOS;

   /*** Last value ***/
  DBMS_OUTPUT.PUT_LINE (NOMOLD || '       ' || TO_CHAR(ROUND ((100*IDLE)/TOTAL,2),'999.99') || '       ' ||
          TO_CHAR(ROUND (100 - ((100*IDLE)/TOTAL),2),'999.99'));
END;
/
