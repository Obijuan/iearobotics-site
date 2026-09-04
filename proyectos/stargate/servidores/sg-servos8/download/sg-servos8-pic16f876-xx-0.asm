;****************************************************************************
;*  sg-servos8-pic16f876-xx-0.asm   Octubre-2003                            *
;---------------------------------------------------------------------------*
; Servidor servos 8
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

;--------- RELACIONADAS CON EL STARGATE ------------------
		
;-- Identificadores de los servicios
SID	EQU 'I'   ; Servicio de identificacion (0x49)
SPING   EQU 'P'   ; Servicio de PING (0x50)
SPOS	EQU 'W'   ; Servicio de Posicionamiento (0x57)
SENA	EQU 'E'   ; Servicio de Habilitacion (0X45)

;-- Identificadores para la respuesta
RPING	EQU 'O'   ; Respuesta al Servicio de PING (0x4F)
RSI	EQU 'I'   ; RSI. Codigo de respuesta del servicio de identificacion
	
;----- Datos devueltos por el servicio de identificacion
IS	EQU 0x30   ; IS. Identificacion del servidor
IM	EQU 0x30   ; IM. Identificacion del microcontrolador
IPV	EQU 0x00   ; IPV. Placa custom. Version 0.
	
;------------- RELACIONADAS CON LOS SERVOS -----------------
PRES8	   EQU 0x82		; Prescaler a 8
DELAY_0_3ms EQU 0xDA		; Tiempo 0'3ms, con prescaler a 8
CENTRO	    EQU 0x83		; Posicion central: 1ms, pres a 8

;---------------------
; VARIABLES
;---------------------
	cblock	0x20

;--- Variables de posicionamiento de los servos
	pos0			; Posicion servo0
	pos1			; Posicion servo1
	pos2			; Posicion servo2
	pos3			; Posicion servo3
	pos4			; Posicion servo4
	pos5			; Posicion servo5
	pos6			; Posicion servo6
	pos7			; Posicion servo7

	salidas	  ; Máscara que indica qué salidas están activas
	estado	  ; Estado del autómata
	mask	  ; Indica máscara de servo actual(0x01-0x80)
	punt	  ; Puntero a la posicion servo actual
	
	car	  		; Caracter recibido por el SCI
	savew			; Guardar el registro W
	savefsr			; Guardar el registro FSR
	pos			; Calculos intermedios
	endc
	
;-----------------------
;- COMIENZO PROGRAMA
;-----------------------
	ORG 0
	GOTO inicio

	ORG 4
;---------------------------------------------
;* Rutina de atención a las interrupciones   *
;* Solo esta activada la interrupcion del    *
;* TMR0, por lo que no hace falta comprobarlo*
;---------------------------------------------
	BCF INTCON,T0IF		;  Quitar flag overflow

	MOVWF savew		; Guardar el registro W
	MOVFW FSR
	MOVWF savefsr		; Guardar registro FSR

;-- Seleccionar servo actual
	MOVFW punt
	MOVWF FSR
	
;-- Según el estado del autónomata saltar a una parte u otra...
	MOVFW estado
	ADDWF PCL,F
	GOTO estado0
	GOTO estado1
	GOTO estado2
;;; -- Aqui no debería llegar!!!

;------------------------
;- ESTADO 0
;------------------------
estado0
;-- Activar la señal del servo activo
	MOVFW mask
	ANDWF salidas,W		; Aplicar la máscara de servos activos
	MOVWF PORTB
	
;-- Lanzar temporizador para calcular anchura fija de 0.3ms
	MOVLW DELAY_0_3ms
	MOVWF TMR0

;-- Pasar al siguiente estado
	INCF estado,F
	GOTO fin

;-----------------------------
;- ESTADO 1
;-----------------------------
estado1
;-- Anchura para situar el servo en el centro
	MOVFW INDF
	MOVWF TMR0		; aunque todavía no sé por qué)

;-- Pasar al siguiente estado
	INCF estado,F
	GOTO fin
	
;------------------------
;- ESTADO 2
;------------------------
estado2
;--- Poner a 0 la señal del Servo
	CLRF PORTB		; Desactivar señal
	CLRF estado		; Pasar al estado 0
	
;-- Anchura hasta llegar a 2'3ms (2ms-pos0) pos0 complementado
	COMF INDF,W
	ADDLW 1
	MOVWF TMR0

;-- Pasar al siguiente servo
	INCF punt,F
	RLF mask,F
	BTFSS STATUS,C		; Era el ultimo servo?
	GOTO fin		; NO --> fin

	MOVLW 0x01		; Si--> volvemos al primero
	MOVWF mask

	MOVLW 0x20	
	MOVWF punt	
fin
	MOVFW savefsr		; Recuperar registro FSR
	MOVWF FSR
	
	MOVFW savew		; Recuperar registro W

	RETFIE
	
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
	
;-- Configurar puerto B como salida
	BSF STATUS,RP0		; Cambiar al banco 1
	CLRF TRISB		; Poner puerto B como salida

;-- Configurar temporizador
;-- Usarlo en modo temporizador, con prescaler indicado
	MOVLW PRES8
	MOVWF OPTION_REG

;-- Configurar las interrupciones
	BSF INTCON,RCIE		; Activar interrupcion overflow TMR0
	BSF INTCON,PEIE		; Activar interrupción de periféricos

	BCF STATUS,RP0		; Cambiar al banco 0
	CLRF PORTB		; Inicializar puerto B

;-- Activar temporizador. Interrupcion cuando se desborde
	CLRW
	MOVWF TMR0

;-- El bit IRP a 0 (Seleccionar banco 0 en direccionamiento indexado)
	BCF STATUS,IRP
	
;-- Inicializar variables
	CLRF estado		; Inicialmente en estado 0
	CLRF salidas		; Los servos están deshabilitados
	MOVLW 0x01
	MOVWF mask		; Establecer mascara servo activo
	MOVLW 0x20
	MOVWF punt
	
	;; -- Posiciones iniciales de los servos
	MOVLW CENTRO
	MOVWF pos0
	MOVWF pos1
	MOVWF pos2
	MOVWF pos3
	MOVWF pos4	
	MOVWF pos5
	MOVWF pos6
	MOVWF pos7		

;-- Activar las interrupciones
 	BSF INTCON,GIE		; Activar interrupciones globales
	
;-- BUCLE PRINCIPAL.

main
	;-- Esperar a recibir un caracter
	CALL leer_car
	MOVWF car		; Almacenar caracter recibido 

	MOVLW SPING		;  Caracter = SPING?
	SUBWF car,W
	BTFSC STATUS,Z
	GOTO serv_ping		;  Si--> Servicio ping

	MOVLW SID		;  Caracter = SID?
	SUBWF car,W
	BTFSC STATUS,Z
	GOTO serv_id		;  Si--> Servicio Identificacion

	MOVLW SPOS		;  Caracter = SPOS?
	SUBWF car,W
	BTFSC STATUS,Z
	GOTO serv_pos		;  Si--> Servicio POS

	MOVLW SENA		;  Caracter = SENA?
	SUBWF car,W
	BTFSC STATUS,Z
	GOTO serv_ena		;  Si--> Servicio ENA
	
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

;-----------------------------------
; Servicio de Posicionamiento
;-----------------------------------
serv_pos	
;--- Leer el número de servo
	CALL leer_car		; Leer el servo
	ADDLW 0x20		; FSR = (servo-1)+0x20. Obtener la
	MOVWF FSR		; direccion de la variable de la posicion
	DECF FSR,F		; del servo
	
;-- Posicionar servo
	CALL leer_car		; Leer la posición
	MOVWF pos		; En la variable del servo hay que
	MOVF  pos,F		;  Pos = 0?
	BTFSS STATUS,Z
	GOTO situar		;  No, continuar
	MOVLW 1			;  si, Poner pos=1. La posicion 0 da
	ADDWF pos,F		; problemas (todavia no se porqué)
	
situar		
	COMF pos,W		; poner la posicion en complemento a dos
	ADDLW 1	
	MOVWF INDF		; Posicionar el servo
	
	GOTO main


;----------------------------------
; Servicio de Habilitación
;----------------------------------
serv_ena
	CALL leer_car		; Leer máscara
	MOVWF salidas		; Actualizar máscara
	
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
	
