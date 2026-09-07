/*************************************************/
/* sci-eco.c.c  (c) Juan Gonzalez. Febrero 2004  */
/*-----------------------------------------------*/
/* Ejemplo para el SCI                           */
/* Implementacion de las funciones para envio y  */
/* recepcion de datos por el puerto serie.       */
/* El programa principal hace eco de todos los   */
/* caracteres recibidos. Velocidad 9600 Baudios  */
/*-----------------------------------------------*/
/* LICENCIA GPL                                  */
/*************************************************/

#include "mc68hc908gp32.h"
#include "sci.h"

void main(void)
{
	unsigned char car;
	
	/*----------------------------*/
	/* Configurar el sistema      */
	/*----------------------------*/
	CONFIG1|=0x01;  //-- Deshabilitar el COP
  DDRB=0xFF;      //-- Configurar Puerto B para salida
	PORTB=0x00;     //-- Poner a 0 Puerto B
	
	/*-----------------------------*/
	/* Configurar el puerto serie  */
	/*-----------------------------*/
	sci_init();
	
	for (;;) {
	  car=sci_leer_car();
		sci_enviar_car(car);
		PORTB=car;
	}	
		
}
