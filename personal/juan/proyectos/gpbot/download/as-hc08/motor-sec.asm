;------------------------------------------------------
;- motor-sec.asm  (c) Juan Gonzalez. Marzo 2004
;------------------------------------------------------
; Ejemplo de prueba para el robot, utilizando los
; motores 1 y 2. El programa hace que el robot avance
; durante un cierto tiempo, que luego retroceda, que
; gire en un sentido, luego en otro y finalmente que
; se pare.
;
; Lo que se considera "adelante" en este programa depende
; de como se hayan conectado los motores
;------------------------------------------------------
; Licencia GPL
;------------------------------------------------------

	;-- Incluir los registros del 6808
	.include "gpregs.inc"

	;-- Incluir mapa de memoria de la GPBOT
	.include "gpmap.inc"

;------------------------------------------
;- Constantes para movimiento del robot
;- Se deben modificar para cada robot
;------------------------------------------
	ADELANTE  = 0x0A
	ATRAS 	  = 0x14
	DERECHA   = 0x12
	IZQUIERDA = 0x0C

;--- Pausa a realizar entre cada movimieno
;--- En unidades de 100ms 
    PAUSA     = 10 

	;-- Zona de codigo
	.area CSEG (ABS)
	.org RomStart
	
;----------------------
;- Programa principal  
;----------------------	
main:
	;-- Inicializar la pila
	ldhx #InitStk
	txs
	
	;-- Deshabilitar el COP
	bset #0,*CONFIG1
	
	; Configurar pines PTC1,PTC2,PTC3 y PTC4 para salida
	lda	#0x1E	
	sta	DDRC
	
	;-- Configurar temporizador para hacer pausas
	jsr delay_config
	
	;-- Mover robot ADELANTE
	lda	#ADELANTE
	sta	PORTC
	
	;-- Pausa
	ldx #PAUSA
	jsr delay

	;-- Mover robot ATRAS
	lda #ATRAS
	sta PORTC
	
	;-- Pausa
	ldx #PAUSA
	jsr delay
	
    ;-- Mover robot DERECHA
	lda #DERECHA
	sta PORTC
	
	;-- Pausa
	ldx #PAUSA
	jsr delay
	
	;-- Mover robot IZQUIERDA
	lda #IZQUIERDA
	sta PORTC
	
	;-- Pausa
	ldx #PAUSA
	jsr delay

    ;-- PARAR Robot
	lda #0x00
	sta PORTC
	
	;-- Bucle infinito
inf:	BRA inf


;----------------------------------------
;- Configurar el temporizador 1 (TIM1)
;- Para hacer pausas
;----------------------------------------
delay_config:
	mov #0x06,*T1SC ; Prescaler: Div entre 64
	
	;-- Se configura para que haga un overflow cada 100ms
	;-- Cuando ocurre se activa el bit 7 del registro T1SC
	ldhx #0x0EF7
	sthx T1MODH
	rts

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
	brclr #7,*T1SC,delay100ms
	
	lda T1SC            ; Poner flag a cero
	bclr #7,*T1SC
	rts

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
