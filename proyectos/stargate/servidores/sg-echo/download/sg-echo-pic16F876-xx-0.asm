;************************************************************************
;* PROYECTO STARGATE.                                                   *
;* sg-echo-pic16f876-xx-0.asm.                                          *
;*                                                                      *
;* Jose Angel de Sande Tundidor <josejosejose@iespana.es>	        *
;* Juan Gonzalez <juan@iearobotics.com>                                 *
;* Octubre-2003                                                         *
;*----------------------------------------------------------------------*
;* Servidor de ECO.                                                     *
;* Servidor: sg-echo                                                    *
;* Implementado para el micro 16F876 en una tarjeta prototipo           *
;*----------------------------------------------------------------------*
;* Se hace eco de todo lo recibido por el puerto serie.                 *
;* El caracter recibido ademas se saca por el puerto B para poderse     *
;* visualizar con la tarjeta PCT-LED                                    *
;*----------------------------------------------------------------------*
;*  Licencia GPL                                                        *
;************************************************************************

;-- Establecer el PIC a emplear
	LIST p=16f876
	INCLUDE "p16f876.inc"

	ORG 0
	
;-- Configuracion del puerto serie
	BSF STATUS,RP0		; Acceso al banco 1
	MOVLW 0x19		; Velocidad: 9600 baudios
	MOVWF SPBRG

	MOVLW 0x24
	MOVWF TXSTA		; Configurar transmisor

	BCF STATUS,RP0		; Acceso al banco 0		
	MOVLW 0x90		; Configurar receptor
	MOVWF RCSTA

	
;-- Configurar puerto B para salida
	BSF STATUS,RP0		;  Acceso al banco 1
	CLRF TRISB		;  Configurarlo para salida

;--- Comienzo del servidor
	BCF STATUS,RP0		; Banco 0
	MOVLW 0xFF
	MOVWF PORTB             ; Valor inicial del puerto B
	
main
	;-- Esperar a recibir un caracter
	CALL leer_car

	;-- Hacer eco
	CALL enviar

	;-- Sacar caracter por el puerto B
	MOVWF PORTB
	
	GOTO main


;**************************************************
;* Recibir un caracter por el SCI
;-------------------------------------------------
; SALIDAS:
;    Registro W contiene el dato recibido
;**************************************************
leer_car
	BTFSS PIR1,RCIF		; ¿RCIF=1?
	GOTO leer_car		; no--> Esperar

	;-- Leer el caracter
	MOVFW RCREG	        ; W = dato recibido
	
	RETURN
	
;*****************************************************
;* Transmitir un caracter por el SCI               
;*---------------------------------------------------
;* ENTRADAS:
;*    Registro W:  caracter a enviar         
;*****************************************************
;-- Esperar a que Flag de listo para transmitir esté a 1
enviar
wait
	BTFSS PIR1,TXIF		; ¿TXIF=1?
	goto wait		; No--> wait

	;; -- Ya se puede hacer la transmision
	MOVWF TXREG
	RETURN
		
	END
	
