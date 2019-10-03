ROM       EQU       0000H
RAM       EQU       8000H

ORG       RAM       
X:        DS        2

Y:        DS        2

Z:        DS        2

; MAIN 
          ORG       ROM

          LD        SP, RAM+0FFFH
          
          CALL      DIV_XY

          HALT

; DIV_XY
DIV_XY:
          PUSH      HL
          PUSH      BC
          PUSH      DE
          PUSH      AF

          LD        BC, 0000H
          LD        HL,(Y)

          LD        A, H
          CP        0000H
          JP        NZ, DIV_START_UP

          LD        A, L
          CP        0000H
          JP        NZ, DIV_START_UP

          ; 0で割ることはできないのでerror

DIV_START_UP:
          LD        HL,(Y)
          LD        A, 10H

DIV_LOOP:
          SRA       H
          RR        L

          RR        B
          RR        C

          LD        HL,(Y)
          ; Zフラグをたたせるため
          DEC       H
          INC       H

          JP        NZ, DIV_CHECK_NONZERO

DIV_END_ACTION:
          LD        HL,(X)
          LD        (Y),HL

          LD        (X),DE

          POP       AF
          POP       DE
          POP       BC
          POP       HL
          RET

DIV_CHECK_NONZERO:
          ;Zフラグ立つかどうか確認
          DEC       L
          INC       L
          JP        NZ, DIV_EXCEPTION_ACTION
          JP        DIV_DIFFERENCE_CHECK

DIV_EXCEPTION_ACTION:
          AND       A
          RL        E
          RL        D
          JP        DIV_CHECK_LOOP_COUNT


DIV_DIFFERENCE_CHECK:
          LD        HL, (X)
          SBC       HL, BC
          JP        C, DIV_EXCEPTION_ACTION
          LD        (X),HL
          SCF
          RL        E
          RL        D
          JP        DIV_CHECK_LOOP_COUNT

DIV_CHECK_LOOP_COUNT:
          ; Aレジスタの値を減らす
          DEC       A

          JP        NZ, DIV_LOOP

          JP        DIV_END_ACTION        

          END
