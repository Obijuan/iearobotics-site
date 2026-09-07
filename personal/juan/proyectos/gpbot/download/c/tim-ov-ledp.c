/*************************************************/
/* tim-ov-ledp.c  (c) Juan Gonzalez. Mayo 2004   */
/*-----------------------------------------------*/
/* Ejemplo de interrupciones del temporizador 1  */
/* Se usa la interrupcion de overflow para que   */
/* el bit PB0 cambie de estado cada 100ms        */
/*-----------------------------------------------*/
/* LICENCIA GPL                                  */
/*************************************************/
#include "mc68hc908gp32.h"

/********************/
/* Constantes       */
/********************/

//-- Valor para conseguir overflow cada 100ms
#define T100ms  0x0EF7

/*****************************************************/
/* Rutina de atencion a la interrupcion de overflow  */
/* del temporizador 1                                */
/*****************************************************/
void rsi_ov1 (void) interrupt 6 
{
  //-- Desactivar flag de interrupcion
  T1SC&=(~0x80);
	
	//-- Cambiar de estado bit 0 del puerto B
	PORTB^=0x01; 
}

void main(void)
{
	/*----------------------------*/
	/* Configurar el sistema      */
	/*----------------------------*/
	CONFIG1|=0x01;  //-- Deshabilitar el COP
  DDRB=0xFF;      //-- Configurar Puerto B para salida
	PORTB=0x00;     //-- Poner a 0 Puerto B
	
	/*-----------------------------*/
	/*- Configurar el temporizador */
	/*-----------------------------*/
	T1SC = 0x76;    // Prescaler: Div entre 64
	
	//-- Establecer modulo del contador
	//-- IMPORTANTE!: Se debe realizar en este orden
	//-- primero la parte alta y luego la baja
	T1MODH = 0x0E;   // Parte alta
	T1MODL = 0xF7;   // Parte baja
	
	//-- Habilitar las interrupciones
	 _asm CLI _endasm;
	
	//-- Activar temporizador
	T1SC&=~(0x20);
	
	for(;;);
}
