/*************************************************************************** */
/* contacto.c      Julio-2005 Version 1.0                                    */
/*                 Mayo-2006  Version 2.0                                    */
/*---------------------------------------------------------------------------*/
/* Ejemplo para el skybot                                                    */
/*---------------------------------------------------------------------------*/
/*  Ejemplo de prueba para los bumpers. El robot se convierte en una "lapa"  */
/*  y tiendo a pegarse a las objetos. Si los dos bumpers estan activados     */
/*  el robot se para. Cuando estan sueltos avanza. Si se activa el derecho   */
/*  gira a la derecha y si lo hace el izquierdo gira a la izquierda          */
/*---------------------------------------------------------------------------*/
/*  Andres Prieto-Moreno <andres@ifara.com>                                  */
/*  Juan Gonzalez <juan@iearobotics.com>                                     */
/*  Ricardo Gomez <ricardo@eagleman.org>                                     */
/*---------------------------------------------------------------------------*/
/*  LICENCIA GPL                                                             */
/*****************************************************************************/

//-- Especificar el pic a emplear
#define __18f2580
#include "pic18f2580.h"

//-- Definiciones para los motores. Estos valores define
//-- los movimientos del robot
#define   AVANZA     0x1C
#define   ATRAS      0x16
#define   IZQUIERDA  0x1E 
#define   DERECHA    0x14 
#define   STOP       0x00

#define DERECHO   0x02 //Bumper 1  Derecho desde arriba
#define IZQUIERDO 0x04 //Bumper 2  Iquierdo desde arriba

//----------------------------
//- Comienzo del programa  
//----------------------------

unsigned char bumpers;
void main(void)
{
  //-- Configurar el puerto B para trabajar con el Skybot
  //-- RB0, RB5, RB6 y RB7 como entradas
  //-- RB1, RB2, RB3 y RB4 como salidas
  TRISB=0xE1;
  
  //-- Configurar el puerto A para trabajar con los bumpers
  ADCON1=0x0E;
  
  for(;;) {
    bumpers=PORTA & (IZQUIERDO | DERECHO); // Leer sensores
 
    switch(bumpers) {
      case IZQUIERDO:       //-- Contacto - Libre
        PORTB=IZQUIERDA;
        break;
      case DERECHO:
        PORTB=DERECHA;   //-- Libre - Contacto
        break;
      case 0x00:         //-- Libre - libre
        PORTB=AVANZA;
        break;
      case (IZQUIERDO | DERECHO):         //-- Contacto - Contacto
        PORTB=STOP;
        break;
    }
  }

}
