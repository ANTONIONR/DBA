--  ----------------------------------------------------------------------------------------------------
--
--  FILE NAME      : changepass.sql
--  DESCRIPTION    : Change pass in all database register in a table
--  AUTHOR         : Antonio NAVARRO - /\/\/
--  CREATE         : 01.03.00
--  LAST MODIFIED  : 06.01.18
--  USAGE          : This script change the password (for user who execute the script) in all databases
--                   register in a table (used like repository)
--  CALL SYNTAXIS  : @changepass.sql 
--  [NOTES]        : 
--   
--  ----------------------------------------------------------------------------------------------------



ACCEPT ACTUAL PROMPT 'PASSWORD ACTUAL   : ' HIDE
ACCEPT PASS1  PROMPT 'PASSWORD NUEVA    : ' HIDE
ACCEPT PASS2  PROMPT 'CONFIRMAR PASSORD ; ' HIDE
ACCEPT CLAVE1 PROMPT 'CLAVE SECRETA     ; ' HIDE
ACCEPT CLAVE2 PROMPT 'CLAVE PUBLICA     ; ' HIDE



SET SERVEROUTPUT ON SIZE 40000
SET VERIFY OFF 
SET TIMING OFF
SET TERMOUT OFF
SET LINESIZE 1000
SET PAGESIZE 0
SET FEEDBACK OFF


/* Load the RSA algorithme, it is a version mine derive for RSA standard */
@C:\ORANT\DBS\RSA4.SQL

SPOOL C:\CAMBZXZW.SQL

DECLARE
  
  /*** Cursor for read the connect strings  ***/
  /*** The data are encripted by my version of RSA, desencripta function get the data in clear ***/
  CURSOR listado_de_bd is
  SELECT DESENCRIPTA (CONESTRING, &CLAVE1, &CLAVE2)
  FROM   ANTONION."BBDDS   ";
  
  
  USUARIO       VARCHAR2(20);		/* User who run the script */
  PassAntigua	  VARCHAR2(30);   /* Password old, hashed */
  PassNueva     VARCHAR2(30);		/* Password new, hashed */
  Cur           INTEGER;		    /* For execute sql sentences */
  PassEnClaro   VARCHAR2(20);   /* Password in clear. */
  ConeString    VARCHAR2(20);		/* Connect string */
  PassActual    VARCHAR2(20);		/* Password actually */
BEGIN
  IF UPPER('&PASS1') = UPPER('&PASS2') THEN
     DBMS_OUTPUT.PUT_LINE (CHR (10));
     
     
     /*** Set pass in clear ***/
     PassEnClaro := '&pass1';
     PassActual  := '&actual';
     
     
     /*** Get current user ***/
     SELECT USER
     INTO   USUARIO
     FROM   DUAL;
     
     
     /*** Get the old pass ***/
     SELECT PASSWORD 
     INTO   PassAntigua
     FROM   DBA_USERS
     WHERE  USERNAME = UPPER (USUARIO);
     
     
     /*** Generate the new pass ***/
     CUR := DBMS_SQL.OPEN_CURSOR;
     DBMS_SQL.PARSE (CUR,'ALTER USER ' || USUARIO || ' IDENTIFIED BY ' || PassEnClaro, DBMS_SQL.V7);
     DBMS_SQL.CLOSE_CURSOR (CUR);
     
     
     /*** Get the new pass ***/
     SELECT PASSWORD 
     INTO   PassNueva
     FROM   DBA_USERS
     WHERE  USERNAME = UPPER (USUARIO);
     
     
     /*** Restore old pass ***/
     CUR := DBMS_SQL.OPEN_CURSOR;
     DBMS_SQL.PARSE (CUR,'ALTER USER ' || USUARIO || ' IDENTIFIED BY VALUES ''' || PassAntigua || '''', DBMS_SQL.V7);
     DBMS_SQL.CLOSE_CURSOR (CUR);
    
     
     /*** Generate the script, will be execute like last step ***/
     OPEN Listado_de_bd;
     
     DBMS_OUTPUT.PUT_LINE (CHR (10));
     LOOP
        FETCH Listado_de_bd INTO ConeString;
        EXIT WHEN Listado_de_bd%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE (' PROMPT >>> CONECTING TO ' || UPPER(ConeString)); 
        DBMS_OUTPUT.PUT_LINE ('CONNECT ' || UPPER(USUARIO) || '/' || UPPER(PassActual) || '@' || UPPER(ConeString));
        DBMS_OUTPUT.PUT_LINE ('ALTER USER ' || USUARIO || ' IDENTIFIED BY VALUES ''' || PassNueva || ''';'); 
     END LOOP;
  
     /*** Connect to repository table ***/
     DBMS_OUTPUT.PUT_LINE ('CONNECT ' || UPPER(USUARIO) || '/' || UPPER('&PASS1') || '@SIGA');
     
     DBMS_OUTPUT.PUT_LINE (CHR(10));
     CLOSE Listado_de_bd;
     
  ELSE
     DBMS_OUTPUT.PUT_LINE (CHR (10));
     DBMS_OUTPUT.PUT_LINE ('PROMPT ');
     DBMS_OUTPUT.PUT_LINE ('PROMPT >>>> ERROR, Passwords are differents ');
  END IF;  
END;
/


SPOOL OFF
SET TERMOUT ON

-- Execute the file generated, connect db by db and update pass
@C:\CAMBZXZW.SQL

-- Delete file a OS level, It is high recomendable perform delete a physical level
HOST DEL C:\CAMBZXZW.SQL


SET TERMOUT OFF

DROP FUNCTION DESENCRIPTA;

SET TERMOUT ON

SET PAGESIZE 1000
SET FEEDBACK ON
SET LINESIZE 1000
SET TIMING ON
