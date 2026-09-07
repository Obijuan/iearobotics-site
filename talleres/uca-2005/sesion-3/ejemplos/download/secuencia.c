/*************************************************************************** */
/* secuencia.c      Julio-2005                                               */
/*---------------------------------------------------------------------------*/
/* Ejemplo para el skybot                                                    */
/*---------------------------------------------------------------------------*/
/*  Ejemplo de una secuencia pregrabada. El robot ejecuta movimientos        */
/*  con unas determinadas duraciones.                                        */
/*---------------------------------------------------------------------------*/
/*  Andres Prieto-Moreno <andres@ifara.com>                                  */
/*  Juan Gonzalez <juan@iearobotics.com>                                     */
/*---------------------------------------------------------------------------*/
/*  LICENCIA GPL                                                             */
/*****************************************************************************/

//-- Especificar el pic a emplear
#define __16f877
#include "pic16f877.h"

//-- Para usar temporizaciones con el timer 0
#include "delay0.h"

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
  
  //-- Configurar temporizador
  timer0_configurar();
  
  //-- Comienzo de la secuencia
  PORTB=AVANZA;
  delay0(100);
  PORTB=DERECHA;
  delay0(130);
  PORTB=AVANZA;
  delay0(100);
  PORTB=DERECHA;
  delay0(40);
  PORTB=AVANZA;
  delay0(100);
  PORTB=IZQUIERDA;
  delay0(200);
  
  
  //-- Fin
  PORTB=STOP;
  
  //-- Bucle infinito
  while(1);

}
