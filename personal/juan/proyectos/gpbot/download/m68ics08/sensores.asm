;-------------------------------------------------------------
;- sensores.asm  (c) Juan Gonzalez. Mayo 2004
;-------------------------------------------------------------
; Ejemplo de manejo de los 4 sensores CNY70, en modo digital
; Su estado se refleja en los bits PB0-PB4 del puerto B
; donde se conectan leds
; La informacion que se saca por el puerto B es:
;
; PB7 PB6 PB5 PB4 PB3 PB2 PB1 PB0
;  0   0   0   0  IR2 IR1 IR4 IR3
;
;-------------------------------------------------------------
; INFORMACION SOBRE LOS SENSORES:
; Los valores que devuelven son:
;   Negro  (o infinito) --> 1
;   Blanco              --> 0
;
; Sensor IR1: Pin PTC5 (PUERTO C)
; Sensor IR2: Pin PTC6 (PUERTO C)
; Sensor IR3: Pin PTA5 (PUERTO A)
; Sensor IR4: Pin PTA6 (PUERTO A)
;-------------------------------------------------------------
; Licencia GPL
;-------------------------------------------------------------

;-- Incluir los registros del 6808
$include 'gpregs.inc'

;-- Incluir mapa de memoria de la GPBOT
$include 'gpmap.inc'

	;-- Zona de codigo
	org RomStart


main:
	;-- Inicializar la pila
	ldhx #InitStk
	txs

	;-- Deshabilitar el COP
	bset 0,CONFIG1

	;-------------------------------
	;- Configuracion PUERTO B
	;-------------------------------
    ;-- Configurar puerto B para salida
    lda	#$FF
	sta	DDRB

	;---------------------------------
	;- Configuracion de los sensores
	;---------------------------------
	;-- Configurar puerto A y C para entrada
	clra
	sta DDRA
	sta DDRC
	;-- Configurar resistencias pull-up para los 4 sensores
	lda #$60
	sta PTAPUE
	sta PTCPUE

bucle:

	;-- Leer sensores IR3 e IR4 del puerto A
	;-- Se leen por los bits PTA5 Y PTA6
    lda PORTA

	;-- Situarlos en los bits 3 y 4 del acumulador
	;-- El resto dejarlos a 0
	rora
	rora
	and #$18

	;-- Poner los bits 6 y 5 a '1'. Lo que hay en el acumulador
	;-- es:  0 1 1 IR4 IR3 0 0 0
	ora #$60

	;-- Anadir sensores IR1 e IR2 del puerto C
	;-- En el acumulador tenemos: 0 IR2 IR1 IR4 IR3 0 0 0
	and PORTC

	;-- Situar los bits de los sensores a las posiciones
	;-- de menor peso:  0 0 0 0 IR2 IR1 IR4 IR3
	rora
	rora
	rora

	;-- Sacar la informacion por el puerto B para visualizarla
	;-- en los leds
	sta PORTB

	BRA bucle


;---------------------------------------
;- Zona de vectores de interrupcion
;---------------------------------------
dummy_isr:
	RTI

 	org VectorStart
	dw dummy_isr	;-- Vector TMB
	dw dummy_isr	;-- Vector DAC
	dw dummy_isr    ;-- Vector KBI
	dw dummy_isr	;-- Vector Transmision SCI
	dw dummy_isr	;-- Vector Receptor SCI
	dw dummy_isr	;-- Vector Error SCI
	dw dummy_isr	;-- Vector Tranmisor SPI
	dw dummy_isr	;-- Vector Receptor SPI
	dw dummy_isr	;-- Vector Overflow TIM2
	dw dummy_isr	;-- Vector Canal 1 TIM2
	dw dummy_isr	;-- Vector Canal 0 TIM2
	dw dummy_isr	;-- Vector Overflow TIM1
	dw dummy_isr	;-- Vector Canal 1  TIM1
	dw dummy_isr    ;-- Vector Canal 0  TIM1
	dw dummy_isr    ;-- Vector PLL
	dw dummy_isr    ;-- Vector IRQ
	dw dummy_isr    ;-- Vector SWI
	dw main	        ;-- Vector Reset
