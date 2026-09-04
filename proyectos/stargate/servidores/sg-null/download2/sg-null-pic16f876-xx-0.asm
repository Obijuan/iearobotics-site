;************************************************************************
;* PROYECTO STARGATE.                                                   *
;* sg-nullo-pic16f876-xx-0.asm.                                         *
;*                                                                      *
;* Jose Angel de Sande Tundidor <josejosejose@iespana.es>	        *
;* Juan Gonzalez <juan@iearobotics.com>                                 *
;* Octubre-2003                                                         *
;*----------------------------------------------------------------------*
;* Servidor NULO                                                        *
;* Servidor: sg-null                                                    *
;* Implementado para el micro 16F876 en una tarjeta prototipo           *
;*----------------------------------------------------------------------*
;* Implementados los servicios de Identificacion y PING.                *
;* Cada vez que se hace un PING se cambia de estado el led.             *
;* Inicialmente el led conectado al pin RB1 esta encendido              *
;* Cualquier otro caracter recibido se ignora                           *
;*----------------------------------------------------------------------*
;*  Licencia GPL                                                        *
;************************************************************************

;-- Establecer el PIC a emplear
	LIST p=16f876
	INCLUDE "p16f876.inc"

;----------------------------
;-- Definiciones
;----------------------------
;-- Identificadores de los servicios

SID	EQU 'I'   ; Servicio de identificacion (0x49)
SPING   EQU 'P'   ; Servicio de PING (0x50)

;-- Identificadores para la respuesta
RPING	EQU 'O'   ; Respuesta al Servicio de PING (0x4F)

;----- Datos devueltos por el servicio de identificacion
RSI	EQU 'I'    ; RSI. Codigo de respuesta del servicio de identificacion
IS	EQU 0x10   ; IS. Identificacion del servidor
IM	EQU 0x30   ; IM. Identificacion del microcontrolador
IPV	EQU 0x00   ; IPV. Placa custom. Version 0.
		
;-- Variables
CAR	EQU 0x20
	
;---------------------------
;--  COMIENZO DEL PROGRAMA
;---------------------------
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

;-- Configurar pin RB6 para salida
	BSF STATUS,RP0		;  Acceso al banco 1
	BCF TRISB,1		;  Configurar bit 1 para salida

;--- Comienzo del servidor
	BCF STATUS,RP0		; Banco 0
	BSF PORTB,1		; Encender el led
	
main
	;-- Esperar a recibir un caracter
	CALL leer_car
	MOVWF CAR		; Almacenar caracter recibido en CAR

	MOVLW SPING		;  Caracter = SPING?
	SUBWF CAR,W
	BTFSC STATUS,Z
	GOTO serv_ping		;  Si--> Servicio ping

	MOVLW SID		;  Caracter = SID?
	SUBWF CAR,W
	BTFSC STATUS,Z
	GOTO serv_id		;  Si--> Servicio Identificacion
	
	GOTO main


;************************************************
;* Servicio PING
;************************************************
serv_ping
	
;-- Enviar la respuesta
	MOVLW RPING
	CALL enviar

;-- Cambiar el led de estado
	MOVLW 0x02
	XORWF PORTB,F
	
	GOTO main

;*************************************************
;* Servicio de IDENTIFICACION
;*************************************************
serv_id

;-- Enviar la trama de respuesta
	MOVLW RSI		; Enviar codigo de respuesta
	CALL enviar
	MOVLW IS		; Enviar identificacion del servidor
	CALL enviar
	MOVLW IM		; Enviar identifiacion del micro
	CALL enviar
	MOVLW IPV		; Enviar identificador placa/version
	CALL enviar
		
	GOTO main
		
;**************************************************
;* Recibir un caracter por el SCI
;-------------------------------------------------
; SALIDAS:
;    Registro W contiene el dato recibido
;**************************************************
leer_car
	BTFSS PIR1,RCIF		; RCIF=1?
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
;-- Esperar a que Flag de listo para transmitir este a 1
enviar
wait
	BTFSS PIR1,TXIF		; TXIF=1?
	goto wait		; No--> wait

	;; -- Ya se puede hacer la transmision
	MOVWF TXREG
	RETURN
		
	END
	
