/*
Ejemplo de programación del Skybot 
usando la libreria_skybot

El robot sigue una linea negra hasta
el final, y se para.

Julio-2007
*/


#include "libreria_skybot.h"


//----------------------------
//- Comienzo del programa  
//----------------------------

void main(void)
{
  ConfigurarSkybot();
  
  for (;;)
  {
    if (SensorIR_Izq_Lee_Negro() && SensorIR_Der_Lee_Negro())
    {
      Avanzar();
    }
    else if (SensorIR_Izq_Lee_Negro())
    {
      GirarIzq();
    }
    else if (SensorIR_Der_Lee_Negro())
    {
      GirarDer();
    }
    else
    {
      Parar();
    }
  }  
}
