/*************************************************************************** */
/* sci-cad.c      Julio-2004   Version 1.0                                   */
/*                Mayo-2006    Version 2.0                                   */
/*---------------------------------------------------------------------------*/
/* Ejemplo para el skybot                                                    */
/*---------------------------------------------------------------------------*/
/* Enviar una cadena por el puerto serie cada vez que se recibe un caracter  */
/*---------------------------------------------------------------------------*/
/*  Juan Gonzalez <juan@iearobotics.com>                                     */
/*  Ricardo Gomez <ricardo@eagleman.org>                                     */
/*---------------------------------------------------------------------------*/
/*  LICENCIA GPL                                                             */
/*****************************************************************************/

//-- Especificar el pic a emplear
#define __18f2580
#include "pic18f2580.h"

//-- Se usa la libreria de comunicaciones serie
#include "sci.h"


/*********************************/
/* Programa principal            */
/*********************************/
void main(void)
{
  
  //-- Configurar el puerto B 
  //-- Todos los pines de entrada, salvo RB1 de salida, que es
  //-- donde esta el led
  TRISB=0xFD;
  
  //-- Configurar las comunicaciones serie
  sci_conf();
  
  //-- Bucle infinito
  for (;;) {
    //-- Esperar a que llegue dato
    sci_read();
    
    //-- Cambiar el led de estado
    PORTB^=0x02;
    
    //-- Enviar la cadena por el puerto serie
    sci_cad("Hola como estas...");
    
    //-- Si se quiere enviar una cadena que esta en un array
    //-- utilizar la funcion sci_cad2()
    //-- Ejemplo: sci_cad2(mi_cadena);
    //-- con: unsigned char mi_cadena[]="test"; una variable global
    //-- definida fuera del main
    //-- Es un bug del SDCC 2.5.1
  }

}
