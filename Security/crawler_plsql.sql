
--  ----------------------------------------------------------------------------------------------------
--
--  FILE NAME      : CRAWLER_PLSQL.SQL
--  DESCRIPTION    : Get the nodes visibility from node where is executed the script
--  AUTHOR         : Antonio NAVARRO - /\/\/
--  CREATE         : 28.10.99
--  LAST MODIFIED  : 28.10.99
--  USAGE          : This script inputs two parameters. Parameter 1 is a flag to specify if
--
--                   This script recive four parameter, 
--                   prev_range : n elements before the machine's IP
--                   post_range : n elements after the machine's IP
--                   try_dblink : Y|N try discover if there is a listener (on defaults) active  
--                   send_mail  : Y|N send a email to a recipent (define by constant) with a report
--
--  CALL SYNTAXIS  : @crawler_plsql.sql 6 3 n N 
--  [NOTES]        :
--                   This script has several constants;
--
--                        debug     : active debug mode, more logging on screen
--                        mail      : recipient of the couriers
--   
--
--                    This version work for last byte (IPv4) or last double byte (IPv6)
--                 
--                 
--                    For IP v4 format :
--                      
--                    IP_DOT1 . IP_DOT2 . IP_DOT3 . IP_DOT4                     
--                    
--                    
--                    For IP v6 format :
--                    
--                    IP_DOT1 : IP_DOT2 : IP_DOT3 : IP_DOT4 : IP_DOT5 : IP_DOT6 : IP_DOT7 : IP_DOT8
--                 
--                 
--                 
--                    --- SECURITY MODEL ---
--                    
--                    User execution UTL_INADDR must have access in ACL 
--                 
--  ----------------------------------------------------------------------------------------------------

set serveroutput on size unlimited

SET FEED OFF VER OFF LIN 32767 PAGES 0 TIMI OFF LONG 32767000 LONGC 32767 TRIMS ON AUTOT OFF;
SET SERVEROUTPUT ON SIZE 50000

PRO
PRO 1. Enter number of previous IPs range (required)
DEF p_prev_range = '&&1';
PRO
PRO 2. Enter number of next IPs range (required)
DEF p_post_range = '&&2';
PRO
PRO 3. Try discover listener on defaults (required)
DEF p_try_dblink = '&&3';
PRO
PRO 4. Send data by email (required)
DEF p_try_sendmail = '&&4';




VAR PrevRANGE   NUMBER;
VAR PostRANGE   NUMBER;
VAR TryDblink   CHAR;
VAR TrySendmail CHAR;


DECLARE
  
  /* contants */
  DEBUG        BOOLEAN        := TRUE;                     /* Debug mode */
  MAIL         VARCHAR2 (128) := 'ANAVARROR@GMAIL.COM';    /* Recipient */
  
  IpVer        NUMBER   (1);             /* Ip version */
               
  IP_DOT1      VARCHAR2 (3);
  IP_DOT2      VARCHAR2 (3);
  IP_DOT3      VARCHAR2 (3);
  IP_DOT4      VARCHAR2 (3);  
               
  IP_V4        VARCHAR2 (15);
  IP_V6        VARCHAR2 (23); 
  IP_RAW       VARCHAR2 (23); 
  
  
  -- Settings for email  
  
  CMailIp     VARCHAR2  (128) := 'server.withmail.com';             -- IP where start mail
  CPort       NUMBER          := 25;                                -- Port to start resend, by default 25
  CFromName   VARCHAR2  (128) := 'Antonio1';                        -- Name (sender)
  CFromEmail  VARCHAR2  (128) := 'oracle@local.com';                -- Boxmail (sender)
  CToName     VARCHAR2  (128) := 'Antonio2';                        -- Name (receipent)
  CToEmail    VARCHAR2  (128) := 'destinity@mymail.com';            -- Boxmail (receipent)
  CSubject    VARCHAR2  (128) := 'Report of neighbours';            -- Issue
    

  
  /* debug procedure a simple debugger */
  PROCEDURE NOTIFICATOR (Text VARCHAR2) IS
  BEGIN
  	 DBMS_OUTPUT.PUT_LINE ('DBG: ' || TO_CHAR (SYSDATE, 'DD.MON.YY HH24:MI:SS') || ': ' || Text);
  END;
  
  
  /* Return IP version possible values are 04 or 06 */ 
  FUNCTION GET_IP_TYPE (ip varchar2) RETURN NUMBER IS
    IpVersion NUMBER;
  BEGIN
  	SELECT regexp_count(ip, '\.') INTO IpVersion FROM DUAL;
  	
  	IF IpVersion = 3 THEN  	
  	   RETURN ( IpVersion+1 );  	  	
  	END IF;
  	
  	SELECT regexp_count(ip, '\:') INTO IpVersion FROM DUAL;
  	IF IpVersion >= 6 THEN
  	   RETURN (6);
  	ELSE
  	   RETURN (0);
  	END IF;
  	
  END;
  
  
  
  FUNCTION GET_ACTUAL_IP  RETURN VARCHAR2 IS
    Hostname VARCHAR2 (128);
  BEGIN
  	SELECT UTL_INADDR.get_host_address INTO Hostname FROM DUAL;
    RETURN ( Hostname );
  END;
  
  
  
  FUNCTION GET_ACTUAL_HOSTNAME RETURN VARCHAR2  IS
    Hostname VARCHAR2 (128);
  BEGIN
  	SELECT UTL_INADDR.get_host_name INTO Hostname FROM DUAL;
    RETURN ( Hostname );
  END;
      
      
  
  /* receive a IP and return a Hostname 
     order by 
     #1 /etc/hosts
     #2 dns (privates)
     #3 dns (publics if setup) */
  FUNCTION GET_HOSTNAME_BY_ASK (Ip VARCHAR2) RETURN VARCHAR2  IS
    Hostname VARCHAR2 (128);
  BEGIN
  	SELECT UTL_INADDR.get_host_name(Ip) INTO Hostname FROM dual;
  	RETURN ( Hostname );
  	  	
 	  EXCEPTION        
       WHEN OTHERS  THEN 
            IF SQLCODE = -29257 THEN RETURN ('* Unknown host *');
            ELSE IF SQLCODE = -24247 THEN RETURN ('* NET ACCESS DENIED *'); 
                 ELSE RETURN ('* Unknown error *');
                 END IF;
            END IF;                             
  END;
  
  
  
  /* Receive a hostname and return a IP  
     order by 
     #1 /etc/hosts
     #2 dns (privates)
     #3 dns (publics if setup) */  
  FUNCTION GET_IP_BY_ASK (Hostname VARCHAR2) RETURN VARCHAR2 IS
    Ip   VARCHAR2 (15);
  BEGIN
  	SELECT UTL_INADDR.get_host_address(Hostname) INTO Ip FROM DUAL;
  	RETURN ( IP );

 	  EXCEPTION        
       WHEN OTHERS  THEN 
            IF SQLCODE = -29257 THEN RETURN ('* Unknown host *');
            ELSE IF SQLCODE = -24247 THEN RETURN ('* NET ACCESS DENIED *'); 
                 ELSE RETURN ('* Unknown error *');
                 END IF;
            END IF;                   	
  END;
  
  
  
  /***
     Executed from server return null 
     Executed from client retunr client's IP
  ***/
  FUNCTION GET_ACTUAL_IP_BY_CONTEXT RETURN VARCHAR2 IS
     Hostname VARCHAR2 (128);
  BEGIN
  	SELECT SYS_CONTEXT('USERENV','IP_ADDRESS') INTO Hostname FROM dual;
    RETURN ( Hostname );
  END;
  
  
  
  /* Get hostname of server databasse */
  FUNCTION GET_ACTUAL_HOSTNAME_BY_CONTEXT RETURN VARCHAR2 IS
    Hostname VARCHAR2 (128);
  BEGIN
  	SELECT SYS_CONTEXT('USERENV','SERVER_HOST') INTO Hostname FROM dual;
    RETURN ( Hostname );
  END;
  
  
  
  /* Get hostname from where executed the client Ess. Windows MACHINE */
  FUNCTION GET_ACTUAL_TERMINAL_BY_CONTEXT RETURN VARCHAR2 IS
    Hostname VARCHAR2 (128);
  BEGIN
  	SELECT SYS_CONTEXT('USERENV','TERMINAL') INTO Hostname FROM dual;
  	RETURN ( Hostname);
  END;
   	
   	
   	
  /*  Get hostname from where executed the client Ess. Windows DOMAIN\MACHINE */
  FUNCTION GET_ACTUAL_HOST_BY_CONTEXT RETURN VARCHAR2 IS
    Hostname VARCHAR2 (128);
  BEGIN
  	SELECT SYS_CONTEXT('USERENV','HOST') INTO Hostname FROM dual;                    
  	RETURN ( Hostname );
  END;
   	
   
   	
  /* Return a piece (delimited by points except head and tail) of an ip (v4 or v6) */ 	
  FUNCTION GET_IP_PIECE (ip varchar2, slice number) RETURN VARCHAR2 IS 
    Subnet    VARCHAR2 (3);
    IpVersion NUMBER      ;      /* values 3 (IP v4) or 5 (IP v6) */
  BEGIN
  	  
  	/* Identified the type of IP */    	
    IpVersion := GET_IP_TYPE (ip);     
  
  
    IF IpVersion = 4 THEN  	        
  	         
  	   /* Is the head */
  	   IF slice=1 THEN 
  	      RETURN ( SUBSTR (IP, 1, (INSTR (ip, '.', 1, slice))-1 ));
       END IF;  	
  	   
  	   /* Is an intermediate */
  	   IF (IpVersion = 4 AND slice <= 3) THEN   /* IP v4 */  	   
  	      RETURN ( SUBSTR (IP,      (INSTR (ip,'.', 1,slice-1))+1,   ((INSTR(ip,'.',1,slice))-1)-(INSTR(ip,'.',1, slice-1))    ));
       END IF;  	          
  	               	
  	   /* If get at this step only can be the tail */
       RETURN ( SUBSTR (IP, (INSTR (ip, '.', 1, slice-1))+1 , LENGTH (IP)-(INSTR (ip, '.', 1, slice))     ) );
             
    END IF; /* IP v4 */
    
    IF IpVersion = 6 THEN         	       
  	         
  	   /* Is the head */
  	   IF slice=1 THEN 
  	      RETURN ( SUBSTR (IP, 1, (INSTR (ip, ':', 1, slice))-1 ));
       END IF;  	
  	   
  	   /* Is an intermediate */
  	   IF (IpVersion = 6) AND (slice <= 7) THEN  /* IP v6 */  	    
  	       RETURN ( SUBSTR (IP,      (INSTR (ip,':', 1,slice-1))+1,   ((INSTR(ip,':', 1,slice))-1)-(INSTR(ip,':',1,slice-1))    ));
       END IF;  	          
  	               	
  	   /* If get at this step only can be the tail */
       RETURN ( SUBSTR (IP, (INSTR (ip, ':', 1, slice-1))+1 , LENGTH (IP)-(INSTR (ip, ':', 1, slice))     ) );    
     
    END  IF;
    
    RETURN ( 'ERR');  /* IpVersion != 4 AND IpVersion != 6 */
        
  END;    /* GET_IP_PIECE */    
  
  
  /* Check if we can send email                                         */
  /* grant execute on sys.utl_smtp to    and ACL privilege is necessary */
  /* SYS and DBA users are excluded                                     */
  FUNCTION CHECK_ACCEST_UTL_SMTP  RETURN BOOLEAN IS
    objConnection              utl_smtp.connection;
  BEGIN  	
  	objConnection := UTL_smtp.open_connection('127.0.0.1', 25); 
  	RETURN (TRUE);
  	
    EXCEPTION        
      WHEN OTHERS  THEN   -- Insufficient privileges ACLs or execute on UTL_SMTP
            RETURN (FALSE);     	
  END;
  


  /* Procedure to send mail, this procedure use smtp on port 25, it must be open */
  PROCEDURE SENDMAIL (
    MailIp    IN VARCHAR2,     -- IP where start mail
    Port      IN NUMBER,       -- Port to start resend, by default 25
    FromName  IN VARCHAR2,     -- Name (sender)
    FromEmail IN VARCHAR2,     -- Boxmail (sender)
    ToName    IN VARCHAR2,     -- Name (receipent)
    ToEmail   IN VARCHAR2,     -- Boxmail (receipent)
    Subject   IN VARCHAR2,     -- Issue
    Body      IN VARCHAR2)     -- Body
  IS
     objConnection              utl_smtp.connection;   -- connection handler
     vrData                     RAW(32767);            -- togheter all in a bundle
  BEGIN
  
    -- Open connection, we declare it like a resending mail -----
   objConnection := UTL_smtp.open_connection(MailIp,Port);
   UTL_smtp.helo(objConnection, MailIp);
   UTL_smtp.mail(objConnection, FromEmail);
   UTL_smtp.rcpt(objConnection, ToEmail);
   UTL_smtp.open_data(objConnection);
  
    -- Header for SMTP Protocol ----
    UTL_smtp.write_data(objConnection, 'From: ' || '"' || FromName || '" <'|| FromEmail ||'>' || UTL_tcp.CRLF);
    UTL_smtp.write_data(objConnection, 'To: ' || '"' || ToName || '" <' ||ToEmail||'>' || UTL_tcp.CRLF);
    UTL_smtp.write_data(objConnection, 'Subject: ' || Subject || UTL_tcp.CRLF);
    UTL_smtp.write_data(objConnection, 'MIME-Version: ' || '1.0' || UTL_tcp.CRLF);
  
    UTL_smtp.write_data(objConnection, 'Content-Type: ' || 'text/plain; charset=utf-8' || UTL_tcp.CRLF);
    UTL_smtp.write_data(objConnection, 'Content-Transfer-Encoding: ' || '8bit'|| UTL_tcp.CRLF);
  
    -- finish header -----
    UTL_smtp.write_data(objConnection, UTL_tcp.CRLF);
  
    -- send body
    -- This version only suppor plain text 
    vrData := utl_raw.cast_to_raw(body);
    UTL_smtp.write_raw_data(objConnection, vrData);
  
    -- Close connection ------
    UTL_smtp.close_data(objConnection);
    UTL_smtp.quit(objConnection);
  
    -- Error management -----
    EXCEPTION
      -- close connection and report error -----
      WHEN OTHERS THEN
        /*  ORA-29279: error permanente de SMTP: 550 5.7.1  Indicate no email daemon listening on port*/
        UTL_smtp.quit(objConnection);
        NOTIFICATOR ('Failing sending mail with Oracle code error: ' || sqlerrm);
  END;   /* SendMail */
  


  /* Create a db linke point default por 1521 to try discover if a DB is avaliable */
  FUNCTION CREATE_DB_LINK (machine varchar2) RETURN NUMBER IS
     Trycount     NUMBER;
  BEGIN 
  
    EXECUTE IMMEDIATE 'create database link DUMMY_DB_LINX using ''(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=' || machine || ')(PORT=1521)))(CONNECT_DATA=(SERVER=DEDICATED)(SERVICE_NAME=orcl)))''';     
    EXECUTE IMMEDIATE 'SELECT COUNT (*) FROM DUAL@DUMMY_DB_LINX';    
    EXECUTE IMMEDIATE 'DROP DATABASE LINK DUMMY_DB_LINX';
    
    RETURN (0);   /* Exit without success */
     	
    EXCEPTION        
       WHEN OTHERS  THEN                        
            /* housekeeping drop the database link*/
            EXECUTE IMMEDIATE 'DROP DATABASE LINK DUMMY_DB_LINX';                              
            
            IF    SQLCODE = 12541 THEN RETURN (12541);  --  Listener is not running                                                                       
            ELSIF SQLCODE = 12170 THEN RETURN (12170);  --  TNS:Connect timeout occurred                                                                  
            ELSIF SQLCODE =  2019 THEN RETURN ( 2019);  --  Connection description for remote database not found                                          
            ELSIF SQLCODE =  2024 THEN RETURN ( 2024);  --  Database link to be dropped is not found in dictionary                                        
            ELSIF SQLCODE = 12514 THEN RETURN (12514);  --  SUCCESS, there is any listener in this IP + this PORT but no this SID or SERVICE              
            ELSIF SQLCODE =  1017 THEN RETURN ( 1017);  --  SUCCESS, there is any listener in this IP + this PORT + this SERVICE but invalid user or pass  
            ELSE RETURN (-1);     
            END IF;
          
  END;  
  
            	 
  
  -- PROCEDURE DISCOVER_HOST (ip VARCHAR2, nBelow NUMBER, nAfter NUMBER) RETURN VARCHAR2 IS
  PROCEDURE DISCOVER_HOST (ip VARCHAR2, nBelow NUMBER, nAfter NUMBER) IS
    IpDot1               VARCHAR2 (3);
    IpDot2               VARCHAR2 (3);
    IpDot3               VARCHAR2 (3);
    IpDot4               VARCHAR2 (3);  
    IpDot5               VARCHAR2 (3);
    IpDot6               VARCHAR2 (3);
    IpDot7               VARCHAR2 (3);
    IpDot8               VARCHAR2 (3);
                         
    IPTry                VARCHAR2 (128);                    /* Ip to try */
    Hostresolve          VARCHAR2 (128);                    /* save the alias for ip */ 
    ResultOfCreateDblink NUMBER;                            /* Result of create DB link */
    OutputListener       VARCHAR2 (15) := 'NO LISTENER';    /* Display when listener option */
    n                    PLS_INTEGER;                       /* Counter */
    TextMail             VARCHAR2 (4000);                   /* For text mail */ 

    TYPE T_IP       IS TABLE OF VARCHAR2  (128) INDEX BY PLS_INTEGER;             
    TYPE T_HOST     IS TABLE OF VARCHAR2  (128) INDEX BY PLS_INTEGER;             
    TYPE T_LISTENER IS TABLE OF VARCHAR2   (15) INDEX BY PLS_INTEGER;             
                                                                                  
    v_ip         T_IP;                                                            
    v_host       T_HOST;                                                          
    v_listener   T_LISTENER;                                                      

  BEGIN
  	
  	IpDot1 := GET_IP_PIECE (ip, 1);
  	IpDot2 := GET_IP_PIECE (ip, 2);
  	IpDot3 := GET_IP_PIECE (ip, 3);
  	IpDot4 := GET_IP_PIECE (ip, 4);
  	  
  	IF  GET_IP_TYPE (ip)  = 6 THEN     /*** This case is for IP v6 ***/
  	    IpDot5 := GET_IP_PIECE (ip, 5);
  	    IpDot6 := GET_IP_PIECE (ip, 6);  
        IpDot7 := GET_IP_PIECE (ip, 7);   
        IpDot8 := GET_IP_PIECE (ip, 8);      	    
  	    
  	    FOR i IN  (to_number (IpDot6)-nBelow) .. (to_number (IpDot6)+nAfter) LOOP  	 
  	       
  	        IPTry :=  IpDot1 || ':' || IpDot2 || ':' || IpDot3 || ':' || IpDot4 || ':' || IpDot5 || ':' || IpDot6 || ':' || IpDot7 || ':' ||to_char (i);
  	        
  	        Hostresolve := GET_HOSTNAME_BY_ASK (IPTry);  	          	          	        
  	        
  	        /* If check listener on defaults */
  	        IF (:TryDblink =  'Y') OR (:TryDblink =  'y') THEN
  	           IF Hostresolve !=  '* Unknown host *' AND  Hostresolve !=  '* NET ACCESS DENIED *' AND Hostresolve !=  '* Unknown error *' THEN  	                           	                       

  	                	        ResultOfCreateDblink :=  CREATE_DB_LINK (IPTry);
  	                	        IF ResultOfCreateDblink = 12514 THEN OutputListener := 'IP + PORT SUCCESS';
  	                	        ELSIF ResultOfCreateDblink = 1017 THEN OutputListener := 'IP + PORT + SN SUCCESS';
  	                	           ELSE                                  OutputListener := 'NO LISTENER';
  	                	        END IF;
  	                	          	                        
  	           END IF;   
  	           DBMS_OUTPUT.PUT_LINE ('    ' || IPtry || '     ' || Hostresolve  || '     ' || OutputListener );
  	        ELSE /* Print if listener option */
  	           DBMS_OUTPUT.PUT_LINE ('    ' || IPtry || '     ' || Hostresolve  );
  	        END IF;  /* Check listener on defaults */
  	        
  	          	        
  	        /* If send email then collect data */  	        
  	        IF (:TrySendmail =  'Y') OR (:TrySendmail =  'y') THEN   	        
  	           v_ip       (i) :=  IPTry;
  	           v_host     (i) :=  Hostresolve;
  	           v_listener (i) :=  OutputListener;
            END IF;  	       
  	          	    
  	    END LOOP;
  	END IF; /* IP v6 */
  	
  	  	
  	IF  GET_IP_TYPE (ip)  = 4 THEN  /* Is case is for IP v4 */   
        /* Loop for the range */
  	    FOR i IN  (to_number (IpDot4)-nBelow) .. (to_number (IpDot4)+nAfter) LOOP  	  
  	      	
  	        -- IPTry :=  IpDot1 || IpDot2 || IpDot3 || to_char (i);  	  <<<< devuelve direccioes  que no debiera INVESTIGAR !!!
  	        IPTry :=  IpDot1 || '.' || IpDot2 || '.' || IpDot3 || '.' || to_char (i);
  	          	    	        
  	        Hostresolve := GET_HOSTNAME_BY_ASK (IPTry);  	          	          	        
  	        
  	        /* If check listener on defaults */
  	        IF (:TryDblink =  'Y') OR (:TryDblink =  'y') THEN   	           
  	           IF Hostresolve !=  '* Unknown host *' AND  Hostresolve !=  '* NET ACCESS DENIED *' AND Hostresolve !=  '* Unknown error *' THEN  	                           	                       

  	                	        ResultOfCreateDblink :=  CREATE_DB_LINK (IPTry);
  	                	        IF ResultOfCreateDblink = 12514 THEN OutputListener := 'IP + PORT SUCCESS';
  	                	        ELSIF ResultOfCreateDblink = 1017 THEN OutputListener := 'IP + PORT + SN SUCCESS';
  	                	           ELSE                                  OutputListener := 'NO LISTENER';
  	                	        END IF;
  	                	          	                        
  	           END IF;   
  	           DBMS_OUTPUT.PUT_LINE ('    ' || IPtry || '     ' || Hostresolve  || '     ' || OutputListener );
  	        ELSE /* Print if listener option */
  	           DBMS_OUTPUT.PUT_LINE ('    ' || IPtry || '     ' || Hostresolve  );
  	        END IF;  /* Check listener on defaults */
  	          	        
  	        /* If send email then collect data */  	        
  	        IF (:TrySendmail =  'Y') OR (:TrySendmail =  'y') THEN   	        
  	           v_ip       (i) :=  IPTry;
  	           v_host     (i) :=  Hostresolve;
  	           v_listener (i) :=  OutputListener;
            END IF;  	         	          	        
  	          	          	          	        
        END LOOP;
        
  	END IF; /* IP v4 */
  	  
  
    -- Show the contains of the varray        
    IF DEBUG THEN        
       n := v_ip.first;                              
       WHILE n IS NOT NULL LOOP                          
                                                             
          NOTIFICATOR ('ARRY IP       INDEX  [ ' || n || ' ] value   : ' || v_ip(n));                                                       
          NOTIFICATOR ('ARRY HOST     INDEX  [ ' || n || ' ] value   : ' || v_host(n));                                                       
          NOTIFICATOR ('ARRY LISTENER INDEX  [ ' || n || ' ] value   : ' || v_listener(n));                                                       
          n := v_ip.next(n);                          
       END LOOP; 
    END IF;                                          	  
    
    IF (:TrySendmail =  'Y') OR (:TrySendmail =  'y') THEN
       n := v_ip.first; 
       WHILE n IS NOT NULL LOOP
          TextMail := TextMail ||  v_ip(n) || '   ' || v_host(n) || '   ' || '   ' || v_listener(n) || CHR(10);
          n := v_ip.next(n);                          
       END LOOP;  
       SendMail (CMailIp, CPort, CFromName, CFromEmail, CToName, CToEmail, CSubject,  TextMail);
    END IF;
  	
  END;   /* DISCOVER_HOST */
  
  
  
  /* Verify if I have access to UTL_INADDR package and ACLs */
  FUNCTION HAVE_I_ACCESS_TO_UTL_INADDR RETURN BOOLEAN IS
    ACTUAL_IP  VARCHAR2 (18);
  BEGIN
  	
  	ACTUAL_IP := GET_ACTUAL_IP ();
  	RETURN (TRUE);
  	
    EXCEPTION        
       WHEN OTHERS  THEN   -- SQLCODE = -24247  NO ACCESS TO ULT_INADDR
            RETURN (FALSE);           
  END;  
  
  
  
  /* Verify if I have privilege CREATE DATABASE LINK */
  /* grant create database link to <user_executing_this_script> */
  FUNCTION HAVE_I_CREATE_DB_LINK_PRIV RETURN BOOLEAN IS
  BEGIN
  	
  	EXECUTE IMMEDIATE 'CREATE DATABASE LINK TRYANR0X01 USING ''DUMMY_CONNECTION''';
  	EXECUTE IMMEDIATE 'DROP DATABASE LINK TRYANR0X01';
  	RETURN (TRUE);
  	
    EXCEPTION        
      WHEN OTHERS  THEN   -- SQLCODE = -01031 Insufficient privileges (NO GRANTED CREATE DB LINK PRIVILEGE)
            RETURN (FALSE);         	
  END;
  
 
  /* Banner */
  PROCEDURE BANNER  IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE ('' || CHR (10));
    DBMS_OUTPUT.PUT_LINE ('.        __________  ___ _       ____    __________     ____  __   _____ ____    __  ');
    DBMS_OUTPUT.PUT_LINE ('.       / ____/ __ \/   | |     / / /   / ____/ __ \   / __ \/ /  / ___// __ \  / /  ');
    DBMS_OUTPUT.PUT_LINE ('.      / /   / /_/ / /| | | /| / / /   / __/ / /_/ /  / /_/ / /   \__ \/ / / / / /   ');
    DBMS_OUTPUT.PUT_LINE ('.     / /___/ _, _/ ___ | |/ |/ / /___/ /___/ _, _/  / ____/ /______/ / /_/ / / /___ ');
    DBMS_OUTPUT.PUT_LINE ('.     \____/_/ |_/_/  |_|__/|__/_____/_____/_/ |_|  /_/   /_____/____/\___\_\/_____/ ');
    DBMS_OUTPUT.PUT_LINE ('.                                                     by Antonio NAVARRO 26.02.19    ');
    DBMS_OUTPUT.PUT_LINE ('' || CHR (10));
  END;
    
  
BEGIN  /*** M A I N    A N O N Y M O U S    B L O C K ***/
      
   /* assign script parameters to variables */
   :PrevRANGE   := &&p_prev_range;
   :PostRANGE   := &&p_post_range;
   :TryDblink   := '&&p_try_dblink';
   :TrySendmail := '&&p_try_sendmail';
 
   BANNER;
   
   IF DEBUG THEN 
      NOTIFICATOR ('PREV RANGE   ' || :PrevRANGE);
      NOTIFICATOR ('POST RANGE   ' || :POSTRANGE);
      NOTIFICATOR ('TryDblink    ' || :TryDblink);
      NOTIFICATOR ('TrySendmail  ' || :TrySendmail);
   END IF;
      
    
   DBMS_OUTPUT.PUT_LINE ('' || CHR (10));
   DBMS_OUTPUT.PUT_LINE ('--------------------------------------------------------------------------------');  
   DBMS_OUTPUT.PUT_LINE ('' || CHR (10));      
   
   -- Check access to utl_inaddr package and ACLs  
   IF HAVE_I_ACCESS_TO_UTL_INADDR THEN
      DBMS_OUTPUT.PUT_LINE ('Checking acces to UTL_INADDR Package      :     Ok');
   ELSE
      DBMS_OUTPUT.PUT_LINE ('SO SORRY, YOU NEED ACCESS TO UTL_INADDR');
      RETURN;
   END IF;
   
   -- Check granted Create DB Link privilege
   IF HAVE_I_CREATE_DB_LINK_PRIV  THEN
      DBMS_OUTPUT.PUT_LINE ('Checking grant to CREATE DB LINK          :     Ok');
   ELSE
      DBMS_OUTPUT.PUT_LINE ('SO SORRY, YOU NEED  "CREATE DABATABASE LINK" PRIVILEGE ');
      RETURN;   
   END IF;
   
   -- Check access to utl_smtp package
   IF CHECK_ACCEST_UTL_SMTP THEN
      DBMS_OUTPUT.PUT_LINE ('Checking acces to utl_smtp                :     Ok');
   ELSE
      DBMS_OUTPUT.PUT_LINE ('SO SORRY, MAIL WILL NOT SEND ');      
   END IF;
         
   
   -- General information visible from this session 
   DBMS_OUTPUT.PUT_LINE ('' || CHR (10));
   DBMS_OUTPUT.PUT_LINE ('GET GET_ACTUAL_IP                         :     ' || GET_ACTUAL_IP);
   DBMS_OUTPUT.PUT_LINE ('GET GET_ACTUAL_HOSTNAME                   :     ' || GET_ACTUAL_HOSTNAME);
   DBMS_OUTPUT.PUT_LINE ('GET GET_ACTUAL_IP_BY_CONTEXT              :     ' || GET_ACTUAL_IP_BY_CONTEXT);
   DBMS_OUTPUT.PUT_LINE ('GET GET_ACTUAL_HOSTNAME_BY_CONTEXT        :     ' || GET_ACTUAL_HOSTNAME_BY_CONTEXT);
   DBMS_OUTPUT.PUT_LINE ('GET GET_ACTUAL_TERMINAL_BY_CONTEXT        :     ' || GET_ACTUAL_TERMINAL_BY_CONTEXT);
   DBMS_OUTPUT.PUT_LINE ('GET GET_ACTUAL_HOST_BY_CONTEXT            :     ' || GET_ACTUAL_HOST_BY_CONTEXT);
   
   DBMS_OUTPUT.PUT_LINE ('IP version                                :     ' || GET_IP_TYPE (GET_IP_BY_ASK (GET_ACTUAL_HOSTNAME_BY_CONTEXT))); 
   DBMS_OUTPUT.PUT_LINE ('GET GET_IP_BY_ASK                         :     ' || GET_IP_BY_ASK (GET_ACTUAL_HOSTNAME_BY_CONTEXT));  
   
   DBMS_OUTPUT.PUT_LINE ('' || CHR (10));
   DBMS_OUTPUT.PUT_LINE ('--------------------------------------------------------------------------------');
   DBMS_OUTPUT.PUT_LINE ('' || CHR (10));
   DBMS_OUTPUT.PUT_LINE ('   - - -   L I S T    O F    H O S T S    D I S C O V E R E D   - - - ' || CHR (10));
   
   
   discover_host (GET_IP_BY_ASK (GET_ACTUAL_HOSTNAME_BY_CONTEXT),  :PrevRANGE,  :PostRANGE );                           
  
   
END;  /***  MAIN ANONYMOUS BLOCK ***/
/








