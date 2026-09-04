;************************************************************************
;* PROYECTO STARGATE.                                                   *
;* sg-echo-pic16f876A-skypic-0.asm.                                     *
;*                                                                      *
;* Juan Gonzalez <juan@iearobotics.com>. Julio 2006                     *
;* Basado en codigo del sg-echo-pic16F876-xx-0 hecho por:               *
;* Jose Angel de Sande Tundidor <josejosejose@iespana.es>	              *
;* Juan Gonzalez <juan@iearobotics.com>                                 *
;*----------------------------------------------------------------------*
;* Servidor de ECO.                                                     *
;* Servidor: sg-echo                                                    *
;* Implementado para la tarjeta SKYPIC                                  *
;*----------------------------------------------------------------------*
;* Se hace eco de todo lo recibido por el puerto serie.                 *
;* El caracter recibido ademas se saca por el puerto B para poderse     *
;* visualizar con la tarjeta FREELEDS                                   *
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

;-- Configurar puerto B para salida
  BSF STATUS,RP0    ;  Acceso al banco 1
  CLRF TRISB        ;  Configurarlo para salida

;---------------------------
;--- Comienzo del servidor
;----------------------------
  BCF STATUS,RP0    ; Banco 0
  MOVLW 0xFF
  MOVWF PORTB             ; Valor inicial del puerto B. Leds encendidos

;-- BUCLE PRINCIPAL
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
;-- Esperar a que Flag de listo para transmitir esté a 1
enviar
wait
  BTFSS PIR1,TXIF   ; TXIF=1?
  goto wait         ; No--> wait

  ;; -- Ya se puede hacer la transmision
  MOVWF TXREG
  RETURN

END
