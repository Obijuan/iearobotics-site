;------------------------------------------------------------------
;- tim-cmp0-ledp.asm.  Mayo 2004
;- Juan Gonzalez
;------------------------------------------------------------------
; Ejemplo de utilzacion del comparador 0 del temporizador 1 (TIM)
; Se hace parpadear un led conectado al Bit 0 del 
; puerto B, usando la interrupcion del comparador 0 del TIM1
;------------------------------------------------------------------
; El modulo del timer se establece para que haya desbordamiento
; cada 100ms. El valor del comparador es indiferente. Se 
; produciran interrupciones cada 100ms.
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
	T100ms   = 0x0EF7  ; 100 ms
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
	ldhx #T100ms    ; Establecer modulo 
	sthx T1MODH     ; Se producira overflow cada 100ms
	
	;---------------------------------
	; Configurar el comparador 0 (Canal 0)
	;---------------------------------
	; Interrupcion permitida
	; Configurar como comparador, sin salida hardware
	mov #0x50,*T1SC0
	
	;-- Establecer el valor de comparacion. Seleccionamos
	;-- la mitad del modulo, pero se podria haber usado
	;-- cualquier otro valor.
	ldhx #T50ms
	sthx T1CH0H
	
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
	.dw dummy_isr	;-- Vector Canal 1  TIM1
	.dw rsi_t1ch0   ;-- Vector Canal 0  TIM1
	.dw dummy_isr   ;-- Vector PLL
	.dw dummy_isr   ;-- Vector IRQ	
	.dw dummy_isr   ;-- Vector SWI
	.dw main	    ;-- Vector Reset
