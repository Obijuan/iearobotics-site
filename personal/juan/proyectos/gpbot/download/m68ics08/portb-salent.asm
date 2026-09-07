;------------------------------------------------------
;- portb-salent.asm  (c) Juan Gonzalez. Febrero 2004
;------------------------------------------------------
; Ejemplo de manejo del puerto B para entrada y salida
; Los 4 bits de menor peso del puerto B se configuran
; para entrada y los 4 mayores como salida.
;  Todo lo recibido por los de menor peso se manda a los
; de mayor
;------------------------------------------------------
; Licencia GPL
;------------------------------------------------------
        
;-- Incluir los registros del 6808
$Include 'gpregs.inc'

;-- Incluir mapa de memoria de la GPBOT
$Include 'gpmap.inc'

	;-- Zona de codigo
	ORG RomStart

main:
	;-- Configurar puerto B
	;-- 4 bits mayor peso--> Salida
	;-- 4 bits menor peso--> Entrada
	lda	#$F0
	sta	DDRB

repite:

	lda PORTB		; Leer puerto B
	nsa	   		; Intercambiar los nibble superior e inferior
	sta PORTB		; Escribir nuevo valor en puerto B
	BRA repite

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
