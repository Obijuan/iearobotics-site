******************************************
* Microbot Tritt: programa de ejemplo    *
*........................................*
* El robot sigue una línea negra trazada *
* en el suelo.                           *
*----------------------------------------*
* Grabar en la EEPROM de un 6811 A1      *
******************************************

	ORG $B600

	LDX  #$1000

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

	END 
