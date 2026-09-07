;------------------------------------------------------------------
;- tim-cmp01-ledp.asm.  Mayo 2004
;- Juan Gonzalez
;------------------------------------------------------------------
; Ejemplo de interrupciones del temporizador 1 (TIM1)
; Con el canal 0 se hace parpadear un led conectado al bit PB0
; y con el 1 otro conectado al bit PB1
;------------------------------------------------------------------
; Licencia GPL
;------------------------------------------------------------------

	;-- Incluir los registros del 6808
	.include "gpregs.inc"

	;-- Incluir mapa de memoria de la GPBOT
	.include "gpmap.inc"
	
;-------------------
;- CONSTANTES
;-------------------
    T200ms   = 0x1DEE  ; 200 ms
	T150ms   = 0x1672  ; 150 ms
	T50ms    = 0x077B  ; 50ms
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
	mov #0x36,*T1SC ; Prescaler: Div entre 64
	ldhx #T200ms    ; Establecer modulo 
	sthx T1MODH     ; Se producira overflow cada 200ms
	
	;---------------------------------
	; Configurar el comparador 0 (Canal 0)
	;---------------------------------
	; Interrupcion permitida
	; Configurar como comparador, sin salida hardware
	mov #0x50,*T1SC0
	
	;-- Establecer el valor de comparacion. 
	ldhx #T50ms
	sthx T1CH0H
	
	;---------------------------------
	; Configurar el comparador 1 (Canal 1)
	;---------------------------------
	; Interrupcion permitida
	; Configurar como comparador, sin salida hardware
	mov #0x50,*T1SC1
	
	;-- Establecer el valor de comparacion. 
	ldhx #T150ms
	sthx T1CH1H
	
	;-----------------------
	; Configurar puerto B  
	;-----------------------
	mov #0xFF,*DDRB
	CLR PORTB
	
	;--------------------------------
	; Habilitar las interrupciones
	;--------------------------------
	cli
	
	;-- Activar temporizador
	bclr #5,*T1SC 
	
	;-- Bucle infinito
bucle:
	bra bucle
	
;-------------------------------------------
; Rutina atencion interrupcion canal 0 TIM1
;-------------------------------------------
rsi_t1ch0:
	;-- Quitar el flag del comparador
	bclr #7,*T1SC0
	
	;-- Cambiar de estado Bit 0 del PUERTO B
	lda PORTB
	eor #0x01
	sta PORTB

	rti
	
;-------------------------------------------
; Rutina atencion interrupcion canal 1 TIM1
;-------------------------------------------
rsi_t1ch1:
	;-- Quitar el flag del comparador
	bclr #7,*T1SC1
	
	;-- Cambiar de estado Bit 1 del PUERTO B
	lda PORTB
	eor #0x02 
	sta PORTB

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
	.dw dummy_isr 	;-- Vector Overflow TIM1
	.dw rsi_t1ch1	;-- Vector Canal 1  TIM1
	.dw rsi_t1ch0   ;-- Vector Canal 0  TIM1
	.dw dummy_isr   ;-- Vector PLL
	.dw dummy_isr   ;-- Vector IRQ	
	.dw dummy_isr   ;-- Vector SWI
	.dw main	    ;-- Vector Reset
