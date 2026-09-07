/*------------------------------------------------------*/
/*- motor-on.asm  (c) Juan Gonzalez. Marzo 2004         */
/*------------------------------------------------------*/
/* Ejemplo de activacion de los motores 1 y 2           */
/* El sentido de giro depende de como se hayan conectado*/
/* los cables.                                          */
/*------------------------------------------------------*/
/* El motor 1 se controla con los bits PTC1 y PTC2, y el*/
/* motor 2 con los bits PTC3 y PT4                      */
/*                                                      */
/* La "tabla de verdad" es como la siguiente:           */
/*   PTC2 PTC1 motor1                                   */
/*   ---------------------                              */
/*     0    0   Parado                                  */
/*     0    1   Un sentido                              */
/*     1    0   Otro sentido                            */
/*     1    1   NO USAR                                 */
/*                                                      */
/*   PTC4 PTC3 motor2                                   */
/*   ---------------------                              */
/*     0    0   Parado                                  */
/*     0    1   Un sentido                              */
/*     1    0   Otro sentido                            */
/*     1    1   NO USAR                                 */
/*                                                      */
/*------------------------------------------------------*/
/* Licencia GPL                                         */
/*------------------------------------------------------*/

#include "mc68hc908gp32.h"

void main(void)
{
	/*----------------------------*/
	/* Configurar el sistema      */
	/*----------------------------*/
	CONFIG1|=0x01;  //-- Deshabilitar el COP
	
	//-- Configurar pines PTC1, PTC2, PTC3 y PTC4 para salida
	DDRC=0x1E;  
	
	//-- Activar el motor 1 y 2
  PORTC=0x0A;

	//-- Bucle infinito
  for (;;);
	
}
