/*
Ejemplo de programación del Skybot 
usando la libreria_skybot

Ejemplo1:
Al apretar el Pulsador el LED se enciende

Julio-2007
*/

#include "libreria_skybot.h"

//----------------------------
//- Comienzo del programa  
//----------------------------

void main(void)
{
  // Configuramos el PIC16f876a para 
  // adaptarse al Robot Skybot
  ConfigurarSkybot();
  // Bucle Principal
  for (;;)
  {
	// Si pulsador apretado enciendo el LED
	if (Pulsador_esta_pulsado() == VERDADERO)
        { 
		EncenderLed();
	}
	else
        {
		ApagarLed(); // en caso contrario apago el LED
	}
  }
  
}
