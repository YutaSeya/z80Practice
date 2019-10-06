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

                ORG         ROM

                LD          SP, RAM+0FFFH

                CALL        PIO_INIT

                CALL        LED_CLEAR

                JP          MAIN

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

MAIN:           

                CALL        KEY_IN
                CALL        L_SHIFT
                JP          MAIN

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