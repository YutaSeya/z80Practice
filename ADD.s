ROM       EQU       0000H
RAM       EQU       8000H

ORG       RAM       
X:        DS        2

Y:        DS        2

Z:        DS        2

; MAIN 
          ORG       ROM

          LD        SP, RAM+0FFFH
          
          CALL      ADD_XY

          HALT


;ADD_XY
ADD_XY:
          PUSH      AF
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
          POP       AF
          RET

; ADD_Z
ADD_Z:
          PUSH      AF
          PUSH      DE
          PUSH      HL    
          
          LD        HL, (X)
          LD        DE, (Z)

          ADD       HL, DE
          LD        (Z),HL    

          ; オーバーフロー処理
          LD        A, H
          CP        28H  
          JP        P, ADD_OVERFLOW    
  
          POP       HL
          POP       DE
          POP       AF
          RET


ADD_OVERFLOW:
          LD        HL, 0FFFFH
          LD        (X), HL
          HALT  
             

          END

