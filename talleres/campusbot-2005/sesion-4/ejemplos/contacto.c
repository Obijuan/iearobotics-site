/*************************************************************************** */
/* bumpers.c      Julio-2005                                                 */
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

#define IZQUIERDO 0x02
#define DERECHO   0x04


//----------------------------
//- Comienzo del programa  
//----------------------------

unsigned char bumpers;
void main(void)
{
  //-- Configurar el puerto B para trabajar con el Skybot
  //-- RB0, RB1, RB2 y RB7 como entradas
  //-- RB3, RB4, RB5 y RB6 como salidas
  TRISB=0x87;
  
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
