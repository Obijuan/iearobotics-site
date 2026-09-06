;****************************************************************************
;*  ledon.asm      Octubre-2003                                             *
;---------------------------------------------------------------------------*
;  Programa ejemplo que enciende el led conectado al pin RB1                *
;---------------------------------------------------------------------------*
;  Andres Prieto-Moreno <andres@iearobotics.com>                            *
;  Juan Gonzalez <juan@iearobotics.com>                                     *
;  LICENCIA GPL                                                             *
;****************************************************************************

 
; --- Especificar el PIC a emplear
	LIST P=16F873
	INCLUDE "p16f873.inc"

; -- Comienzo del programa
	ORG 0

; -- Poner el bit RB1 como salida
	BSF STATUS,RP0		; Acceder al banco 1
	BCF TRISB,1		; Poner RB1 como salida

; -- Activar RB1 para encender el led
	BCF STATUS,RP0		; Acceder al banco 0
	BSF PORTB,1		; Sacar un '1' por RB1

fin	GOTO fin		; Bucle infinito
	
	END
	
