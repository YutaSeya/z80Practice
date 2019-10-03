ROM       EQU       0000H
RAM       EQU       8000H

ORG       RAM       
X:        DS        2

Y:        DS        2

Z:        DS        2

; MAIN 
          ORG       ROM

          LD        SP, RAM+0FFFH
          
          CALL      ADD_Z

          HALT


;ADD_XY
ADD_XY:
          PUSH      DE
          PUSH      HL

          LD        HL, (X)
          LD        DE, (Y)

          ADD       HL, DE
          LD        (X),HL       
          
          POP       HL
          POP       DE
          RET

; ADD_Z
ADD_Z:
          PUSH      DE
          PUSH      HL    
          
          LD        HL, (X)
          LD        DE, (Z)

          ADD       HL, DE
          LD        (Z),HL        
  
          POP       HL
          POP       DE
          RET

          END
