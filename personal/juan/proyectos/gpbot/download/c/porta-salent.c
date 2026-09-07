/*--------------------------------------------------------*/
/*- porta-salent.asm  (c) Juan Gonzalez. Marzo 2004       */
/*--------------------------------------------------------*/
/* Ejemplo de manejo del puerto A para entrada y salida   */
/* Los 4 bits de menor peso del puerto A se configuran    */
/* para entrada y los 4 mayores como salida.              */
/*  Todo lo recibido por los de menor peso se manda a los */
/* de mayor                                               */
/*--------------------------------------------------------*/
/* Licencia GPL                                           */
/*--------------------------------------------------------*/

#include "mc68hc908gp32.h"

unsigned char valor;

void main(void)
{
	//-- Configurar puerto A
	//-- 4 bits mayor peso [7,6,5,4] --> Salida
	//-- 4 bits menor peso [3,2,1,0] --> Entrada
  DDRA=0xF0;   
	
	//-- Bucle infinito
	for (;;) {
		valor=PORTA;       //-- Leer puerto A
		valor=(valor<<4);  //-- Desplazar 4 bits a la izquierda
		PORTA=valor;       //-- Enviar valor por puerto A
	}
}
