/*************************************************************************** */
/* linea.c  Julio-2005                                                       */
/*---------------------------------------------------------------------------*/
/* Ejemplo para el skybot                                                    */
/*---------------------------------------------------------------------------*/
/* Programa de seguimiento de linea para el robot Skybot                     */
/*---------------------------------------------------------------------------*/
/*  Andres Prieto-Moreno <andres@ifara.com>                                  */
/*  Juan Gonzalez <juan@iearobotics.com>                                     */
/*---------------------------------------------------------------------------*/
/*  LICENCIA GPL                                                             */
/*****************************************************************************/

//-- Especificar el pic a emplear
#define __16f877
#include "pic16f877.h"

//-- Definiciones para los motores. Estos valores define
//-- los movimientos del robot
#define   AVANZA     0x1C
#define   ATRAS      0x16
#define   IZQUIERDA  0x1E 
#define   DERECHA    0x14 
#define   STOP       0x00

//-- Definiciones de los sensores
#define   SENSOR1  0x01
#define   SENSOR2  0x20
#define   SENSOR3  0x40
#define   SENSOR4  0x80

//-- MOdificar esto para indicar la colocacion de los sensores
#define IZQUIERDO SENSOR4
#define DERECHO   SENSOR3

unsigned char sensores; 
void main(void)
{
  
  //-- Configurar puerto B
  TRISB=0xE1;
  
  //-- Inicialmente robot parado
  PORTB=STOP;
  
  for (;;) {
		sensores=PORTB& (IZQUIERDO | DERECHO); // Leer sensores
		switch (sensores) {
			case (IZQUIERDO | DERECHO):  //-- Caso negro-negro
				PORTB=AVANZA;
			  break;
			case DERECHO:  //-- Caso Blanco-negro
				PORTB=DERECHA;
			  break;
			case IZQUIERDO:  //-- Caso Negro-Blanco
				PORTB=IZQUIERDA;
				break;
		  default:
	      PORTB=STOP; 		
   	}
  }  
}
