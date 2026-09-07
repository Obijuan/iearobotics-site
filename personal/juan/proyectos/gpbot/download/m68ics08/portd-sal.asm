;-------------------------------------------------------------------
;- portd-sal.asm  (c) Juan Gonzalez. Mayo 2004
;-------------------------------------------------------------------
; Enviar un valor por el puerto D de la tarjeta GPBOT
; AVISO!! Los jumpers JP5 (1 y 2, 3 y 4) Deben estar colocados!!!
;-------------------------------------------------------------------
; Licencia GPL
;-------------------------------------------------------------------

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

	lda	#$FF	; Configurar puerto D para salida
	sta	DDRD

	lda	#$55	; Enviar un valor al puerto D
	sta	PORTD

	;-- Bucle infinito
inf:	BRA inf


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
