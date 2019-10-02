ROM       EQU       0000H
RAM       EQU       8000H

ORG       RAM       
X:        DS        2

Y:        DS        2

Z:        DS        2

; MAIN 
          ORG       ROM

          CALL      STACK_INIT
          CALL      ADD_XY

          HALT



; STACK_INIT
STACK_INIT:
          LD        SP, RAM+0FFFH
          RET

;ADD_XY
ADD_XY:
          POP       HL
          POP       DE

          LD        HL, (X)
          LD        DE, (Y)
          ADD       HL, DE
          LD        (Z),HL
          
          PUSH      HL
          PUSH      DE
          RET

; ADD_Z
ADD_Z:
          POP       HL
          POP       DE

          LD        HL, (X)
          LD        DE, (Z)
          ADD       HL, DE
          LD        (Z),HL
          
          PUSH      HL
          PUSH      DE      
          RET

          END