/*************************************************************************** */
/* sensor4.c      Junio-2005 Version 1.0                                     */
/*                Mayo-2006  Version 2.0                                     */
/*---------------------------------------------------------------------------*/
/* Ejemplo para el skybot                                                    */
/*---------------------------------------------------------------------------*/
/* Prueba del sensor 4. Cuando este sensor lee negro se enciende el led y    */
/* lo apaga en caso contrario. Es muy util para comprobar si los sensores    */
/* se han construido correctamente                                           */
/*---------------------------------------------------------------------------*/
/*  Juan Gonzalez <juan@iearobotics.com>                                     */
/*  Ricardo Gomez <ricardo@eagleman.org>                                     */
/*---------------------------------------------------------------------------*/
/*  LICENCIA GPL                                                             */
/*****************************************************************************/

//-- Especificar el pic a emplear
#define __18f2580
#include "pic18f2580.h"

//-- Definiciones de los sensores
#define   SENSOR1  0x01
#define   SENSOR2  0x20
#define   SENSOR3  0x40
#define   SENSOR4  0x80

//-- Indicar el sensor a comprobar. Esto se puede cambiar, pero no se puede
//-- poner el sensor 2 porque comparte pin con el led
#define   SENSOR SENSOR4

#define LED       0x02     // Pin del led de la Skypic


//----------------------------
//- Comienzo del programa  
//----------------------------
unsigned char sensor;
void main(void)
{
  //-- Configurar pin del led como salida
  //-- El resto como entradas
  TRISB&=~LED;
  
  //-- Bucle principal
  while(1) {
    //-- Si el sensor lee blanco
    if ((PORTB & SENSOR)==0)
       PORTB&=~LED;           //-- Apagar el led
    else
       PORTB|=LED;            //-- Sino, encenderlo
  }

}
