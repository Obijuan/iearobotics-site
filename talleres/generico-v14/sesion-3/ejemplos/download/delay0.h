/*****************************************************************************/
/* delay0.h      Julio-2007                                                  */
/*---------------------------------------------------------------------------*/
/* Libreria de temporizacion para el skybot                                  */
/*---------------------------------------------------------------------------*/
/* Este fichero esta pensado para ser incluido en el programa principal.     */
/* Antes de utilizar la funcion delay0() es necesario llamar a               */
/* timer0_configurar() para configurar correctamente el timer 0              */
/*---------------------------------------------------------------------------*/
/* Utilizacion del temporizador 0 para generar una pausa de 10ms y           */
/* obtener una rutina de delay en unidades de 10ms                           */
/* No se utilizan interrupciones                                             */
/* El temporizador 0 es de 8 bits                                            */
/*---------------------------------------------------------------------------*/
/*  Andres Prieto-Moreno <andres@ifara.com>                                  */
/*  Juan Gonzalez <juan@iearobotics.com>                                     */
/*  Modificado por: Javier Valiente <jvaliente@ifara.com>                    */
/*---------------------------------------------------------------------------*/
/*  LICENCIA GPL                                                             */
/*****************************************************************************/

#ifndef _DELAYH
#define _DELAYH

#include <pic16f876a.h>

//-- Definiciones
#define TICKS10 0x3D  // Valor con el que inicializar contador para
                      // conseguir TICKs de 10ms

/************************************/
/* Configurar el temporizador 0     */
/************************************/
void timer0_configurar();

/************************************************/
/* Hacer una pausa en unidades de 10ms          */
/* ENTRADA:                                     */
/*   -pausa: Valor de la pausa en decenas de ms */
/************************************************/
void delay0(unsigned char pausa);

#endif
