/*
Ejemplo de programación del Skybot 
usando la libreria_skybot

Ejemplo7:
Al apretar el Bumper Izquierdo el robot se para

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
    // Si el bumper izquierdo esta apretado me paro
    if (Bumper_Izq_esta_apretado() == VERDADERO)
    {
      Parar();
    }
    else // en caso contrario avanzo
    {
      Avanzar();
    }
  }
}
