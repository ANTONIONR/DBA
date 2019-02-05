--  ----------------------------------------------------------------------------------------------------
--
--  FILE NAME      : GENERATE_KILLER.SQL
--  DESCRIPTION    :  >>>> SE CALCULA TODO EN MEGAS Y REDONDEADO A 4 DECIMALES
--  AUTHOR         : Antonio NAVARRO - /\/\/
--  CREATE         : 25.04.00
--  LAST MODIFIED  : 25.04.00
--  USAGE          : This script asks for a user and generates an exit with the commands to kill all 
--                   the connections of the indicated user. The script is killed from the OS using 
--                   native commands, except in the case of windows that makes it alter systems
--  CALL SYNTAXIS  : @generate_killer.sql
--  [NOTES]        :
--   
--  ----------------------------------------------------------------------------------------------------

 

-- alter session disable commit in procedure;


set verify off
set linesize 1000
set pagesize 1000
set serveroutput on size 50000
accept Usuario prompt 'Usuario: '

declare

   /********************** DECLARATION OF CURSORS **************************/
   
        /* Cursor of the person to be eliminated with all their sessions */
   		CURSOR persona_a_eliminar IS
		SELECT  SID, SERIAL#, USERNAME, OSUSER, PROGRAM
		FROM    V$SESSION
		WHERE   USERNAME = LTRIM(RTRIM(UPPER('&USUARIO')));


		/* Cursor that looks for the ID of the process in memory */
		
        CURSOR persona_proceso IS
		SELECT  SPID, A.SID, A.USERNAME, A.OSUSER, A.PROGRAM, A.MACHINE
		FROM    V$SESSION A,
		        V$PROCESS B
		WHERE   A.PADDR = B.ADDR AND
		        A.USERNAME = LTRIM(RTRIM(UPPER('&USUARIO'))); 	
		
   /*************** VARIABLES FOR THE CURSOR *****************/
   AUX_SID          NUMBER;               /* SID        */
   AUX_SERIAL       NUMBER;               /* SERIAL     */
   AUX_USERNAME     VARCHAR2(30);         /* USERNAME   */
   AUX_OSUSER       VARCHAR2(15);         /* OS USER    */
   AUX_PROGRAM      VARCHAR2(64);         /* PROGRAM    */
   AUX_MACHINE      VARCHAR2(64);         /* MACHINE    */
   
   AUX_SPID         VARCHAR2(9);          /* SPID     */
   
		
   /************ VARIABLE FOR DETERMINE S.O. **************/
   LongCadena       INTEGER;		         /* LENTGH OF STRING        */  
   I                INTEGER;		         /* COUNTER                 */ 
   NombreFichero    VARCHAR2(513);	     /* NAME OF LAST DBF        */ 
   Salir          	BOOLEAN;	    	     /*  VARIABLE BOOLEAN       */
   EsNT         	  BOOLEAN := FALSE;	   /* FLAG IS WINDOWS         */
   EsUNIX       	  BOOLEAN := FALSE;	   /* FLAG IS UNIX.           */
   EsVMS        	  BOOLEAN := FALSE;	   /* FLAG IS VMS.            */
   Caracter         CHAR;		    	       /* POINTER INSIDE STRING   */
   
   
   /********************** Other variables ************************/
   CadenaDeTexto    VARCHAR2(50);
   Longitud	        NUMBER;	
begin
   

   /* we determine the operating system on which the script is running. For   */
   /* this we obtain the name of the last dbf that was created                */
   SELECT FILE_NAME 
   INTO NombreFichero
   FROM DBA_DATA_FILES 
   WHERE FILE_ID = (SELECT MAX (FILE_ID)
                    FROM DBA_DATA_FILES);
	
   -- Get the length of filename ---------------
   LongCadena := LENGTH (NOMBREFICHERO);			
   
   -- Get the OS --------------
   I := 1;
   SALIR := FALSE;
   WHILE (I <= LongCadena) AND (NOT SALIR) LOOP
       CARACTER := SUBSTR (NombreFichero, i, 1);
	   IF CARACTER = '\' THEN
	      DBMS_OUTPUT.PUT_LINE ('>>>> IS WINDOWS');
		  SALIR := TRUE;
		  EsNT := TRUE;
	   END IF;
	   IF CARACTER = '/' THEN
	      DBMS_OUTPUT.PUT_LINE ('>>>> IS UNIX');
		  SALIR := TRUE;
		  EsUNIX := TRUE;
	   END IF;
	   IF CARACTER = '[' THEN
	      DBMS_OUTPUT.PUT_LINE ('>>>> IS OpenVMS');
		  SALIR := TRUE;
		  EsVMS := TRUE;
	   END IF; 
	   I := I + 1;
   END LOOP;
   
   /* Print banner */
   DBMS_OUTPUT.PUT_LINE ('--------------------------------------');
   DBMS_OUTPUT.PUT_LINE ( CHR (10));
   
   /************************ PROCCESS FOR WINDOWS ***********************/
   IF EsNT THEN
       OPEN Persona_a_eliminar;
	   LOOP 
	      FETCH Persona_a_eliminar INTO AUX_SID, AUX_SERIAL, AUX_USERNAME, AUX_OSUSER, AUX_PROGRAM;
              EXIT WHEN Persona_a_eliminar%NOTFOUND;
		  
		  CadenaDeTexto := 'ALTER SYSTEM KILL SESSION ''' || AUX_SID || ', ' || AUX_SERIAL || ''';';
		  Longitud := length (CadenaDeTexto);
		  
		  DBMS_OUTPUT.PUT (CadenaDeTexto);
		  FOR i IN Longitud + 1..60 LOOP
		      DBMS_OUTPUT.PUT (' '); 
		  END LOOP; 
		  DBMS_OUTPUT.PUT_LINE (AUX_USERNAME || '    ' || AUX_OSUSER || '    ' || AUX_PROGRAM);
		  
		 /* GENERATE USER TO KILL */
		 DBMS_OUTPUT.PUT_LINE ('ALTER SYSTEM KILL SESSION ''' || AUX_SID || ', ' || AUX_SERIAL || ''';' || '     ' || AUX_USERNAME || '    ' || AUX_OSUSER || '    ' || AUX_PROGRAM);
	   END LOOP;
	   CLOSE Persona_a_eliminar;
   END IF;  
	 
   /**************************** PROCCESS FOR UNIX/LINUX **************************/
   IF EsUNIX THEN
    
	  /* We generate the sentences to kill from the S.O. */
      OPEN persona_proceso;
	  LOOP
	     FETCH persona_proceso INTO AUX_SPID, AUX_SID, AUX_USERNAME, AUX_OSUSER, AUX_PROGRAM, AUX_MACHINE; 
		 EXIT WHEN persona_proceso%NOTFOUND;
		 DBMS_OUTPUT.PUT_LINE ('kill -9 ' || AUX_SPID);		 
		 
		 CadenaDeTexto := 'kill -9 ' || AUX_SPID;
                 Longitud := length (CadenaDeTexto);
		  
		 DBMS_OUTPUT.PUT (CadenaDeTexto);
		 FOR i IN Longitud + 1..25 LOOP
		     DBMS_OUTPUT.PUT (' '); 
		 END LOOP; 
		 DBMS_OUTPUT.PUT_LINE (AUX_SID || '     ' || AUX_USERNAME || '    ' || AUX_OSUSER || '    ' || AUX_PROGRAM || '    ' || AUX_MACHINE);
	  END LOOP;
	  CLOSE persona_proceso;
   END IF; 	
   
   /**************************** PROCCESS FOR OpenVMS ***********************/
   IF EsVMS THEN
   
      /* We generate the sentences to kill from the S.O. */
      OPEN persona_proceso;
	  LOOP
	     FETCH persona_proceso INTO AUX_SPID, AUX_SID, AUX_USERNAME, AUX_OSUSER, AUX_PROGRAM, AUX_MACHINE;  
		 EXIT WHEN persona_proceso%NOTFOUND;
		 DBMS_OUTPUT.PUT_LINE ('stop /id=' || AUX_SPID);		 
		 
		 CadenaDeTexto := 'stop /id=' || AUX_SPID;
                 Longitud := length (CadenaDeTexto);
		  
		 DBMS_OUTPUT.PUT (CadenaDeTexto);
		 FOR i IN Longitud + 1..25 LOOP
		     DBMS_OUTPUT.PUT (' '); 
		 END LOOP; 
		 DBMS_OUTPUT.PUT_LINE (AUX_SID || '     ' || AUX_USERNAME || '    ' || AUX_OSUSER || '    ' || AUX_PROGRAM || '    ' || AUX_MACHINE); 
	  END LOOP;
	  CLOSE persona_proceso;
   END IF;
end;
/

