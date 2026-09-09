/*************************************************************************** */
/* sci-sensor.c      Junio-2005 Version 1.0                                  */
/*					 Mayo-2006  Version 2.0                                  */
/*---------------------------------------------------------------------------*/
/* Ejemplo para el skybot                                                    */
/*---------------------------------------------------------------------------*/
/*  Leer el estado de un sensor (se puede definir cual) y enviar su estado   */
/*  por el puerto serie. Si lee negro se manda una 'N', si es blanco una 'B' */
/*  Para ver su funcionamiento es necesario ejecutar un terminal de          */
/*  comunicaciones                                                           */
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

#include "sci.h"

//-- Definiciones de los sensores
#define   SENSOR1  0x01
#define   SENSOR2  0x20
#define   SENSOR3  0x40
#define   SENSOR4  0x80

//-- Indicar el sensor a comprobar. Esto se puede cambiar
#define   SENSOR SENSOR4

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
  
  //-- Configurar las comunicaciones serie
  sci_conf();

  //-- Bucle principal
  while(1) {
    
    //-- Sensor lee blanco?
    if ((PORTB & SENSOR)==0) 
       sci_write('B');          //-- Si, mandar la B
    else    
       sci_write('\N');         //-- No, manda la N
    
    //-- Enviar un caracter de retroceso
    sci_write('\b');  
  }  
  
}
