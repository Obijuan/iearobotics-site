/*************************************************/
/* sci-menu.c  (c) Juan Gonzalez. Febrero 2004   */
/*-----------------------------------------------*/
/* Ejemplo para el SCI                           */
/* Sacar un menu por el SCI                      */
/*-----------------------------------------------*/
/* LICENCIA GPL                                  */
/*************************************************/

#include "sci.h"
#include "gpregs.h"

void menu(void)
{
	sci_enviar("Menu de opciones\n");
	sci_enviar("----------------\n");
	sci_enviar(" 1.- Cambiar de estado Bit0 puerto B\n");
	sci_enviar(" 2.- Sacar este menu\n");
	sci_enviar(" Opcion? ");
}

void main(void)
{
  unsigned char car;
	
	/*----------------------------*/
	/* Configurar el sistema      */
	/*----------------------------*/
	CONFIG1|=0x01;  //-- Deshabilitar el COP
  DDRB=0xFF;      //-- Configurar Puerto B para salida
	PORTB=0x70;     //-- Poner a 0 Puerto B
	
	/*-----------------------------*/
	/* Configurar el puerto serie  */
	/*-----------------------------*/
	sci_init();
	
	/*---------------------*/
	/* Programa principal  */
	/*---------------------*/
	
	menu();
	for(;;) {
	  car=sci_leer_car();
	  switch(car) {
		  case '1':
			  PORTB^=0x01;
			  break;
		  case '2':
			  menu();
			  break;
			default:
				PORTB=car;
	  }
	}
		
}
