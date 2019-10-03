ROM       EQU       0000H
RAM       EQU       8000H

ORG       RAM       
X:        DS        2

Y:        DS        2

Z:        DS        2

; MAIN 
          ORG       ROM

          LD        SP, RAM+0FFFH
          CALL      MUL_XY

          HALT

MUL_XY:
          PUSH      AF
          PUSH      BC
          PUSH      DE
          PUSH      HL

          LD        BC, (Y)
          LD        DE, (X)
          LD        HL, 0000H
          LD        A,  10H

MUL_LOOP:
          ; HLレジスタを左にシフト
          SLA       L
          RL        H

          ; overflow

          ; BCレジスタを左にシフト
          SLA       C
          RL        B

          CALL      C, ADD_HL
          
          ; Aレジスタの値を減らす
          DEC       A

          JP        NZ, MUL_LOOP

          LD        (X), HL

          POP       HL
          POP       DE
          POP       BC
          POP       AF
          RET

ADD_HL:
          ADD       HL, DE
          RET

          END

