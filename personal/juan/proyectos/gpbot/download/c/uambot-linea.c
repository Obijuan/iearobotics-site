/****************************************************/
/* uambot-linea.c  (c) Juan Gonzalez. Febrero 2004  */
/*--------------------------------------------------*/
/* Ejemplo de prueba para el UAMBOT                 */
/* Seguimiento de linea                             */
/*--------------------------------------------------*/
/* LICENCIA GPL                                     */
/****************************************************/

#include "mc68hc908gp32.h"
#include "sci.h"

void main(void)
{	
	unsigned char sensores;
	/*----------------------------*/
	/* Configurar el sistema      */
	/*----------------------------*/
	CONFIG1|=0x01;  //-- Deshabilitar el COP
	
	//-- Configurar las entradas/salidas de los puertos A y C
	DDRA=0x9F; // PTA5 y PTA6 entradas
	DDRC=0x9F; // PTC5 y PTA6 entradas
	
	//-- Configurar los pull-ups
	PTAPUE=0x60;
	PTCPUE=0x60;
	
	//-- Apagar todos los motores
	PORTA=0x00;
	PORTC=0x00;

	//-- DEBUG
	DDRB=0xFF;
	PORTB=0xF0;
	
	for (;;) {
		sensores=PORTC; // Leer sensores
		switch (sensores&0x60) {
			case 0x60:  //-- Caso negro-negro
				PORTB=0xFF;
				PORTC=0x0A;
			  break;
			case 0x20:  //-- Caso Blanco-negro
				PORTB=0x55;
			  PORTC=0x12;
			  break;
			case 0x40:  //-- Caso Negro-Blanco
				PORTB=0xAA;
			  PORTC=0x0C;
				break;
		  default:
	      PORTB=0; 
		    PORTC=0x00;			
   	}
	}
	
}
