/*************************************************/
/* tim-delay.c  (c) Juan Gonzalez. Febrero 2004  */
/*-----------------------------------------------*/
/* Ejemplo para el Temporizador (TIM)            */
/* Funcion para realizar pausas cada 100ms.      */
/* Se hace parpadear el led conectado al bit 0   */
/* del PUERTO B                                  */
/*-----------------------------------------------*/
/* LICENCIA GPL                                  */
/*************************************************/
#include "mc68hc908gp32.h"

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
	  //-- Esperar a que se ponga a '1' el Flag del temporizador
	  while(!(T1SC & 0x80));
		
    //-- Poner a 0 el flag
	  T1SC&=(~0x80);

		time--;
	}		
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
	T1SC = 0x06;    // Prescaler: Div entre 64
	T1MODH = 0x0E;  // Establecer modulo 0x0EF7
	T1MODL = 0xF7;
	
	//-- Hacer que el bit0 del puerto B cambie de estado
	for (;;) {
    PORTB^=0x01;
    delay(5);
  }
}
