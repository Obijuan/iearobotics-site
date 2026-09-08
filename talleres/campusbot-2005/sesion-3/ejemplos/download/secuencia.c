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
