/*------------------------------------------------------------*/
/*  ad-test1.asm                                              */
/*  (c) Juan Gonzalez. Marzo 2004                             */
/*------------------------------------------------------------*/
/* Prueba del conversor analogico/digital                     */
/* Se leen muestras del CANAL 0 (PB0) y se sacan por el       */
/* puerto A, donde se pueden visualizar en una placa de leds  */
/* Si se conecta un pontenciometro al canal 0 y una placa de  */
/* leds al puerto A, se puede ir viendo como cambian los leds */
/* segun la posicion del potenciometro                        */
/*------------------------------------------------------------*/
/* Licencia GPL                                               */
/*------------------------------------------------------------*/

#include "mc68hc908gp32.h"

void main(void)
{
	/*----------------------------*/
	/* Configurar el sistema      */
	/*----------------------------*/
	CONFIG1|=0x01;  //-- Deshabilitar el COP
	
	//-- Configurar puerto A para salida
	DDRA=0xFF;

  //-- Configurar el conversor A/D
	//-- Configurar conversor A/D
	//-- Reloj del bus interno: Bit4-->1
	//-- Bits 7,6 y 5--> Dividir entre 2 para conseguir
	//--  una frecuencia de 1MHZ
	//-- El resto de bits no se emplean
	ADCLK=0x30;
	
	//----------------------------
	//-- BUCLE PRINCIPAL          
	//----------------------------
	for (;;) {
		//-- Seleccionar canal 0 (PB0)
	  //-- y activar la conversion
	  ADSCR=0x00;
		
		//-- Esperar a que la conversion se realice
		//-- (se ha terminado cuando el bit 7 de ADSCR se pone a 1
	  while(!(ADSCR & 0x80)); 
			
		//-- Leer la muestra y enviarla al puerto A
		PORTA=ADR;
	}
	
}
