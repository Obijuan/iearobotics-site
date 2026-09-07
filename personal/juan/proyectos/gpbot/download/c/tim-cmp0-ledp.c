/*******************************************************************/
/* tim-cmp0-ledp.c  (c) Juan Gonzalez. Mayo 2004                   */
/*-----------------------------------------------------------------*/
/* Ejemplo de utilzacion del comparador 0 del temporizador 1 (TIM) */
/* Se hace parpadear un led conectado al Bit 0 del                 */
/* puerto B, usando la interrupcion del comparador 0 del TIM1      */
/*-----------------------------------------------------------------*/
/* El modulo del timer se establece para que haya desbordamiento   */
/* cada 100ms. El valor del comparador es indiferente. Se          */
/* produciran interrupciones cada 100ms.                           */
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
/************************************************************/
void rsi_t1ch0 (void) interrupt 4
{
	//-- Desactivar flag de interrupcion
  T1SC0&=(~0x80);
	
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
	T1SC = 0x36;    // Prescaler: Div entre 64
	
	//-- Establecer modulo del contador
	//-- IMPORTANTE!: Se debe realizar en este orden
	//-- primero la parte alta y luego la baja
	T1MODH = 0x0E;   // Parte alta
	T1MODL = 0xF7;   // Parte baja
	
	/*----------------------------------------*/
	/*- Configurar el comparador 0 (canal 0)  */
	/*----------------------------------------*/
  // Interrupcion permitida
	// Configurar como comparador, sin salida hardware
	T1SC0 = 0x50;
	
	//-- Establecer el valor de comparacion. Seleccionamos
	//-- la mitad del modulo, pero se podria haber usado
	//-- cualquier otro valor.
	T1CH0H = 0x07;
	T1CH0L = 0x7B;
	
	//-- Habilitar las interrupciones
	 _asm CLI _endasm;
	
	//-- Activar temporizador
	T1SC&=~(0x20);
	
	for(;;);
}
