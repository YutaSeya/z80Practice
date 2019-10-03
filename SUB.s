ROM       EQU       0000H
RAM       EQU       8000H

ORG       RAM       
X:        DS        2

Y:        DS        2

Z:        DS        2

; MAIN 
          ORG       ROM

          CALL      STACK_INIT
          CALL      SUB_XY

          HALT

; STACK_INIT
STACK_INIT:
          LD        SP, RAM+0FFFH
          RET

; SUB_XY
SUB_XY:
          POP       HL
          POP       DE

          LD        HL, (X)
          LD        DE, (Y)
          SBC       HL, DE
          LD        (Z),HL
          
          PUSH      DE
          PUSH      HL
          RET

          END