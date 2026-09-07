
/*------------------------------------------------------*/
/*- sensor1.c  (c) Juan Gonzalez. Marzo 2004            */
/*------------------------------------------------------*/
/* Ejemplo de manejo del sensor CNY70, en modo digital  */
/* Se lee el sensor IR1 (Conectado al pin PTC5) y       */
/* se saca su estado por el puerto B                    */
/*------------------------------------------------------*/
/* Sensor IR1: Pin PTC5                                 */
/* Valores devueltos por el sensor:                     */
/*   Negro -->  1                                       */
/*   Blanco --> 0                                       */
/*------------------------------------------------------*/
/* Licencia GPL                                         */
/*------------------------------------------------------*/

#include "mc68hc908gp32.h"

unsigned char sensor;

void main(void)
{
	/*----------------------------*/
	/* Configurar el sistema      */
	/*----------------------------*/
	CONFIG1|=0x01;  //-- Deshabilitar el COP
	
	//-- Configurar puerto B para salida
	DDRB=0xFF;

  /*---------------------------------------------------------*/
	/*- Configucion para utilizar el sensor en modo digital    */
	/*---------------------------------------------------------*/
  //-- Configurar puerto C para entrada
	DDRC=0x00;
	
  //-- Configurar pull-up
	PTCPUE=0x20;
	
	for(;;) {
		//-- Leer sensor ir1
		sensor=(PORTC & 0x20);
		
		//-- Enviar el valor al puerto B para visualizarlo
		PORTB=sensor;
	}
		
}
