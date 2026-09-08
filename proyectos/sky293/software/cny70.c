/*
	Andres Prieto-Moreno <andres@ifara.com>
	Juan Gonzalez <juan@iearobotics.com>
	LICENCIA GPL
*/

// Especificar el pic a emplear
#define __16f877

// Especificamos las librerias necesarias
#include "pic16f877.h"
#include "sci.h"
#include "delay0.h"

    char sensor[4];

//----------------------------
//- Comienzo del programa  
//----------------------------

void main(void)
{

	
	//-- Configurar pin del led como salida
	TRISB = 0xE1;
	
	//-- Configurar AN4 como IO de salida
	TRISA =0x0;
	
	//-- Configurar el puerto serie
	sci_conf();
	
	//-- configura timer para hacer pausas
	timer0_configurar();

	while (1) {
		sensor[0]=PORTB & 0x01;
		sensor[1]=PORTB & 0x20;
		sensor[2]=PORTB & 0x40;
		sensor[3]=PORTB & 0x80;			
		
		if ( sensor[0]==0 ) {
			sci_cad("0 ");
		} else {
			sci_cad("1 ");
		}
		
		if ( sensor[1]==0 ) {
			sci_cad("0 ");
		} else {
			sci_cad("1 ");
		}
		
		if ( sensor[2]==0 ) {
			sci_cad("0 ");
		} else {
			sci_cad("1 ");
		}
		
		if ( sensor[3]==0 ) {
			sci_cad("0 \n\r");
		} else {
			sci_cad("1 \n\r");
		}
		
		delay0(100);
		
	}
}
