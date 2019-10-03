ROM       EQU       0000H
RAM       EQU       8000H

PIO_AD    EQU       01CH
PIO_AC    EQU       01DH
PIO_BD    EQU       01EH
PIO_BC    EQU       01FH

          ORG       RAM
X:        DS        2

Y:        DS        2

Z:        DS        2

; MAIN
          ORG       ROM
          LD        SP, RAM+0FFFH

; INIT
INIT: 
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

          END