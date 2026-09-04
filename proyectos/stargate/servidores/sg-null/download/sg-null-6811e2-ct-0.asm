*************************************************************************
* PROYECTO STARGATE.                                                    *
* sg-null-6811e2-ct-0.asm.  Juan Gonzalez <juan@iearobotics.com>        *
*-----------------------------------------------------------------------*
* Servidor NULO.                                                        *
* Servidor: sg-null                                                     *
* Implementado para el micro 6811E2 y la tarjeta CT6811.                *
*-----------------------------------------------------------------------*
* Implementados los servicios de Identificacion y PING.                 *
* Cada vez que se hace un PING se cambia de estado el led.              *
* Inicialmente el led de la CT6811 se enciende.                         *
* Cualquier otro caracter recibido se ignora                            *
*-----------------------------------------------------------------------*
*  Licencia GPL                                                         *
*************************************************************************

*----- Datos devueltos por el servicio de identificacion
RSI EQU 'I'   * RSI. Codigo de respuesta del servicio de identificacion
IS EQU 0x10   * IS. Identificacion del servidor
IM EQU 0x10   * IM. Identificacion del microcontrolador (68hc11E2)
IPV EQU 0x10  * IPV. Placa CT6811. Versión 0.


*-- Identificadores de los servicios
SID   EQU 'I'   * Servicio de identificacion (0x49)
SPING EQU 'P'   * Servicio de PING (0x50)

*-- Identificadores para la respuesta
RPING EQU 'O'   * Respuesta al Servicio de PING (0x4F)

* Registros del SCI

BAUD    equ  $2B
SCCR1   equ  $2C
SCCR2   equ  $2D
SCSR    equ  $2E
SCDR    equ  $2F

* -- Programa para la eeprom de un E2
	ORG $F800

inicio
        LDX #$1000 
	LDS #$FF     ; inicializar el puntero de pila 

* -- Configurar el puerto serie

	LDAA #$30
	STAA BAUD,X      ; Configurar a 9600 baudios

 	LDAA #$00
        STAA SCCR1,X    ; 8 bits de datos

        LDAA #$0C
        STAA SCCR2,X    ; Inhibir interrupciones SCI.
*                       ; Activar transmisor y receptor del SCI

* Encender el led
	LDAA #$40
	STAA 0,X     

* Bucle principal
server  
        BSR leer_car    ; Esperar a que el PC solicite un servicio
        CMPA #SPING     ; Servicio de PING?
        BEQ serv_ping

	CMPA #SID       ; Servicio de identificacion?
	BEQ serv_id

	BRA server

********************
* Servicio de PING *
********************
serv_ping
        LDAA #RPING  ; Enviar la respuesta al PING
        BSR enviar

	LDAA $1000   ; Cambiar el led de estado
	EORA #$40
	STAA $1000

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
* ENTRADAS: El acumulador A contiene el car cter a enviar  *
* SALIDAS: Ninguna.                                        *
************************************************************
enviar  BRCLR SCSR,X $80 enviar
        STAA SCDR,X
        RTS

************************************
* Vector de interrupción de RESET  *
************************************
	ORG $FFFE
	FDB #inicio


        END

