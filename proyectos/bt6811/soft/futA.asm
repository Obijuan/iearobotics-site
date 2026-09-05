* ..........................................................................
* .  FUTABA.  Version 1.0                                                  .
* ..........................................................................
* .  Programa para la gestion de 4 servomecanismos Futaba S3003            .
* ..........................................................................


**************************************************
* Identificador del módulo esclavo               *
**************************************************

M_ES  equ 'a'

***********************************************************************
* Registros y Puertos del 68hc11                                      *
***********************************************************************

* Puertos del 68hc11

PORTA equ $00
PORTB equ $04
PORTC equ $03
DDRC  equ $07


* Registros del SPI

PORTD   EQU $08
DDRD    EQU $09
SPCR    EQU $28
SPDR    EQU $2A
SPSR    EQU $29
 
* Registros de los comparadores

TCNT  equ $0E  ; valor del temporizador principal
TMSK1 equ $22
TFLG1 equ $23
TCTL1 equ $20
TOC1  equ $16  ; este registro es de 16 bits
TOC2  equ $18  ; este registro es de 16 bits
TOC3  equ $1A  ; este registro es de 16 bits
TOC4  equ $1C  ; este registro es de 16 bits
TOC5  equ $1E  ; este registro es de 16 bits

***********************************************************************
* Constantes del programa                                             *
***********************************************************************

PERIODO  EQU 42000  ; Periodo de la señal cuadrada 21 mseg
EXTREMO1 EQU 600
CENTRO   EQU 2600
EXTREMO2 EQU 4300

***********************************************************************
* Máscaras de acceso                                                  *
***********************************************************************

OC1  equ $80   ; Comparador 1
OC2  equ $40   ; Comparador 2
OC3  equ $20   ; Comparador 3
OC4  equ $10   ; Comparador 4
OC5  equ $08   ; Comparador 5

FUT1 equ $01   ; Bit donde se encuentra el FUTABA 1
FUT2 equ $02   ; Bit donde se encuentra el FUTABA 2
FUT3 equ $04   ; Bit donde se encuentra el FUTABA 3
FUT4 equ $08   ; Bit donde se encuentra el FUTABA 4
LED  equ $10   ; Bit donde se encuentra el LED


***********************************************************************
* Variables del programa                                              *
***********************************************************************

	ORG $0

posi1   RMB 2
posi2   RMB 2
posi3   RMB 2
posi4   RMB 2
salidas RMB 1  ; máscara que indica las salidas hardware activas 

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
	
*  --- Configuración del SPI (como esclavo) ----

        LDAA  #$3C       * SS de entrada
        STAA  DDRD,X     * El SPI configura las salidas automáticamente

        LDAA  #$40       * Colector cerrado
        STAA  SPCR,X     * Activa en modo esclavo el SPI

* --- Configuración del Puerto C como salida

	LDAA #$FF
	STAA DDRC,X
 
* --- Configuración de los comparadores ---

	CLRA  
	STAA  TCTL1,X       ; Comparadores sin salida hardware	
	LDAA  #OC1          ; Activo el comparador 1 
	STAA  TMSK1,X

* --- Configuración de las salidas ---
	
	LDD   #2000
	STD   posi1
	STD   posi2
	STD   posi3
	STD   posi4

	CLRA                  ; indico que todos los motores activos
	STAA  salidas

	CLI                 ; permito las interrupciones
        
        LDAA #$FF           ; @@
        STAA PORTB,X        ; @@
	 

*************************************************************************
* BUCLE PRINCIPAL                                                       *
*************************************************************************

inicio
	BSR  recibir_spi 
	CMPA #M_ES            ; verifica que la trama sea para él
	BEQ  analizar
	BSR  recibir_spi
	BSR  recibir_spi
	BSR  recibir_spi
	BRA  inicio

analizar BSR  recibir_spi      ; leo dos carácteres por el puerto serie SPI
	 CMPA #'l'
	 BEQ  cambia_led
	 CMPA #'e'
	 BEQ  servicio_activa
	 CMPA #'p'
	 BEQ  servicio_posicionar
	 CMPA #'c'
	 BEQ  salida_puertoc
	 BRA  inicio

*************************************************************************
* SUBRUTINAS DEL PROGRAMA                                               *
*************************************************************************

* ...........................................................
* . Rutina que cambia el estado del LED                     .
* ...........................................................

cambia_led
	BSR  recibir_spi
	BSR  recibir_spi
	LDAB PORTB,X
	EORB #$10
	STAB PORTB,X
	BRA  inicio


* ...........................................................
* . Rutina que activa o desactiva los motores               .
* ...........................................................

servicio_activa
	BSR  recibir_spi   
	STAA salidas
	BSR  recibir_spi
	BRA  inicio

* ...........................................................
* . Rutina que envia un byte al puerto de salida C          .
* ...........................................................

salida_puertoc
	BSR  recibir_spi   
	STAA PORTC,X
	BSR  recibir_spi
	BRA  inicio

* ...........................................................
* . Servicio posicionar motor                               .
* ...........................................................

servicio_posicionar
        BSR recibir_spi  ; Leer nºmotor ( $1, $2, $3, $4 )
		
* Si se llega aqui es que se ha solicitado servicio de posicionamiento
* Meter en Y el numero (motor-1)*2
	DECA    ; A=motor-1
	LSLA	; A=(motor-1)*2
	TAB
	CLRA
	XGDY	; Y=(motor-1)*2

	BSR  recibir_spi    ; Leer posicion (0-255)
	CLRB
	LSRD
	LSRD
	LSRD
	LSRD
	ADDD #EXTREMO1  * D=(posicion*16+EXTREMO1)
	SEI
	STD  0,Y         * Almacenar posicion
	CLI
	BRA  inicio

* ...........................................................
* . Rutina que recibe un dato por el SPI                    .
* . La rutina espera hasta recibir el dato                  .
* . Entradas: Ninguna                                       .
* . Salidas: El acumulador A contiene el dato               .
* ...........................................................

recibir_spi
espera  BRCLR SPSR,X $80 espera  ; espero que el dato se haya recibido
        LDAA  SPDR,X
	RTS

******************************************************************
*     Rutinas de interrupcion de los  COMPARADORES               *
******************************************************************

* .........................................................
* . Comparador 1: Establece el principio de los pulsos    .
* .........................................................
* . Podemos poner BSET porque las interrupciones de los   .
* . otros comparadores estan desactivadas. En caso        .
* . contrario habría que utilizar load y store.           .
* .........................................................           

int_oc1
	BSET TFLG1,X OC1  ; Poner a cero el flag de interrupción

        LDD TCNT,X        ; Actualizar comparador 1
        ADDD #PERIODO     ; próxima interrupción = ... 
        STD TOC1,X        ;   ... tiempo_actual(TCNT) + Periodo

        LDAA PORTB,X
	ORA  salidas
	ANDA #$18         ; Si salida 4 habilitada ponerla a
        STAA PORTB,X      ; nivel alto
        LDD  TCNT,X       ; Actualizar comparador 5 (FUTABA 4)
        ADDD posi4        ; Establecer tiempo anchura del pulso
        STD  TOC5,X

        LDAA PORTB,X
	ORA  salidas
	ANDA #$1C         ; Si salida 3 habilitada ponerla a
        STAA PORTB,X      ; nivel alto
        LDD TCNT,X        ; Actualizar comparador 4 (FUTABA 3)
        ADDD posi3        ; Establecer tiempo anchura del pulso
        STD TOC4,X

        LDAA PORTB,X
	ORA  salidas
	ANDA #$1E         ; Si salida 2 habilitada ponerla a
        STAA PORTB,X      ; nivel alto
        LDD TCNT,X        ; Actualizar comparador 3 (FUTABA 2)
        ADDD posi2        ; Establecer tiempo anchura del pulso
        STD TOC3,X

        LDAA PORTB,X
	ORA  salidas
	ANDA #$1F         ; Si salida 1 habilitada ponerla a
        STAA PORTB,X      ; nivel alto
        LDD TCNT,X        ; Actualizar comparador 2 (FUTABA 1)
        ADDD posi1        ; Establecer tiempo anchura del pulso
        STD TOC2,X

* Activar las interrupciones de los comparadores de las salidas

        BSET TMSK1,X $78  

        RTI

* ..................................................................... 
* . ¡OJO¡  No podemos poner BSET porque podria desactivar las otras   .
* . interrupciones de los comparadores antes de ser atendidas         .
* .....................................................................
* .    Rutina de servicio de interrupcion del COMPARADOR 2       .
* .    POSICION DEL FUTABA 1                                     .
* ................................................................

int_oc2 
	LDAA #OC2   ; pongo a cero el flag de interrupción
	STAA TFLG1,X

        BCLR PORTB,X FUT1  ; pongo a cero la salida hardware correspondiente
        BCLR TMSK1,X OC2   ; Deshabilitar interrupción del comparador
        RTI

* ................................................................
* .    Rutina de servicio de interrupcion del COMPARADOR 3       .
* .    POSICION DEL FUTABA 2                                     .
* ................................................................

int_oc3 
	LDAA #OC3   ; pongo a cero el flag de interrupción
	STAA TFLG1,X

        BCLR PORTB,X FUT2  ; pongo a cero la salida hardware correspondiente
        BCLR TMSK1,X OC3   ; Deshabilitar interrupción del comparador
        RTI

* ................................................................
* .    Rutina de servicio de interrupcion del COMPARADOR 4       .
* .    POSICION DEL FUTABA 3                                     .
* ................................................................

int_oc4 
	LDAA #OC4          ; pongo a cero el flag de interrupción
	STAA TFLG1,X

        BCLR PORTB,X FUT3  ; pongo a cero la salida hardware correspondiente
        BCLR TMSK1,X OC4   ; Deshabilitar interrupción del comparador
        RTI

* ................................................................
* .    Rutina de servicio de interrupcion del COMPARADOR 5       .
* .    POSICION DEL FUTABA 4                                     .
* ................................................................

int_oc5 
	LDAA #OC5          ; pongo a cero el flag de interrupción
	STAA TFLG1,X

        BCLR PORTB,X FUT4  ; pongo a cero la salida hardware correspondiente
        BCLR TMSK1,X OC5   ; Deshabilitar interrupción del comparador
        RTI

 
***************************************************************************
* Inicializacion de los vectores de interrupcion                          *
***************************************************************************

         ORG $FFE0          * coloco vector de interrupcion del comparador 5
v_comp5  FDB  #int_oc5      * FUTABA 4

         ORG $FFE2          * coloco vector de interrupcion del comparador 4
v_comp4  FDB  #int_oc4      * FUTABA 3

         ORG $FFE4          * coloco vector de interrupcion del comparador 3
v_comp3  FDB  #int_oc3      * FUTABA 2

         ORG $FFE6          * coloco vector de interrupcion del comparador 2
v_comp2  FDB  #int_oc2      * FUTABA 1

         ORG $FFE8          * coloco vector de interrupcion del comparador 1
v_comp1  FDB  #int_oc1

         ORG $FFFE          * coloco vector de interrupcion del reset
v_reset  FDB  #inicializar

	 END

