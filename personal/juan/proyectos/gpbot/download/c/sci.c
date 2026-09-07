/*************************************************/
/* sci.c    (c) Juan Gonzalez. Febrero 2004      */
/*-----------------------------------------------*/
/* Modulo para comunicaciones serie con la GPBOT */
/*-----------------------------------------------*/
/* LICENCIA GPL                                  */
/*************************************************/

#include "sci.h"
#include "mc68hc908gp32.h"

/***************************************/
/* Inicializar el puerto serie.        */
/* Velocidad: 9600 baudios             */
/***************************************/
void sci_init(void)
{
	SCBR = 0x22;   //-- 9600 Baudios
	SCC1 = 0x40;   //-- Habilitar SCI
	SCC2 = 0x0C;   //-- Habilitar Transmisor y receptor
}

/*****************************************/
/* Leer un caracter por el puerto serie  */
/*****************************************/
unsigned char sci_leer_car(void)
{
  //-- Esperar a que se ponga a '1' el Flag (Bit 5)
	while(!(SCS1 & 0x20)); 
	return SCDR;
}

/*******************************************/
/* Enviar un caracter por el puerto serie  */
/* ENTRADAS:                               */
/*     - Caracter a enviar                 */
/*******************************************/
void sci_enviar_car(const char c)
{
  /* Esperar hasta que se pueda enviar algun caracter */
  /* Se tiene que activar el bit TDRE del registro SCSR */
  while(!(SCS1 & 0x80));
  
  /* Enviar el caracter */
  SCDR = c;
}

/*****************************************/
/* Enviar una cadena por el puerto serie */
/*****************************************/
void sci_enviar(const char *cad)
{
  unsigned char i=0;
  
  while (cad[i]!=0) {
    sci_enviar_car(cad[i]);
    i++;
  }
}
