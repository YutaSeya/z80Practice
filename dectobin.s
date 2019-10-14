
ROM       EQU       0000H
RAM       EQU       8000H

          ORG       RAM    
LED_1:    DS        1
LED_2:    DS        1
LED_3:    DS        1
LED_4:    DS        1   
X:        DS        2

Y:        DS        2

Z:        DS        2



; MAIN 
          ORG       ROM

          LD        SP, RAM+0FFFH
          LD        A, 001H
          LD        (LED_1), A
          LD        A, 000H
          LD        (LED_2), A
          LD        (LED_3), A
          LD        (LED_4), A
          CALL      DECTOBIN

          HALT

; 7セグメントLED表示を数値に変換する
; 変換結果は変数Zに格納 
DECTOBIN:
          PUSH      AF
          PUSH      BC
          PUSH      DE
          PUSH      HL
         
          ; 変数Zの値を0で初期化
          LD       HL, 00000H 
          LD       (Z), HL

          ; 千の位の掛け算の準備
          ; Yに1000を代入
          LD       HL, 003e8H
          LD       (Y), HL
          ; LED1をロード
          LD        A, (LED_1)
          LD        C, A
          LD        B, 000H
          ; XにBCを追加
          LD        (X), BC

          ; 千の位の掛け算を行う
          CALL      MUL_XY
          ; ZにXとZの掛け算の結果を足し合わせる
          CALL      ADD_Z

          ; 百の位の桁の掛け算の準備
          ; Yに100を代入
          LD       HL, 00064H
          LD       (Y), HL
          ; LED2をロード
          LD        A, (LED_2)
          LD        C, A
          LD        B, 000H
          ; XにBCを追加
          LD        (X), BC

          ; 百の位の掛け算を行う
          CALL      MUL_XY
          ; ZにXとZの掛け算の結果を足し合わせる
          CALL      ADD_Z 

          ; 十の位の桁の掛け算の準備
          ; Yに10を代入
          LD       HL, 0000AH
          LD       (Y), HL
          ; LED3をロード
          LD        A, (LED_3)
          LD        C, A
          LD        B, 000H
          ; XにBCを追加
          LD        (X), BC

          ; 十の位の掛け算を行う
          CALL      MUL_XY
          ; ZにXとZの掛け算の結果を足し合わせる
          CALL      ADD_Z        

          ; 一の位の桁の掛け算の準備
          ; LED4をロード
          LD        A, (LED_4)
          LD        C, A
          LD        B, 000H
          ; XにBCを追加
          LD        (X), BC

          ; ZにXとZの掛け算の結果を足し合わせる
          CALL      ADD_Z      

          ; X,Yを0クリアしておく
          LD        HL, 00000H        
          LD        (X), HL
          LD        (Y), HL

          POP       HL
          POP       DE
          POP       BC
          POP       AF

          RET

; 計算結果を7セグメントLEDで表示する形に変更する
BINTODEC:
          PUSH      AF
          PUSH      BC
          PUSH      DE
          PUSH      HL
         
          ; 変数Zの値を0で初期化
          LD       HL, 00000H 
          LD       (Z), HL

          ; Xから計算結果を読み込む。また、計算結果をZに保存しておく
          LD       HL, (X)
          LD       (Z), HL

          ; 千の位の割り算の準備
          ; Yに1000を代入
          LD       HL, 003e8H
          LD       (Y), HL

          ; 千の位の割り算を行う
          CALL      DIV_XY
          ; 計算結果を取得
          LD        BC, (X)
          LD        A,C
          LD        (LED_1), A
          ; 計算結果を千倍して引く
          ; Yに1000を代入
          LD        HL, 003e8H
          LD        (Y), HL  
          CALL      MUL_XY
          ; 掛け算の結果をYに代入
          LD        HL, (X)
          LD        (Y), HL
          ; ZをXに代入
          LD        HL, (Z)
          LD        (X), HL
          CALL      SUB_XY
          ; 引き算の結果をZに保存する
          LD        HL,(X)
          LD        (Z),HL



          ; 百の位の割り算の準備
          ; Yに100を代入
          LD       HL, 00064H
          LD       (Y), HL

          ; 百の位の割り算を行う
          CALL      DIV_XY
          ; 計算結果を取得
          LD        BC, (X)
          LD        A,C
          LD        (LED_2), A
          ; 計算結果を百倍して引く
          ; Yに100を代入
          LD        HL, 00064H
          LD        (Y), HL  
          CALL      MUL_XY
          ; 掛け算の結果をYに代入
          LD        HL, (X)
          LD        (Y), HL
          ; ZをXに代入
          LD        HL, (Z)
          LD        (X), HL
          CALL      SUB_XY
          ; 引き算の結果をZに保存する
          LD        HL,(X)
          LD        (Z),HL



          ; 十の位の割り算の準備
          ; Yに10を代入
          LD       HL, 0000AH
          LD       (Y), HL

          ; 十の位の割り算を行う
          CALL      DIV_XY
          ; 計算結果を取得
          LD        BC, (X)
          LD        A,C
          LD        (LED_3), A
          ; 計算結果を百倍して引く
          ; Yに10を代入
          LD        HL, 0000AH
          LD        (Y), HL  
          CALL      MUL_XY
          ; 掛け算の結果をYに代入
          LD        HL, (X)
          LD        (Y), HL
          ; ZをXに代入
          LD        HL, (Z)
          LD        (X), HL
          CALL      SUB_XY
          ; 引き算の結果をLED_4に保存する
          LD        BC,(X)
          LD        A,C
          LD        (LED_4), A

          POP       HL
          POP       DE
          POP       BC
          POP       AF        
          RET 

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

          ; オーバーフロー処理
          JP        C, MUL_OVERFLOW

          ; BCレジスタを左にシフト
          SLA       C
          RL        B

          CALL      C, ADD_HL
          
          ; Aレジスタの値を減らす
          DEC       A

          JP        NZ, MUL_LOOP

          LD        (X), HL

          ; オーバーフロー処理
          LD        A, H
          CP        28H  
          JP        P, MUL_OVERFLOW    

          POP       HL
          POP       DE
          POP       BC
          POP       AF
          RET

ADD_HL:
          ADD       HL, DE
          RET

MUL_OVERFLOW:
          LD        HL, 0FFFFH
          LD        (X), HL
          HALT  

; ADD_Z
ADD_Z:
          PUSH      AF
          PUSH      DE
          PUSH      HL    
          
          LD        HL, (X)
          LD        DE, (Z)

          ADD       HL, DE
          LD        (Z),HL    
  
          POP       HL
          POP       DE
          POP       AF
          RET

; DIV_XY
DIV_XY:
          PUSH      HL
          PUSH      BC
          PUSH      DE
          PUSH      AF


          LD        HL,(Y)

          LD        A, L
          CP        000H
          JP        NZ, DIV_START_UP

          LD        A, H
          CP        000H
          JP        NZ, DIV_START_UP

          ; 0で割ることはできないのでerror
          ; ひとまずエラーをしらせるため0xffffをいれる
          JP        DIV_OVERFLOW

DIV_START_UP:
          LD        BC, 0000H
          LD        A, 10H

DIV_LOOP:
          LD        HL,(Y)

          SRA       H
          RR        L

          RR        B
          RR        C

          LD        (Y), HL
          ; Zフラグをたたせるため
          DEC       H
          INC       H

          JP        NZ, DIV_EXCEPTION_ACTION
          DEC       L
          INC       L
          JP        NZ, DIV_EXCEPTION_ACTION

          JP        DIV_DIFFERENCE_CHECK

DIV_END_ACTION:
          LD        HL,(X)
          LD        (Y),HL

          LD        (X),DE

          ; オーバーフロー処理
          LD        A, D
          CP        28H  
          JP        P, DIV_OVERFLOW    

          POP       AF
          POP       DE
          POP       BC
          POP       HL
          RET

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

DIV_OVERFLOW:
          LD        HL, 0FFFFH
          LD        (X), HL
          HALT  

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
          
          ; オーバーフロー処理
          JP        M, SUB_OVERFLOW
          LD        A, H
          CP        28H  
          JP        P, SUB_OVERFLOW
          
          POP       HL
          POP       DE
          POP       AF
          RET

SUB_OVERFLOW:
          LD        HL, 0FFFFH
          LD        (X), HL
          HALT 

          END