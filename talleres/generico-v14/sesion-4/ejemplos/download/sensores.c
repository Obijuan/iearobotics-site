/*****************************************************************************/
/* sensores.c      Junio-2005                                                */
/*---------------------------------------------------------------------------*/
/* Ejemplo para el skybot                                                    */
/*---------------------------------------------------------------------------*/
/*  Se lee el estado de los 4 sensores y se envia por el puerto A. Si se     */
/*  conectan 4 leds a los bits RA0, RA1, RA2 y RA3 se veran respectivamente  */
/*  los sensores 1, 2 , 3 y 4                                                */
/*  Este programa es muy util para comprobar el correcto funcionamiento      */
/*  de todos los sensores, pero es necesario la conexion de leds externos.   */
/*  Este ejemplo funciona perfectamente con la placa FREELEDS, que tiene 8   */
/*  leds                                                                     */
/*---------------------------------------------------------------------------*/
/*  Andres Prieto-Moreno <andres@ifara.com>                                  */
/*  Juan Gonzalez <juan@iearobotics.com>                                     */
/*  Modificado por: Javier Valiente <jvaliente@ifara.com>                    */
/*---------------------------------------------------------------------------*/
/*  LICENCIA GPL                                                             */
/*****************************************************************************/

//-- Especificar el pic a emplear
#include <pic16f876a.h>

//-- Definiciones de los sensores
#define   SENSOR1  0x01
#define   SENSOR2  0x20
#define   SENSOR3  0x40
#define   SENSOR4  0x80

//-- Definiciones de los bits del puerto A
#define   RA0  0x01
#define   RA1  0x02
#define   RA2  0x04
#define   RA3  0X08

//----------------------------
//- Comienzo del programa  
//----------------------------

void main(void)
{
	//-- Configurar puerto A para salida
	TRISA=0;
	
	//-- Configurar el puerto B para trabajar con el Skybot
	//-- RB0, RB5, RB6 y RB7 como entradas
	//-- RB1, RB2, RB3 y RB4 como salidas
	TRISB=0xE1;
	
	//-- Los motores del Skybot parados
	PORTB=0x00;
	
	//-- Inicialmente los leds apagados
	PORTA=0x00;
	
	//-- Bucle principal
	while(1)
  	{
		//-- Sensor 1 lee blanco?
		if ((PORTB & SENSOR1)==0)
    		{
			PORTA&=~RA0;           //-- si, Apagar el led
    		}
		else
    		{
			PORTA|=RA0;            //-- no, Encender led
    		}
		
		//-- Sensor 2 lee blanco?
		if ((PORTB & SENSOR2)==0)
    		{
			PORTA&=~RA1;           //-- si, Apagar el led
    		}
		else
    		{
			PORTA|=RA1;            //-- no, Encender led
    		}
		
		//-- Sensor 3 lee blanco?
		if ((PORTB & SENSOR3)==0)
    		{
			PORTA&=~RA2;           //-- si, Apagar el led
    		}
		else
    		{
			PORTA|=RA2;            //-- no, Encender led
    		}
		
		//-- Sensor 4 lee blanco?
		if ((PORTB & SENSOR4)==0)
    		{
			PORTA&=~RA3;           //-- si, Apagar el led
    		}
		else
    		{
			PORTA|=RA3;            //-- no, Encender led
    		}
	}
}

