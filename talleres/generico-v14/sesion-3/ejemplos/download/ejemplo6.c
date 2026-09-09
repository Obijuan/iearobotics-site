/*
Ejemplo de programación del Skybot 
usando la libreria_skybot

Ejemplo6:
Al apretar el Bumper Derecho el LED se enciende

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
    // Si el Bumper Derecho esta activado enciendo el LED
    if (Bumper_Der_esta_apretado() == VERDADERO)
    {
      EncenderLed();
    }
    else // en caso contrario apago el LED
    {
      ApagarLed();
    }
  }
}
