;-----------------------------------------------------------------
;- tim-cap0.asm.  Mayo 2004
;- Juan Gonzalez
;-----------------------------------------------------------------
; Ejemplo de manejo del capturador 0 del TIM 1
; Este capturador esta asociado al PIN PTD4
; Cada vez que se recibe una transicion por ese pin
; (paso de 0-1 o de 1-0) se incrementar el valor sacado por el puerto B,
; que indica el numero de transiciones ocurridas
;-----------------------------------------------------------------
; NOTA: Los jumpers JP5 (1 y 2, 3 y 4) Deben estar colocados!!!
;-----------------------------------------------------------------
; Licencia GPL
;-----------------------------------------------------------------

;-- Incluir los registros del 6808
$include 'gpregs.inc'

;-- Incluir mapa de memoria de la GPBOT
$include 'gpmap.inc'


;-------------------
;- CODIGO
;-------------------
	;-- Zona de codigo
	org RomStart

main:
	;-- Inicializar la pila
	ldhx #InitStk
	txs

	;-- Deshabilitar el COP
	bset 0,CONFIG1

	;--- Configurar puerto D
	lda #$10    ;-- Activar pull-up del pin PTD4
	sta PTDPUE

	;-- Configurar puerto B para salida
	mov #$FF,DDRB
	mov #$00,PORTB

	;-----------------------------
	;- Configurar el temporizador
	;-------------------------------
	mov #$16,T1SC ; Prescaler: Div entre 64

	;-- Configurar Capturador de entrada (Timer 1, canal 0)
	;-- sensible a flancos de subida y de bajada
	mov #$4C,T1SC0

	;-- Activar las interrupciones
	cli

bucle:
	bra bucle

;-------------------------------------------
; Rutina atencion interrupcion canal 0 TIM1
;-------------------------------------------
rsi_t1ch0:
	;-- Quitar el flag del comparador
	bclr 7,T1SC0

	;-- Incementar el valor sacado por PUERTO B
	inc PORTB

	rti

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
	dw rsi_t1ch0    ;-- Vector Canal 0  TIM1
	dw dummy_isr    ;-- Vector PLL
	dw dummy_isr    ;-- Vector IRQ
	dw dummy_isr    ;-- Vector SWI
	dw main	        ;-- Vector Reset


 
