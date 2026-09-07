;------------------------------------------------------
;- motor-on.asm  (c) Juan Gonzalez. Marzo 2004
;------------------------------------------------------
; Ejemplo de activacion de los motores 1 y 2
; El sentido de giro depende de como se hayan conectado
; los cables.
;------------------------------------------------------
; El motor 1 se controla con los bits PTC1 y PTC2, y el
; motor 2 con los bits PTC3 y PT4
;
; La "tabla de verdad" es como la siguiente:
;   PTC2 PTC1 motor1     
;   ---------------------
;     0    0   Parado     
;     0    1   Un sentido
;     1    0   Otro sentido
;     1    1   NO USAR
;
;   PTC4 PTC3 motor2     
;   ---------------------
;     0    0   Parado     
;     0    1   Un sentido
;     1    0   Otro sentido
;     1    1   NO USAR
;
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

   	; Configurar pines PTC1,PTC2,PTC3 y PTC4 para salida
	lda	#0x1E	
	sta	DDRC

    ;-- Activar el motor 1 y 2
	lda	#0x0A
	sta	PORTC

	;-- Bucle infinito
inf:	BRA inf


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
