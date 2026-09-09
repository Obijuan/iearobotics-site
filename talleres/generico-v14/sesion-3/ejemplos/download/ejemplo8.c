/*
Ejemplo de programación del Skybot 
usando la libreria_skybot

Ejemplo8:
El Led parpadea

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
    CambiarLed();
    PausaTiempo(1,0);
  }
}
