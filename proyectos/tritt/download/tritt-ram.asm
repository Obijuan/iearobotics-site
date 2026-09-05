******************************************
* Microbot Tritt: programa de ejemplo    *
*........................................*
* El robot sigue una línea negra trazada *
* en el suelo.                           *
*----------------------------------------*
* Programa para la RAM interna del 6811  *
* Tanto el modelo A1 como el E2          *
******************************************

	ORG $0000

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
