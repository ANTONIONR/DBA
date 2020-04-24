

DECLARE
  IntoCommentMultiline      BOOLEAN       := FALSE;
  PositionMultiOpen         PLS_INTEGER;
  PositionMultiClose        PLS_INTEGER;
  PositionDBMSOUTPUT        PLS_INTEGER;
  PositionMono              PLS_INTEGER;
  
  PROCEDURE PRINT (PLINE NUMBER, POWNER VARCHAR2, PNAME VARCHAR2) IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE ('DBMS_OUTPUT FIND AT LINE: ' || LPAD (to_char(PLINE),10) ||chr(9)  || POWNER || '.' || PNAME );
  END;  
  
BEGIN
  FOR i IN
  (
    SELECT LINE, OWNER, NAME, TEXT FROM DBA_SOURCE WHERE 
    -- OWNER ='ANTONION'
    OWNER NOT IN ('SYS','SYSTEM') 
  )
  LOOP     
     PositionMultiOpen  := INSTR (i.TEXT, '/*');
     PositionMultiClose := INSTR (i.TEXT, '*/');
     PositionMono       := INSTR (i.TEXT, '--');
     
     IF PositionMultiOpen > 0 THEN   -- There is a multicomment open, check if is valid, no monocomment before
        IF (PositionMono < PositionMultiOpen) and (PositionMono != 0) THEN IntoCommentMultiline := FALSE;
        ELSE IntoCommentMultiline := TRUE;
        END IF;
     END IF;
          
     PositionDBMSOUTPUT :=  INSTR (UPPER (i.TEXT), 'DBMS_OUTPUT');
     IF PositionDBMSOUTPUT > 0 THEN   -- There is a DBMS_OUPUT, check if is commented
        IF IntoCommentMultiline THEN
           IF PositionMultiClose != 0 THEN 
              IF PositionMono  != 0 THEN
                  IF (PositionDBMSOUTPUT > PositionMono) AND (PositionDBMSOUTPUT >  PositionMultiClose) THEN                     
                     PRINT (i.LINE, i.OWNER, i.NAME);
                  END IF;
              ELSE 
                  IF PositionMultiClose < PositionDBMSOUTPUT THEN                     
                     PRINT (i.LINE, i.OWNER, i.NAME);
                  END IF;
              END IF;   
           END IF;
        ELSE -- No multicoment check if monocoment 
              IF PositionMono > PositionDBMSOUTPUT THEN   -- monocomment is after the dbms_ouput                                      
                   PRINT (i.LINE, i.OWNER, i.NAME);
              END IF;                             
        END IF; 
     END IF;
               
     -- Check if close multicomment
     IF IntoCommentMultiline THEN
        IF (PositionMono < PositionMultiClose) and (PositionMono != 0)  THEN NULL;
        ELSE IntoCommentMultiline := FALSE;
        END IF;
     END IF;
   
   END LOOP;
       
END;
/     
    
    