/*************************************************/
/* Delay.c  (c) Juan Gonzalez. Marzo 2004        */
/*-----------------------------------------------*/
/* Modulo para hacer pausas utilizando el        */
/* TIM 1, por espera activa                      */
/*-----------------------------------------------*/
/* LICENCIA GPL                                  */
/*************************************************/
#include "mc68hc908gp32.h"
#include "delay.h"

/************************************************/
/* Inicializacion del temporizador. Se debe     */
/* llamar esta funcion antes de hacer cualquier */
/* pausa.                                       */
/* Se configura el TIM1 para active el flag de  */
/* Overflow cada 100ms                          */
/************************************************/
void delay_init(void)
{
	/*-----------------------------*/
	/*- Configurar el temporizador */
	/*-----------------------------*/
	T1SC = 0x06;    // Prescaler: Div entre 64
	T1MODH = 0x0E;  // Establecer modulo 0x0EF7
	T1MODL = 0xF7;
}

/***************************************************/
/* Rutina de pausa, en unidades de 100ms           */
/*-------------------------------------------------*/
/* ENTRADAS:                                       */
/*   time: Numero de unidades de tiempo a esperar  */
/*         Cada unidad de tiempo es de 100ms       */
/***************************************************/
void delay(unsigned char time)
{
	while (time>0) {
	  //-- Esperar a que se ponga a '1' el Flag de Overflow del temporizador
	  while(!(T1SC & 0x80));
		
    //-- Poner a 0 el flag
	  T1SC&=(~0x80);

		time--;
	}		
}
