******************************************
* Microbot Tritt: programa de ejemplo    *
*........................................*
* El robot sigue una línea negra trazada *
* en el suelo.                           *
*----------------------------------------*
* Programa para la eeprom de un 6811 E2  *
******************************************

	ORG $F800

principio
	LDX  #$1000 ; acceso indexado
	LDS  #$FF   ; pila

	LDAA $26,X
	ORAA #$08
	STAA $26,X ; PA3 de salida

* --- programa principal

inicio  
	STAA  $0,X
	BRSET $0,X $03 avanza  
	BRSET $0,X $01 derecha
	BRSET $0,X $02 izquierda

derecha
	LDAA #$58
	BRA  inicio

izquierda
	LDAA #$38
	BRA  inicio

avanza
	LDAA #$18
	BRA  inicio


* --- vector de reset

	ORG $FFFE
v_reset FDB #principio    

	END
