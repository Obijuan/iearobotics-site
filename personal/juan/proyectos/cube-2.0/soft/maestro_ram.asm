**************************************************************
* Programa para el módulo maestro                            *
**************************************************************
* Version para la RAM interna                                *
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
 

	ORG $0000  * Dirección de comienzo del programa

inicio	
	LDX   #$1000     * Para acceder a los registros de control

* ---- Configuración del SCI ----

wait    BRCLR SCSR,X $40 wait  * espero a que se estabilice el SCI

	LDAA  #$22	 * Poner 22 para velocidad de 7812 baudios
	STAA  BAUD,X	 * Poner 30 para velocidad de 9600 baudios

* ---- Configuración del SPI (como maestro) ----

	LDAA  #$3C
	STAA  DDRD,X     * El SPI configura las salidas automáticamente

* El maestro lo ponemos con colector cerrado.

	LDAA  #$50       * Colector cerrado
	STAA  SPCR,X     * Activa en modo maestro el SPI

* El puerto C tienen que ser de entrada
	CLRA
	STAA DDRC,X      * Puerto C de entrada	

main
	JSR  leer_car    * leo carácter por el puerto serie
	JSR  enviar_spi  * mando la orden a la BT6811
	BRA  main

	
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

	END	
	
