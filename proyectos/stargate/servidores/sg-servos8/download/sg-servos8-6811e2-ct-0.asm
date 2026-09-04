************************************************************************
* sg-servos8-6811e2-ct-0.asm.  Juan Gonzalez Gomez. Licencia GPL       *
*----------------------------------------------------------------------*
* Servidor para el posicionamiento de 8 servos del tipo Futaba 3003    *
************************************************************************

***********************************************************************
* Registros y Puertos del 68hc11                                      *
***********************************************************************

* Puertos del 68hc11

PORTA equ $00
PORTB equ $04
PORTC EQU $03
DDRC  EQU $07


* Registros de los comparadores

TCNT  equ $0E  ; valor del temporizador principal
TMSK1 equ $22
TFLG1 equ $23
TCTL1 equ $20
TOC1  equ $16  ; este registro es de 16 bits

* Registros del SCI

BAUD    equ  $2B
SCCR1   equ  $2C
SCCR2   equ  $2D
SCSR    equ  $2E
SCDR    equ  $2F

	
***********************************************************************
* Constantes del programa                                             *
***********************************************************************

T20ms    EQU 40000  ; Retraso de 20ms
T2_5ms   Equ 5000   ; Retraso de 2.5ms

*-- Posiciones del servo	
EXTREMO1 EQU 600
CENTRO   EQU 2400
EXTREMO2 EQU 4300

*-- Estado dentro de una ventana de tiempo	
S1	 EQU $01  * Estado 1. Nivel alto
S0       EQU $00  * Estado 0. Nivel bajo

*----- Datos devueltos por el servicio de identificacion
IS EQU 0x30   * IS. Identificacion del servidor
IM EQU 0x10   * IM. Identificacion del microcontrolador (68hc11E2)
IPV EQU 0x10  * IPV. Placa CT6811. Version 0.

*-- Identificadores de los servicios
SID   EQU 'I'   * Servicio de identificacion (0x49)
SPING EQU 'P'   * Servicio de PING (0x50)
SPOS  EQU 'W'   * Servicio de Posicionamiento (0x57)
SENA  EQU 'E'   * Servicio de Habilitacion    (0x45)

*-- Identificadores para la respuesta
RPING EQU 'O'   * Respuesta al Servicio de PING (0x4F)
RSI EQU 'I'     * RSI. Codigo de respuesta del servicio de identificacion

		
***********************************************************************
* Máscaras de acceso                                                  *
***********************************************************************

OC1  equ $80   ; Comparador 1

FUT1 equ $01   ; Bit donde se encuentra el FUTABA 1
FUT2 equ $02   ; Bit donde se encuentra el FUTABA 2
FUT3 equ $04   ; Bit donde se encuentra el FUTABA 3
FUT4 equ $08   ; Bit donde se encuentra el FUTABA 4
FUT5 equ $10   ; Bit para el futaba 5
FUT6 equ $12   ; Bit para el futaba 6
FUT7 equ $14   ; Bit para el futaba 7
FUT8 equ $18   ; Bit para el futaba 8

***********************************************************************
* Variables del programa                                              *
***********************************************************************

	ORG $0000

*----- Tabla de PWM
posi1   RMB 2
posi2   RMB 2
posi3   RMB 2
posi4   RMB 2
posi5	RMB 2
posi6	RMB 2
posi7   RMB 2
posi8   RMB 2
punt	RMB 2
salidas RMB 1  ; máscara que indica las salidas hardware activas 
servo   RMB 1  * Contador que indica el servo que toca ahora (ventana activa)
estado  RMB 1  * Estado actual (S1, S0)
	
**********************************************************************
* ------------------------------------------------------------------ *
* |                 PROGRAMA PRINCIPAL                             | *
* ------------------------------------------------------------------ *
**********************************************************************

        ORG $F800    ; Programa para el microcontrolador E2

***********************************************************************
* Inicialización del programa                                         *
*********************************************************************** 

inicializar
	LDS #$FF     ; inicializo el puntero de pila
        LDX #$1000   ; para acceder a los registros de control internos

* -- Configurar el puerto serie

	LDAA #$30
	STAA BAUD,X      ; Configurar a 9600 baudios

 	LDAA #$00
        STAA SCCR1,X    ; 8 bits de datos

        LDAA #$0C
        STAA SCCR2,X    ; Inhibir interrupciones SCI.
*                       ; Activar transmisor y receptor del SCI
	
* --- Configuración de los comparadores ---

	CLRA  
	STAA  TCTL1,X       ; Comparadores sin salida hardware	
	LDAA  #OC1          ; Activar el comparador 1 
	STAA  TMSK1,X

* --- Configura el Puerto C

       LDX  #$1000
       LDAA #$FF
       STAA DDRC,X
       CLRA
		
* --- Posicion inicial de los servos ---
	
	LDD   #CENTRO
	STD   posi1
	STD   posi2
	STD   posi3
	STD   posi4
	STD   posi5
	STD   posi6
	STD   posi7
	STD   posi8

	LDAA  #FUT1   * Se comienza por el servo 1
	STAA  servo
	LDY   #posi1  * Y contiene la posicion del servo 1
	STY   punt
	LDAA  #S1
	STAA estado
	
	CLRA          * Inicialmente no hay servos activos            
	STAA  salidas

        LDD TCNT,X        ; Inicializar el comparador 1
	ADDD #40000       ; Dentro de 20ms se producirá una interrupción 
        STD TOC1,X        

	CLI                 ; permitir las interrupciones. 
	                    
        CLRA              * Señales PWM a 0
        STAA PORTB,X

	LDAA #$40       * Encender el led de la CT6811
	STAA PORTA,X
	
*************************************************************************
* BUCLE PRINCIPAL                                                       *
*************************************************************************
server
        BSR leer_car    ; Esperar a que el PC solicite un servicio
        CMPA #SPING     ; Servicio de PING?
        BEQ serv_ping

	CMPA #SID       ; Servicio de identificacion?
	BEQ serv_id

	CMPA #SPOS      ;  Servicio de posicionamiento?
	BEQ serv_pos

	CMPA #SENA      ; Servicio de habilitacion (enable)
	BEQ serv_ena
	
	BRA  server

********************
* Servicio de PING *
********************
serv_ping
        LDAA #RPING  ; Enviar la respuesta al PING
        BSR enviar

        JMP server

*******************************
* Servicio de identificacion  *
*******************************
serv_id
	LDAA #RSI   ; Enviar codigo de respuesta
        BSR enviar
	LDAA #IS    ; Enviar identificacion del servidor
	BSR enviar  
	LDAA #IM    ; Enviar identificador del micro
	BSR enviar
	LDAA #IPV   ; Enviar identificador placa/version
	BSR enviar
	
	JMP server

*********************************
* Servicio de posicionamiento   *
*********************************
serv_pos
	BSR leer_car  * Leer el numero de motor
*-- Meter en Y el numero de motor

	DECA  ; A=motor-1
	LSLA  ; A=(motor-1)*2
	TAB
	CLRA
	XGDY  ; Y=(motor-1)*2

	BSR leer_car  * Leer posicion del servo (0-255)
	CLRB
	LSRD
	LSRD
	LSRD
	LSRD
	ADDD #EXTREMO1 * D=(posicion*16 + EXTREMO1)

*--- Cambiar posicion en la tabla de PWM
	SEI
	STD 0,Y
	CLI
	BRA server

***********************************
* Servicio de habilitacion
***********************************
serv_ena
	BSR leer_car  * Leer la mascara de habilitacion
	STAA salidas  * Actualizar la mascara de habilitacion
	BRA server
	
***********************************************************
* Rutina par leer un caracter del puerto serie (SCI)      *
* La rutina espera hasta que llegue algun caracter        *
* ENTRADAS: Ninguna.                                      *
* SALIDAS: El acumulador A contiene el caracter recibido  *
***********************************************************
leer_car BRCLR SCSR,X $20 leer_car   ; Esperar hasta que llegue un caracter
        LDAA SCDR,X
        RTS

************************************************************
* Enviar un caracter por el puerto serie (SCI)             *
* ENTRADAS: El acumulador A contiene el carÂ cter a enviar  *
* SALIDAS: Ninguna.                                        *
************************************************************
enviar  BRCLR SCSR,X $80 enviar
        STAA SCDR,X
        RTS


	
******************************************************************
*     Rutinas de interrupcion de los  COMPARADORES               *
******************************************************************

* .........................................................
* . Comparador 1: Generacion de los 8 pwm                 .
* .........................................................

int_oc1
	BSET TFLG1,X OC1  ; Poner a cero el flag de interrupción

	LDAA estado   * En que estado estamos?
	CMPA #S1
	BNE estado_s0
	
*--- Estado S1

        LDY punt       * Activar temporizador con posicion servo actual
	LDD TCNT,X
	ADDD 0,Y
	STD TOC1,X

	LDAA servo	* Poner señal PWM a 1 del servo actual
	ANDA salidas    * si es que está habilitada
	STAA PORTB,X

	LDAA #S0        * Pasar al estado S0, en la proxima int.
	STAA estado
	RTI

*----- Estado S0	
estado_s0
	LDY punt       * Int. dentro de 2.5ms-anchura
	LDD #T2_5ms
	SUBD 0,Y 
	ADDD TCNT,X
	STD TOC1,X 

	CLRA           * Poner señal PWM a 0
	STAA PORTB,X

	LDAA servo     * Siguiente servo
	LSLA
	STAA servo
	
	LDY punt       * Actualizar puntero a tabla de PWM
	INY            
	INY            
	STY punt

	LDAA #S1       * Pasar a estado S1, en la proxima int.
	STAA estado
	
	LDAA servo        * Se han actualizado los 8 servos?
	CMPA #$00
	BNE fin_oc1       * No, terminar
	LDAA #$01         * Si, volver a comenzar por servo 1
	STAA servo
	LDY #posi1
	STY punt
	
fin_oc1
	RTI

         ORG $FFE8          * Vector de interrupcion del comparador 1
         FDB  #int_oc1

         ORG $FFFE          * Vector de interrupcion del reset
         FDB  $F800

	
