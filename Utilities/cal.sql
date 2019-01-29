--  ----------------------------------------------------------------------------------------------------
--
--  FILE NAME      : cal.sql
--  DESCRIPTION    : Return calendar in unix-style
--  AUTHOR         : Antonio NAVARRO - /\/\/
--  CREATE         : 22.10.15
--  LAST MODIFIED  : 06.01.18
--  USAGE          : This script show a calendar unix-style, mounth and year must be numerical values
--  CALL SYNTAXIS  : @cal.sql mounth year
--  [NOTES]        : 
--   
--  ----------------------------------------------------------------------------------------------------


SET FEED OFF VER OFF LIN 32767 PAGES 1000 TIMI ON LONG 32767000 LONGC 32767 TRIMS ON AUTOT OFF;
SET SERVEROUTPUT ON SIZE UNLIMITED


DECLARE

   /*** Create a varray to containts the Months ***/
   TYPE list_of_months IS VARRAY (12) OF VARCHAR2 (100);
   Months list_of_months := list_of_months ('January', 'February', 'March','April', 'May', 'June','July', 'August', 'September','October', 'November', 'December'); 
   
   /*** Create a varray to containts the numbers of each month ***/
   TYPE list_of_numberofdays IS VARRAY (12) OF NUMBER (2);
   Days list_of_numberofdays := list_of_numberofdays (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31); 
      
   i         PLS_INTEGER;
   d         PLS_INTEGER;
   LineCal   VARCHAR2 (100);


   FUNCTION DAY
   (
     Month Number,
     Year  Number
   )
   RETURN NUMBER IS
     DayString    VARCHAR2 (10);    -- WITH THIS FORMAT DD/MM/YYYY
     DayOfTheWeek NUMBER;
   BEGIN
   	DayString := '01/' || Month || '/' || Year;
   	SELECT TO_NUMBER (to_char(to_date(DayString,'dd/mm/yyyy'), 'D')) INTO DayOfTheWeek FROM DUAL;
   	RETURN DayOfTheWeek;
   END;
         

   FUNCTION IsLeapYear
   (
     year   NUMBER
   ) RETURN BOOLEAN IS
   BEGIN     
     IF (( MOD (year,4) = 0) AND ( MOD (year,100) != 0)) THEN RETURN TRUE; END IF;
     IF ( MOD (year,400) = 0) THEN  RETURN TRUE; END IF;
     RETURN FALSE;
   END;  /*** IsLeapYear ***/


BEGIN

   -- Check for leap year
   IF ((&1 = 2) AND (isLeapYear(&2))) THEN Days (2) := 29; END IF; 
   
   -- Print header
   DBMS_OUTPUT.PUT_LINE ('.   ' ||  Months (&1) || ' ' || &2);
   DBMS_OUTPUT.PUT_LINE ('.   S   M  Tu   W  Th   F   S');
   DBMS_OUTPUT.PUT_LINE ('. ');
   
   d := day (&1, &2);
   LineCal := '.';
 
   -- Print the calendar
   -- The first line
   i := 0;
   WHILE i < d LOOP
         i := i+1;
         LineCal :=  LineCal || '    ' ;
   END LOOP;
   
   -- The rest of lines
   i := 0;
   WHILE i <= days (&1) LOOP
      i := i + 1;
      
      IF (i < 10) THEN    -- Add one more space if it is one digit
        LineCal := LineCal || '   ' || i;
      ELSE
        LineCal := LineCal || '  ' || i;
      END IF ;
      
      IF ((MOD ((i+d),7) = 0) OR (i = days (&1))) THEN 
         dbms_output.put_line (LineCal);     
         LineCal := '.';
      END IF;
      
   END LOOP;
 
   
END; /*** Main ***/
/



