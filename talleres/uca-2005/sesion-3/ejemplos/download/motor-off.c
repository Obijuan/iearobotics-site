/*************************************************************************** */
/* motor-off.c      Junio-2005                                               */
/*---------------------------------------------------------------------------*/
/* Ejemplo para el skybot                                                    */
/*---------------------------------------------------------------------------*/
/*  Prueba de los motores. El programa simplemente los para                  */
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


//----------------------------
//- Comienzo del programa  
//----------------------------

void main(void)
{
  //-- Configurar el puerto B para trabajar con el Skybot
  //-- RB0, RB5, RB6 y RB7 como entradas
  //-- RB1, RB2, RB3 y RB4 como salidas
  TRISB=0xE1;
  
  //-- Parar el robot
  PORTB=STOP;
  
  //-- Bucle infinito
  while(1);

}
