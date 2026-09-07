;------------------------------------------------------
;- tim-pwm-fut8.asm.  Mayo 2004
;- Juan Gonzalez
;------------------------------------------------------
; Ejemplo de posicionamienot de servos Futaba 3003
; Se utiliza el TIM1 para posicionar hasta 8 servos
; El posicionamiento se hace por interrupciones
; La interrupcion de overflow se configura para que se
; produzca cada 2.5ms. La interrupcion del capturador
; determina el anchu del servo actual.
;------------------------------------------------------
; Los servos se conectan por el puerto B
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

;-- Posiciones del servo
CENTRO   EQU $0C72  ; 1,3 ms. Posicion central
EXTREMO1 EQU $2DF   ; 0,3 ms. Un extremo
EXTREMO2 EQU $1605  ; 2,3 ms. El otro extremo

T2_5ms    EQU $17D1  ; 2,5 ms

;-------------------
;- VARIABLES
;-------------------
	org RamStart

;--- Posiciones de los servos
posi1:   ds 2
posi2:   ds 2
posi3:   ds 2
posi4:   ds 2
posi5:   ds 2
posi6:   ds 2
posi7:   ds 2
posi8:   ds 2

punt:	 ds 2	; Puntero a la posicion actual
servo:	 ds 1  ; Servo actual (ventana activa)
salidas: ds 1  ; Mascara de habilitacion de servos

;-------------------
;- CODIGO
;-------------------

	;-- Zona de codigo
	org RomStart

main:
	;-- Inicializar la pila
	ldhx #InitStk
	txs

	;-- Deshabilitar el COP y el LVI
	mov #$31,CONFIG1

	;-----------------------------
	;- Configurar el temporizador
	;-------------------------------
	mov #$60,T1SC ; Prescaler: Div entre 1
	ldhx #T2_5ms    ; Establecer modulo: 2,5ms
	sthx T1MODH

	;-- Canal 0 TIM1
	mov #$50,T1SC0

	;-----------------------
	; Configurar puerto B
	;-----------------------
	mov #$FF,DDRB
	CLR PORTB

	;------------------------------------------
	; Establecer las posiciones de los servos
	;------------------------------------------
	ldhx #CENTRO
	sthx posi1
	sthx posi2
	sthx posi3
	sthx posi4
	sthx posi5
	sthx posi6
	sthx posi7
	sthx posi8

	;-- punt contiene la posicion del servo 1
	ldhx #posi1
	sthx punt

	;-- Establecer servo actual
	mov #$01,servo

	;-- Habilitacion de servos
	mov #$FF,salidas

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
; Se produce cada 2,5ms
;-------------------------------------------
rsi_ov1:
	;-- Quitar el flag de overflow
	bclr 7,T1SC

	;-- Establecer valor del ancho del pulso
	;-- Pasar la palabra apuntada por punt a
	;-- T1CH0H:T1CH0L
	ldhx punt
	lda ,x
	sta T1CH0H
	incx
	lda ,x
	sta T1CH0L

	;--- Poner senal PWM del servo actual a 1
	lda servo
	and salidas    ; ...si es que esta habilitada
	sta PORTB

	rti

;-------------------------------------------
; Rutina atencion interrupcion canal 0 TIM1
; Sirve para calcular el anchu del pulso
; comprendido entre 0,3 y 2,3ms
;-------------------------------------------
rsi_t1ch0:
	;-- Quitar el flag del comparador
	bclr 7,T1SC0

	;-- Poner senal PWM a 0
	clr PORTB

	;-- Pasar al siguiente servo. El puntero apunta al siguiente
	ldhx punt
	incx
	incx
	sthx punt

	lsl servo	; Siguiente servo
	lda servo
	cmp #0             ; Se han actualizado los 8 servos?
	bne fin_t1ch0      ; No, terminar
	lda #$01          ; Si, volver a comenzar por servo 1
	sta servo
	ldhx #posi1
	sthx punt

fin_t1ch0:
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
	dw rsi_t1ch0    ;-- Vector Canal 0  TIM1
	dw dummy_isr    ;-- Vector PLL
	dw dummy_isr    ;-- Vector IRQ
	dw dummy_isr    ;-- Vector SWI
	dw main	        ;-- Vector Reset
