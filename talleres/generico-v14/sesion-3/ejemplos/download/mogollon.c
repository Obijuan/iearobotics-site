/*
Ejemplo de programación del Skybot 
usando la libreria_skybot para la
participacion en el concurso del
Mogollón.

El robot enciende un led y queda
a la espera de que le aprieten el
pulsador.
Espera 5 segundos haciendo que el
led parpadee.
Empieza a avanzar y rebotar contra
cualquier linea negra que detecte.

Julio-2007
*/



#include "libreria_skybot.h"

#define ESPERA 200


//----------------------------
//- Comienzo del programa  
//----------------------------
unsigned char i;

void main(void)
{
  ConfigurarSkybot();
  
  PausaTiempo(0,30);
  EncenderLed();
  
  
  //-- Esperar a que se apriete el pulsador
  while (Pulsador_no_esta_pulsado());
  
  
  //-- Hacer que el led parpadee durante 5 segundos
  for (i=0; i<5; i++)
  {
    ApagarLed();
    PausaTiempo(0,50);
    EncenderLed();
    PausaTiempo(0,50);
  }  
  
  for (;;)
  {
    if (SensorIR_Izq_Lee_Blanco() && SensorIR_Der_Lee_Negro())
    { //-- Blanco-negro
      GirarIzq();
      PausaTiempo(0,ESPERA);
    }  
    else if (SensorIR_Izq_Lee_Negro() && SensorIR_Der_Lee_Blanco())
    { //-- Negro-Blanco
      GirarDer();
      PausaTiempo(0,ESPERA);
    }
    else if (SensorIR_Izq_Lee_Negro() && SensorIR_Der_Lee_Negro())
    {  //-- Negro-negro
      Retroceder();
      PausaTiempo(0,ESPERA);
    }
    else Avanzar();
  }
}
