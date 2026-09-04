*************************************************************************
* PROYECTO STARGATE.                                                    *
* sg-generic-6811e2-ct-0.asm.  Juan Gonzalez <juan@iearobotics.com>     *
*-----------------------------------------------------------------------*
* Servidor GENERICO                                                     *
* Servidor: sg-generic                                                  *
* Implementado para el micro 6811E2 y la tarjeta CT6811.                *
*-----------------------------------------------------------------------*
* Servicios básico: Identificacion y PING                               *
* Servicios LOAD y STORE                                                *
* Inicialmente el led de la CT6811 se enciende.                         *
*-----------------------------------------------------------------------*
*  Licencia GPL                                                         *
*************************************************************************

*----- Datos devueltos por el servicio de identificacion
IS EQU 0x20   * IS. Identificacion del servidor
IM EQU 0x10   * IM. Identificacion del microcontrolador (68hc11E2)
IPV EQU 0x10  * IPV. Placa CT6811. Versión 0.


*-- Identificadores de los servicios
SID   EQU 'I'   * Servicio de identificacion (0x49)
SPING EQU 'P'   * Servicio de PING (0x50)
SLD   EQU 'L'   * Servicio LOAD (0x4C)
SST   EQU 'S'   * Servicio STORE (0X52)

*-- Identificadores para la respuesta
RPING EQU 'O'   * Respuesta al Servicio de PING (0x4F)
RSI EQU 'I'     * RSI. Codigo de respuesta del servicio de identificacion
RLD EQU 'L'     * Codigo respuesta servicio LOAD
RST EQU 'S'     * Codigo respuesta servicio STORE

* Registros del SCI

BAUD    equ  $2B
SCCR1   equ  $2C
SCCR2   equ  $2D
SCSR    equ  $2E
SCDR    equ  $2F

*---- Variables en RAM
	ORG $0000
dirini   RMB  2

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

	CMPA #SLD       ; Servicio de LOAD?
	BEQ serv_ld  

	CMPA #SST       ; Servicio de STORE?
	BEQ serv_st 

	BRA server

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

*********************
* Servicio LOAD     *
*********************
serv_ld
	BSR leer_dir ; Leer la direccion
	LDAA 0,Y     ; Leer el dato pedido
	TAB
	LDAA #RLD 
	BSR enviar   ; Enviar codigo respuesta
	TBA
	BSR enviar   ; Enviar dato al cliente
	
	JMP server

**********************
* Servicio  STORE    *
**********************
serv_st
	BSR leer_dir ; Leer la direccion
	BSR leer_car ; Leer el dato a guardar
	STAA 0,Y     ; Guardarlo
	LDAA #RST
	BSR enviar   ; Enviar la respuesta
	JMP server

******************************************************
* El el campo DIRECCION  de las tramas LOAD y STORE  *
* Devuelve en Y la direccion obtenida                *
******************************************************
leer_dir
        BSR leer_car    ; Leer byte bajo de la direccion
        TAB             ; B contiene byte bajo direccion
        BSR leer_car    ; A contiene byte alto de la direccion
        XGDY            ; Ahora Y contiene la direccion leida
        RTS

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

