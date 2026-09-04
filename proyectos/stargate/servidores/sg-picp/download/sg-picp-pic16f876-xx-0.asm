;****************************************************************************
;*  sg-picp-pic16f876-xx-0.asm   Octubre-2003                               *
;---------------------------------------------------------------------------*
; Servidor PICP, para la programacion de microcontroladores PIC             *
;---------------------------------------------------------------------------*
;  Juan Gonzalez <juan@iearobotics.com>                                     *
;  LICENCIA GPL                                                             *
;****************************************************************************

;-- Establecer el PIC a emplear
	LIST p=16f876
	INCLUDE "p16f876.inc"

;----------------------------
;-- Definiciones
;----------------------------

;----- Datos devueltos por el servicio de identificacion
IS EQU  0x40   ; IS. Identificacion del servidor
IM EQU  0x30   ; IM. Identificacion del microcontrolador
IPV EQU 0x00   ; IPV. Placa custom. Version 0.

;-- Identificadores de los servicios
SID   EQU 'I'  ; Servicio de identificacion (0x49)
SPING EQU 'P'  ; Servicio de PING (0x50)
SRD   EQU 'R'  ; Servicio READ-DATA (0x52)
SINC  EQU 'A'  ; Servicio INCREMENT-ADDERSS (0x41)
SPROG EQU 'W'  ; Servicio PROGRAMACION (0x57)
SCONF EQU 'C'  ; Servicio LOAD-CONFIGURATION (0x43)
SRST  EQU 'T'  ; Servicio RESET (0x54)
SDATA EQU 'D'  ; Servicio LOAD-DATA (0x44)
SBEG  EQU 'B'  ; Servicio BEGIN program/erase cycle (0x42)		

;-- Identificadores para la respuesta
RPING EQU 'O'  ; Respuesta al Servicio de PING (0x4F)
RSI   EQU 'I'  ; RSI. Codigo de respuesta del servicio de identificacion
RRD   EQU 'R'  ; Respuesta servicio READ-DATA	
RINC  EQU 'A'  ; Respuesta servicio INCREMENT-ADDRES
RPROG EQU 'W'  ; Respuesta servicio PROG
RCONF EQU 'C'  ; Respuesta Servicio LOAD-CONFIGURATION
RRST  EQU 'T'  ; Respuesta Servicio RESET
RDATA EQU 'D'  ; Respuesta Servicio LOAD-DATA
RBEG  EQU 'B'  ; Respuesta Servicio BEGIN programa/erase cycle	
	
;-- Conexiones entre el grabador y el PIC
;------------------
;- CLOCK --> RB6
;- DATA ---> RB7
;- RESET --> MCLR
	
;-- Se definen los bits
#define CLOCK 6		; Salida
#define DATA  7		; Entrada/salida
#define RESET 5 	; Salida

;-- Codigos de los comandos del monitor del PIC
LOAD_CONFIG EQU 0x00  ; Comando: LOAD CONFIGURATION
LOAD_DATA   EQU 0x02  ; Comando: LOAD DATA For Program Memory
READ_DATA   EQU 0x04  ; Comando READ_DATA from Program Memory
INC_ADDR    EQU 0x06  ; COMANDO INCREMENT ADDRESS
BEG_ER_PRO  EQU 0x08  ; Comando: BEGIN ERASE PROGRAMMING CICLE	

;-- Definiciones para el temporizaodr
TICKS10	EQU 0xD8		; Valor con el que inicializar contador para
				; conseguir TICKs de 10ms
	
;---------------------
; VARIABLES
;---------------------
	cblock	0x20
	
;-- Parámetros para la funcion write_bits
	datow			; Información a enviar
	nbits			; Número de bits a enviar
	
;-- Bucle principal
	car			; Caracter recibido

;-- Rutina delay
	cont			; Numero de ticks a esperar

;-- Palabras del pic
	palabral		; Byte de menor peso
	palabrah		; Byte de mayor peso
		
	endc
	
;-----------------------
;- COMIENZO PROGRAMA
;-----------------------
	ORG 0

	
;------------------------------
;-    PROGRAMA PRINCIPAL
;------------------------------
inicio

;-- Configuracion del puerto serie
	BSF STATUS,RP0		; Acceso al banco 1
	MOVLW 0x19		; Velocidad: 9600 baudios
	MOVWF SPBRG

	MOVLW 0x24
	MOVWF TXSTA		; Configurar transmisor

	BCF STATUS,RP0		; Acceso al banco 0		
	MOVLW 0x90		; Configurar receptor
	MOVWF RCSTA
		
;-- Configurar el puerto B
	BSF STATUS,RP0		; Cambiar al banco 1
	BCF TRISB,CLOCK		; Señal Clock--> Salida
	BCF TRISB,DATA		; Señal Data--> E/S.
	BCF TRISB,RESET		; Señal Reset--> Salida

;-- Configurar temporizador, para la rutina delay
;-- Usarlo en modo temporizador, prescaler = 256
	MOVLW 0x87
	MOVWF OPTION_REG
	
;-- Estado inicial puerto B
	BCF STATUS,RP0		; Cambiar al banco 0
	CLRF PORTB
		
;-- BUCLE PRINCIPAL.
main
	CLRF PORTB
	
	;-- Esperar a recibir un caracter
	CALL leer_car
	MOVWF car		; Almacenar caracter recibido 

	MOVLW SPING		;  Servicio PING
	SUBWF car,W
	BTFSC STATUS,Z
	GOTO serv_ping		

	MOVLW SID		;  Servicio ID
	SUBWF car,W
	BTFSC STATUS,Z
	GOTO serv_id		

	MOVLW SRST		;  Servicio RESET
	SUBWF car,W
	BTFSC STATUS,Z
	GOTO serv_rst		

	MOVLW SRD		;  Servicio READ-DATA
	SUBWF car,W
	BTFSC STATUS,Z
	GOTO serv_rd		

	MOVLW SINC		;  Servicio INCREMENT-ADDRESS
	SUBWF car,W
	BTFSC STATUS,Z
	GOTO serv_inc	       

	MOVLW SCONF		;  Servicio LOAD CONFIG
	SUBWF car,W
	BTFSC STATUS,Z
	GOTO serv_conf	    

	MOVLW SDATA		; Servicio LOAD-DATA
	SUBWF car,W
	BTFSC STATUS,Z
	GOTO serv_load_data

	MOVLW SBEG		; Servicio Begin program/erase cycle
	SUBWF car,W
	BTFSC STATUS,Z
	GOTO serv_begin

	MOVLW SPROG		; Servicio PROG
	SUBWF car,W
	BTFSC STATUS,Z
	GOTO serv_prog
	
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
	
;****************************************************************
;* Servicio RESET. Hacer un RESET del PIC                       *
;****************************************************************
serv_rst

	CLRF PORTB
	
;-- Hacer el reset.
        BSF PORTB,RESET		; Activar reset
	MOVLW 2
	CALL delay		; Esperar 20ms
	BCF PORTB,RESET		; Desactivar reset

;-- Mandar trama de respuesta
	MOVLW RRST
	CALL enviar
	
	GOTO main	
	
;*******************************************************************
; Servicio READ-DATA. Lectura de la palabra de la posicion actual  *
;*******************************************************************	
serv_rd
	
;--- Mandar cabecera de la trama de respuesta
	MOVLW RRD
	CALL enviar
	
;-------- Leer palabra del pic
;-- Mandar comando read-data
	MOVLW READ_DATA
	CALL send_cmd
	
;-- Leer la palabra
	CALL read_data		; Se encuentra en palabrah y palabral
	
;-------- enviar el dato al PC
	MOVFW palabral		; Dato de menor peso
	CALL enviar

	MOVFW palabrah		; Dato de mayor peso
	CALL enviar

	GOTO main

;*********************************************************************
;* Servicio INCREMENT-ADDRESS. Incremento de la direccion actual
;*********************************************************************
serv_inc
	
;-- Ejecutar el comando
	MOVLW INC_ADDR
	CALL send_cmd
	
;-- Mandar trama de respuesta
	MOVLW RINC
	CALL enviar
		
	GOTO main	

;***************************************************************
;* Servicio LOAD CONF. Acceder a la memoria de configuracion
;***************************************************************
serv_conf
;-- Ejecutar el comando
	MOVLW LOAD_CONFIG
	CALL send_cmd

	CLRF palabrah		; Mandar cualquier cosa
	CLRF palabral
	CALL load_data
	
;-- Mandar la trama de respuesta
	MOVLW RCONF
	CALL enviar

	GOTO main

;*****************************************************************
;* Servicio PROG. Grabar un dato en la memoria
;*****************************************************************	
serv_prog
;-- Leer el valor a grabar
	CALL leer_car		; Obtener byte bajo
	MOVWF palabral
	CALL leer_car
	MOVWF palabrah		; Obtener byte alto

;-- Grabar
	MOVLW LOAD_DATA
	CALL send_cmd
	CALL load_data		; Mandar al pic dato a grabar

	MOVLW BEG_ER_PRO	; Programar!!!
	CALL send_cmd

;-- Mandar trama de respuesta
	MOVLW RPROG
	CALL enviar

	GOTO main
	
;****************************************************************
;* Servicio LOAD-DATA. Enviar un dato al PIC                    *
;****************************************************************
serv_load_data
	
;--- Leer el valor
	CALL leer_car		; Leer byte bajo
	MOVWF palabral
	CALL leer_car		; Leer byte alto
	MOVWF palabrah
	
;-- Ejecutar el comando
	MOVLW LOAD_DATA
	CALL send_cmd

	CALL load_data  	; Mandar el dato al pic
	
;-- Mandar trama de respuesta
	MOVLW RDATA
	CALL enviar
		
	GOTO main

;****************************************************************
;* Servicio BEGIN PROGRAM/ERASE CYCLE                           *
;****************************************************************
serv_begin
	MOVLW BEG_ER_PRO
	CALL send_cmd
	
;-- Mandar trama de respuesta
	MOVLW RBEG
	CALL enviar
	
	GOTO main			
	
		
;***************************************************
; Enviar un comando al PIC.                        
; ENTRADAS:
;   -Registro W:       Comando a enviar
;***************************************************
send_cmd
	BCF PORTB,CLOCK		; Poner Clock a '0'

	MOVWF datow		; Comando a enviar
	MOVLW 0x06		; Hay que enviar 6 bits
	MOVWF nbits
	CALL write_bits
	
	BSF PORTB,DATA		; Fin comando
	NOP
	
	RETURN

;***************************************
;* Leer un dato proveniente del PIC    
;* ENTRADAS: Ninguna                   
;* SALIDAS:
;*   -palabral:	 Byte de menor peso
;*   -palabrah:	 Byte de mayor peso
;***************************************
read_data

;-- Configurar pin DATA para entrada
	BSF STATUS,RP0		; Banco 1
	BSF TRISB,DATA
	BCF STATUS,RP0		; Volver al Banco 0

;-- Leer los 8 bits menos significativos
	MOVLW 0x09		
	MOVWF nbits
	CALL read_bits		; Se encuentran en datow
	MOVFW datow
	MOVWF palabral		; Meterlos en palabral
	
;-- Leer los 6 bits más significativo
	MOVLW 0x07
	MOVWF nbits
	CALL read_bits		; Lectura depositada en datow
	RRF  datow,W
	ANDLW 0x3F
	MOVWF palabrah		; Meterlos en palabrah
	
;-- Configurar pin DATA para salida
	BSF STATUS,RP0		; Banco 1
	BCF TRISB,DATA
	BCF STATUS,RP0		; Volver al banco 0
		
	RETURN
	
;***************************************************
; Leer un numero de bits por la entrada de DATOS   *
;*-------------------------------------------------*
;* ENTRADAS:
;*   -nbits:	Numero de bits a leer
;* SALIDA:
;    -datow:	Dato leido
;***************************************************
read_bits
	CLRF datow
	
read_bucle
	RRF datow,F
	
;-- Cambiar el reloj
	BSF PORTB,CLOCK		; Flanco de subida en Clock
	NOP
	NOP
	BCF PORTB,CLOCK		; Flanco de bajada en CLOCK

;-- Leer el bit recibido
	BTFSS PORTB,DATA	; Según el bit recibido
	GOTO bit0		; Recibido un '0'
	BSF datow,7		; Recibido un '1'

	GOTO rd_cont
bit0	
	BCF datow,7

rd_cont
	
	DECFSZ nbits,F		; Recibidos todos los bits?
	GOTO read_bucle		; No, recibir siguiente bit

fin_read_bits

	RETURN

;*****************************************
;* Enviar una palabra de 14 bits al PIC 
;* ENTRADAS:
;*    -palabral: 8 bits de menor peso
;*    -palabrah: Bits de mayor peso
;*****************************************
load_data

;-- Enviar bit de start '0'
	CLRF  datow
	MOVLW 1
	MOVWF nbits
	CALL write_bits
	
;-- Enviar 8 bits de menor peso
	MOVLW 8
	MOVWF nbits
	MOVFW palabral
	MOVWF datow
	CALL write_bits

;-- Enviar los 6 bits de mayor peso + bit stop
	MOVLW 7
	MOVWF nbits
	MOVLW 0x3F		; Limpiar los 2 bits de mayor peso
	ANDWF palabrah,W	; de palabrah (nos quedamos con 6 bits)
	MOVWF datow
	CALL write_bits

	RETURN		
	
;****************************************************
;* Enviar bits al PIC                               
;* ENTRADA:
;*   -Registro datow:	Informacion a enviar
;*   -Registro nbits:	Número de bits a enviar
;****************************************************
write_bits
;-- Comprobar bit menor peso de datow
	BTFSS datow,0		; datow<0>=0?
	GOTO send0		; Si--> enviar un '0'
	
;-- Enviar un '1'
	BSF PORTB,DATA		; no--> Enviar un '1'
	GOTO reloj

;-- Enviar un '0'
send0
	BCF PORTB,DATA		; Enviar un '0'

reloj
	BSF PORTB,CLOCK		; Flanco de subida
	NOP
	NOP			
	BCF PORTB,CLOCK		; Flanco de bajada

;-- Preparar siguiente bit a enviar
	RRF datow,F
	DECFSZ nbits,F		; nbits--, ¿nbits=0?
	GOTO write_bits		; No, enviar siguiente bit

	RETURN			; Si, terminar
	
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

;************************************************************
;* Rutina de espera.
;* ENTRADA:
;*    -W: Numero de ticks a esperar. Cada tick es de 10ms
;************************************************************
delay
	MOVWF cont		; Inicializar contador de ticks

wait10	
	MOVLW TICKS10		;  Poner valor en timer
	MOVWF TMR0
	BCF INTCON,T0IF		;  Quitar flag overflow
delay_wait	
	;;-- Esperar a que transcurra un Tick (de 10ms)
	BTFSS INTCON,T0IF	; Ha terminado temporizador?
	GOTO delay_wait		; No --> Esperar
	
	;;-- Ha transcurrido un tick de 10ms
	DECFSZ	cont,F		; Decrementar contador. Es cero?
	GOTO wait10		; No --> Esperar otros 10ms
	
	RETURN			; Si, terminar
	
		
		
	END
	
