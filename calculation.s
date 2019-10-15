ROM       EQU       0000H
RAM       EQU       8000H

PIO_AD          EQU         01CH
PIO_AC          EQU         01DH
PIO_BD          EQU         01EH
PIO_BC          EQU         01FH


          ORG       RAM   
X:        DS        2

Y:        DS        2

Z:        DS        2

LED_1:          DS          1
LED_2:          DS          1
LED_3:          DS          1
LED_4:          DS          1

; MODE : 0 入力なし 
; MODE : 1 足し算,  MODE : 2 引き算 
; MODE : 3 かけ算,  MODE : 4 割り算
MODE:           DS          1

; MAIN
                ORG         ROM

                LD          SP, RAM+0FFFH

                CALL        PIO_INIT

                CALL        LED_CLEAR

                JP          NUM_IN

                HALT


; CALCULATION
; MODEに併せて計算処理を行う
CALCULATION:
            ; 数値の保存をする必要あり
            ; 変数Xの数値を壊さないようにBCレジスタに待避
            LD          BC, (X)
            CALL        DECTOBIN
            LD          HL, (Z)
            ; 数値をXYに保存
            LD          (X), BC
            LD          (Y), HL 
            ; MODEの数値をＡレジスタに格納
            LD          A, (MODE)
            ; +のとき
            CP          001H
            JP          Z, ADDITION
            ; -のとき
            CP          002H
            JP          Z, SUBSTRACTION
            ; *のとき
            CP          003H
            JP          Z, MULTIPLICATION
            ; /のとき
            CP          004H
            JP          Z, DIVISION
            ; どれもみたさないとき
            JP          NUM_IN      

ADDITION:
            CALL        ADD_XY
            CALL        BINTODEC
            JP          C_WAIT

SUBSTRACTION:
            CALL        SUB_XY
            CALL        BINTODEC
            JP          C_WAIT
MULTIPLICATION:
            CALL        MUL_XY
            CALL        BINTODEC
            JP          C_WAIT

DIVISION:
            CALL        DIV_XY
            CALL        BINTODEC
            JP          C_WAIT


; Cが押されるまで待つ
C_WAIT:
CLEAR_BUTTON_LOOP:
            CALL        KEY_GET
            CP          00AH
            CALL        LED_OUT
            JP          NZ, CLEAR_BUTTON_LOOP

            JP          NUM_IN

OVERFLOW:
          LD        A, 0FFH
          LD        HL, 0FFFFH
          LD        (X), HL
          LD        (Y), HL
          LD        (LED_1),A
          LD        (LED_2),A
          LD        (LED_3),A
          LD        (LED_4),A
          POP       AF
          POP       DE
          POP       BC
          POP       HL
          RET


; ADD_XY
ADD_XY:
          PUSH      AF
          PUSH      BC
          PUSH      DE
          PUSH      HL

          LD        HL, (X)
          LD        DE, (Y)

          ADD       HL, DE
          LD        (X),HL       
          
          ; オーバーフロー処理
          LD        A, H
          CP        28H  
          JP        P, ADD_OVERFLOW

          POP       HL
          POP       DE
          POP       BC
          POP       AF
          RET

ADD_OVERFLOW:
          LD        HL, 0FFFFH
          LD        (X), HL
          JP        OVERFLOW 

; ADD_Z
ADD_Z:
          PUSH      AF
          PUSH      BC
          PUSH      DE
          PUSH      HL
          
          LD        HL, (X)
          LD        DE, (Z)

          ADD       HL, DE
          LD        (Z),HL    
  
          POP       HL
          POP       DE
          POP       BC
          POP       AF
          RET

SUB_XY:
          PUSH      AF
          PUSH      BC
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
          POP       BC
          POP       AF
          RET

SUB_OVERFLOW:
          LD        HL, 0FFFFH
          LD        (X), HL
          JP        OVERFLOW 


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
          JP        OVERFLOW 


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

DIV_OVERFLOW:
          LD        HL, 0FFFFH
          LD        (X), HL
          JP        OVERFLOW  

; 計算関連からJPでとんでくる。PUSHしたペアレジスタをすべてPOPする
; RETを返すことで処理の終わりを知らせる。

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
          ; Aの値が10よりも大きくないかを比較する
          CP        00AH
          ; Aの値が10よりも大きい場合はオーバーフロー処理に飛ぶ
          JP        P, OVERFLOW
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

; PIO_INIT
PIO_INIT: 
          LD A,0CFH
          OUT (PIO_AC),A
          
          LD A,000H
          OUT (PIO_AC),A
          
          LD A,007H
          OUT (PIO_AC),A

          LD A,0CFH
          OUT (PIO_BC),A
          
          LD A,00FH
          OUT (PIO_BC),A
          
          LD A,007H
          OUT (PIO_BC),A
          
          RET

LED_CLEAR:
          PUSH        AF
          LD          A,000H
          LD          (LED_1), A
          LD          (LED_2), A
          LD          (LED_3), A
          LD          (LED_4), A
          OUT         (PIO_AD),A
          POP         AF
          RET

NUM_IN:    
           ; 一つ目の数字と演算子が入力されるまでループ       
          JP         INPUT_FIRST_NUMBER_OPE
INPUT_NUM2:
          JP         INPUT_SEDOND_NUMBER_CALC
          JP         NUM_IN


INPUT_FIRST_NUMBER_OPE:
                CALL        KEY_IN
                ; ここで入力されたキーによって処理を変えるようにすればよい
                CP          00AH
                JP          Z, INPUT_C_BUTTON 

                ; オペランドの入力確認を行う
                ; = のとき無視
                CP          00BH
                JP          Z, INPUT_FIRST_NUMBER_OPE
                ; + のとき
                CP          00CH
                JP          Z, INPUT_ADD_OPE:

                ; - のとき
                CP          00DH
                JP          Z, INPUT_SUB_OPE:

                ; * のとき
                CP          00EH
                JP          Z, INPUT_MUL_OPE:

                ; / のとき
                CP          00FH
                JP          Z, INPUT_DIV_OPE:
                
                CALL        NZ, L_SHIFT
                JP          INPUT_FIRST_NUMBER_OPE

INPUT_SEDOND_NUMBER_CALC:
                CALL        KEY_IN
                ; ここで入力されたキーによって処理を変えるようにすればよい
                CP          00AH
                JP          Z, INPUT_C_BUTTON 

                ; オペランドの入力確認を行う
                ; = のとき
                CP          00BH
                JP          Z, CALCULATION
                ; + , -, * , /のとき無視
                CP          00CH
                JP          P, INPUT_SEDOND_NUMBER_CALC
                ; 数字だったときの処理
                CALL        NZ, L_SHIFT
                JP          INPUT_SEDOND_NUMBER_CALC


INPUT_C_BUTTON: 
                LD          A, 000H
                LD          (MODE), A
                CALL        LED_CLEAR
                JP          NUM_IN

INPUT_ADD_OPE:
                LD          A, 001H
                LD          (MODE),A
                ; 数値の保存をする必要あり
                CALL        DECTOBIN
                LD          HL, (Z)
                LD          (X), HL
                CALL        LED_CLEAR
                JP          INPUT_NUM2

INPUT_SUB_OPE:  
                LD          A, 002H
                LD          (MODE),A
                ; 数値の保存をする必要あり
                CALL        DECTOBIN
                LD          HL, (Z)
                LD          (X), HL
                CALL        LED_CLEAR
                JP          INPUT_NUM2

INPUT_MUL_OPE:  
                LD          A, 003H
                LD          (MODE),A
                ; 数値の保存をする必要あり
                CALL        DECTOBIN
                LD          HL, (Z)
                LD          (X), HL
                CALL        LED_CLEAR
                JP          INPUT_NUM2

INPUT_DIV_OPE:
                LD          A, 004H
                LD          (MODE),A
                 ; 数値の保存をする必要あり
                CALL        DECTOBIN
                LD          HL, (Z)
                LD          (X), HL
                CALL        LED_CLEAR
                JP          INPUT_NUM2               

L_SHIFT:
                LD          B,A

                LD          A, (LED_2)
                LD          (LED_1), A

                LD          A, (LED_3)
                LD          (LED_2), A

                LD          A, (LED_4)
                LD          (LED_3), A
                
                LD          A,B

                LD          (LED_4),A
                RET    

LED_OUT:        
                PUSH        AF
                PUSH        HL
                PUSH        BC

                IN          A,(PIO_AD)
                ADD         A,010H
                AND         030H
                LD          B,A

                RRCA
                RRCA
                RRCA
                RRCA

                LD          HL,LED_1
                ADD         A,L
                LD          L,A
                LD          A,(HL)
                OR          B
                OUT         (PIO_AD),A

                POP         BC
                POP         HL
                POP         AF
                RET

KEY_IN:
                PUSH        HL
                PUSH        BC
                CALL        KEY_LP
                POP         BC
                POP         HL
                RET  

KEY_LP:
                CALL        KEY_GET 
                LD          C,A
                CALL        KEY_GET
                CP          C 
                JP          NZ,KEY_LP
                LD          B,A
                CALL        WAIT
                LD          A,B
                RET

KEY_GET:
LOOP:       
                CALL        LED_OUT
                ADD         A,010H
                AND         030H
                
                OUT         (PIO_BD),A
                SRL         A
                SRL         A
                SRL         A
                SRL         A

                AND         003H
                LD          B,A

                IN          A,(PIO_BD)

                BIT         0,A   

                JP          Z,ROW4

                BIT         1,A

                JP          Z,ROW3

                BIT         2,A

                JP          Z,ROW2

                BIT         3,A

                JP          Z,ROW1

                JP          LOOP

WAIT:       
                CALL        LED_OUT
                IN          A,(PIO_BD)
                AND         00FH
                CP          00FH
                JP          NZ, WAIT
                RET

ROW4:
                LD          A,B
                ADD         A,00CH
                LD          B,A
                RET

ROW3:
                LD          A,B 
                ADD         A,008H
                LD          B,A
                RET

ROW2:
                LD          A,B
                ADD         A,004H
                LD          B,A
                RET

ROW1:
                LD          A,B
                ADD         A,000H
                LD          B,A
                RET

          END