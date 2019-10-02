ROM       EQU       0000H
RAM       EQU       8000H

ORG       RAM       
X:        DS        2

Y:        DS        2

Z:        DS        2

; MAIN 
          ORG       ROM

          CALL      STACK_INIT
          CALL      MUL_XY

          HALT

; STACK_INIT
STACK_INIT:
          LD        SP, RAM+0FFFH
          RET

MUL_XY:
          POP       HL
          POP       DE

          LD        HL, (X)
          LD        DE, (Y)
          LD        IX, 0
          
          PUSH      HL
          PUSH      DE
          RET

          END