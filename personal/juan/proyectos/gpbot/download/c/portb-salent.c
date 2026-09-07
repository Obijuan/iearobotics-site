/*--------------------------------------------------------*/
/*- portb-salent.asm  (c) Juan Gonzalez. Marzo 2004       */
/*--------------------------------------------------------*/
/* Ejemplo de manejo del puerto B para entrada y salida   */
/* Los 4 bits de menor peso del puerto B se configuran    */
/* para entrada y los 4 mayores como salida.              */
/*  Todo lo recibido por los de menor peso se manda a los */
/* de mayor                                               */
/*--------------------------------------------------------*/
/* Es exactamente igual que el programa porta-salent.c,   */
/* pero para el puerto B                                  */
/*--------------------------------------------------------*/
/* Licencia GPL                                           */
/*--------------------------------------------------------*/

#include "mc68hc908gp32.h"

unsigned char valor;

void main(void)
{
	//-- Configurar puerto B
	//-- 4 bits mayor peso [7,6,5,4] --> Salida
	//-- 4 bits menor peso [3,2,1,0] --> Entrada
  DDRB=0xF0;   
	
	//-- Bucle infinito
	for (;;) {
		valor=PORTB;       //-- Leer puerto B
		valor=(valor<<4);  //-- Desplazar 4 bits a la izquierda
		PORTB=valor;       //-- Enviar valor por puerto B
	}
}
