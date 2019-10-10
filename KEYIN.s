RAM             EQU         8000H
ROM             EQU         0000H

PIO_AD          EQU         01CH
PIO_AC          EQU         01DH
PIO_BD          EQU         01EH
PIO_BC          EQU         01FH

                ORG         RAM

LED_1:          DS          1
LED_2:          DS          1
LED_3:          DS          1
LED_4:          DS          1

MODE:           DS          1
; MODE0 入力なし MODE1 入力1 演算子入力完了
; MODE1 足し算,  MODE2 引き算 
; MODE3 かけ算,  MODE4 割り算



                ORG         ROM

                LD          SP, RAM+0FFFH

                CALL        PIO_INIT

                CALL        LED_CLEAR

                JP          NUM_IN

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
          LD          A,00AH
          LD          (LED_1), A
          LD          (LED_2), A
          LD          (LED_3), A
          LD          A,000H
          LD          (LED_4), A
          OUT         (PIO_AD),A
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
                
                ; 数字だったときの処理
                LD          B, A
                LD          A, (LED_4)
                CP          000H 
                LD          A, B
                JP          Z, OVERWRITE_FIRST_PLACE_NUM1
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
                JP          Z, ENDP
                ; + , -, * , /のとき無視
                CP          00CH
                JP          P, INPUT_SEDOND_NUMBER_CALC
                ; 数字だったときの処理
                LD          B, A
                LD          A, (LED_4)
                CP          000H 
                LD          A, B
                JP          Z, OVERWRITE_FIRST_PLACE_NUM2
                CALL        NZ, L_SHIFT
                JP          INPUT_SEDOND_NUMBER_CALC


; HALTして確認する用途で作成
ENDP:
                ;+以上のとき
                ;CP          00CH
                ;JP          P, ENDP
                HALT

INPUT_C_BUTTON: 
                LD          A, 000H
                LD          (MODE), A
                CALL        LED_CLEAR
                JP          NUM_IN

INPUT_ADD_OPE:
                LD          A, 002H
                LD          (MODE),A
                ; 数値の保存をする必要あり
                CALL        LED_CLEAR
                JP          INPUT_NUM2

INPUT_SUB_OPE:  
                LD          A, 003H
                LD          (MODE),A
                ; 数値の保存をする必要あり
                CALL        LED_CLEAR
                JP          INPUT_NUM2

INPUT_MUL_OPE:  
                LD          A, 004H
                LD          (MODE),A
                ; 数値の保存をする必要あり
                CALL        LED_CLEAR
                JP          INPUT_NUM2

INPUT_DIV_OPE:
                LD          A, 005H
                LD          (MODE),A
                ; 数値の保存をする必要あり
                CALL        LED_CLEAR
                JP          INPUT_NUM2               

OVERWRITE_FIRST_PLACE_NUM1:
                LD          (LED_4), A         
                JP          INPUT_FIRST_NUMBER_OPE

OVERWRITE_FIRST_PLACE_NUM2:
                LD          (LED_4), A         
                JP          INPUT_SEDOND_NUMBER_CALC

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
    
                HALT
                END