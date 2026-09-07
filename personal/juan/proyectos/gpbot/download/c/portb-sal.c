/*************************************************/
/* portb-sal.c  (c) Juan Gonzalez. Marzo 2004    */
/*-----------------------------------------------*/
/* Ejemplo para el PUERTO B.                     */
/* Se configura para salida y se envia un dato   */
/*-----------------------------------------------*/
/* LICENCIA GPL                                  */
/*************************************************/

#include "mc68hc908gp32.h"

void main(void)
{
  DDRB=0xFF;   //-- Configurar Puerto B para salida
  PORTB=0xAA;  //-- Enviar un dato
}
