/*
Ejemplo de programación del Skybot 
usando la libreria_skybot

Ejemplo3:
Hacemos que el robot se mueva en diferentes direcciones

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
  
  // El Skybot avanza durante 2 segundos
  GirarIzq();
  PausaTiempo(2,0);
  
  // El Skybot avanza durante 2 segundos
  GirarDer();
  PausaTiempo(2,0);
  
  // paramos el Robot
  Parar();
}
