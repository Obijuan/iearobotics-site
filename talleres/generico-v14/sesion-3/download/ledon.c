/*************************************************************************** */
/* ledon.c      Julio-2007                                                   */
/*---------------------------------------------------------------------------*/
/* Ejemplo para el skybot                                                    */
/*---------------------------------------------------------------------------*/
/*  Encender el led de la Skypic                                             */
/*---------------------------------------------------------------------------*/
/*  Andres Prieto-Moreno <andres@ifara.com>                                  */
/*  Juan Gonzalez <juan@iearobotics.com>                                     */
/*  Javier Valiente <jvaliente@ifara.com>                                    */
/*---------------------------------------------------------------------------*/
/*  LICENCIA GPL                                                             */
/*****************************************************************************/

#include <pic16f876a.h>

//-- Definiciones
#define LED       0x02     // Pin del led de la Skypic

//----------------------------
//- Comienzo del programa  
//----------------------------

void main(void)
{
  //-- Configurar pin del led como salida
  TRISB&=~LED;

  //-- Activar el led
  PORTB|=LED;
  
  //-- Bucle infinito
  while(1);
}
