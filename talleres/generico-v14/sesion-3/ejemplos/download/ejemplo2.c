/*
Ejemplo de programación del Skybot 
usando la libreria_skybot

Ejemplo2:
Hacemos que el Skybot avance durante 2 segundos

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
  
  // El Skybot avanza durante 2 segundos
  Avanzar();
  PausaTiempo(2,0);
  Parar();
  
}
