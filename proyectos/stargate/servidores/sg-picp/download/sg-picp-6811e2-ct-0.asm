****************************************************
* sg-picp-6811e2-ct-0.asm  Juan Gonzalez. Oct-2003 *
*--------------------------------------------------*
* Pic-Programmer Server. Servidor de grabacion     *
* de microcontroladores PIC                        *
*--------------------------------------------------*
* Version para un 68hc11E2                         *
* Licencia GPL                                     *
*--------------------------------------------------*
* IEARobotics                                      *
* www.iearobotics.com                              *
****************************************************

*----- Datos devueltos por el servicio de identificacion
IS EQU  0x40   * IS. Identificacion del servidor
IM EQU  0x10   * IM. Identificacion del microcontrolador (68hc11E2)
IPV EQU 0x10  * IPV. Placa CT6811. Version 0.

*-- Identificadores de los servicios
SID   EQU 'I'   * Servicio de identificacion (0x49)
SPING EQU 'P'   * Servicio de PING (0x50)
SRD   EQU 'R'   * Servicio READ-DATA (0x52)
SINC  EQU 'A'   * Servicio INCREMENT-ADDERSS (0x41)
SPROG EQU 'W'   * Servicio PROGRAMACION (0x57)
SCONF EQU 'C'   * Servicio LOAD-CONFIGURATION (0x43)
SRST  EQU 'T'   * Servicio RESET (0x54)
SDATA EQU 'D'   * Servicio LOAD-DATA (0x44)
SBEG  EQU 'B'   * Servicio BEGIN program/erase cycle (0x42)		

*-- Identificadores para la respuesta
RPING EQU 'O'   * Respuesta al Servicio de PING (0x4F)
RSI   EQU 'I'   * RSI. Codigo de respuesta del servicio de identificacion
RRD   EQU 'R'	* Respuesta servicio READ-DATA	
RINC  EQU 'A'   * Respuesta servicio INCREMENT-ADDRES
RPROG EQU 'W'   * Respuesta servicio PROG
RCONF EQU 'C'   * Respuesta Servicio LOAD-CONFIGURATION
RRST  EQU 'T'   * Respuesta Servicio RESET
RDATA EQU 'D'   * Respuesta Servicio LOAD-DATA
RBEG  EQU 'B'   * Respuesta Servicio BEGIN programa/erase cycle
	
			
* Registros del SCI
BAUD    equ  $2B
SCCR1   equ  $2C
SCCR2   equ  $2D
SCSR    equ  $2E
SCDR    equ  $2F

* Registros puertos
PORTA   equ $00
PACTL   equ $26

********************************************************
* Conexiones entre la CT6811 y el PIC                  *
*------------------------------------------------------*
* PA3 Saca la señal de Reloj, CLOCK ---> RB6           *
* PA7 Saca la señal de Datos, DATA  <--> RB7           *
* PA4 Se usa para hacer un reset del PIC               *
********************************************************
PA3	 equ $08  ; Bit PA3
PA4      equ $10  * Bit PA4	
PA7      equ $80  * Bit PA7
CLOCK    equ PA3  ; PA3 lleva el reloj (CLOCK)
DATA	 equ PA7  ; PA7 Lleva los Datos (DATA)
RESET    equ PA4  * PA4 Lleva RESET

* Registros del temporizador
TFLG1   EQU $23
TCNT    EQU $0E
TOC5    EQU $1E

TIEMPO  EQU 40000  ; Numero de tics de reloj necesarios para generar un
*                   ; retraso de 10 ms. Cada tic de reloj son 500ns = 0.5useg
*                   ; 40000*0.5 = 10000microseg = 20mseg.

**********************************************
* Codigos de los comandos que ofrece el PIC  *
**********************************************		
LOAD_CONFIG equ $00  ; Comando: LOAD CONFIGURATION
LOAD_DATA   equ $02  ; Comando: LOAD DATA For Program Memory
READ_DATA   equ $04  ; Comando READ_DATA from Program Memory
INC_ADDR    equ $06  ; COMANDO INCREMENT ADDRESS
BEG_ER_PRO  equ $08  ; Comando: BEGIN ERASE PROGRAMMING CICLE


*************************************************************
* COMIENZO DEL PROGRAMA. LA RUTINA PRINCIPAL ESTA AL FINAL  *
* MIRAR EL VECTOR DE RESET PARA VER DONDE COMIENZA          *
*************************************************************	
		
	ORG $F800
********************************
* Inicializacion del servidor  *
********************************
init_ppserver
*----------------------------------*
* Configuracion inicial puertos    *
*----------------------------------*
	LDAA #$30
	STAA BAUD,X      ; Configurar a 9600 baudios

 	LDAA #$00
        STAA SCCR1,X    ; 8 bits de datos

        LDAA #$0C
        STAA SCCR2,X    ; Inhibir interrupciones SCI.
*                       ; Activar transmisor y receptor del SCI

	LDAA #$88
	STAA PACTL,X  * Configurar PA7 y PA3 para salida

	LDAA #$0
	STAA PORTA,X    ; Poner todas las salidas a 0
	RTS

***********************************************************
* Rutina para leer un caracter del puerto serie (SCI)     *
* La rutina espera hasta que llegue algunn caracter       *
* ENTRADAS: Ninguna.                                      *
* SALIDAS: El acumulador A contiene el caracter recibido  *
***********************************************************
leer_car BRCLR SCSR,X $20 leer_car   ; Esperar hasta que llegue un caracter
        LDAA SCDR,X
        RTS

************************************************************
* Enviar un caracter por el puerto serie (SCI)              *
* ENTRADAS: El acumulador A contiene el carÂ cter a enviar  *
* SALIDAS: Ninguna.                                        *
************************************************************
enviar  BRCLR SCSR,X $80 enviar
        STAA SCDR,X
        RTS


***************************************
* Leer un dato proveniente del PIC    *
* ENTRADAS: Ninguna                   *
* SALIDAS:  A y B contienen los 14    *
*           bits recibidos  (D)       *
***************************************
read_data
	PSHY

	BCLR PACTL,X DATA   * Configurar PA7 para Entrada
	CLRA
	LDY #$09

	BSR read_bits
	TAB   * Tenemos en B lo 8 bits menos significativos

	LDY #$07
	BSR read_bits
	RORA
	ANDA #$3F   * Tenemos en A los 6 bits mÃ¡s significativos

	BSET PACTL,X DATA  * Configurar PA7 para salida

	PULY
	RTS

***************************************************
* Leer un numero de bits por la entrada de DATOS  *
*-------------------------------------------------*
* ENTRADAS: Y numero de bits a leer               *
* SALIDA: A bits leidos                           *
***************************************************
read_bits
read_bucle
* Cambiar el reloj
	BSET PORTA,X CLOCK     *Flanco subido en CLOCK 
	NOP
	NOP
	BCLR PORTA,X CLOCK     *Flanco de bajada en CLOCK

	BRSET PORTA,X DATA bit1 * Se lee un '1'
	ANDA #$7F               * Se lee un '0'
	BRA rd_cont
bit1
	ORAA #$80
rd_cont
	DEY
	CPY #0              * Enviados todos los bits?
	BEQ fin_read_bits   * Si, fin
	RORA
	BRA read_bucle

fin_read_bits

	RTS


****************************************************
* Enviar un comando al PIC.                        *
* ENTRADA: Acumulador A contiene el comando        *
* SALIDAS: Ninguna                                 *
****************************************************
send_cmd
	PSHY
	
	BCLR PORTA,X CLOCK  * Poner clock a '0'

	LDY #$6   * Hay que enviar 6 bits
	BSR write_bits
	BSET PORTA,X DATA   * Hay que dejar el bit de datos a '1'
	NOP
	NOP
	
	PULY
	RTS


*****************************************************
* Enviar bits al PIC                                *
* ENTRADA: Acumulador A contiene los bits a enviar  *
*          Registro Y: Numero de bits a enviar      *
*****************************************************
write_bits
	PSHB
next_bit
	TAB
	ANDB #$01           * Comprobar estado bit PA0
	BEQ  send0	    * PA0=0, enviar un '0'
* Enviar un '1'
	BSET PORTA,X DATA   * Enviar '1'
	BRA cont
send0	
	BCLR PORTA,X DATA   * Enviar '0'
cont
	BSET PORTA,X CLOCK     *Flanco subido en CLOCK 
	NOP
	NOP
	BCLR PORTA,X CLOCK     *Flanco de bajada en CLOCK

	RORA

	DEY
	CPY #0              * Enviados todos los bits?
	BEQ fin_write_bits  * Si, fin
	BRA next_bit

fin_write_bits
	PULB
	RTS

*****************************************
* Enviar datos al PIC                   *
* ENTRADAS: D: Dato a enviar (14 bits)  *
*****************************************
load_data
	PSHY
	PSHA
	LDY #$01          * Enviar Bit de start '0'
	CLRA
	JSR write_bits

	LDY #$08          * Enviar 8 bits menos peso
	TBA
	JSR write_bits

	LDY #$07	  * Enviar 6 bits mayor peso + bit stop
	PULA
	ANDA #$3F
	JSR write_bits
	PULY
	RTS

*-------------------------------------*
* Grabar un programa                  *
* ENTRADAS: B: Numero de palabras     *
*           Y: Puntero al buffer      *
*-------------------------------------*
save_block
	PSHB
	LDAA #LOAD_DATA
	JSR send_cmd

	LDD 0,Y
	JSR load_data	

	LDAA #BEG_ER_PRO  * Programar!!
	JSR send_cmd

	PULB
*--hacer pausa de 20ms

	JSR delay20
	LDAA PORTA,X
	EORA #$40
	STAA PORTA,X

*-- Apuntar a la siguiente direccion
	LDAA #INC_ADDR
	JSR send_cmd
	
	INY
	INY
	DECB
	BNE save_block
	RTS

************************************
* Subrutina para esperar 20ms.    *
***********************************
delay20
	PSHA
	PSHB
        LDD TCNT,X              ; Escribir en comparador 5 el valor del
        ADDD #TIEMPO            ; temporizador principal mas el numero de
        STD TOC5,X              ; tics de reloj necesarios para una pausa
*                               ; de 20ms.
        BSET TFLG1,X $08        ; Poner a cero flag del comparador 5
oc5     BRCLR TFLG1,X $08 oc5   ; Esperar a que se activa flag del comparador

	PULB
	PULA
        RTS                     ; Terminar



************************************************************************
	
*******************
* Datos           *
*******************

*-- Palabra de configuracion
config	FDB $3FF9
	
**************************
* Programa principal     *
**************************	
inicio
	LDX #$1000   ; Para acceder a registros del SCI
	LDS #$FF     ; inicializar el puntero de pila

	JSR init_ppserver

* Bucle principal
server
* -- Led de la CT6811 encendido. Todas las señales a 0
	LDAA #$40
	STAA PORTA,X
	
        JSR leer_car    ; Esperar a que el PC solicite un servicio

	
        CMPA #SPING     ; Servicio de PING?
        BEQ serv_ping

	CMPA #SID       ; Servicio de identificacion?
	BEQ serv_id

	CMPA #SRD		; Servicio READ-DATA?
	BEQ serv_rd

	CMPA #SINC		; Servicio INCREMENT-ADDRESS?
	BEQ serv_inc

        CMPA #SCONF		; Servicio LOAD CONFIG
	BEQ serv_conf

	CMPA #SPROG	; Servicio PROG
	BEQ serv_prog1
	
	CMPA #SRST		; Servicio RESET
	BEQ serv_rst1

	CMPA #SDATA		; Servicio LOAD-DATA
	BEQ serv_load_data1

	CMPA #SBEG
	BEQ serv_begin1		; Servicio Begin program/erase cycle
	
	BRA server


**************************************
* Etiquetas para saltos intermedios  *
**************************************
serv_load_data1
	JMP serv_load_data2	

serv_rst1
	JMP serv_rst	
	
serv_begin1
	JMP serv_begin	

serv_prog1
	JMP serv_prog	

	
	
********************
* Servicio de PING *
********************
serv_ping
        LDAA #RPING  ; Enviar la respuesta al PING
        JSR enviar

        JMP server

*******************************
* Servicio de identificacion  *
*******************************
serv_id
	LDAA #RSI   ; Enviar codigo de respuesta
        JSR enviar
	LDAA #IS    ; Enviar identificacion del servidor
	JSR enviar  
	LDAA #IM    ; Enviar identificador del micro
	JSR enviar
	LDAA #IPV   ; Enviar identificador placa/version
	JSR enviar

	JMP server
	
********************************************************************
* Servicio READ-DATA. Lectura de la palabra de la posicion actual  *
********************************************************************	
serv_rd

*--- Mandar cabecera de la trama	
	LDAA #RRD
	JSR enviar
	
*-------- Leer palabra del pic
*-- Mandar comando read-data	
	LDAA #READ_DATA
	JSR send_cmd
	
*-- Leer la palabra	
	JSR read_data
	
*-------- enviar el dato al PC
	PSHA
	TBA
	JSR enviar  		; Dato menor peso
	PULA
	JSR enviar		; Dato mayor peso
	JMP server

**********************************************************************
* Servicio INCREMENT-ADDRESS. Incremento de la direccion actual
**********************************************************************
serv_inc
*-- Ejecutar el comando
	LDAA #INC_ADDR
	JSR send_cmd
	
*-- Mandar trama de respuesta
	LDAA #RINC
	JSR enviar	
	JMP server	

****************************************************************
* Servicio LOAD CONF. Acceder a la memoria de configuracion
****************************************************************
serv_conf
*-- Ejecutar el comando
	LDAA #LOAD_CONFIG
	JSR send_cmd	

	LDD #$0
	JSR load_data  * Mandar cualquier cosa
	
*-- Mandar la trama de respuesta
	LDAA #RCONF
	JSR enviar
	JMP server

		
*****************************************************************
* Servicio PROG. Grabar un dato en la memoria          
*****************************************************************	
serv_prog
*-- Leer el valor a grabar
        JSR leer_car    ; Leer byte bajo de la direccion
        TAB             ; B contiene byte bajo direccion
        JSR leer_car    ; A contiene byte alto de la direccion
        XGDY            ; Ahora Y contiene el valor leido
	
*-- Grabar
	LDAA #LOAD_DATA
	JSR send_cmd

	XGDY		*  Mandar al pic dato a grabar 
	JSR load_data	

	LDAA #BEG_ER_PRO  * Programar!!
	JSR send_cmd

*-- Mandar trama de respuesta
	LDAA #RPROG
	JSR enviar	
	JMP server
	
****************************************************************
* Servicio RESET. Hacer un RESET del PIC                       *
****************************************************************
serv_rst

*-- Hacer el reset.
        BSET PORTA,X RESET  * Activar PA4 para hacer RESET
	JSR delay20         * Esperar 20ms
	BCLR PORTA,X RESET  * Desactivar PA4	
		
*-- Mandar trama de respuesta
	LDAA #RRST
	JSR enviar
	
	JMP server	

****************************************************************
* Servicio LOAD-DATA. Enviar un dato al PIC                    *
****************************************************************
serv_load_data2
*-- Leer el valor
        JSR leer_car    ; Leer byte bajo de la direccion
        TAB             ; B contiene byte bajo direccion
        JSR leer_car    ; A contiene byte alto de la direccion
        XGDY            ; Ahora Y contiene el valor leido
	
*-- Ejecutar el comando
	LDAA #LOAD_DATA
	JSR send_cmd

	XGDY		*  Mandar al pic el dato 
	JSR load_data	
	
*-- Mandar trama de respuesta
	LDAA #RDATA
	JSR enviar
		
	JMP server

	
****************************************************************
* Servicio BEGIN PROGRAM/ERASE CYCLE                           *
****************************************************************
serv_begin
	LDAA #BEG_ER_PRO  * Programar!!
	JSR send_cmd
		
*-- Mandar trama de respuesta
	LDAA #RBEG
	JSR enviar
	
	JMP server			
					
************************************
* Vector de interrupcion de RESET  *
************************************
	ORG $FFFE
	FDB #inicio
