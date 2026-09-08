/*****************************************************************************/
/* conversor.c     Junio-2005                                                */
/*---------------------------------------------------------------------------*/
/* Ejemplo para el skybot                                                    */
/*---------------------------------------------------------------------------*/
/*  Ejemplo para el conversor A/D. Se utiliza el canal 0 (PA0) donde esta    */
/*  conectado el sensor de luz. El valor leido (nivel de luz) se             */
/*  se compara con un umbral. Si no se supera se apaga el LED.               */
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
  ADCON0 = 0x01;  // enciendo el conversor
  ADCON1 = 0x0E;  // configuro AN0 como entrada analogica, resto digital
  
 
  //-- Configurar puerto B para salida
  TRISB=0x00;  
  
  for(;;) {
    //-- Activar la conversion
	//-- Hay que hacerlo cada vez que se termina la anterior
    ADCON0 |= 0x04;
    
    //-- Esperar a que se haga la conversion
    while ((ADCON0&0x04)==0x04);
    
	/* el dato se encuentra en el registro ADRESH. Se corresponde
	   con un valor entre 0 y 255, y me indica el nivel de intensidad
	   de luz recibida por el sensor.
	   Debido al circuito de polarizacion de la SKY293 y al propio sensor
	   el umbral ha de situarse cerca del 200. Cuando se ilumina el sensor
	   el valor leido disminuye.
	   
	   El UMBRAL depende mucho de las condiciones de iluminacion, se
	   recomienda adaparlo a cada entorno.
	   
	*/
    if (ADRESH>=250) {  // En ADRESH esta el dato leído
		PORTB=LED;
	}
	else {
		PORTB=0;
	}
   }
}
