/*************************************************************************** */
/* motor-on.c      Junio-2005                                                */
/*---------------------------------------------------------------------------*/
/* Ejemplo para el skybot                                                    */
/*---------------------------------------------------------------------------*/
/*  Prueba de los motores. El programa simplemente los activa                */
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
#define   AVANZA     0x18
#define   ATRAS      0x78
#define   IZQUIERDA  0x58 
#define   DERECHA    0x38 
#define   STOP       0x00


//----------------------------
//- Comienzo del programa  
//----------------------------

void main(void)
{
  //-- Configurar el puerto B para trabajar con el Skybot
  //-- RB0, RB1, RB2 y RB7 como entradas
  //-- RB3, RB4, RB5 y RB6 como salidas
  TRISB=0x87;
  
  //-- Activar los bits de los motores para que el robot avance
  PORTB=AVANZA;
  
  //-- Bucle infinito
  while(1);

}
