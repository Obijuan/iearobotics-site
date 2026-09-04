;+------------------------------------------------+
;| Ejemplo PULSADOR y LED                         |
;| El led parpadea y al apretar el pulsador se    |
;| queda encendido                                |
;| Pulsador conectado a RB0 ( PORTB: xxxx - xxxP) |
;| LED conectado a RB1 ( PORTB: xxxx - xxLx )     |
;|                                                |
;| Autor: Andrés Prieto-Moreno                    |
;| 14 - 11 - 2004                                 |
;+------------------------------------------------+

	list P=16F876A ; indicamos el modelo de PIC que tenemos
	include "p16f876a.inc"
	
; constantes del programa

TIEMPO  equ 0x30   ; posicion de memoria
TICKS   equ 10     ; Ticks entre parpadeo

; principio del codigo
; no hay interrupciones ->  coloco el codigo a partir de la posicion 0

	org 0


; Accedemos al segundo banco de RAM de Datos
	
	bsf	STATUS,5	

; Configuración puertos

	movlw	0x01
	movwf	TRISB  ; PB0=entrada , resto de salida

; configuracion del timer

	movlw	b'01010111'  ; divisor = 256, timer
	movwf	OPTION_REG

; Accedemos al primer banco de RAM

	bcf	STATUS,5

; Pongo a cero el puerto B
	clrf	PORTB 

; empieza el programa principal
 
inicio
	; mientras este apretado el pulsador quedate en este bucle
	btfsc   PORTB,0   ; salta si RB0=1 
	goto    parpadea  ; hace que parpadee el led
	bsf	PORTB,1   ; enciende el LED
	goto	inicio    ; vuelve al principio
	
	
parpadea
	; aqui llega siempre que no este apretado el pulsador
	bcf	PORTB,1 ; apaga led
	call    pausa
	bsf     PORTB,1 ; enciende led
	call    pausa
	goto    inicio


; RUTINA DE ESPERA
pausa
	movlw	TICKS      ; tiempo_espera = TICKs * t_tic
	movwf	TIEMPO     ; guarda valor en memoria	
otro_tic
	movlw   0xB2
	movwf   TMR0       ; t_tic = 20 mseg 	
sigue	
	btfss	INTCON,2   ; ¿desbordamiento ?
	goto	sigue	   ; no
        bcf	INTCON,2   ; si -> repongo flag
	decfsz	TIEMPO,1
	goto    otro_tic	
	return     

	END

 
