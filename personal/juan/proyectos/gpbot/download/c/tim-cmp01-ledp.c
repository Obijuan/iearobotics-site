/*******************************************************************/
/* tim-cmp01-ledp.c  (c) Juan Gonzalez. Mayo 2004                  */
/*-----------------------------------------------------------------*/
/* Ejemplo de interrupciones del temporizador 1 (TIM1)             */
/* Con el canal 0 se hace parpadear un led conectado al bit PB0    */
/* y con el 1 otro conectado al bit PB1                            */
/*-----------------------------------------------------------------*/
/* LICENCIA GPL                                                    */
/*******************************************************************/
#include "mc68hc908gp32.h"

/********************/
/* Constantes       */
/********************/
#define T200ms  0x1DEE   //-- 200 ms
#define T150ms  0x1672   //-- 100ms
#define T50ms   0x077B   //-- 50ms

/************************************************************/
/* Rutina de atencion a la interrupcion del canal 0 (TIM1)  */
/************************************************************/
void rsi_t1ch0 (void) interrupt 4
{
	//-- Desactivar flag de interrupcion
  T1SC0&=(~0x80);
	
	//-- Cambiar de estado bit 0 del puerto B
	PORTB^=0x01; 
}

/************************************************************/
/* Rutina de atencion a la interrupcion del canal 1 (TIM1)  */
/************************************************************/
void rsi_t1ch1 (void) interrupt 5
{
	
	//-- Desactivar flag de interrupcion
  T1SC1&=(~0x80);
	
	//-- Cambiar de estado bit 1 del puerto B
	PORTB^=0x02; 

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
	T1SC = 0x36;    // Prescaler: Div entre 64
	
	//-- Establecer modulo del contador
	//-- IMPORTANTE!: Se debe realizar en este orden
	//-- primero la parte alta y luego la baja
	T1MODH = 0x1D;   // Parte alta
	T1MODL = 0xEE;   // Parte baja
	
	/*----------------------------------------*/
	/*- Configurar el comparador 0 (canal 0)  */
	/*----------------------------------------*/
  // Interrupcion permitida
	// Configurar como comparador, sin salida hardware
	T1SC0 = 0x50;
	
	//-- Establecer el valor de comparacion. 
	T1CH0H = 0x07;
	T1CH0L = 0x7B;
	
	/*---------------------------------------*/
	/* Configurar el comparador 1 (Canal 1)  */
	/*---------------------------------------*/
	// Interrupcion permitida
	// Configurar como comparador, sin salida hardware
	T1SC1 = 0x50;
	
	//-- Establecer el valor de comparacion. 
	T1CH1H = 0x16;
	T1CH1L = 0x72;
	
	//-- Habilitar las interrupciones
	 _asm CLI _endasm;
	
	//-- Activar temporizador
	T1SC&=~(0x20);
	
	for(;;);
}
