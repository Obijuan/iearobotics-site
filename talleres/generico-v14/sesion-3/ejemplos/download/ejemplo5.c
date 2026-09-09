/*
Ejemplo de programación del Skybot 
usando la libreria_skybot

Ejemplo5:
Mientras el Sensor3 lea blanco avanza el robot

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
    // Si leo blanco avanzo
    if (SensorIR_Izq_Lee_Blanco() == VERDADERO)
    {
      Avanzar();
    }
    else // en caso contrario me paro
    {
      Parar();
    }
  }
}
