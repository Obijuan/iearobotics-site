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


//----------------------------
//- Comienzo del programa  
//----------------------------

void main(void)
{
	unsigned char tecla;
	//-- Configurar pin del led como salida
	TRISB = 0xE1;
	
	//-- Configurar AN4 como IO de salida
	TRISA =0x0;
	
	//-- Configurar el puerto serie
	sci_conf();

	while (1) {
		
		if (RCIF) {  // ha llegado dato		
			tecla = RCREG;
		
			switch (tecla) {
				case '1':  // cambio sentido  motor 1
								PORTB =PORTB ^ 0x02;
								
				  				break;
				case '2':  // enciendo motor1
								PORTB=PORTB ^ 0x04;
								
			  					break;
				case '3':  // cambio sentido motor 2
								PORTB=PORTB ^ 0x08;
								
				  				break;
				case '4':  // enciendo motor 2
								PORTB=PORTB ^ 0x10;
								
			  					break;
				default:
						        // parar motor
								PORTB = PORTB & 0xEB;
					  			break;
			}
		}
		
		
	}
}
