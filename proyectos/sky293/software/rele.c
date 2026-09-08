/*
	RELE
	Septiembre-2005
	Programacion del rele de la SKY293
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

//! Bit donde esta conectado el LED de la SKYPIC
#define LED       0x02     // Pin del led de la Skypic
#define RELE      0xFF     // Pin del RELE
#define BOTON  0x01     // Bit donde esta el pulsador


void abre_puerta() {
	PORTB = PORTB | LED;
	PORTA = PORTA  | RELE;
	delay0(10);
	PORTB = PORTB & ~LED;
	PORTA = PORTA & ~RELE;
}


//----------------------------
//- Comienzo del programa  
//----------------------------

void main(void)
{
	unsigned char tecla;
	//-- Configurar pin del led como salida
	TRISB&= ~LED;
	//-- Configurar AN4 como IO de salida
	TRISA=0x0;
	
	//-- Configurar el puerto serie
	sci_conf();

	//-- Configurar Timer
	timer0_configurar();
	
	while (1) {
		if ( (PORTB & BOTON) == 0x00 ) { // han apretado pulsador
			abre_puerta();
		}
		
		if (RCIF) {  // ha llegado dato		
			tecla = RCREG;
		
			switch (tecla) {
				case 'z':  // enciendo el LED y el RELE
								PORTB=PORTB | LED;
								PORTA=PORTA  | RELE;
				  				break;
				case 'x':  // apago el LED y el RELE
								PORTB=PORTB & ~LED;
								PORTA=PORTA & ~RELE;
			  					break;
				case 'a': // abro la puerta
							    abre_puerta();
			  					break;
			
				default:
					  			break;
			}
		}
		
	}
}
