;------------------------------------------------------
;- sensor1.asm  (c) Juan Gonzalez. Marzo 2004
;------------------------------------------------------
; Ejemplo de manejo del sensor CNY70, en modo digital
; Se lee el sensor IR1 (Conectado al pin PTC5) y
; se saca su estado por el puerto B
;------------------------------------------------------
; Sensor IR1: Pin PTC5
; Valores devueltos por el sensor:
;   Negro -->  1
;   Blanco --> 0
;------------------------------------------------------
; Licencia GPL
;------------------------------------------------------

	;-- Incluir los registros del 6808
	.include "gpregs.inc"

	;-- Incluir mapa de memoria de la GPBOT
	.include "gpmap.inc"

	;-- Zona de codigo
	.area CSEG (ABS)
	.org RomStart
	
main:
	;-- Inicializar la pila
	ldhx #InitStk
	txs
	
	;-- Deshabilitar el COP
	bset #0,*CONFIG1

    ;-- Configurar puerto B para salida
    lda	#0xFF	
	sta	DDRB

    ;---------------------------------------------------------
	;- Configucion para utilizar el sensor en modo digital  
	;---------------------------------------------------------
   	;-- Configurar puerto C para entrada
	clra
	sta	DDRC
	;-- Configurar pull-up
	lda #0x20
	sta PTCPUE
	

bucle:
    ;-- Leer sensor ir1 (Puerto C)
    lda PORTC
	and #0x20   ; Nos quedamos solo con bit PCT5
	
	;-- Enviar el valor al puerto B para visualizarlo
	;-- en los leds
	sta PORTB   

	BRA bucle


;---------------------------------------
;- Zona de vectores de interrupcion  
;---------------------------------------
dummy_isr:
	RTI

 	.area VECTOR (ABS)
	.org VectorStart
	.dw dummy_isr	;-- Vector TMB	
	.dw dummy_isr	;-- Vector DAC
	.dw dummy_isr ;-- Vector KBI
	.dw dummy_isr	;-- Vector Transmision SCI
	.dw dummy_isr	;-- Vector Receptor SCI
	.dw dummy_isr	;-- Vector Error SCI		
	.dw dummy_isr	;-- Vector Tranmisor SPI
	.dw dummy_isr	;-- Vector Receptor SPI
	.dw dummy_isr	;-- Vector Overflow TIM2
	.dw dummy_isr	;-- Vector Canal 1 TIM2
	.dw dummy_isr	;-- Vector Canal 0 TIM2
	.dw dummy_isr	;-- Vector Overflow TIM1
	.dw dummy_isr	;-- Vector Canal 1  TIM1
	.dw dummy_isr ;-- Vector Canal 0  TIM1
	.dw dummy_isr ;-- Vector PLL
	.dw dummy_isr ;-- Vector IRQ	
	.dw dummy_isr ;-- Vector SWI
	.dw main	;-- Vector Reset
