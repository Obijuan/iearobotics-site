;+------------------------------------------------+
;| Ejemplo 1 (LED ON/OFF sin pausa)               |
;| Al no haber pausa el efecto es que el LED esta |
;| siempre encendido                              |
;|                                                |
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

	org 0

; Accedemos al segundo banco de RAM de Datos
	
	bsf	STATUS,5	

; Configuración puertos

	movlw	0
	movwf	DDRB ; TRISB = 0  -> puerto B de salida

; Accedemos al primer banco de RAM

	bcf	STATUS,5

; empieza el programa principal

inicio	movlw	0x02	; Enciendo el LED	
	movwf	PORTB	; devuelvo el valor al puerto B	
	bcf	PORTB,1
	goto 	inicio  ; lo dejo en bucle infinito

	END

 
