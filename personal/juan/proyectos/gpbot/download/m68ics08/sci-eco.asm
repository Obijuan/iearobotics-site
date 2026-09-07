;------------------------------------------------------
;- sci-eco.asm.  Febrero 2004
;- Ivan Gonzalez
;- Carlos Jesus Venegas
;- Juan Gonzalez
;------------------------------------------------------
; Hacer Eco por el SCI. Configuracion a 9600 Baudios
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
	;-- Configuracion comunicaciones serie
	;----------------------------------------
	;-- 9600 Baudios
	lda #$22
	sta SCBR

	;-- Habilitar el SCI
	lda #$40
	sta SCC1

	;-- Habilitar Transmisor y receptor
	lda #$0C
	sta SCC2

	;------------------------
	;- Otras configuraciones
	;-------------------------

	;-- Configurar puerto B para salida
	lda	#$FF
	sta	DDRB

	;-- Encender bit0 puerto B
	lda #$01
	sta PORTB

	;-------------------
	;- Bucle principal
	;-------------------

bucle:
	JSR leer_sci	;-- Leer dato
	sta PORTB	    ;-- Mandarlo al puerto B
	JSR enviar_sci  ;-- Enviarlo por el SCI

	bra bucle

;---------------------------------------------
;- Enviar un byte por el SCI
;- ENTRADAS:
;-   -Acumulador A contiene dato a enviar
;---------------------------------------------
leer_sci:
	brclr 5,SCS1,leer_sci
	lda SCDR
	rts

;-----------------------------------------
;- Recibir un dato del SCI
;- SALIDAS:
;-    -Acumulador A devuelve dato leido
;-----------------------------------------
enviar_sci:
	brclr 7,SCS1,enviar_sci
	sta SCDR
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
