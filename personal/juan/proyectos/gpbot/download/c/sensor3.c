
/*------------------------------------------------------*/
/*- sensor3.c  (c) Juan Gonzalez. Mayo 2004             */
/*------------------------------------------------------*/
/* Ejemplo de manejo del sensor CNY70, en modo digital  */
/* Se lee el sensor IR3 (Conectado al pin PTA5) y       */
/* se saca su estado por el puerto B                    */
/*------------------------------------------------------*/
/* Sensor IR3: Pin PTA5                                 */
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
  //-- Configurar puerto A para entrada
	DDRA=0x00;
	
  //-- Configurar pull-up
	PTAPUE=0x20;
	
	for(;;) {
		//-- Leer sensor ire
		sensor=(PORTA & 0x20);
		
		//-- Enviar el valor al puerto B para visualizarlo
		PORTB=sensor;
	}
		
}
