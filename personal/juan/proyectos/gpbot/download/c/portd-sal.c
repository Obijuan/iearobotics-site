/*************************************************/
/* portd-sal.c  (c) Juan Gonzalez. Mayo    2004  */
/*-----------------------------------------------*/
/* Ejemplo para el PUERTO D.                     */
/* Se configura para salida y se envia un dato   */
/* NOTA: Los jumpers JP5 (1 y 2, 3 y 4) Deben    */
/* deben estar colocados                         */
/*-----------------------------------------------*/
/* LICENCIA GPL                                  */
/*************************************************/

#include "mc68hc908gp32.h"

void main(void)
{
  DDRD=0xFF;   //-- Configurar Puerto A para salida
  PORTD=0x55;  //-- Enviar un dato
}
