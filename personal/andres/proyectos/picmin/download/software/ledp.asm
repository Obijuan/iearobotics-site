;+------------------------------------------------+
;| Ejemplo 3 (LED PARPADEANTE)                    |
;| LED conectado a RB1 ( PORTB: xxxx - xxLx )     |
;|                                                |
;| Autor: Andrés Prieto-Moreno                    |
;| 18 - 06 - 2002                                 |
;+------------------------------------------------+

	list P=16F84 ; indicamos el modelo de PIC que tenemos

; registros

DDRB    equ 0x06 ; banco 1
PORTB   equ 0x06 ; banco 0
STATUS  equ 0x03 ; banco 0 y 1
TMR0    equ 0x01 ; banco 0
OPTIO   equ 0x01 ; banco 1
INTCON  equ 0x0b ; banco 0 y 1


; constantes del programa

TIEMPO  equ 0x30   ; posicion de memoria
TICKS   equ 20     ; Ticks entre parpadeo


	org 0


; Accedemos al segundo banco de RAM de Datos
	
	bsf	STATUS,5	

; Configuración puertos

	movlw	0
	movwf	DDRB  ; TRISB = 0  -> puerto B de salida

; configuracion del timer

	movlw	b'01010111'  ; divisor = 256, timer
	movwf	OPTIO

; Accedemos al primer banco de RAM

	bcf	STATUS,5

; Pongo a cero el puerto B
	clrf	PORTB 

; empieza el programa principal
 
inicio
	bsf	PORTB,1 ; enciende led
	call    pausa
	bcf     PORTB,1 ; apaga led
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

 
