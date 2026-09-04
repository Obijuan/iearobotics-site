**************************************************************
* Andrés Prieto-Moreno     Mayo-2002                         *
* Juan González Gómez                                        *
**************************************************************
* Programa bajo LICENCIA GPL                                 *
*------------------------------------------------------------*
* Generacion de una secuencia de movimiento de 4 pasos       *
* para mover el robot SHEILA                                 *
**************************************************************

* --- Puertos de entrada y salida

PORTA   EQU $0
PORTB   EQU $04
PORTC   EQU $03
DDRC    EQU $07

* --- Registros del SCI

BAUD	EQU $2B
SCCR1	EQU $2C
SCCR2	EQU $2D
SCSR	EQU $2E
SCDR	EQU $2F

* --- Registros del SPI

PORTD   EQU $08
DDRD	EQU $09
SPCR	EQU $28
SPDR	EQU $2A
SPSR	EQU $29
 

	ORG $F800  * Dirección de comienzo del programa

inicio	LDS   #$FF
	LDX   #$1000     * Para acceder a los registros de control


* ---- Configuración del SCI ----

wait    BRCLR SCSR,X $40 wait  * espero a que se estabilice el SCI

	LDAA  #$30	 * Poner 22 para velocidad de 7812 baudios
	STAA  BAUD,X	 * Poner 30 para velocidad de 9600 baudios
	LDAA  #$0
	STAA  SCCR1,X	 * 8 bits de datos
	LDAA  #$0C       * No usar interrupciones del SCI
	STAA  SCCR2,X    * Activar receptor y transmisor

* ---- Configuración del SPI (como maestro) ----

	LDAA  #$3C
	STAA  DDRD,X     * El SPI configura las salidas automáticamente

* El maestro lo ponemos con colector cerrado.

	LDAA  #$50       * Colector cerrado
	STAA  SPCR,X     * Activa en modo maestro el SPI


*******************************
* ------ PROGRAMA 2 --------- *
*******************************

prog_dos
	JSR  esperar
	JSR  enable_c
	JSR  enable_a
	JSR  enable_b

secuencia
	LDY  #movi0
bucle   JSR  dar_paso
	JSR  esperar
	CPY  #fin_movi
	BNE  bucle
	BRA  secuencia
	
**********************************
* Subrutinas utilizadas por los  *
* bucles principales uno y dos   *
**********************************

*.................................
*. Rutina que recibe un caracter .
*. por el puerto serie           .
*.................................

leer_car
	BRCLR SCSR,X $20 leer_car
        LDAA  SCDR,X
        RTS

*.................................
*.  Rutina que envia un caracter .
*.  por el puerto serie          .
*.................................

enviar_car
	BRCLR SCSR,X $80 enviar_car
        STAA SCDR,X
        RTS


*.......................................
*. Rutina que envía un dato por el SPI .
*.......................................
*. Si se quiere pausa entre datos      .
*. enviados llamar a: enviar_spi_pausa .
*.                                     .
*. Si no se quiere pausa entre datos   .
*. envados llamar a: enviar_spi        .
*.......................................

enviar_spi_pausa
	PSHY                    * pausa entre datos
	LDY   #$18              * valor de 150 microseg
pausa   DEY
	CPY #$0
	BNE pausa
	PULY

enviar_spi
	LDAB  PORTD,X
	ANDB  #$DF
	STAB  PORTD,X            * Mandamos activarse al esclavo

	STAA  SPDR,X             * introduzco el dato a mandar
espera  BRCLR SPSR,X $80 espera  * ¿transmisión efectuada? 

	LDAB  PORTD,X
	ORB   #$20
	STAB  PORTD,X            * Desactivamos al esclavo

	RTS
	
*.........................
*. Rutina de pausa       .
*.........................

esperar
	PSHY
	LDY  #$C400
sigue   DEY
	CPY  #$0
	BNE  sigue
	PULY
	RTS


*....................................
*. Rutinas para activar los módulos .
*....................................
enable_c
	LDAA #'c'
	BRA  fin_enable
enable_b
	LDAA #'b'
	BRA  fin_enable
enable_a
  	LDAA #'a'
fin_enable
	JSR  enviar_spi_pausa
	LDAA #'e'
	JSR  enviar_spi_pausa
	LDAA #$0F
	JSR  enviar_spi_pausa
	JSR  enviar_spi_pausa	
	RTS


*.................................
*.  Rutina que envía un paso de  .
*.  la secuencia                 .
*.................................

dar_paso
	LDAA #'a'             * a1
	JSR  enviar_spi_pausa
	LDAA #'p'
	JSR  enviar_spi_pausa
	LDAA #$01
	JSR  enviar_spi_pausa
	LDAA $0,Y
	JSR  enviar_spi_pausa
        INY

	LDAA #'a'             * a2
	JSR  enviar_spi_pausa
	LDAA #'p'
	JSR  enviar_spi_pausa
	LDAA #$02
	JSR  enviar_spi_pausa
	LDAA $0,Y
	JSR  enviar_spi_pausa
        INY

	LDAA #'a'             * a3
	JSR  enviar_spi_pausa
	LDAA #'p'
	JSR  enviar_spi_pausa
	LDAA #$03
	JSR  enviar_spi_pausa
	LDAA $0,Y
	JSR  enviar_spi_pausa
        INY


        RTS


*****************************************************
*           SECUENCIAS DE MOVIMIENTOS               *
*****************************************************
* A1,A2,A3
*****************************************************

*.......................
*. RECTO               .
*.......................

movi0   FCB 131,112, 109
movi2   FCB 131,195, 198
movi3   FCB 218,195, 198
movi4   FCB 217,140, 109
fin_movi FCB $0



*********************************
* Vectores de interrupción      *
*********************************

	ORG $FFFE
v_reset FDB #inicio

	END	
	
