;---------------------------------------------------------------------
;- modelo.asm.                                                       *
;--------------------------------------------------------------------*
;- (c) 2003 Ivan Gonzalez        <Ivan.Gonzalez@ii.uam.es>           *
;-          Carlos Jesus Venegas <eventyr@terra.es>                  *
;--------------------------------------------------------------------*
; Plantilla para hacer programas en ensamblador para la              *
; Tarjeta GPBOT, utilizando el ensamblador de P&E Microsystems       *
;--------------------------------------------------------------------*
; Licencia GPL                                                       *
;---------------------------------------------------------------------

;-- Incluir los registros del 6808
$Include 'gpregs.inc'

;-- Incluir mapa de memoria de la GPBOT
$Include 'gpmap.inc'

	;-- Zona de codigo
	ORG RomStart

main:
	;-- Inicializar la pila
	ldhx #InitStk
	txs

	;-- Deshabilitar el COP
	bset 0,CONFIG1

;---------------------------------
;--- Comienzo del programa
;---------------------------------

;-- Escribir en esta zona el codigo




;---------------------------------
;--- FINAL del programa
;---------------------------------


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
