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

char bumper[6];

//----------------------------
//- Comienzo del programa  
//----------------------------

void main(void)
{

	//-- Configurar Puerto A entrada
	TRISA =0xFF;
	
	//-- Configurar el puerto serie
	sci_conf();
	
	//-- configura timer para hacer pausas
	timer0_configurar();
	
	ADCON0=0x00;
	ADCON1=0x06;
	
	while (1) {
		bumper[0]=PORTA & 0x01;
		bumper[1]=PORTA & 0x02;
		bumper[2]=PORTA & 0x04;
		bumper[3]=PORTA & 0x08;			
		bumper[4]=PORTA & 0x10;
		bumper[5]=PORTA & 0x20;
		
		if ( bumper[0]==0 ) {
			sci_cad("0 ");
		} else {
			sci_cad("1 ");
		}
		
		if ( bumper[1]==0 ) {
			sci_cad("0 ");
		} else {
			sci_cad("1 ");
		}
		
		if ( bumper[2]==0 ) {
			sci_cad("0 ");
		} else {
			sci_cad("1 ");
		}
		
		if ( bumper[3]==0 ) {
			sci_cad("0 ");
		} else {
			sci_cad("1 ");
		}
		
		if ( bumper[4]==0 ) {
			sci_cad("0 ");
		} else {
			sci_cad("1 ");
		}
		
		if ( bumper[5]==0 ) {
			sci_cad("0 \n\r");
		} else {
			sci_cad("1 \n\r");
		}
		
		delay0(100);
		
	}
}
