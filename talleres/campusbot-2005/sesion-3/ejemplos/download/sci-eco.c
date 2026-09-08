/*************************************************************************** */
/* sci-eco.c      Julio-2005                                                 */
/*---------------------------------------------------------------------------*/
/* Ejemplo para el skybot                                                    */
/*---------------------------------------------------------------------------*/
/* Se hace eco de todo lo recibido por el puerto serie                       */
/*---------------------------------------------------------------------------*/
/*  Juan Gonzalez <juan@iearobotics.com>                                     */
/*---------------------------------------------------------------------------*/
/*  LICENCIA GPL                                                             */
/*****************************************************************************/
//-- Especificar el pic a emplear
#define __16f877
#include "pic16f877.h"

//-- Se usa la libreria de comunicaciones serie
#include "sci.h"


/*********************************/
/* Programa principal            */
/*********************************/
void main(void)
{
  unsigned char c;

  //-- Configurar el puerto B 
  //-- RB0, RB2 y RB7 como entradas
  //-- RB1, RB3, RB4, RB5, RB6 como salidas
  //-- Todos los sensores de entrada, pero el RB1 de salida, que es
  //-- donde esta el led
  TRISB=0x85;
  
  //-- Configurar las comunicaciones serie
  sci_conf();
  
  //-- Bucle infinito
  for (;;) {
    
    //-- Esperar a que llegue dato del PC
    c=sci_read();
    
    //-- Cambiar el led de estado
    PORTB^=0x02; 
    
    //-- ...y enviar de vuelta el caracter por el puerto serie
    sci_write(c);
  }

}
