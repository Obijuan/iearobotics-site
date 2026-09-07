;------------------------------------------------------
;- motor-on.asm.  Marzo 2004
;- Juan Gonzalez
;------------------------------------------------------
; Ejemplo de prueba para los motores.
; Se mueven los motores 1 y 2
; El sentido de giro depende de como se hayan conectado
; los cables
;------------------------------------------------------
; Licencia GPL
;------------------------------------------------------

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

	;----------------------------------------
	;- Configurar el temporizador 1 (TIM1)
	;----------------------------------------
	mov #$06,T1SC ; Prescaler: Div entre 64

	;-- Se configura para que haga un overflow cada 100ms
	;-- Cuando ocurre se activa el bit 7 del registro T1SC
	ldhx #$0EF7
	sthx T1MODH

	;----------------------------------
	; Configurar puerto B para salida
	;----------------------------------
	mov #$FF,DDRB
	CLR PORTB

	;---------------------------------
	; Bucle principal
	;---------------------------------
bucle:
	;-- Hacer una pausa de 500ms
	ldx #$05
	jsr delay

	;-- Cambiar de estado el bit PTB0
	;-- PORTB = (PORTB xor 0x01);
	lda PORTB
	eor #$01
	sta PORTB

	bra bucle


;------------------------------------------------------------
; Subrutina para realizar una pausa
; ENTRADAS:
;  -Registro X: tiempo de la pausa, en unidades de 100ms
;    (ej. X=10 hace una pausa de 1 segundo)
;-------------------------------------------------------------
delay:
	jsr delay100ms  ; Hacer una pausa de 100ms
	decx            ; X--
	cpx #0          ; X=0?
	bne delay       ; No, repite el bucle
	rts             ; Si, terminar


;--------------------------------------------------------
;- Realizar una pausa de 100ms,
;- Por espera activa
;- Cada vez que se activa el bit 7 del registros
;- T1SC, es que han transcurrido 100ms
;--------------------------------------------------------
delay100ms:
    ;-- Mientras que bit 7 de T1SC este a 0, repetir bucle
	brclr 7,T1SC,delay100ms

	lda T1SC            ; Poner flag a cero
	bclr 7,T1SC
	rts

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
