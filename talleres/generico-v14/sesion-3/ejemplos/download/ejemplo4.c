/*
Ejemplo de programación del Skybot 
usando la libreria_skybot

Ejemplo4:
Si el sensor 1 detecta negro apago el LED

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
  
  // Bucle principal
  for (;;)
  {
	// Si leo NEGRO apago el LED
	if (SensorIR_Izq_Lee_Negro() == VERDADERO)
        {
		ApagarLed();
	}
	// en caso contrario lo enciendo
	else
        {
		EncenderLed();
	}
  }
}
