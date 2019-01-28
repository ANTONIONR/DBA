--  ----------------------------------------------------------------------------------------------------
--
--  FILE NAME      : look_for_dbas.sql
--  DESCRIPTION    : Look for dbas users
--  AUTHOR         : Antonio NAVARRO - /\/\/
--  CREATE         : 15.06.01
--  LAST MODIFIED  : 06.01.18
--  USAGE          : This script look for users dbas and check if have pass = username 
--  CALL SYNTAXIS  : @look_for_dbas.sql
--  [NOTES]        : 
--   
--  ----------------------------------------------------------------------------------------------------


SET FEED OFF VER OFF LIN 32767 PAGES 1000 TIMI ON LONG 32767000 LONGC 32767 TRIMS ON AUTOT OFF;
SET SERVEROUTPUT ON SIZE UNLIMITED


REM ****************************************************************************
REM List user with DBA role
REM ****************************************************************************
DECLARE
  CURSOR roles_dba is
  SELECT 
    GRANTEE,
    ADMIN_OPTION,           
    DEFAULT_ROLE 
  FROM
    DBA_ROLE_PRIVS
  WHERE 
    GRANTED_ROLE ='DBA'
	AND GRANTEE NOT LIKE 'OPS%';
	
  ANR_GRANTEE          VARCHAR2(30);	
  ANR_ADMIN_OPTION     VARCHAR2(3);
  ANR_DEFAULT_ROLE     VARCHAR2(3);
BEGIN

  OPEN roles_dba;
  LOOP
     FETCH ROLES_DBA INTO ANR_GRANTEE, ANR_ADMIN_OPTION, ANR_DEFAULT_ROLE;
     EXIT WHEN ROLES_DBA%NOTFOUND;
	 
	   DBMS_OUTPUT.PUT_LINE (anr_grantee || '   ' || anr_admin_option || '   ' || anr_default_role );
	 
  END LOOP;
  
  CLOSE roles_dba;
  
END;
/


REM ****************************************************************************
REM Select que por si algo va mal nos dice el pass antiguo del usuario
REM ****************************************************************************

SELECT 
  username, 
  password
FROM 
  dba_users u, 
  dba_role_privs r
WHERE 
  r.grantee = u.username AND
  r.granted_role = 'DBA' AND
  r.grantee not like 'OPS%'
/


REM ****************************************************************************
REM List user with pass = username
REM ****************************************************************************
DECLARE
  CURSOR roles_dba IS
  SELECT 
    GRANTEE,
    ADMIN_OPTION,           
    DEFAULT_ROLE 
  FROM
    DBA_ROLE_PRIVS
  WHERE 
    GRANTED_ROLE ='DBA'
	AND GRANTEE NOT LIKE 'OPS%';
	
  ANR_GRANTEE         VARCHAR2(30);	
  ANR_ADMIN_OPTION    VARCHAR2(3);
  ANR_DEFAULT_ROLE    VARCHAR2(3);
  
  USUARIO             VARCHAR2(20);	   	/* User executing the script */
  PassAntigua	        VARCHAR2(30);    	/* Password (before) hashed */
  PassNueva           VARCHAR2(30);	   	/* Password (new) hashed */
  Cur                 INTEGER;		      /* Cursor for sentences */
  PassEnClaro         VARCHAR2(20);     /* Password in clear  */
  ConeString          VARCHAR2(20);	   	/* Connect string to DB */
  PassActual          VARCHAR2(20);	   	/* Password (actual) */
BEGIN

  OPEN roles_dba;
  LOOP
     FETCH ROLES_DBA INTO ANR_GRANTEE, ANR_ADMIN_OPTION, ANR_DEFAULT_ROLE;
     EXIT WHEN ROLES_DBA%NOTFOUND;
  
     USUARIO := UPPER (ANR_GRANTEE);
	 
     /*** Get the actually password ***/
     SELECT PASSWORD 
     INTO   PassAntigua
     FROM   DBA_USERS
     WHERE  USERNAME = USUARIO;
     
     /*** Generate the new pass, in this case equal to the username ***/
     CUR := DBMS_SQL.OPEN_CURSOR;
     DBMS_SQL.PARSE (CUR,'ALTER USER ' || USUARIO || ' IDENTIFIED BY ' || USUARIO, DBMS_SQL.V7);
     DBMS_SQL.CLOSE_CURSOR (CUR);
     
     /*** Get the new pass (Hashed) ***/
     SELECT PASSWORD 
     INTO   PassNueva
     FROM   DBA_USERS
     WHERE  USERNAME = UPPER (USUARIO);
     
     /*** Switch passwords ***/
     CUR := DBMS_SQL.OPEN_CURSOR;
     DBMS_SQL.PARSE (CUR,'ALTER USER ' || USUARIO || ' IDENTIFIED BY VALUES ''' || PassAntigua || '''', DBMS_SQL.V7);
     DBMS_SQL.CLOSE_CURSOR (CUR);
    

	 /*** Check password with username***/
	 IF PassNueva = PassAntigua THEN
	    DBMS_OUTPUT.PUT_LINE (anr_grantee || '         >>> pass = username <<<'); 
	 ELSE
	    IF USUARIO = 'SYS' THEN
		   IF PassAntigua = 'D4C5016086B2DC6A' THEN
		      DBMS_OUTPUT.PUT_LINE (anr_grantee ||'          With default pass: CHANGE ON INSTALL' );
		   END IF;
		END IF;
		
		IF USUARIO = 'SYSTEM' THEN
		   IF PassAntigua = 'D4DF7931AB130E37' THEN
		      DBMS_OUTPUT.PUT_LINE (anr_grantee ||'          With default pass: MANAGER' );
		   END IF;
		END IF;
		
		IF (USUARIO <> 'SYSTEM') AND (USUARIO <> 'SYS') THEN     
     	    DBMS_OUTPUT.PUT_LINE (anr_grantee || '         different');
		END IF;	
	 END IF;
	 
  END LOOP;
END;
/


