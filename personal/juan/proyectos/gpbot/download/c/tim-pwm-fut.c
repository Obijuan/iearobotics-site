/*******************************************************************/
/* tim-pwm-fut.c  (c) Juan Gonzalez. Mayo 2004                     */
/*-----------------------------------------------------------------*/
/* Ejemplo de posicionamiento de servos del tipo FUTABA 3003       */
/* Se utiliza el temporizador 1 (TIM 1)                            */
/* El posicionamiento se hace por interrupciones. Se usa la        */
/* interrupcion de overflow para determinar el periodo de la       */
/* senal PWM (20ms) y el comparador 0 para calcular el ancho       */
/* del pulso                                                       */
/*-----------------------------------------------------------------*/
/* LICENCIA GPL                                                    */
/*******************************************************************/
#include "mc68hc908gp32.h"

/********************/
/* Constantes       */
/********************/
#define CENTRO    0x0C72   //-- 1,3ms. Posicion central
#define EXTREMO1  0x02DF   //-- 0,3ms. Un extremo
#define EXTREMO2  0x1605   //-- 2,3ms. El otro extremo
#define T20ms     0xBF7B   //-- 20ms. Periodo de la senal

/************************************************************/
/* Rutina de atencion a la interrupcion del canal 0 (TIM1)  */
/************************************************************/
void rsi_t1ch0 (void) interrupt 4
{
	//-- Desactivar flag de interrupcion
  T1SC0&=(~0x80);
	
	//-- Poner pwm a '0'
	PORTB=0x00; 
}

/************************************************************/
/* Rutina de atencion a la interrupcion de overflow (TIM1)  */
/* Se produce cada 20ms                                     */
/************************************************************/
void rsi_ov1 (void) interrupt 6
{
	//-- Desactivar flag de interrupcion
  T1SC&=(~0x80);
	
	//-- Poner senal PWM a 1
	PORTB|=0x01; 

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
	T1SC = 0x60;    // Prescaler: Div entre 64
	
	//-- Establecer modulo del contador
	//-- IMPORTANTE!: Se debe realizar en este orden
	//-- primero la parte alta y luego la baja
	T1MODH = 0xBF;   // Parte alta
	T1MODL = 0x7B;   // Parte baja
	
	/*----------------------------------------*/
	/*- Configurar el comparador 0 (canal 0)  */
	/*----------------------------------------*/
  // Interrupcion permitida
	// Configurar como comparador, sin salida hardware
	T1SC0 = 0x50;
	
	//-- Establecer posicion del servo. 
	T1CH0H = 0x0C;
	T1CH0L = 0x72;
	
	//-- Habilitar las interrupciones
	 _asm CLI _endasm;
	
	//-- Activar temporizador
	T1SC&=~(0x20);
	
	for(;;);
}
