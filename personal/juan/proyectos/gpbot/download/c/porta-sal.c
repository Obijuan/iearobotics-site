/*************************************************/
/* porta-sal.c  (c) Juan Gonzalez. Marzo   2004  */
/*-----------------------------------------------*/
/* Ejemplo para el PUERTO A.                     */
/* Se configura para salida y se envia un dato   */
/*-----------------------------------------------*/
/* LICENCIA GPL                                  */
/*************************************************/

#include "mc68hc908gp32.h"

void main(void)
{
  DDRA=0xFF;   //-- Configurar Puerto A para salida
  PORTA=0x55;  //-- Enviar un dato
}
