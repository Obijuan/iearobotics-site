/*
Ejemplo de programación del Skybot 
usando la libreria_skybot

Ejemplo8:
Lectura de la LDR y huida hacia
delante (huye de la luz)

Julio-2007
*/

#include "libreria_skybot.h"

//----------------------------
//- Comienzo del programa  
//----------------------------

unsigned char luz;

void main(void)
{
  // Configuramos el PIC16f876a para 
  // adaptarse al Robot Skybot
  ConfigurarSkybot();
  while (!Pulsador_esta_pulsado());

  // Bucle Principal
  for (;;)
  {
    luz = LeerLDR();
    if (luz > 200 || Bumper_Izq_esta_apretado())
    {
      EncenderLed();
      Avanzar();
      PausaTiempo(1,0);
    }
    else
    {
      ApagarLed();
      Parar();
      PausaTiempo(1,0);
    }
  }
}
