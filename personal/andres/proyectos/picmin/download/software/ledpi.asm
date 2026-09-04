;+------------------------------------------------+
;| Ejemplo 4 (LED PARPADEANTE por INTERRUPCIONES) |
;| LED conectado a RB1 ( PORTB: xxxx - xxLx )     |
;| Calcula el tiempo con el temporizador pero no  |
;| utiliza interrupciones                         |
;|                                                |
;| Autor: Andrés Prieto-Moreno                    |
;| 14 - 11 - 2002                                 |
;+------------------------------------------------+

	list P=16F84

	#include p16f84a.inc

	#define BANCO_1 bsf STATUS,RP0
	#define BANCO_0 bcf STATUS,RP0

; constantes del programa

TIEMPO  equ 0x30   ; posicion de memoria
TICKS   equ 20     ; Ticks entre parpadeo 20

; empieza el programa

	org 0
	goto inicio


; ******************************************
; *    RUTINA de INTERRUPCIÓN GENERAL      *
; ******************************************

	org 4
	
	btfss INTCON,T0IF   ; ¿ la interrupción es por el timer ?
	retfie              ; NO -> olvidala, devuelve el control
	goto  int_timer     ; SI -> ve a la rutina de ateción
	

; ******************************************************************
; * A continuación de la rutina de interrupción empieza el programa *
; ******************************************************************

; Accedemos al segundo banco  RAM de Datos
	
inicio
	BANCO_1

; Configuración puertos

	movlw	0
	movwf	TRISB  ; TRISB = 0  -> puerto B de salida

; Configuración general

; RBPU (7) = 0 : pull-up activados
; TOCS (5) = 0 : seleccionamos timer
; TOSE (3) = 0 : Prescaler asignada al timer
; PS2:PS0 = 111 (1/256)

	movlw	b'01010111'  ; divisor = 256, timer
	movwf	OPTION_REG

; Accedemos al primer banco de RAM

	BANCO_0

; Pongo a cero el puerto B
	clrf	PORTB 
	movlw	TICKS        ; tiempo_espera = TICKs * t_tic
	movwf	TIEMPO       ; guarda valor en memoria	
	bsf     INTCON,GIE   ; activa las interrupciones 
	bsf     INTCON,T0IE  ; activa interrupción del timer

; **********************************
; *  empieza el programa principal *
; **********************************
 
bucle
	; codigo del programa

	goto bucle

; ********************************
; *   RUTINAS DE INTERRUPCION    *
; ********************************

; RUTINA DE INTERRUPCION DEL TIMER

int_timer
	decfsz	TIEMPO,F   ; ¿ TIEMPO=0 ?
	goto    sal_int    ; no -> sigue contando

	movf    PORTB,W
	xorlw   2          ; hace parpadear LED
	movwf   PORTB
                           
	movlw	TICKS      ; tiempo_espera = TICKs * t_tic
	movwf	TIEMPO     ; guarda valor en memoria	

sal_int
	movlw   0xB2        ; FF-B2 -> 4 * 1/frec * TMRO * Prescaler (B2)
	movwf   TMR0        ; t_tic = 20 mseg 		
	bcf     INTCON,T0IF ; borra el flag de interrupción
	retfie              ; devuelve el control al programa 

	END

 
