*************************************************************************
* RTI.ASM  (C) Grupo J&J. Febrero 1997                                  *
*-----------------------------------------------------------------------*
* Programa ejemplo para la tarjeta CT6811. Este programa se debe cargar *
* en la ram interna del 6811                                            *
*-----------------------------------------------------------------------*
* Ejemplo de las interrupciones en tiempo real. Cambiar el estado del   *
* led cada 32.7ms. Se hace mediante espera activa.                      *
*************************************************************************

TMSK2   EQU $24
TFLG2   EQU $25
PACTL   EQU $26
PORTA   EQU $00

        ORG $0000

        LDX #$1000

        BSET PACTL,X $03
bucle
main    BRCLR TFLG2,X $40 main  ; Esperar a que se active el flag

        BSET TFLG2,X $40        ; Poner a cero flag de interrupci¢n

        LDAA PORTA,X
        EORA #$40
        STAA PORTA,X
        BRA bucle

        END

