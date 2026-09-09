/*************************************************************************** */
/* sci-eco.c      Julio-2005 Version 1.0                                     */
/*                Mayo-2006  Version 2.0                                     */
/*---------------------------------------------------------------------------*/
/* Ejemplo para el skybot                                                    */
/*---------------------------------------------------------------------------*/
/* Se hace eco de todo lo recibido por el puerto serie                       */
/*---------------------------------------------------------------------------*/
/*  Juan Gonzalez <juan@iearobotics.com>                                     */
/*  Ricardo Gomez <ricardo@eagleman.org>                                     */
/*---------------------------------------------------------------------------*/
/*  LICENCIA GPL                                                             */
/*****************************************************************************/
//-- Especificar el pic a emplear
#define __18f2850
#include "pic18f2580.h"

//-- Se usa la libreria de comunicaciones serie
#include "sci.h"


/*********************************/
/* Programa principal            */
/*********************************/
void main(void)
{
  unsigned char c;

  //-- Configurar el puerto B 
  //-- Todos los pines de entrada, salvo RB1 de salida, que es
  //-- donde esta el led
  TRISB=0xFD;
  
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
