;------------------------------------------------------
;- tim-ov-ledp.asm.  Mayo 2004
;- Juan Gonzalez
;------------------------------------------------------
; Ejemplo de utilzacion del temporizador (TIM)
; Se hace parpadear un led conectado al Bit 0 del
; puerto B, usando la interrupcion de overflow del
; TIMER 1
;
;------------------------------------------------------
; Licencia GPL
;------------------------------------------------------

;-- Incluir los registros del 6808
$include 'gpregs.inc'

;-- Incluir mapa de memoria de la GPBOT
$include 'gpmap.inc'

;-------------------
;- CONSTANTES
;-------------------
T100ms   EQU $0EF7  ; 100 ms

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

	;-----------------------------
	;- Configurar el temporizador
	;-------------------------------
	mov #$76,T1SC ; Prescaler: Div entre 64
	ldhx #T100ms    ; Establecer modulo
	sthx T1MODH     ; Se producira overflow cada 100ms

	;-----------------------
	; Configurar puerto B
	;-----------------------
	mov #$FF,DDRB
	CLR PORTB

	;--------------------------------
	; Habilitar las interrupciones
	;--------------------------------
	cli

	;-- Activar temporizador
	bclr 5,T1SC

bucle:

	bra bucle

;-------------------------------------------
; Rutina atencion interrupcion overflow TIM1
; Se produce cada 100ms
;-------------------------------------------
rsi_ov1:
	;-- Quitar el flag de overflow
	bclr 7,T1SC

	;-- Cambiar de estado Bit 0 del PUERTO B
	lda PORTB
	eor #$01
	sta PORTB

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
	dw rsi_ov1	;-- Vector Overflow TIM1
	dw dummy_isr	;-- Vector Canal 1  TIM1
	dw dummy_isr    ;-- Vector Canal 0  TIM1
	dw dummy_isr    ;-- Vector PLL
	dw dummy_isr    ;-- Vector IRQ
	dw dummy_isr    ;-- Vector SWI
	dw main	        ;-- Vector Reset
