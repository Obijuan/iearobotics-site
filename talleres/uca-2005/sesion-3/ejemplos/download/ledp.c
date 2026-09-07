/*************************************************************************** */
/* ledp.c      Junio-2005                                                    */
/*---------------------------------------------------------------------------*/
/* Ejemplo para la tarjeta SKYPIC                                            */
/*---------------------------------------------------------------------------*/
/* Hacer parpear el led de la Skypic. No se utilizan los temporizadores      */
/*---------------------------------------------------------------------------*/
/*  Andres Prieto-Moreno <andres@ifara.com>                                  */
/*  Juan Gonzalez <juan@iearobotics.com>                                     */
/*---------------------------------------------------------------------------*/
/*  LICENCIA GPL                                                             */
/*****************************************************************************/
//-- Especificar el pic a emplear
#define __16f877
#include "pic16f877.h"

//-- Definiciones
#define LED       0x02     // Pin del led de la Skypic
#define CONFIG_B  ~LED     // Configuracion para el puerto B.
                           // RB1 salida, resto entradas

//-- Cambiando este valor se modifica el tiempo de pausa
//-- 0xFFFF es la maxima y 0x0000 la minima
#define RETRASO 0xFFFF

//-- Contador para la pausa
unsigned int contador;

/**************************************************************************/
/* Rutina de pausa. Se hace que el contador vaya desde 0000 hasta retraso */
/* ENTRADAS:                                                              */
/*   -retraso: Indica el valor de la pausa. 0xFFFF es el valor maximo     */        
/**************************************************************************/
void pausa(unsigned int retraso)
{
	while (retraso>0) {
	  retraso--;
  }  
}

void main(void)
{
  //-- Configurar puerto B
  TRISB=CONFIG_B;

  //-- Bucle infinito
  for (;;) {
    PORTB^=LED;        //-- Cambiar led de estado
    pausa(RETRASO);    //-- Pausa
  }

}
