;-----------------------------------------------------------
;- tim-pwm-fut.asm.  Mayo 2004
;- Juan Gonzalez
;-----------------------------------------------------------
; Ejemplo de posicionamiento de servos del tipo FUTABA 3003
; Se utiliza el temporizador 1 (TIM 1)
; El posicionamiento se hace por interrupciones. Se usa la
; interrupcion de overflow para determinar el periodo de la
; senal PWM (20ms) y el comparador 0 para calcular el ancho
; del pulso
;-----------------------------------------------------------
; El servo se conecta al pin PB0
;-----------------------------------------------------------
; Licencia GPL
;-----------------------------------------------------------

;-- Incluir los registros del 6808
	.include "gpregs.inc"

	;-- Incluir mapa de memoria de la GPBOT
	.include "gpmap.inc"
	
;-------------------
;- CONSTANTES
;-------------------

;-- Posiciones del servo
	CENTRO   = 0x0C72  ; 1,3 ms. Posicion central
	EXTREMO1 = 0x2DF   ; 0,3 ms. Un extremo
	EXTREMO2 = 0x1605  ; 2,3 ms. El otro extremo
	
	T20ms    = 0xBF7B  ; Periodo de 20ms 

;-------------------
;- CODIGO 
;-------------------
	
	;-- Zona de codigo
	.area CSEG (ABS)
	.org RomStart

main:
	;-- Inicializar la pila
	ldhx #InitStk
	txs
	
	;-- Deshabilitar el COP
	bset #0,*CONFIG1
	
	;-----------------------------
	;- Configurar el temporizador
	;-------------------------------
	mov #0x60,*T1SC ; Prescaler: Div entre 1. Tic de reloj=0.41useg
	ldhx #T20ms     ; Establecer modulo 
	sthx T1MODH
	
	;-- Canal 0 TIM1
	mov #0x50,*T1SC0
	
	;-----------------------
	; Configurar puerto B  
	;-----------------------
	mov #0xFF,*DDRB
	CLR PORTB
	
	;-------------------------------------------
	; Establecer posicion del servo
	; Cambiando el valor almacenado en T1CH0H
	; se modifica la posicion del servo
	;-------------------------------------------
	ldhx #CENTRO
	sthx T1CH0H
	
	;--------------------------------
	; Habilitar las interrupciones
	;--------------------------------
	cli
	
	;-- Activar temporizador
	bclr #5,*T1SC
	
bucle:
	
	bra bucle
	
;-------------------------------------------
; Rutina atencion interrupcion overflow TIM1
; Se produce cada 20ms
;-------------------------------------------
rsi_ov1:
	;-- Quitar el flag de overflow
	bclr #7,*T1SC
	
	;-- Pone a 1 senal PWM
	bset #0,*PORTB
	
	rti
	
;-------------------------------------------
; Rutina atencion interrupcion canal 0 TIM1
; Sirve para calcular el ancho del pulso
; comprendido entre 0,3 y 2,3ms
;-------------------------------------------
rsi_t1ch0:
	;-- Quitar el flag del comparador
	bclr #7,*T1SC0

	;-- Poner senal PWM a 0
	clr PORTB

	rti

;---------------------------------------
;- Zona de vectores de interrupcion  
;---------------------------------------
dummy_isr:
	RTI

 	.area VECTOR (ABS)
	.org VectorStart
	.dw dummy_isr	;-- Vector TMB	
	.dw dummy_isr	;-- Vector DAC
	.dw dummy_isr   ;-- Vector KBI
	.dw dummy_isr	;-- Vector Transmision SCI
	.dw dummy_isr	;-- Vector Receptor SCI
	.dw dummy_isr	;-- Vector Error SCI		
	.dw dummy_isr	;-- Vector Tranmisor SPI
	.dw dummy_isr	;-- Vector Receptor SPI
	.dw dummy_isr	;-- Vector Overflow TIM2
	.dw dummy_isr	;-- Vector Canal 1 TIM2
	.dw dummy_isr	;-- Vector Canal 0 TIM2
	.dw rsi_ov1 	;-- Vector Overflow TIM1
	.dw dummy_isr	;-- Vector Canal 1  TIM1
	.dw rsi_t1ch0   ;-- Vector Canal 0  TIM1
	.dw dummy_isr   ;-- Vector PLL
	.dw dummy_isr   ;-- Vector IRQ	
	.dw dummy_isr   ;-- Vector SWI
	.dw main	    ;-- Vector Reset
