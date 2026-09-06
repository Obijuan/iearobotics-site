;***************************************************
;* suma.asm.   Juan Gonzalez Gomez.  Octubre 2003
;---------------------------------------------------
;* Programa ejemplo que realiza la suma 1 + 2 y
;* deposita el resultado en la variable SUMA
;---------------------------------------------------
; LICENCIA GPL
;***************************************************

;--- Especificar el PIC a emplear
	LIST P=16F873
	INCLUDE "p16f873.inc"

;--- Variables
SUMA	EQU 0x20
	
;-- Comienzo del programa
	ORG 0

	MOVLW 1
	ADDLW 2
	MOVWF SUMA

fin	GOTO fin

	END

	

	
