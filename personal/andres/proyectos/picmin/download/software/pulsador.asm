;+------------------------------------------------+
;| Ejemplo 2 (PULSADOR)                           |
;| Al pulsar el Pulsador el Led se enciende       |
;| Pulsador conectado a RB0 ( PORTB: xxxx - xxxP) |
;| LED conectado a RB1 ( PORTB: xxxx - xxLx )     |
;|                                                |
;| Autor: Andrés Prieto-Moreno                    |
;| 18 - 06 - 2002                                 |
;+------------------------------------------------+

;	list P=16F84 ; indicamos el modelo de PIC que tenemos

; definición

PORTB	equ 0x06
DDRB	equ 0x06
STATUS	equ 0x03

W	equ 0
f	equ 1

	org 0

; Accedemos al segundo banco de RAM de Datos
	
	bsf	STATUS,5	

; Configuración puertos

	movlw	0x01
	movwf	DDRB ; RB0 entrada, resto salida

; Accedemos al primer banco de RAM

	bcf	STATUS,5

; empieza el programa principal
 
inicio
	btfss	PORTB,0    ; salta si RB0=1
	goto	led_on
 	bcf	PORTB,1 ; apago el led   
	goto 	inicio     
led_on bsf	PORTB,1 ; enciendo el led
	goto 	inicio

	END

 
