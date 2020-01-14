
-- ----------------------------------------------------------------------------------------------------
--
--  FILE NAME      : KILLER.SQL
--  DESCRIPTION    : Generate commands to eliminate sessions
--  AUTHOR         : Antonio NAVARRO - /\/\/
--  CREATE         : 28.10.99
--  LAST MODIFIED  : 28.10.99
--  USAGE          : This script inputs two parameters. Parameter 1 is sid or an username or a sqlid
--                   Parameter 2 is the way of eliminate the conection. Kill command, Disconnect 
--                   command, kill from Operating System command, or ALL, show all options
--                   Default option for parameter 2 is DISCONNECT
--
--
--  CALL SYNTAXIS  : @killer.sql  <sid> | <username> | <sqlid>  [KILL | DISCONNECT | OS | ALL]
--  [NOTES]        :
--         
--                 DBA role is recommended to run this scrit
--                 Select on this views is necessary
--                        gv$session
--                        gv$procress
--                        gv$instance
--                        v$parameter
--
            
set serveroutput on size unlimited

SET FEED OFF VER OFF LIN 32767 PAGES 0 TIMI OFF LONG 32767000  TRIMS ON AUTOT OFF;
SET SERVEROUTPUT ON SIZE 50000

-- Read the first parameteR
PRO
PRO 1. Enter SID or USERNAME or SQLID (required)
DEF E_Parameter1 = '&&1';

-- Read the second parameter, if not values is specified el default is DISCONNECT
COL 2 new_value 2 noprint
select '' "2" from dual where rownum = 0;
DEF E_Parameter2 = &&2 "DISCONNECT"

PRO 



VAR Parameter1 VARCHAR2(20);
VAR Parameter2 VARCHAR2(20);

declare
  
  DEBUG          BOOLEAN  :=   FALSE;

  /* Global variables */
  IsRAC          BOOLEAN  :=   FALSE;          /* Flag is RAC enviroment */ /* used at global level */
  IsMTS          BOOLEAN  :=   FALSE;          /* Flag is MTS */ /* used at global level */
  OracleVersion  NUMBER   :=   10;             /* Version oracle */

  IsSID          BOOLEAN  :=   FALSE;          /* Flag is SID */
  IsSQLID        BOOLEAN  :=   FALSE;          /* Flag is SQLID */  
  IsUSERNAME     BOOLEAN  :=   FALSE;          /* Flag is USERNAME */
  
  Is_Kill          BOOLEAN  :=   FALSE;        /* Flag is eliminate wih Kill option */
  Is_Disconnect    BOOLEAN  :=   FALSE;        /* Flag is eliminate with Disconnect option */
  Is_OS            BOOLEAN  :=   FALSE;        /* Flag is eliminate from OS option */ 

  -- Array for procces the gv$session          /* used at gloabl level */
  type V_Inst_id IS VARRAY(5000) OF INTEGER;
  type V_SID     IS VARRAY(5000) OF INTEGER;
  type V_SERIAL  IS VARRAY(5000) OF INTEGER;

  list_V_Inst_id V_Inst_id;                    /* used at global level */
  list_V_SID     V_SID;
  list_V_SERIAL  V_SERIAL;
  
  Param2Action   PLS_INTEGER := 2;             /* 1 KILL, 2 DISCONNECT, 3 OS, 4 ALL */ /* Used at global level */
 
  /* This function check if is a number o is text */
  FUNCTION is_number (StringTest IN VARCHAR2) RETURN BOOLEAN IS
     Test NUMBER;
  BEGIN
     Test := TO_NUMBER(StringTest);
     RETURN (TRUE);
  EXCEPTION
    WHEN OTHERS THEN RETURN (FALSE);
  END;  


  /* Is a SID */
  FUNCTION Is_SID (PossibleSid IN NUMBER) RETURN BOOLEAN IS
    Occurences NUMBER;
  BEGIN
    SELECT COUNT (*) INTO Occurences FROM GV$SESSION WHERE SID = PossibleSid;
    IF Occurences = 0 THEN RETURN (FALSE);
    ELSE RETURN (TRUE);
    END IF;
  END;
  

  /* Is a username, use v$session because is most faster than dba_users */
  FUNCTION Is_Username (PossibleUsername IN VARCHAR2) RETURN BOOLEAN IS
      Occurences NUMBER;
  BEGIN
    SELECT COUNT (*) INTO Occurences FROM GV$SESSION WHERE USERNAME = UPPER (PossibleUsername);
    IF Occurences = 0 THEN RETURN (FALSE);
    ELSE RETURN (TRUE);
    END IF;
  END;


  /* Is a sqlid at first level, second level check in v$sql */
  FUNCTION Is_SQLID (PossibleSQLID IN VARCHAR2) RETURN BOOLEAN IS
      Occurences NUMBER;
  BEGIN
    SELECT COUNT (*) INTO Occurences FROM GV$SESSION WHERE SQL_ID = PossibleSQLID;
    IF Occurences = 0 THEN RETURN (FALSE);
    ELSE RETURN (TRUE);
    END IF;
  END;


  /* Is RAC enviroment */
  FUNCTION Is_RAC RETURN BOOLEAN IS
      Occurences NUMBER;
  BEGIN
    SELECT COUNT (*) INTO Occurences FROM GV$INSTANCE;
       IF Occurences = 1 THEN RETURN (FALSE);
    ELSE RETURN (TRUE);
    END IF;
  END;


  /* Get Instances number */
  FUNCTION Get_Number_Of_Nodes RETURN NUMBER IS
      Occurences NUMBER;
  BEGIN
    SELECT COUNT (*) INTO Occurences FROM GV$INSTANCE;
    RETURN (Occurences);
  END;


  /* Get if MultiThread Server is enable*/
  FUNCTION Is_MTS RETURN BOOLEAN IS 
      Occurences NUMBER;
  BEGIN
      SELECT COUNT (*) INTO Occurences FROM GV$DISPATCHER;
      IF Occurences > 0 THEN RETURN (TRUE);
      ELSE RETURN (FALSE);
      END IF;
  END;

  /* Get OS type*/
  FUNCTION Get_OS RETURN VARCHAR IS

     NombreFichero        VARCHAR2(513);		-- NOMBRE DEL ULTIMO DATAFILE CREADO.
     I                    INTEGER;                -- VARIABLE CONTADOR.
     LongCadena           INTEGER;		-- LONGITUD DE LA CADANA NombreFichero.
     Caracter             CHAR;			-- CONTIENE UN SOLO CARACTER .
   
  BEGIN
    -------------------------------------------------
    -- PREVIAMENTE HA HACER NADA OBTENEMOS EL S.O. --
    -------------------------------------------------
    -- obtenemos el nombre del ultimo datafile creado -------
    SELECT FILE_NAME 
    INTO NombreFichero
    FROM DBA_DATA_FILES 
    WHERE FILE_ID = (SELECT MAX (FILE_ID)
                     FROM DBA_DATA_FILES);
	  
    -- Obtenemos la longitud de la cadena ---------------
    LongCadena := LENGTH (NOMBREFICHERO);			
    
    -- Investigamos que tipo de maquina es --------------
    I := 1;
    WHILE (I <= LongCadena)  LOOP
        CARACTER := SUBSTR (NombreFichero, i, 1);
	    IF CARACTER = '\\' THEN
	       RETURN ('WINTEL');		  
	    END IF;
	    IF CARACTER = '/' THEN
	       RETURN ('UNIX');
	    END IF;
	    IF CARACTER = '[' THEN
	       RETURN ('OPENVMS');
	    END IF; 
	    I := I + 1;
    END LOOP;
    RETURN ('NONE');
  END;



  PROCEDURE Separator_Line IS
  BEGIN
     DBMS_OUTPUT.PUT_LINE (CHR(10));
  END;
  
  PROCEDURE Show_Help IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE (CHR(10));
    DBMS_OUTPUT.PUT_LINE ('Please use as show below; ');
    DBMS_OUTPUT.PUT_LINE (CHR(10));
    DBMS_OUTPUT.PUT_LINE ('@killer.sql  <sid> | <username> | <sqlid>    [KILL | DISCONNECT | OS | ALL]');
    DBMS_OUTPUT.PUT_LINE (CHR(10));
  END;
  
  
  
  PROCEDURE Show_Error_Parse IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE ('No SID, USER or SQLID match with parameter 1 !!! ');  	
  	Show_Help;    
  END;
  
     
  -- Generate the script for Disconnect 
  PROCEDURE Generate_Disconnect (DSID IN NUMBER, DSERIAL IN NUMBER, DINSTANCE IN NUMBER DEFAULT 0) IS
  BEGIN
    IF DINSTANCE = 0 THEN   -- Is stand-alone
       DBMS_OUTPUT.PUT_LINE ('ALTER SYSTEM DISCONNECT SESSION ''' || DSID || ',' || DSERIAL || ''' IMMEDIATE;');
    ELSE  -- IS RAC, NEED INSTANCE ID
       DBMS_OUTPUT.PUT_LINE ('ALTER SYSTEM DISCONNECT SESSION ''' || DSID || ',' || DSERIAL || ',' || DINSTANCE || ''' IMMEDIATE;');
    END IF; 
  END;

  -- Generate the script for Kill 
  PROCEDURE Generate_Kill (DSID IN NUMBER, DSERIAL IN NUMBER, DINSTANCE IN NUMBER DEFAULT 0) IS
  BEGIN
    IF DINSTANCE = 0 THEN   -- Is stand-alone
       DBMS_OUTPUT.PUT_LINE ('ALTER SYSTEM KILL SESSION ''' || DSID || ',' || DSERIAL || ';');    
    ELSE  -- IS RAC, NEED INSTANCE ID
       DBMS_OUTPUT.PUT_LINE ('ALTER SYSTEM KILL SESSION ''' || DSID || ',' || DSERIAL || ',' || DINSTANCE || ';');
    END IF;
  END;


  PROCEDURE Show_Offer  IS
    Total    NUMBER;         -- Number of elements to eliminate
    OS       VARCHAR2 (10);  -- Operating System
    INSTAN   VARCHAR2 (20);  -- Instance name from executed this code
  BEGIN

    Total := list_V_SID.count;
    
    -- Kill or all actions  
    IF (Param2Action = 1) OR (Param2Action = 4) THEN
       IF NOT IsMTS THEN -- Kill eliminate the Shared Server and elimited all connections using this server
          -- Kill 
          FOR i in 1 .. Total LOOP      
              IF IsRAC THEN Generate_Kill (list_V_SID  (i), list_V_SERIAL   (i), list_V_Inst_id (i));
              ELSE Generate_Kill (list_V_SID  (i), list_V_SERIAL   (i));
              END IF;
          END LOOP;
       ELSE
         DBMS_OUTPUT.PUT_LINE ('>>> MTS IS IN USE. SHARED SERVER CAN NOT BE ELIMINATE !!!'); 
       END IF;
       Separator_Line;
    END IF;
    
    -- Disconnect or all actions, too default action    
    IF (Param2Action = 2) OR (Param2Action = 4) THEN
        -- Disconnect
        FOR i in 1 .. Total LOOP             
            IF IsRAC THEN Generate_Disconnect (list_V_SID  (i), list_V_SERIAL   (i), list_V_Inst_id (i));
            ELSE Generate_Disconnect (list_V_SID  (i), list_V_SERIAL   (i));
            END IF;
        END LOOP;
        Separator_Line;
    END IF;           

    -- OS or all actions
    IF (Param2Action = 3) OR (Param2Action = 4) THEN
        -- Disconnect
        FOR i in 1 .. Total LOOP                                     
   
           OS := Get_OS;
           FOR j IN
           (
               SELECT s.inst_id,                             
                      p.spid       
               FROM   
                      gv$session s JOIN gv$process p ON p.addr = s.paddr 
                      AND p.inst_id = s.inst_id 
                      AND s.sid = list_V_SID  (i)
                      AND s.serial# = list_V_SERIAL   (i)      
               WHERE  s.type != 'BACKGROUND' -- Prevent of kill Oracle daemons
            )
            LOOP
               CASE
                  WHEN OS = 'WINTEL' THEN                                      
                                  SELECT VALUE INTO INSTAN FROM V$PARAMETER WHERE NAME = 'instance_name';
                                  dbms_output.put_line('orakill ' || instan || ' ' || j.spid);                                                                             
                  WHEN OS = 'UNIX' THEN 
                              IF IsRAC THEN  dbms_output.put_line('kill -9 ' || j.spid || '        ### IN INSTANCE_NUMBER ' || j.inst_id);                                 
                              ELSE dbms_output.put_line('kill -9 ' || j.spid);
                              END IF;
                  WHEN OS = 'OPENVMS' THEN dbms_output.put_line('STOP /ID=' || j.spid);   
                  ELSE dbms_output.put_line('NADA DE NADA');
               END CASE;
            END LOOP;  -- j index

         END LOOP;
         Separator_Line;
     END IF;   -- OS or all actions                   

  END;  -- SHOW_OFFER


  PROCEDURE Generate_Script_For_SID (XSID IN NUMBER)  IS
  BEGIN
    SELECT INST_ID, SID, SERIAL# BULK COLLECT INTO list_V_Inst_id, list_V_SID, list_V_SERIAL FROM GV$SESSION WHERE SID = XSID; 
    Show_Offer;
  END;

  
  PROCEDURE Generate_Script_For_Username (XUSERNAME IN VARCHAR2 ) IS
  BEGIN
  
    SELECT INST_ID, SID, SERIAL# BULK COLLECT INTO list_V_Inst_id, list_V_SID, list_V_SERIAL FROM GV$SESSION WHERE USERNAME = UPPER (XUSERNAME); 
    Show_Offer;
  END;


  PROCEDURE Generate_Script_For_SQLID (XSQLID IN VARCHAR2) IS
  BEGIN
    SELECT INST_ID, SID, SERIAL# BULK COLLECT INTO list_V_Inst_id, list_V_SID, list_V_SERIAL FROM GV$SESSION WHERE SQL_ID = XSQLID; 
    Show_Offer;                                                                                                                        
  END;	                                                                                                                                        
 

BEGIN               /* * *    M A I N    * * */
	
  :Parameter1 := '&&E_Parameter1';    
  :Parameter2 := '&&E_Parameter2';


  /* Assing value to IsRAC flag */
  IF Is_RAC THEN IsRAC := TRUE;  
  ELSE IsRAC := FALSE;  
  END IF;
  

  /* Assing value to IsMTS flag */
  IF Is_MTS THEN IsMTS := TRUE; 
  ELSE IsMTS := FALSE; 
  END IF;
  
  
  -- Phase parse Parameter 1
  IF Is_Number (:Parameter1) THEN  /*** Maybe SID ***/
     IF Is_SID (:Parameter1) THEN IsSID := TRUE;
     ELSE   Show_Error_Parse;           
     END IF;
  ELSE /*** May SQLID or USERNAME ***/
     IF Is_Username (:Parameter1) THEN IsUSERNAME := TRUE;
     ELSE IF Is_SQLID (:Parameter1) THEN IsSQLID := TRUE;
          ELSE Show_Error_Parse;             
          END IF;
     END IF; 
  END IF;


  -- Phase parse Parameter 2  KILL | DISCONNECT | OS | ALL
  IF  UPPER (:Parameter2) = 'KILL' THEN     
     Param2Action := 1;
  ELSE IF UPPER (:Parameter2) = 'DISCONNECT' THEN        
          Param2Action := 2;
       ELSE IF UPPER (:Parameter2) = 'OS' THEN
               Param2Action := 3;
            ELSE IF UPPER (:Parameter2) = 'ALL' THEN
                    Param2Action := 4;
                 ELSE             
                    Param2Action := 2;
                 END IF;
            END IF;
       END IF;     
  END IF;
 
 
  -- We have a positive SID, SQLID OR SESSION to eliminate 
  -- Get all data asociated  SID, SERIAL#, INST_ID 
  
  IF IsSID THEN
     Generate_Script_For_SID (:Parameter1);
  ELSE IF IsUSERNAME THEN
          Generate_Script_For_Username (:Parameter1);
       ELSE IF IsSQLID THEN
               Generate_Script_For_SQLID (:Parameter1);
            ELSE -- Parameter 1 no match anything, terminate execution 
               RETURN;
            END IF;
       END IF;
  END IF;
  

END;  /* MAIN */
/



undef E_Parameter1
undef E_Parameter2
undef 2

