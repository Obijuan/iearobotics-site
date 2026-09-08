/*************************************************************************** */
/* bumpers.c      Febrero-2006                                               */
/*---------------------------------------------------------------------------*/
/* Ejemplo para el skybot                                                    */
/*---------------------------------------------------------------------------*/
/*  Ejemplo de prueba para los bumpers.                                      */
/*  Al apretar el Bumper1 (Derecho) se apaga el LED                          */
/*---------------------------------------------------------------------------*/
/*  Andres Prieto-Moreno <andres@ifara.com>                                  */
/*  Juan Gonzalez <juan@iearobotics.com>                                     */
/*---------------------------------------------------------------------------*/
/*  LICENCIA GPL                                                             */
/*****************************************************************************/

//-- Especificar el pic a emplear
#define __16f877
#include "pic16f877.h"

#define DERECHO   0x02 //Bumper 1  Derecho desde arriba
#define IZQUIERDO 0x04 //Bumper 2  Iquierdo desde arriba

//----------------------------
//- Comienzo del programa  
//----------------------------

unsigned char bumper;
void main(void)
{
  //-- Configurar el puerto B para trabajar con el Skybot
  //-- RB0, RB5, RB6 y RB7 como entradas
  //-- RB1, RB2, RB3 y RB4 como salidas
  TRISB=0xE1;
  
  //-- Configurar el puerto A para trabajar con los bumpers
  ADCON1=0x0E;
  
  for(;;) {
    bumper=PORTA & DERECHO; // Leer bumper 1
	if ( bumper==0) { 
		PORTB=0x02;
	} else {    // al apretar el bumper leemos 1
		PORTB=0;
	}
	
  }

}
