*************************************************************************
* PROYECTO STARGATE.                                                    *
* sg-echo-6811e2-ct-0.asm.  Juan Gonzalez <juan@iearobotics.com>        *
*-----------------------------------------------------------------------*
* Servidor de ECO.                                                      *
* Servidor: sg-echo                                                     *
* Implementado para el micro 6811E2 y la tarjeta CT6811.                *
*-----------------------------------------------------------------------*
* Se hace eco de todo lo recibido por el puerto serie. Se cambia el     *
* estado del led con cada byte recibido y se envia al puerto C para     *
* que sea visualizado en una PCTLED.                                    *
*-----------------------------------------------------------------------*
*  Licencia GPL                                                         *
*************************************************************************

* Puerto C
PORTC EQU $03
DDRC  EQU $07

* Registros del SCI

BAUD    equ  $2B
SCCR1   equ  $2C
SCCR2   equ  $2D
SCSR    equ  $2E
SCDR    equ  $2F

* -- Programa para la eeprom de un E2
	ORG $F800

inicio
        LDX #$1000 
	LDS #$FF     ; inicializar el puntero de pila 

* -- Configurar el puerto serie

	LDAA #$30
	STAA BAUD,X      ; Configurar a 9600 baudios

 	LDAA #$00
        STAA SCCR1,X    ; 8 bits de datos

        LDAA #$0C
        STAA SCCR2,X    ; Inhibir interrupciones SCI.
*                       ; Activar transmisor y receptor del SCI

* Encender el led
	LDAA #$40
	STAA 0,X     

* Configurar puerto C
	LDAA #$FF
        STAA DDRC,X
        CLRA
        STAA PORTC,X	

* Bucle principal
bucle   BSR leer_car     ; Leer el caracter que viene por el SCI
        BSR enviar       ; Enviar el caracter recibido

	STAA PORTC,X	 ; Enviar el caracter a la PCTLED
	LDAA 0,X	 ; Cambiar de estado el LED
	EORA #$40
	STAA 0,X
        BRA bucle

***********************************************************
* Rutina par leer un caracter del puerto serie (SCI)      *
* La rutina espera hasta que llegue algun caracter        *
* ENTRADAS: Ninguna.                                      *
* SALIDAS: El acumulador A contiene el caracter recibido  *
***********************************************************
leer_car BRCLR SCSR,X $20 leer_car   ; Esperar hasta que llegue un caracter
        LDAA SCDR,X
        RTS

************************************************************
* Enviar un caracter por el puerto serie (SCI)             *
* ENTRADAS: El acumulador A contiene el car cter a enviar  *
* SALIDAS: Ninguna.                                        *
************************************************************
enviar  BRCLR SCSR,X $80 enviar
        STAA SCDR,X
        RTS

************************************
* Vector de interrupción de RESET  *
************************************
	ORG $FFFE
	FDB #inicio


        END

