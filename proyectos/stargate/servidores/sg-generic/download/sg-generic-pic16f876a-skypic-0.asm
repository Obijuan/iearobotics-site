;************************************************************************
;* PROYECTO STARGATE.                                                   *
;* sg-generic-pic16f876-skypic-0.asm.                                   *
;*                                                                      *
;* Juan Gonzalez <juan@iearobotics.com>. Julio 2006                     *
;* Basado en el codigo del servidor sg-generic-p16f876a-xx-0 hecho por: *
;*                                                                      *
;* Jose Angel de Sande Tundidor <josejosejose@iespana.es>               *
;* Juan Gonzalez <juan@iearobotics.com>                                 *
;*----------------------------------------------------------------------*
;* Servidor GENERICO                                                    *
;* Servidor: sg-generic                                                 *
;* Implementado para la tarjeta Skypic a 20MHz                          *
;*----------------------------------------------------------------------*
;* Servicios basicos: Identificacion y PING                             *
;* Servicios LOAD y STORE                                               *
;* Inicialmente se enciende el led de la skypic (RB1)                   *
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
SLD     EQU 'L'       ; Servicio LOAD (0x4C)
SST     EQU 'S'       ; Servicio STORE (0X53)

;-- Identificadores para la respuesta
RPING   EQU 'O'       ; Respuesta al Servicio de PING (0x4F)
RLD     EQU 'L'       ; Codigo respuesta servicio LOAD
RST     EQU 'S'       ; Codigo respuesta servicio STORE	

;----- Datos devueltos por el servicio de identificacion
RSI EQU 'I'    ; RSI. Codigo de respuesta del servicio de identificacion
IS  EQU 0x20   ; IS. Identificacion del servidor
IM  EQU 0x30   ; IM. Identificacion del microcontrolador
IPV EQU 0x10   ; IPV. Placa skypic. Version 0.

;---------------------
; VARIABLES
;---------------------
cblock  0x20
  CAR       ;--- Almacenar caracter recibido
  DIRH      ; Byte alto Direccion donde hacer load/store
  DIRL      ; Byte bajo Direccion donde hacer load/store
  DATO      ; Dato a almacenar al hacer STORE
endc

;---------------------------
;--  COMIENZO DEL PROGRAMA
;---------------------------
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
  
;-- Bucle principal  

main
  ;-- Esperar a recibir un caracter
  CALL leer_car
  MOVWF CAR         ; Almacenar caracter recibido en CAR

  MOVLW SPING       ;  Caracter = SPING?
  SUBWF CAR,W
  BTFSC STATUS,Z
GOTO serv_ping      ;  Si--> Servicio ping

  MOVLW SID         ;  Caracter = SID?
  SUBWF CAR,W
  BTFSC STATUS,Z
  GOTO serv_id      ;  Si--> Servicio Identificacion

  MOVLW SLD         ;  Caracter = SLD?
  SUBWF CAR,W
  BTFSC STATUS,Z
  GOTO serv_ld      ;  Si--> Servicio LOAD

  MOVLW SST         ;  Caracter = SST?
  SUBWF CAR,W
  BTFSC STATUS,Z
  GOTO serv_st      ;  Si--> Servicio STORE
    
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
  MOVLW RSI   ; Enviar codigo de respuesta
  CALL enviar
  MOVLW IS    ; Enviar identificacion del servidor
  CALL enviar
  MOVLW IM    ; Enviar identifiacion del micro
  CALL enviar
  MOVLW IPV   ; Enviar identificador placa/version
  CALL enviar

  GOTO main

;**********************************************
;*  SERVICIO LOAD
;**********************************************
serv_ld
  CALL leer_dir   ; Leer la direccion

  MOVFW INDF      ; Leer el dato pedido
  MOVWF DATO

;-- Enviar la trama de resupesta
  MOVLW RLD       ; Enviar Cabecera
  CALL enviar

  MOVFW DATO      ; Enviar Dato
  CALL enviar

  GOTO main

;**********************************************
;*  SERVICIO STORE
;**********************************************
serv_st
  CALL leer_dir   ; Leer la direccion
  CALL leer_car   ; Leer dato a guardar 

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
  CALL leer_car   ; Leer byte bajo direccion
;--- ponerlo en registro FSR para direccionamiento indirecto
  MOVWF FSR

  CALL leer_car   ; Leer byte alto direccion
  MOVWF DIRH

;-- Poner el bit de menos peso de DIRH en el bit IRP
;-- del registro de STATUS
  BTFSC DIRH,0        ; Bit 0 de DIRH=0?
  goto irp_1          ; No--> poner IRP a 1
  BCF STATUS,IRP      ; si--> poner IRP a 0
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
  BTFSS PIR1,RCIF   ; RCIF=1?
  GOTO leer_car     ; no--> Esperar

  ;-- Leer el caracter
  MOVFW RCREG         ; W = dato recibido
  
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
