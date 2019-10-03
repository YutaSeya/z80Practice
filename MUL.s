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
          POP       BC

          LD        BC, (Y)
          LD        DE, (X)
          LD        HL, 0
          LD        C, 16

MUL_LOOP:
          ; HLレジスタを左にシフト
          SLA       HL
          ; BCレジスタを左にシフト
          SLA       BC
          ; Cレジスタの値を減らす
          DEC       C

          CALL      C, ADD_HL

          JP        NZ, MUL_LOOP

          LD        (Z), HL

          PUSH      BC
          PUSH      DE
          PUSH      HL
          RET

ADD_HL:
          ADD       HL, DE
          RET

          END
