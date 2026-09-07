/*---------------------------------------------------------*/
/*- motor-sec.asm  (c) Juan Gonzalez. Marzo 2004           */
/*---------------------------------------------------------*/
/* Ejemplo de prueba para el robot, utilizando los         */
/* motores 1 y 2. El programa hace que el robot avance     */
/* durante un cierto tiempo, que luego retroceda, que      */
/* gire en un sentido, luego en otro y finalmente que      */
/* se pare.                                                */
/*                                                         */
/* Lo que se considera "adelante" en este programa depende */
/* de como se hayan conectado los motores                  */
/*---------------------------------------------------------*/
/* Licencia GPL                                            */
/*---------------------------------------------------------*/

#include "mc68hc908gp32.h"
#include "delay.h"

//------------------------------------------
//- Constantes para movimiento del robot
//- Se deben modificar para cada robot
//------------------------------------------
#define	ADELANTE   0x0A
#define	ATRAS 	   0x14
#define	DERECHA    0x12
#define	IZQUIERDA  0x0C

//--- Pausa a realizar entre cada movimieno
//--- En unidades de 100ms 
#define PAUSA      10 

void main(void)
{
	/*----------------------------*/
	/* Configurar el sistema      */
	/*----------------------------*/
	CONFIG1|=0x01;  //-- Deshabilitar el COP
	
	//-- Configurar pines PTC1, PTC2, PTC3 y PTC4 para salida
	DDRC=0x1E;  
	
	//-- Inicializar el modulo de pausa
  delay_init();
	
	//-- Mover robot ADELANTE
	PORTC=ADELANTE;
	delay(PAUSA);
	
	//-- Mover ATRAS
  PORTC=ATRAS;
	delay(PAUSA);
	
  //-- Mover a la DERECHA
	PORTC=DERECHA;
	delay(PAUSA);
	
	//-- Mover a la IZQUIERDA
	PORTC=IZQUIERDA;
	delay(PAUSA);
	
	//-- PARA el robot
  PORTC=0x00;
	
	//-- Bucle infinito
	for (;;);
	
}
