/*****************************************************************************/
/* mogollon.c.c  Julio-2007                                                  */
/*---------------------------------------------------------------------------*/
/* Ejemplo para el skybot                                                    */
/*---------------------------------------------------------------------------*/
/* Programa modelo para el concurso del "mogollon"                           */
/*---------------------------------------------------------------------------*/
/*  Andres Prieto-Moreno <andres@ifara.com>                                  */
/*  Juan Gonzalez <juan@iearobotics.com>                                     */
/*  Javier Valiente <jvaliente@ifara.com>                                    */
/*---------------------------------------------------------------------------*/
/*  LICENCIA GPL                                                             */
/*****************************************************************************/

//-- Especificar el pic a emplear
#include <pic16f876a.h>

//-- Para usar temporizaciones con el timer 0
#include "delay0.h"

//-- Definiciones para los motores. Estos valores definen
//-- los movimientos del robot
#define   ROBOT_AVANZA      0x1C
#define   ROBOT_ATRAS       0x16
#define   ROBOT_IZQUIERDA   0x1E 
#define   ROBOT_DERECHA     0x14 
#define   ROBOT_STOP        0x00

//-- Definiciones de los sensores
#define   SENSOR1  0x01
#define   SENSOR2  0x20
#define   SENSOR3  0x40
#define   SENSOR4  0x80

//-- Pulsador de la Skypic
#define PULSADOR 0x01

//-- MOdificar esto para indicar la colocacion de los sensores
#define SENSOR_IZQUIERDO SENSOR4
#define SENSOR_DERECHO   SENSOR3

//-- Tiempo en segundos para esperar a que el algoritmo arranque
#define TIEMPO  2

unsigned char sensores; 
void main(void)
{
	unsigned char i;
	
	//-- Configurar puerto B
	TRISB=0xE1;
	
	//-- Inicialmente robot parado
	PORTB=ROBOT_STOP;
	
	//-- Configurar temporizador
	timer0_configurar();
	
	//-- Esperar 300ms y encender led
	delay0(50);
	
	//-- Encender el led
	PORTB=0x02;
	
	//-- Esperar a que se apriete el pulsador
	while ((PORTB & PULSADOR)!=0);
	
	//-- Hacer que el led parpadee durante 5 segundos
	for (i=0; i<TIEMPO*2; i++)
  	{
		PORTB^=0x02;  //-- Cambiar el led de estado
		delay0(50);
	}  
	
	//-- Si blanco-blanco --> recto
	//-- Si blanco-negro --> Girar izquierda durante un tiempo
	//-- Si negro-blanco --> Girar derecha durante un tiempo
	//-- Si negro-negro --> atras durante un tiempo
	
	for (;;)
  	{
		sensores=PORTB& (SENSOR_IZQUIERDO | SENSOR_DERECHO); // Leer sensores
		switch (sensores)
    		{
			case SENSOR_DERECHO:      //-- Caso blanco-negro
				PORTB=ROBOT_IZQUIERDA;
				delay0(50);
				break;
			case SENSOR_IZQUIERDO:    //-- Caso negro-blanco
				PORTB=ROBOT_DERECHA;
				delay0(50);
				break;
			case (SENSOR_IZQUIERDO | SENSOR_DERECHO):  //-- Caso negro-negro
				PORTB=ROBOT_ATRAS;
				delay0(50);
				break;
			default:  //-- Caso blanco-blanco
				PORTB=ROBOT_AVANZA;
		}
	}  
}

