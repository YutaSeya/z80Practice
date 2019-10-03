ROM       EQU       0000H
RAM       EQU       8000H

ORG       RAM       
X:        DS        2

Y:        DS        2

Z:        DS        2

; MAIN 
          ORG       ROM

          LD        SP, RAM+0FFFH
          CALL      SUB_XY

          HALT

; SUB_XY
SUB_XY:
          PUSH      AF
          PUSH      DE
          PUSH      HL

          ; AND命令が呼ばれるとCフラグはリセットされる
          LD        A, 00H
          AND       A

          LD        HL, (X)
          LD        DE, (Y)
          SBC       HL, DE
          LD        (X),HL
          
          POP       HL
          POP       DE
          POP       AF
          RET

          END