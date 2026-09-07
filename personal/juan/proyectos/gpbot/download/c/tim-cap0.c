/*******************************************************************/
/* tim-cap0-ledp.c  (c) Juan Gonzalez. Mayo 2004                   */
/*-----------------------------------------------------------------*/
/* Ejemplo de manejo del capturador 0 del TIM 1                    */
/* Este capturador esta asociado al PIN PTD4                       */
/* Cada vez que se recibe una transicion por ese pin               */
/* (paso de 0-1 o de 1-0) se incrementar el valor sacado por el    */
/* puerto B, que indica el numero de transiciones ocurridas        */
/*-----------------------------------------------------------------*/
/* NOTA: Los jumpers JP5 (1 y 2, 3 y 4) Deben estar colocados!!!   */
/*-----------------------------------------------------------------*/
/* LICENCIA GPL                                                    */
/*******************************************************************/
#include "mc68hc908gp32.h"

/********************/
/* Constantes       */
/********************/
#define T100ms  0x0EF7   //-- 100ms
#define T50ms   0x077B   //-- 50ms

/************************************************************/
/* Rutina de atencion a la interrupcion del canal 0 (TIM1)  */
/* Se ejecuta cada vez que ocurre una transicion de 0->1 o  */
/* 1->0 por el pin PTD4                                     */
/************************************************************/
void rsi_t1ch0 (void) interrupt 4
{
	//-- Desactivar flag de interrupcion
  T1SC0&=(~0x80);
	
	//-- Cambiar de estado bit 0 del puerto B
	PORTB++; 
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
	/*--- Configurar puerto D      */
	/*-----------------------------*/
	PTDPUE=0x10; //-- Activar pull-up del pin PTD4
	
	/*-----------------------------*/
	/*- Configurar el temporizador */
	/*-----------------------------*/
	T1SC = 0x16;  // Prescaler: Div entre 64
	
	//-- Configurar Capturador de entrada (Timer 1, canal 0)
	//-- sensible a flancos de subida y de bajada
	T1SC0 = 0x4C;
	
	//-- Habilitar las interrupciones
	 _asm CLI _endasm;
	
	//-- Activar temporizador
	//T1SC&=~(0x20);
	
	for(;;);
}
