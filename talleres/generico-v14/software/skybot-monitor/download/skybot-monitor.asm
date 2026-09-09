;************************************************************************
;* SKYBOT-MONITOR.                                                      *
;* Julio 2005: Adaptado el servidor generico sg-generic-pic16f876-xx    *
;*  para ser cargado con el bootloader de Microchip, utilizado para el  *
;*  robot Skybot                                                        *
;*  - Para cargarlo con el bootloader, asegurarse que el fichero .hex   *
;*    generado esta en formato inhx8m                                   *
;*  Juan Gonzalez                                                       *
;*----------------------------------------------------------------------*
;* PROYECTO STARGATE.                                                   *
;* sg-generic-pic16f876-xx-0.asm.                                       *
;*                                                                      *
;* Jose Angel de Sande Tundidor <josejosejose@iespana.es>	        *
;* Juan Gonzalez <juan@iearobotics.com>                                 *
;* Octubre-2003                                                         *
;*----------------------------------------------------------------------*
;* Servidor GENERICO                                                    *
;* Servidor: sg-generic                                                 *
;* Implementado para el micro 16F876 en una tarjeta prototipo           *
;*----------------------------------------------------------------------*
;* Servicios basicos: Identificacion y PING                             *
;* Servicios LOAD y STORE                                               *
;* Inicialmente se activa el led conectado al pin RB1                   *
;*----------------------------------------------------------------------*
;*  Licencia GPL                                                        *
;************************************************************************

;-- Establecer el PIC a emplear
	LIST p=16f876
	INCLUDE "p16f876.inc"

;--- Valores para establecer la velocidad a 9600 baudios
;--- Depende del cristal que se tenga
#define B9600_4MHZ  0x19
#define B9600_20MHZ 0x81

;--- Cambiar esta constante segun la velocidad
;--- El skybot funciona a 20MHz
#define B9600 B9600_20MHZ

	
;----------------------------
;-- Definiciones
;----------------------------
;-- Identificadores de los servicios
SID	EQU 'I'   ; Servicio de identificacion (0x49)
SPING   EQU 'P'   ; Servicio de PING (0x50)
SLD	EQU 'L'   ; Servicio LOAD (0x4C)
SST	EQU 'S'   ; Servicio STORE (0X53)

;-- Identificadores para la respuesta
RPING	EQU 'O'   ; Respuesta al Servicio de PING (0x4F)
RSI	EQU 'I'    ; RSI. Codigo de respuesta del servicio de identificacion
RLD	EQU 'L'   ; Codigo respuesta servicio LOAD
RST	EQU 'S'   ; Codigo respuesta servicio STORE	

;----- Datos devueltos por el servicio de identificacion
IS	EQU 0x20   ; IS. Identificacion del servidor
IM	EQU 0x30   ; IM. Identificacion del microcontrolador
IPV	EQU 0x10   ; IPV. Placa skypic. Version 0.
		
;-- Variables
CAR	EQU 0x20
DIRH	EQU 0x21		; Byte alto Direccion donde hacer load/store
DIRL	EQU 0x22		; Byte bajo Direccion donde hacer load/store
DATO	EQU 0x23		; Dato a almacenar al hacer STORE
		
;---------------------------
;--  COMIENZO DEL PROGRAMA
;---------------------------
	ORG 0
	
;-- Esta parte es necesaria para que funcione el bootloader	
	clrf    0x3
        movlw   0
        movwf   0xa
        goto    0x4

;-- COMIENZO DEL PROGRAMA
;-- Configuracion del puerto serie
	BSF STATUS,RP0		; Acceso al banco 1
	MOVLW B9600		; Velocidad: 9600 baudios
	MOVWF SPBRG

	MOVLW 0x24
	MOVWF TXSTA		; Configurar transmisor

	BCF STATUS,RP0		; Acceso al banco 0		
	MOVLW 0x90		; Configurar receptor
	MOVWF RCSTA
  
;-- Configurar monitor para el Skybot v.1.2  
  BSF STATUS,RP0		; Acceso al banco 1
  MOVLW 0x1E
  MOVWF TRISB
  

;--- Comienzo del servidor
	BCF STATUS,RP0		; Banco 0
	
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

	MOVLW SLD		;  Caracter = SLD?
	SUBWF CAR,W
	BTFSC STATUS,Z
	GOTO serv_ld		;  Si--> Servicio LOAD

	MOVLW SST		;  Caracter = SST?
	SUBWF CAR,W
	BTFSC STATUS,Z
	GOTO serv_st		;  Si--> Servicio STORE
	
	GOTO main


;************************************************
;* Servicio PING
;************************************************
serv_ping
	
;-- Enviar la respuesta
	MOVLW RPING
	CALL enviar

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

;**********************************************
;*  SERVICIO LOAD
;**********************************************
serv_ld
	CALL leer_dir		; Leer la direccion

	MOVFW INDF		; Leer el dato pedido
	MOVWF DATO

;-- Enviar la trama de resupesta
	MOVLW RLD		; Enviar Cabecera
	CALL enviar

	MOVFW DATO		; Enviar Dato
	CALL enviar
	
	GOTO main

;**********************************************
;*  SERVICIO STORE
;**********************************************
serv_st
	CALL leer_dir		; Leer la direccion
	CALL leer_car		; Leer dato a guardar

;--- Guardar dato en dirección indicada
	MOVWF INDF

;--- Enviar la respuesta
	MOVLW RST
	CALL enviar
	
	GOTO main	

;*******************************************************
;* Leer el campo direccion de las tramas LOAD y STORE  *
;* El byte bajo se guarda en el registro FSR y el      *
;* noveno bit se pone en el bit IRP del registro de    *
;* de STATUS                                           *
;*******************************************************
leer_dir
	CALL leer_car		; Leer byte bajo direccion
;--- ponerlo en registro FSR para direccionamiento indirecto
	MOVWF FSR

	CALL leer_car		; Leer byte alto direccion
	MOVWF DIRH

;-- Poner el bit de menos peso de DIRH en el bit IRP
;-- del registro de STATUS
	BTFSC DIRH,0		; Bit 0 de DIRH=0?
        goto irp_1		; No--> poner IRP a 1
	BCF STATUS,IRP	       	; si--> poner IRP a 0
	goto cont
irp_1
	BSF STATUS,IRP

;-- Listos para hacer direccionamiento indirecto
cont
		
	RETURN
	
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
