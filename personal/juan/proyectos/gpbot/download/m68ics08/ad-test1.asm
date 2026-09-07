;------------------------------------------------------------
;  ad-test1.asm
;  (c) Juan Gonzalez. Marzo 2004
;  (c) Ivan Gonzalez. 2002, 2003
;------------------------------------------------------------
; Prueba del conversor analogico/digital
; Se leen muestras del CANAL 0 (PB0) y se sacan por el
; puerto A, donde se pueden visualizar en una placa de leds
; Si se conecta un pontenciometro al canal 0 y una placa de
; leds al puerto A, se puede ir viendo como cambian los leds
; segun la posicion del potenciometro
;------------------------------------------------------------
; Licencia GPL
;------------------------------------------------------------
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

	;-- Configurar puerto A para salida
	lda	#$FF	; Configurar puerto A para salida
	sta	DDRA

	;-- Configurar conversor A/D
	;-- Reloj del bus interno: Bit4-->1
	;-- Bits 7,6 y 5--> Dividir entre 2 para conseguir
	;--  una frecuencia de 1MHZ
	;-- El resto de bits no se emplean
	lda #$30
	sta ADCLK

	;----------------------------
	;-- BUCLE PRINCIPAL
	;----------------------------
bucle:
	;-- Seleccionar canal 0 (PB0)
	;-- y activar la conversion
	LDA #$00
	STA ADSCR
	;-- Esperar a que la conversion se realice
wait:
	BRCLR 7,ADSCR,wait

	;-- Leer la muestra y enviarla al puerto A
	LDA ADR
	STA PORTA

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
