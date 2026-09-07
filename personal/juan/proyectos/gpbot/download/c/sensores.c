/*-------------------------------------------------------------*/
/*- sensores.c  (c) Juan Gonzalez. Mayo 2004                   */
/*-------------------------------------------------------------*/
/* Ejemplo de manejo de los 4 sensores CNY70, en modo digital  */
/* Su estado se refleja en los bits PB0-PB4 del puerto B       */
/* donde se conectan leds                                      */
/* La informacion que se saca por el puerto B es:              */
/*                                                             */
/* PB7 PB6 PB5 PB4 PB3 PB2 PB1 PB0                             */
/*  0   0   0   0  IR2 IR1 IR4 IR3                             */
/*                                                             */
/*-------------------------------------------------------------*/
/* INFORMACION SOBRE LOS SENSORES:                             */
/* Los valores que devuelven son:                              */
/*   Negro  (o infinito) --> 1                                 */
/*   Blanco              --> 0                                 */
/*                                                             */
/* Sensor IR1: Pin PTC5 (PUERTO C)                             */
/* Sensor IR2: Pin PTC6 (PUERTO C)                             */
/* Sensor IR3: Pin PTA5 (PUERTO A)                             */
/* Sensor IR4: Pin PTA6 (PUERTO A)                             */
/*-------------------------------------------------------------*/
/* Licencia GPL                                                */
/*-------------------------------------------------------------*/

#include "mc68hc908gp32.h"

unsigned char sensor;

void main(void)
{
	/*----------------------------*/
	/* Configurar el sistema      */
	/*----------------------------*/
	CONFIG1|=0x01;  //-- Deshabilitar el COP
	
	/*-------------------------------*/
	/*- Configuracion PUERTO B      -*/
	/*-------------------------------*/
  //-- Configurar puerto B para salida
	DDRB=0xFF;

	/*---------------------------------*/
	/*- Configuracion de los sensores  */
	/*---------------------------------*/
	/*-- Configurar puerto A y C para entrada */
	DDRA=0x00;
	DDRC=0x00;
	
	/*-- Configurar resistencias pull-up para los 4 sensores */
	PTAPUE=0x60;
	PTCPUE=0x60;
	
	/*-- Bucle principal --*/
	for(;;) {
		/*-- Sacar por puerto B: 0 0 0 0 IR2 IR1 IR4 IR3  */
		PORTB=(((PORTA & 0x60)>>2) | (PORTC & 0x60))>>3;
	}
		
}
