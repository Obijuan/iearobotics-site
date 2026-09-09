/*****************************************************************************/
/* motores-sensor3.c      Julio-2007                                         */
/*---------------------------------------------------------------------------*/
/* Ejemplo para el skybot                                                    */
/*---------------------------------------------------------------------------*/
/*  Se lee el estado del sensor 3 y se activan los motores. Si lee blanco,   */
/*  el robot se para. Si lee negro avanza.                                   */
/*  Es un ejemplo de un comportamiento reactivo muy sencillo                 */
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
//-- Definiciones para los motores. Estos valores definen
//-- los movimientos del robot
#define   AVANZA     0x1C
#define   ATRAS      0x16
#define   IZQUIERDA  0x1E 
#define   DERECHA    0x14 
#define   STOP       0x00

//-- Indicar el sensor a utilizar. Por defecto esta puesto el 3, pero se
//-- puede poner cualquier otro: 1,2 o 4.
#define   SENSOR SENSOR3

//----------------------------
//- Comienzo del programa  
//----------------------------

void main(void)
{
	//-- Configurar el puerto B para trabajar con el Skybot
	//-- RB0, RB5, RB6 y RB7 como entradas
	//-- RB1, RB2, RB3 y RB4 como salidas
	TRISB=0xE1;
	
	//-- Los motores del Skybot parados
	PORTB=0x00;
	
	//-- Bucle principal
	while(1)
  	{
		//-- Sensor  lee blanco?
		if ((PORTB & SENSOR)==0)
    		{
			PORTB=AVANZA;           //-- si, avanzar
    		}
		else
    		{
			PORTB=STOP;             //-- no, parar
    		}
	}
}

