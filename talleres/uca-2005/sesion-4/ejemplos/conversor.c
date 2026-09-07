/*****************************************************************************/
/* conversor.c     Junio-2005                                                */
/*---------------------------------------------------------------------------*/
/* Ejemplo para el skybot                                                    */
/*---------------------------------------------------------------------------*/
/*  Ejemplo para el conversor A/D. Se utiliza el canal 0 (PA0) donde esta    */
/*  conectado el sensor de luz. El valor leido (nivel de luz) se envia       */
/*  al PUERTO B. Si se conectan unos leds se puede ver.                      */
/*  Es un ejemplo de como leer el conversor, para adaptarlo a cualquier      */
/*  aplicacion                                                               */
/*---------------------------------------------------------------------------*/
/*  Andres Prieto-Moreno <andres@ifara.com>                                  */
/*  Juan Gonzalez <juan@iearobotics.com>                                     */
/*---------------------------------------------------------------------------*/
/*  LICENCIA GPL                                                             */
/*****************************************************************************/

//-- Especificar el pic a emplear
#define __16f877
#include "pic16f877.h"

//-- Definiciones
#define LED       0x02     // Pin del led de la Skypic

//----------------------------
//- Comienzo del programa  
//----------------------------

unsigned char ad;
void main(void)
{
  
  //-- Configurar conversor analogico/digital
  //-- Entrada analogica: PA0 (Clema 2 de la CT293)
  //-- Resto de entradas del puerto A: digitales
  ADCON0 = 0x01;
  ADCON1 = 0x0E;
  
 
  //-- Configurar puerto B para salida
  TRISB=0x00;  
  
  for(;;) {
    //-- Activar la conversion
    ADCON0 |= 0x04;
    
    //-- Esperar a que se haga la conversion
    while ((ADCON0&0x04)==1);
    
    ad = ADRESH;
    PORTB = ad;
  }
  
}
