;************************************************************************
;* PROYECTO STARGATE.                                                   *
;* sg-null-pic16f876A-skypic-0.asm.                                     *
;*                                                                      *
;* Juan Gonzalez <juan@iearobotics.com>. Julio 2006                     *
;* Basado en codigo del sg-null-pic16F876-xx-0 hecho por:               *
;* Jose Angel de Sande Tundidor <josejosejose@iespana.es>               *
;* Juan Gonzalez <juan@iearobotics.com>                                 *
;*----------------------------------------------------------------------*
;* Servidor NULO                                                        *
;* Servidor: sg-null                                                    *
;* Implementado para la tarjeta Skypic a 20MHz                          *
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
  INCLUDE "p16f876a.inc"
  
  
;---------------------------------------
;- CONSTANTES 
;---------------------------------------
;--- Valores para establecer la velocidad a 9600 baudios
;--- Depende del cristal que se tenga
#define B9600_4MHZ  0x19
#define B9600_20MHZ 0x81


;--------------------------------------------
;- CONSTANTES MODIFICABLES POR EL USUARIO  
;--------------------------------------------
;--- Cambiar esta constante segun la velocidad
;--  Los valores posibles son B9600_20MHZ y B9600_4MHZ segun que se tenga
;--  un cristal de 20 o 40MHZ respectivamente
;--- La Skypic funciona a 20MHz
#define B9600 B9600_20MHZ        
  
;-- Indicar si se quiere que funcione con Bootloader
;-- Por defecto NO esta activado
#define BOOTLOADER 0             ; 0-> No.  1->Cargar con Bootloader

;----------------------------
;-- Definiciones
;----------------------------
;-- Identificadores de los servicios

SID     EQU 'I'       ; Servicio de identificacion (0x49)
SPING   EQU 'P'       ; Servicio de PING (0x50)

;-- Identificadores para la respuesta
RPING   EQU 'O'       ; Respuesta al Servicio de PING (0x4F)

;----- Datos devueltos por el servicio de identificacion
RSI EQU 'I'    ; RSI. Codigo de respuesta del servicio de identificacion
IS  EQU 0x10   ; IS. Identificacion del servidor
IM  EQU 0x30   ; IM. Identificacion del microcontrolador
IPV EQU 0x10   ; IPV. Placa skypic. Version 0.

;---------------------
; VARIABLES
;---------------------
cblock  0x20
  CAR          ;--- Almacenar caracter recibido
endc


;-------------------------
; COMIENZO DEL PROGRAMA 
;-------------------------

  ORG 0

;-- Ejecutar el Bootloader si esta activo
  IF BOOTLOADER == 1
    CLRF    0x3
    MOVLW   0
    MOVWF   0xA
    GOTO    0x4
  ENDIF

;-- Configuracion del puerto serie
  BSF STATUS,RP0    ; Acceso al banco 1
  MOVLW B9600       ; Velocidad: 9600 baudios
  MOVWF SPBRG

  MOVLW 0x24
  MOVWF TXSTA       ; Configurar transmisor

  BCF STATUS,RP0    ; Acceso al banco 0
  MOVLW 0x90        ; Configurar receptor
  MOVWF RCSTA

;-- Configurar LED de la Skypic
  BSF STATUS,RP0    ;  Acceso al banco 1
  BCF TRISB,1       ;  Configurar bit 1 para salida

;---------------------------
;--- Comienzo del servidor
;----------------------------

;-- Inicialmente el led esta encendido
  BCF STATUS,RP0    ; Banco 0
  MOVLW 0x02
  MOVWF PORTB

main
  ;-- Esperar a recibir un caracter
  CALL leer_car
  MOVWF CAR         ; Almacenar caracter recibido en CAR

  MOVLW SPING       ;  Caracter = SPING?
  SUBWF CAR,W
  BTFSC STATUS,Z
  GOTO serv_ping    ;  Si--> Servicio ping

  MOVLW SID         ;  Caracter = SID?
  SUBWF CAR,W
  BTFSC STATUS,Z
  GOTO serv_id      ;  Si--> Servicio Identificacion

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
  MOVLW RSI   ; Enviar codigo de respuesta
  CALL enviar
  MOVLW IS    ; Enviar identificacion del servidor
  CALL enviar
  MOVLW IM    ; Enviar identifiacion del micro
  CALL enviar
  MOVLW IPV   ; Enviar identificador placa/version
  CALL enviar

  GOTO main


;**************************************************
;* Recibir un caracter por el SCI
;-------------------------------------------------
; SALIDAS:
;    Registro W contiene el dato recibido
;**************************************************
leer_car
  BTFSS PIR1,RCIF   ;  RCIF=1?
  GOTO leer_car     ;  no--> Esperar

  ;-- Leer el caracter
  MOVFW RCREG        ; W = dato recibido

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
  BTFSS PIR1,TXIF   ; TXIF=1?
  goto wait         ; No--> wait

  ;; -- Ya se puede hacer la transmision
  MOVWF TXREG
  RETURN

END
