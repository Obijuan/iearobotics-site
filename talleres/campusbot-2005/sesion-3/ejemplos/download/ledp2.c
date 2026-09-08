/*************************************************************************** */
/* delay0.c      Junio-2004                                                  */
/*---------------------------------------------------------------------------*/
/* Ejemplo para la tarjeta SKYPIC                                            */
/*---------------------------------------------------------------------------*/
/* Utilizacion del temporizador 0 para generar una pausa de 10ms y           */
/* obtener una rutina de delay en unidades de 10ms                           */
/* No se utilizan interrupciones                                             */
/* El temporizador 0 es de 8 bits                                            */
/*---------------------------------------------------------------------------*/
/* Se hace cambiar el led de estado cada 500ms (medio segundo)               */
/*  Encender el led, que encuentra en el pin RB1                             */
/*---------------------------------------------------------------------------*/
/*  Andres Prieto-Moreno <andres@ifara.com>                                  */
/*  Juan Gonzalez <juan@iearobotics.com>                                     */
/*---------------------------------------------------------------------------*/
/*  LICENCIA GPL                                                             */
/*****************************************************************************/

#define __16f877
#include "pic16f877.h"

//-- Para usar temporizaciones con el timer 0
#include "delay0.h"

//----------------------------
//- Comienzo del programa  
//----------------------------
 
void main(void)
{
  //-- Configurar el puerto B 
  //-- RB0, RB2 y RB7 como entradas
  //-- RB1, RB3, RB4, RB5, RB6 como salidas
  //-- Todos los sensores de entrada, pero el RB1 de salida, que es
  //-- donde esta el led
  TRISB=0x85;
  
  //-- Configurar temporizador
  timer0_configurar();
  
  //-- Encender el led
  PORTB=0x02;

  //-- Bucle principal
  for (;;) {
    
    //-- Se utilizan unidades de 10ms
    //-- Ejemplos de valores:
    //-- 1   --> 10ms
    //-- 100 --> 1 segundo
    //-- Valor maximo: 256 --> 2 segundos y medio
    delay0(50);    //-- Pausa de 0.5seg
    PORTB^=0x02;  //-- Cambiar el led de estado
  }
 
}
